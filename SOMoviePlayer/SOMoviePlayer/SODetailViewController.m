//
//  SODetailViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 17/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SODetailViewController.h"
#import "SONotifications.h"
#import "SOSettingsViewController.h"
#import "SOScreenViewController.h"

@interface SODetailViewController ()

@property (retain, nonatomic) CMMotionManager           *motionManager;
@property (assign, nonatomic) CADisplayLink             *motionDisplayLink;

@property (weak, nonatomic) IBOutlet UILabel            *attitudeLabel;

@property (retain, nonatomic) UIScrollView              *scrollView;



@property (assign,nonatomic) AVPlayer *avFrontPlayer;
@property float zoomLevel;




-(void)onMotionManagerReset:(NSNotification *)notification;



@end

@implementation SODetailViewController


#pragma mark - Motion Manager

-(void)setupMotionManager{
    
    if(self.motionDisplayLink==nil){
        self.motionManager = [[CMMotionManager alloc] init];
    }
    
    self.motionManager.deviceMotionUpdateInterval = 0.02;  // 50 Hz
    
    if(self.motionDisplayLink==nil){
        self.motionDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(motionRefresh:)];
        [self.motionDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    if ([self.motionManager isDeviceMotionAvailable]) {
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
    }
    

}

-(void)closeMotionManager{

    [self.motionDisplayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    if(self.motionDisplayLink!=nil)
        self.motionDisplayLink = nil;
    
    if(self.motionManager!=nil)
        self.motionManager = nil;

}

#pragma mark - Setup

-(void)setMovieFilePathA:(NSURL *)pathA{
    
    if (_movieFilePath != pathA) {
        _movieFilePath = pathA;
        
    }
    
    // Update the view.
    [self configureView];
    
}

- (void)configureView{

    self.zoomLevel = 1.2f;
    
    CGRect aspectFrame = CGRectMake(0.0, 0.0,
                                  self.view.bounds.size.height,
                                  self.view.bounds.size.width);


    CGRect fullFrame = CGRectMake(0.0, 0.0,
                                  self.view.bounds.size.height * self.zoomLevel,
                                  self.view.bounds.size.width * self.zoomLevel);

    
    
    // setup views
    self.scrollView = [[UIScrollView alloc] initWithFrame:aspectFrame];
    [self resetScrollView];

    [self.view addSubview:self.scrollView];
    [self.scrollView setBackgroundColor:[UIColor darkGrayColor]];

    SOScreenViewController *svc = [[SOScreenViewController alloc] initWithFrame:fullFrame];
    [self.scrollView addSubview:svc.view];
    
    
//
//    // setup avplayers
//    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.movieFilePath options:nil];
//
//    _avFrontPlayer = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
//    AVPlayerLayer *frontLayer = [AVPlayerLayer playerLayerWithPlayer:self.avFrontPlayer];
//    [frontLayer setFrame:fullFrame];
//    frontLayer.opacity = 0.1f;  
//    //[self.aView.layer addSublayer:frontLayer];
//    
//    // fade in example
//    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    flash.fromValue = [NSNumber numberWithFloat:0.0];
//    flash.toValue = [NSNumber numberWithFloat:1.0];
//    flash.duration = 5.0;        // 1 second
//    flash.autoreverses = NO;    // Back
//    flash.repeatCount = 0;       // Or whatever
//    
//    [frontLayer addAnimation:flash forKey:@"fadeIn"];
//
    
//    // add boundry observer
//    CMTime duration = self.avFrontPlayer.currentItem.asset.duration;
//    Float64 durationInSeconds = CMTimeGetSeconds(duration);
//    
//    NSArray *times = @[[NSValue valueWithCMTime:CMTimeMakeWithSeconds(5.0f, self.avFrontPlayer.currentTime.timescale)]];
////    __weak SODetailViewController *weakSelf = self;
//    [self.avFrontPlayer addBoundaryTimeObserverForTimes:times queue:NULL usingBlock:^(){
//        NSLog(@"%f",durationInSeconds);
//        //[weakSelf.avFrontPlayer pause];
//    }];
//    
//    times = @[[NSValue valueWithCMTime:CMTimeMakeWithSeconds(durationInSeconds - 5.0f, self.avFrontPlayer.currentTime.timescale)]];
//    [self.avFrontPlayer addBoundaryTimeObserverForTimes:times queue:NULL usingBlock:^(){
//        NSLog(@"fadeOut");
//        CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        flash.fromValue = [NSNumber numberWithFloat:1.0];
//        flash.toValue = [NSNumber numberWithFloat:0.0];
//        flash.duration = 5.0;
//        flash.autoreverses = NO;
//        flash.repeatCount = 0;      
//        
//        [frontLayer addAnimation:flash forKey:@"fadeOut"];
//    }];
//
//    
//    [self.avFrontPlayer play];
    
    
    
    
    // gestures
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(onDoubleTap:)];
    [tapGesture setNumberOfTapsRequired:2];
    [[self view] addGestureRecognizer:tapGesture];


    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(onSwipeRight:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer: swipeGesture];

    // observe stuff
    [self addObservers];
    
    // attitude label
    [self.view bringSubviewToFront:self.attitudeLabel];
    [self.attitudeLabel setHidden:YES];

}
-(void)resetScrollView{

    CGRect fullFrame = CGRectMake(0.0, 0.0,
                                    self.view.bounds.size.height * self.zoomLevel,
                                    self.view.bounds.size.width * self.zoomLevel);
    
    [self.scrollView setContentSize:fullFrame.size];
    [self.scrollView setContentOffset:self.scrollView.center animated:NO];
    [self.scrollView setScrollEnabled:NO];

}
-(void)addObservers{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avFrontPlayer currentItem]];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onMotionManagerReset:)
												 name:kMotionManagerReset
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onZoomReset:)
												 name:kZoomReset
											   object:nil];


}
-(void)removeObservers{

    AVPlayer *avFrontPlayer = self.avFrontPlayer;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:avFrontPlayer];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMotionManagerReset
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kZoomReset
                                                  object:nil];

}

