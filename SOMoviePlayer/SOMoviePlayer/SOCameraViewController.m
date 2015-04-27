//
//  SOCameraViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 27/07/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOCameraViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface SOCameraViewController ()
@property (weak, nonatomic) IBOutlet UIView *imageView;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@end

@implementation SOCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //----- SHOW LIVE CAMERA PREVIEW -----
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPresetMedium;
	
	CALayer *viewLayer = self.imageView.layer;
	NSLog(@"viewLayer = %@", viewLayer);
	
	self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	
    CGRect bounds = self.imageView.layer.bounds;
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer.bounds=bounds;
    self.captureVideoPreviewLayer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

    
	[self.imageView.layer addSublayer:self.captureVideoPreviewLayer];
	
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	NSError *error = nil;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!input) {
		// Handle the error appropriately.
		NSLog(@"ERROR: trying to open camera: %@", error);
	}
	[session addInput:input];

    AVCaptureConnection *previewLayerConnection = self.captureVideoPreviewLayer.connection;
    [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];

	[session startRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    }


//// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft );
//}
//
//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight ;
//}
//-(BOOL)shouldAutorotate{
//    return YES;
//}

@end
