//
//  ViewController.h
//  FaceHeatIOS
//
//  Created by Daijiro on 2/19/15.
//  Copyright (c) 2015 Team3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLE.h"


@interface ViewController : UIViewController

@property(nonatomic, strong) BLE *ble;
@property(nonatomic, strong) CBPeripheral *activePeripheral;
@property(nonatomic, strong) AVCaptureVideoDataOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end
