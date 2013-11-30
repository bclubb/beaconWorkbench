//
//  BSLThermostatPeripheralService.m
//  beaconWorkbench
//
//  Created by Brian Clubb on 11/21/13.
//  Copyright (c) 2013 Bubblesort Laboratories LLC. All rights reserved.
//

#import "BSLThermostatPeripheral.h"

@interface BSLThermostatPeripheral ()

@property CBUUID *thermostateCurrentTempServiceUUID;
@property CBUUID *thermostateCurrentTempCharacteristicUUID;

@property CBPeripheralManager *manager;
@property NSTimer *temperatureChanger;

@property BOOL poweredOn;
@property BOOL poweredOff;

-(NSData*)currentTemperatureData;

@end

@implementation BSLThermostatPeripheral

- (id)init
{
    self = [super init];
    if (self) {
        _poweredOn = NO;
        _poweredOff = YES;
        _thermostateCurrentTempServiceUUID = [CBUUID UUIDWithString:@"F43932F1-6D0C-4C13-A0F5-185C0612D4D0"];
        _thermostateCurrentTempCharacteristicUUID = [CBUUID UUIDWithString:@"7E0A3AA7-175E-4DEF-9009-56D90E770816"];
        _thermostatCurrentTempService = [[CBMutableService alloc] initWithType:_thermostateCurrentTempServiceUUID primary:YES];
        _thermostatCurrentTempCharacteristic = [[CBMutableCharacteristic alloc] initWithType:_thermostateCurrentTempCharacteristicUUID properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
        
        _thermostatCurrentTempService.characteristics = @[_thermostatCurrentTempCharacteristic];
        
        _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        
        [self addObserver:self forKeyPath:@"currentTemperature" options:NSKeyValueObservingOptionNew context:nil];
        
        [self changeTemp];
        
        _temperatureChanger = [NSTimer timerWithTimeInterval:1000 target:self selector:@selector(changeTemp) userInfo:nil repeats:YES];
        [_temperatureChanger fire];
    }
    return self;
}

- (void)setupPeripheral{
    [_manager addService:_thermostatCurrentTempService];
    [_manager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey: @[_thermostatCurrentTempService.UUID]}];
}

- (NSData*)currentTemperatureData{
    return [NSData dataWithBytes:&_currentTemperature length:sizeof(_currentTemperature) ];
}

- (void)changeTemp{
    _currentTemperature = [NSNumber numberWithFloat:(100*random())];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentTemperature"]) {
        NSNumber *newTemperature = [change objectForKey:NSKeyValueChangeNewKey];
        NSData *updatedTemperature = [NSData dataWithBytes:&newTemperature length:sizeof(newTemperature) ];
        _thermostatCurrentTempCharacteristic.value = updatedTemperature;
        NSLog(@"Temperature changed");
        if (_poweredOn) {
            NSLog(@"Temperature changed - Notified Centrals");
            [_manager updateValue:updatedTemperature forCharacteristic:_thermostatCurrentTempCharacteristic onSubscribedCentrals:nil];
        }
    }
}


#pragma Singleton

static BSLThermostatPeripheral * _current = NULL;
+ (BSLThermostatPeripheral*) current
{
    @synchronized(self){
        if(_current == NULL){
            _current = [[BSLThermostatPeripheral alloc] init];
        }
    }
    return _current;
}

#pragma CBPeripheralManagerDelegateMethods

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    NSLog(@"Power State: %d", peripheral.state);
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        _poweredOn = YES;
        _poweredOff = NO;
        [self setupPeripheral];
        NSLog(@"Powered On");
    } else if(peripheral.state < CBPeripheralManagerStatePoweredOff) {
        _poweredOff = YES;
        _poweredOn = NO;
        NSLog(@"Powered On");
    } else {
        _poweredOn = NO;
        _poweredOff = NO;
        NSLog(@"Powered Sleep");
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    // Error while advertising
    NSLog(@"Error: %@", error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    if ([request.characteristic.UUID isEqual:_thermostatCurrentTempCharacteristic.UUID]) {
        if (request.offset > _thermostatCurrentTempCharacteristic.value.length) {
            [_manager respondToRequest:request withResult:CBATTErrorInvalidOffset];
        } else {
            request.value = [_thermostatCurrentTempCharacteristic.value subdataWithRange:NSMakeRange(request.offset, _thermostatCurrentTempCharacteristic.value.length-request.offset)];
            [_manager respondToRequest:request withResult:CBATTErrorSuccess];
        }
    } else {
        [_manager respondToRequest:request withResult:CBATTErrorAttributeNotFound];
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{
    [peripheral updateValue:[self currentTemperatureData] forCharacteristic:_thermostatCurrentTempCharacteristic onSubscribedCentrals:nil];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"Central subscribed to characteristic %@", characteristic);
}

- (void)dealloc{
    [_temperatureChanger invalidate];
    [self removeObserver:self forKeyPath:@"currentTemperature"];
}

@end
