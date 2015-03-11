//
//  ViewController.h
//  FaceHeatIOS
//
//  Created by Alick, Daijiro on 2/19/15.
//  Copyright (c) 2015 Team3. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FLIROneSDK/FLIROneSDK.h>

@interface ViewController : UIViewController <FLIROneSDKImageReceiverDelegate, FLIROneSDKStreamManagerDelegate, FLIROneSDKVideoRendererDelegate, FLIROneSDKImageEditorDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *yc8view;
@property (weak, nonatomic) IBOutlet UIImageView *thermalView;
@property (weak, nonatomic) IBOutlet UILabel *faceFeatureLabel;
@property (strong, nonatomic) CIDetector *facedetector;
@end

