//
//  BSLPeripheralViewController.m
//  beaconWorkbench
//
//  Created by Brian Clubb on 11/20/13.
//  Copyright (c) 2013 Bubblesort Laboratories LLC. All rights reserved.
//

#import "BSLPeripheralViewController.h"

@interface BSLPeripheralViewController ()

@property NSNumber *currentTemperatureValue;
@property NSNumber *desiredTemperatureValue;

@end

@implementation BSLPeripheralViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _currentTemperatureValue = [NSNumber numberWithFloat:52.0];
        _desiredTemperatureValue = [NSNumber numberWithFloat:62.0];
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

-(IBAction)changeCurrentTemperature:(id)sender{
    _currentTemperatureValue = [NSNumber numberWithFloat:(100*random())];
    [self updateDisplay];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
