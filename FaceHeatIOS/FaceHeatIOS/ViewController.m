//
//  ViewController.m
//  FaceHeatIOS
//
//  Created by Alick, Daijiro on 2/19/15.
//  Copyright (c) 2015 Team3. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

//The main viewfinder for the FLIR ONE
@property (weak, nonatomic) IBOutlet UIView *masterImageView;

//labels for various camera information
@property (strong, nonatomic) UIView *hottestPoint;
@property (strong, nonatomic) UILabel *hottestLabel;

@property (strong, nonatomic) NSData *thermalData;
@property (nonatomic) CGSize thermalSize;

//buttons for interacting with the FLIR ONE
//capture video
@property (nonatomic, strong) IBOutlet UIButton *captureVideoButton;



//data for UI to display
@property (strong, nonatomic) UIImage *thermalImage;

@property (nonatomic) FLIROneSDKTuningState tuningState;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
