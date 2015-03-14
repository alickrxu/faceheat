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

@property (weak, nonatomic) IBOutlet UIImageView *ycBview;
@property (weak, nonatomic) IBOutlet UIImageView *thermalView;
@property (weak, nonatomic) IBOutlet UILabel *faceFeatureLabel;
@property (strong, nonatomic) CIDetector *facedetector;

@property (weak, nonatomic) IBOutlet UILabel *rightEyeLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftEyeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mouthLabel;
@property (weak, nonatomic) IBOutlet UILabel *originLabel;
@property (weak, nonatomic) IBOutlet UILabel *frameCountLabel;


@property (strong, nonatomic) NSArray * faceFeatures;
@end

