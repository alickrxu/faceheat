//
//  ViewController.m
//  FaceHeatIOS
//
//  Created by Daijiro on 2/19/15.
//  Copyright (c) 2015 Team3. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end
@implementation ViewController
@synthesize ble;

- (void)viewDidLoad {
    [super viewDidLoad];
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;    
}



- (void) scanForPeripherals {
    [ble findBLEPeripherals:3];
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
}



- (void) bleDidReceiveData:(unsigned char *)data length:(int)length{
    NSLog(@"received data");
}

-(void) connectionTimer:(NSTimer *)timer
{
    if (ble.peripherals.count < 1){
        NSLog(@"none found");
        return;
    }
    self.activePeripheral = ble.peripherals[0];
    [ble connectPeripheral:self.activePeripheral];
}



-(void) bleDidConnect {
    const char d[] = {'S', 0x02, 0x04};
    [ble write:[NSData dataWithBytes:&d length:3]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)scan:(id)sender {
    [self scanForPeripherals];
}

- (IBAction)sendData:(id)sender {
    const char d[] = {'O', 0x02, 0xff};
    [ble write:[NSData dataWithBytes:&d length:3]];
    
}
@end
