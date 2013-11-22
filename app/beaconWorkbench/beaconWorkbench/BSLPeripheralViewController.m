//
//  BSLPeripheralViewController.m
//  beaconWorkbench
//
//  Created by Brian Clubb on 11/20/13.
//  Copyright (c) 2013 Bubblesort Laboratories LLC. All rights reserved.
//

#import "BSLPeripheralViewController.h"
#import "BSLThermostatPeripheral.h"

@interface BSLPeripheralViewController ()

@property NSNumber *currentTemperatureValue;
@property NSNumber *desiredTemperatureValue;

@property BSLThermostatPeripheral *thermostatPeripheral;

@end

@implementation BSLPeripheralViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _desiredTemperatureValue = [NSNumber numberWithFloat:62.0];
        _thermostatPeripheral = [BSLThermostatPeripheral current];
        [_thermostatPeripheral addObserver:self forKeyPath:@"currentTemperature" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateDisplay];
}

- (void)updateDisplay{
    _currentTemperature.text = [NSString stringWithFormat:@"%.1f", _currentTemperatureValue.floatValue];
    _desiredTemperature.text = [NSString stringWithFormat:@"%.1f", _desiredTemperatureValue.floatValue];
}

-(IBAction)increaseTemperature:(id)sender{
    _desiredTemperatureValue = [NSNumber numberWithFloat:(_desiredTemperatureValue.floatValue + 1)];
    [self updateDisplay];
}

-(IBAction)decreaseTemperature:(id)sender{
    _desiredTemperatureValue = [NSNumber numberWithFloat:(_desiredTemperatureValue.floatValue - 1)];
    [self updateDisplay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentTemperature"]) {
        _currentTemperature = [change objectForKey:NSKeyValueChangeNewKey];
        [self updateDisplay];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [_thermostatPeripheral removeObserver:self forKeyPath:@"currentTemperature"];
}

@end
