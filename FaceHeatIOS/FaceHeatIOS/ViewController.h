//
//  ViewController.h
//  FaceHeatIOS
//
//  Created by Daijiro on 2/19/15.
//  Copyright (c) 2015 Team3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLE.h"
@interface ViewController : UIViewController<BLEDelegate>
- (IBAction)scan:(id)sender;
- (IBAction)sendData:(id)sender;

@property(nonatomic, strong) BLE *ble;
@property(nonatomic, strong) CBPeripheral *activePeripheral;

@end

