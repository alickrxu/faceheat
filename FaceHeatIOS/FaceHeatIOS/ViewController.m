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

int currentAngle = 125;


- (void)viewDidLoad {
    [super viewDidLoad];
    
       // Do any additional setup after loading the view.
    
    //Capture Session
   
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
}





- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    NSArray *features = [self getFeatures:image];
    
    for (CIFaceFeature *f in features){
        float centerX = (f.bounds.origin.x + f.bounds.size.width)/2.0;
        float centerY = (f.bounds.origin.y + f.bounds.size.height)/2.0;
        NSLog(@"%f", centerX);
        [self centerRigX:centerX Y:centerY];
        
    }
}


- (void) centerRigX:(float)fcenterX Y:(float)fcenterY {
    
    
    
    NSLog(@"%f", fcenterX);
    
    if (fcenterX < 300 && fcenterX > 250)
        return;
    
    if (fcenterX > 300){
        currentAngle -= 2;
    }
    else {
        currentAngle += 2;
    }
    
    if (currentAngle > 255)
        currentAngle = 255;
    else if (currentAngle < 0)
        currentAngle = 0;
    char data[] = {'O', 0x02, currentAngle};
    
    [self sendData:[NSData dataWithBytes:data length:3]];
}




- (void) scanForPeripherals {
    [ble findBLEPeripherals:3];
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
}



- (NSArray *) getFeatures:(UIImage *) inputImage {
    CIImage *ciImage = [inputImage CIImage];
    if (!ciImage)
        return @[];
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh, CIDetectorTracking: @YES};      // 2
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:opts];
    
    NSArray * features = [detector featuresInImage:ciImage options:@{ CIDetectorImageOrientation : @1}];
    return features;
}


- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    CIImage *image = [CIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    
    return ([UIImage imageWithCIImage:image]);
}


- (void) willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [UIView setAnimationsEnabled:NO];
}
- (void) bleDidReceiveData:(unsigned char *)data length:(int)length{

//   NSLog(@"received data: %s", data);
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
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    //Add device
    AVCaptureDevice *device =
    [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //Input
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    if (!input)
    {
        NSLog(@"No Input");
    }
    
    [session addInput:input];
    //Output
    self.output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:self.output];
    self.output.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    
    
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [_output setSampleBufferDelegate:self queue:queue];
    
    //Preview Layer
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    UIView *myView = self.view;
    _previewLayer.frame = CGRectMake(0, 0, myView.bounds.size.height, myView.bounds.size.width);
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_previewLayer];
    AVCaptureConnection *previewLayerConnection=self.previewLayer.connection;
    previewLayerConnection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    char init1[] = {'S', 0x02, 0x04};
    [self sendData: [NSData dataWithBytes:init1 length:3]];
    char centerX[] = {'O', 0x02, currentAngle};
    
    [self sendData:[NSData dataWithBytes:centerX length:3]];
    //Start capture session
    [session startRunning];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) sendData:(char *) bytes length:(int) length{
    [self sendData:[NSData dataWithBytes:bytes length:length]];
}

- (void) sendData:(NSData *) data {
    [ble write:data];
}


- (IBAction)scan:(id)sender {
    [self scanForPeripherals];
}


@end
