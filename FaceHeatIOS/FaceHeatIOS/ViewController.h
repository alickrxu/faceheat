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

@interface ViewController : UIViewController<AVCaptureAudioDataOutputSampleBufferDelegate>

@property AVCaptureVideoPreviewLayer *previewLayer;
@property AVCaptureVideoDataOutput *output;

@end
