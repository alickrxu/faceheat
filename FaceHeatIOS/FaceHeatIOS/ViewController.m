//
//  ViewController.m
//  FaceHeatIOS
//
//  Created by Alick, Daijiro on 2/19/15.
//  Copyright (c) 2015 Team3. All rights reserved.
//

#import "ViewController.h"
#import <tgmath.h>

@interface ViewController ()

//The main viewfinder for the FLIR ONE

@property (weak, nonatomic) IBOutlet UILabel *connectionLabel;

//labels for various camera information
@property (strong, nonatomic) UIView *hottestPoint;
@property (strong, nonatomic) UILabel *hottestLabel;

@property (strong, nonatomic) NSData *thermalData;
@property (nonatomic) CGSize thermalSize;

//buttons for interacting with the FLIR ONE
//capture video

//FLIR data for UI to display
@property (strong, nonatomic) UIImage *visualYCbCrImage;
@property (strong, nonatomic) UIImage *radiometricImage;


@property (nonatomic) FLIROneSDKTuningState tuningState; //tuning state of the FLIR
@property (nonatomic) BOOL connected; //determines if FLIR is connected to the phone
@property (nonatomic) FLIROneSDKImageOptions options; //options for the FLIR stream

@property (strong, nonatomic) dispatch_queue_t renderQueue; //queue for rendering


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //set options for the FLIR one
    self.options = FLIROneSDKImageOptionsThermalRadiometricKelvinImage | FLIROneSDKImageOptionsVisualYCbCr888Image;
    
    //create a queue for rendering
    self.renderQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    
    
    
    NSDictionary *detectoroptions = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"CIDetectorAccuracy", @"CIDetectorAccuracyLow",nil];
    self.facedetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectoroptions];
    
    // add view controller to FLIR stream manager delegates
    [[FLIROneSDKStreamManager sharedInstance] addDelegate:self];
    [[FLIROneSDKStreamManager sharedInstance] setImageOptions: self.options];
    
    //update UI here
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) FLIROneSDKDidConnect {
    self.connected = YES;
    [self updateUI];
}

- (void) FLIROneSDKDidDisconnect {
    self.connected = NO;
    [self updateUI];
}


- (void) FLIROneSDKTuningStateDidChange:(FLIROneSDKTuningState)newTuningState {
    self.tuningState = newTuningState;
}


- (UIImage *)imageForFrameAtTimestamp:(CMTime)timestamp{
    return [[UIImage alloc] init];
}

// once per frame, this method is called and notifies the delegate. Depending on type of image, a different
// didReceive method gets called
- (void)FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveFrameWithOptions:(FLIROneSDKImageOptions)options metadata:(FLIROneSDKImageMetadata *)metadata {
    self.options = options;
    if(!(self.options & FLIROneSDKImageOptionsVisualYCbCr888Image)) {
        self.visualYCbCrImage = nil;
    }
    
    //update UI here
}


- (void) updateUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.yc8view.image = self.visualYCbCrImage;
        if (self.connected)
            self.connectionLabel.text = @"connected";
        else
            self.connectionLabel.text = @"disconnected";
        
        self.thermalView.image = self.radiometricImage;
        
        
        for (CIFeature *faceFeature in self.faceFeatures){
            self.faceFeatureLabel.text = [NSString stringWithFormat:@"%f %f", faceFeature.bounds.size.height, faceFeature.bounds.size.width];
        }
        self.faceFeatures = @[];
    });
}

// when visualYCbCr is captured, this gets called. Best formatted for temperature data
- (void)FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveVisualYCbCr888Image:(NSData *)visualYCbCr888Image imageSize:(CGSize)size {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.visualYCbCrImage = [FLIROneSDKUIImage imageWithFormat:FLIROneSDKImageOptionsVisualYCbCr888Image andData:visualYCbCr888Image andSize:size];
        
        
        self.faceFeatures = [self.facedetector featuresInImage:[[CIImage alloc] initWithImage: self.visualYCbCrImage]];
        
        [self updateUI];
        //update UI here
    });
    
}

- (void)FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveRadiometricData:(NSData *)radiometricData imageSize:(CGSize)size {
    
    @synchronized(self) {
        self.thermalData = radiometricData; //update thermal data here
        self.thermalSize = size;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.radiometricImage = [FLIROneSDKUIImage imageWithFormat:FLIROneSDKImageOptionsThermalRadiometricKelvinImage andData:radiometricData andSize:size];
        [self updateUI];
    });
}



// converts temperature data into degrees (Kelvin). NOTE the pixels in the image are row major, ex:
// [0] [1] [2] [3] [4]
// [5] [6] [7] [8] [9]
// [10] [11] ...
//
- (void) performTemperatureCalculations {
    //grab a two-byte pointer to the first value in the array, which is a pointer to pixel (0,0)
    uint16_t *tempData = (uint16_t*)[self.thermalData bytes];
    
    //get total number of pixels to iterate over
    int totalPixels = self.thermalSize.width * self.thermalSize.height;
    
    for(int i = 0; i < totalPixels; i++) {
        float degreesKelvin = tempData[i] / 100.0; //gets temperature at index i
        CGFloat xCoord = fmod(i, self.thermalSize.width); //x coord of thermal data
        CGFloat yCoord = floor(i / self.thermalSize.width); //y coord of thermal data
        
        //x coord and y coord of thermal will differ from visual due to the different resolutions...
        //get the x coordinate and y coordinate of visual, convert to thermal
    }
    
}



//grab any valid image delivered from the sled
- (UIImage *)currentImage {
    UIImage *image = self.visualYCbCrImage;
    if(!image) {
        image = self.radiometricImage;
    }
    if(!image) {
    }
    if(!image) {
        image = self.visualYCbCrImage;
    }
    return image;
}


@end