#pragma mark - Gestures & Notifications

- (void)onDoubleTap:(UIGestureRecognizer *)gestureRecognizer{
    
    [self.avFrontPlayer pause];
    
    [self.attitudeLabel setHidden:NO];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    SOSettingsViewController *settingsVC = [sb instantiateViewControllerWithIdentifier:@"settingsVCID"];
    [self addChildViewController:settingsVC];
    [settingsVC.view setFrame:self.view.frame];
    [self.view addSubview:settingsVC.view];
    [settingsVC.view setTransform:CGAffineTransformMakeTranslation(0.0,320.0f)];
    
    __block SODetailViewController *blockSelf = self;
    [settingsVC setOnCloseUpBlock:^(){
        [blockSelf.avFrontPlayer play];
        [blockSelf.attitudeLabel setHidden:YES];
        
    }];
    
    [UIView animateWithDuration:0.2
                         delay :0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         settingsVC.view.transform = CGAffineTransformMakeTranslation(0.0,0.0f);
                     }
                     completion:^(BOOL  complete){
                     }
     ];
    
}

- (void)onSwipeRight:(UIGestureRecognizer *)gestureRecognizer{
    
    [self cleanup];
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)onZoomReset:(NSNotification *)notification{
//
//    UISwitch *swch = (UISwitch*)[notification object];
//    
//    if([swch isOn]){
//        
//        self.zoomLevel = 2.0f;
//        [self resetScrollView];
//        
//        self.motionDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(motionRefresh:)];
//        [self.motionDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//
//    }else{
//     
//        [self.motionDisplayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//        
//        if(self.motionDisplayLink!=nil)
//            self.motionDisplayLink = nil;
//
//        self.zoomLevel = 1.0f;
//        [self resetScrollView];
//  
//    }
}
-(void)onMotionManagerReset:(NSNotification *)notification{
    
    
    [self closeMotionManager];
    [self setupMotionManager];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification{
    

//    [self.avFrontPlayer seekToTime:kCMTimeZero];
//    [self.avBackPlayer seekToTime:kCMTimeZero];
//    [self.avFrontPlayer play];
//    [self.avBackPlayer play];
    
}

#pragma mark - Views

- (void)viewDidLoad{
    
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor blackColor]];
    [self setupMotionManager];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [[self tabBarController].tabBar setHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[self tabBarController].tabBar setHidden:NO];
}

-(void)cleanup{
 
    [self removeObservers];

    self.scrollView = nil;
    [self.avFrontPlayer pause];
    self.avFrontPlayer = nil;
    
    
    [self closeMotionManager];
    
    
}

- (void)viewDidUnload
{
    
    [self cleanup];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMotionManagerReset object:nil];
}
#pragma mark - Motion Refresher

- (void)motionRefresh:(id)sender {
    
    float roll = self.motionManager.deviceMotion.attitude.roll;
    float pitch = self.motionManager.deviceMotion.attitude.pitch;
    float yawf = self.motionManager.deviceMotion.attitude.yaw;
    float heading = self.motionManager.deviceMotion.magneticField.field.y;
    
    self.attitudeLabel.text = [NSString stringWithFormat:@"roll %.2f pitch %.2f yaw %.2f h %.2f",roll,pitch,yawf,heading];
    
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft){
        
        
    }else if (orientation == UIInterfaceOrientationLandscapeRight){
        
    }

    
    float xpers = self.view.frame.size.width;
    float ypers = self.view.frame.size.height;
    float xs = 3.0f;
    float ys = 3.0f;
    
    (roll < 0.0f) ? roll *= -1.0f : roll;
    
    yawf = yawf / (2.0 * M_PI) * xs;
    roll = -roll / (2.0 * M_PI) * ys;
    
    float offsetx = (xpers * 0.5f * (self.zoomLevel - 1.0));
    float offsety = (ypers * 0.5f * (self.zoomLevel - 1.0));
    xpers = offsetx - (yawf * xpers);
    ypers = offsety + (roll * ypers) + (ypers * 0.25f * ys);
    
    CGPoint pnt = CGPointMake(xpers, ypers);
    
    
    [self.scrollView setContentOffset:pnt animated:NO];
    
    
}


@end

