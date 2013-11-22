//
//  BSLThermostatPeripheralService.h
//  beaconWorkbench
//
//  Created by Brian Clubb on 11/21/13.
//  Copyright (c) 2013 Bubblesort Laboratories LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BSLThermostatPeripheral : NSObject <CBPeripheralManagerDelegate>

@property CBMutableService *thermostatCurrentTempService;
@property CBMutableCharacteristic *thermostatCurrentTempCharacteristic;
@property NSNumber *currentTemperature;

+ (BSLThermostatPeripheral*) current;

@end