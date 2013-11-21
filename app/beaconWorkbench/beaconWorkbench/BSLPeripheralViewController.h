//
//  BSLPeripheralViewController.h
//  beaconWorkbench
//
//  Created by Brian Clubb on 11/20/13.
//  Copyright (c) 2013 Bubblesort Laboratories LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSLPeripheralViewController : UIViewController

@property IBOutlet UILabel *currentTemperature;
@property IBOutlet UILabel *desiredTemperature;

-(IBAction)increaseTemperature:(id)sender;
-(IBAction)decreaseTemperature:(id)sender;
-(IBAction)changeCurrentTemperature:(id)sender;

@end
