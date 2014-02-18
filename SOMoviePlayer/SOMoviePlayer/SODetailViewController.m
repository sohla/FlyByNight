//
//  SODetailViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 17/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SODetailViewController.h"

@interface SODetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *attitudeLabel;
@property (retain,nonatomic) MPMoviePlayerController *player;
@property (retain, nonatomic) CMMotionManager *motionManager;
@property (retain, nonatomic) CADisplayLink *motionDisplayLink;

@property double motionLastYaw;


@end

@implementation SODetailViewController


#pragma mark - Managing the detail item

-(void)setupMotionManager{
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 0.02;  // 50 Hz
    
    self.motionDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(motionRefresh:)];
    [self.motionDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    if ([self.motionManager isDeviceMotionAvailable]) {
        // to avoid using more CPU than necessary we use `CMAttitudeReferenceFrameXArbitraryZVertical`
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
    }
    
}

- (void)configureView{

    NSURL *url  = [NSURL fileURLWithPath:self.movieFilePath];
    self.player = [[MPMoviePlayerController alloc] initWithContentURL: url];
//    [self.player setControlStyle:MPMovieControlStyleNone];
    [self.player setScalingMode:MPMovieScalingModeAspectFit];
    [self.player prepareToPlay];
    [self.player setFullscreen:YES animated:YES];
    [self addObservers];
    
    // flip it to landscape ratio
    self.player.view.frame = CGRectMake(0.0, 0.0,
                                        self.view.bounds.size.height,
                                        self.view.bounds.size.width);
    
    [self.view addSubview:self.player.view];
    [self.view sendSubviewToBack:self.player.view];
    
    [self.player play];
    [self.player setCurrentPlaybackRate:0.5];

    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(onSwipeRight:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer: swipeGesture];

}
- (void)onSwipeRight:(UIGestureRecognizer *)gestureRecognizer{
    
    [self.navigationController popViewControllerAnimated:YES];
    [self removeObservers];
    
    [self.motionDisplayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.motionDisplayLink = nil;
    self.motionManager = nil;

}
-(void)addObservers{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.player];

}
-(void)removeObservers{

    MPMoviePlayerController *player = self.player;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:player];



}
-(void)setMovieFilePath:(NSString *)movieFilePath{
    
    if (_movieFilePath != movieFilePath) {
        _movieFilePath = movieFilePath;
        
        // Update the view.
        [self configureView];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
 

    [self.view setBackgroundColor:[UIColor blackColor]];
    [self setupMotionManager];
    
}

- (void)viewDidUnload
{
    [self removeObservers];
    
    [self.motionDisplayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.motionDisplayLink = nil;
    self.motionManager = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Motion Refresher

- (void)motionRefresh:(id)sender {
    
    // found at : http://www.dulaccc.me/2013/03/computing-the-ios-device-tilt.html
    
    CMQuaternion quat = self.motionManager.deviceMotion.attitude.quaternion;
    double yaw = asin(2*(quat.x*quat.z - quat.w*quat.y));
    
    if (self.motionLastYaw == 0) {
        self.motionLastYaw = yaw;
    }
    
    // kalman filtering
    static float q = 0.1;   // process noise
    static float r = 0.1;   // sensor noise
    static float p = 0.1;   // estimated error
    static float k = 0.5;   // kalman filter gain
    
    float x = self.motionLastYaw;
    p = p + q;
    k = p / (p + r);
    x = x + k*(yaw - x);
    p = (1 - k)*p;
    self.motionLastYaw = x;
    
    float speed = (-x / 1.5) * 2.0;
    
    if(speed < 0.1) speed = 0.1;
    if(speed > 2.0) speed = 2.0;

    self.attitudeLabel.text = [NSString stringWithFormat:@"%.2f",speed];
    
    //[self.player setCurrentPlaybackRate:speed];

    float max = 5.0;
    float yaxis = ((-x / 1.5) - 0.5) * max;
    
    if(yaxis < -max) yaxis = -max;
    if(yaxis > max) yaxis = max;
    self.player.view.frame = CGRectOffset(self.player.view.frame, 0.0, yaxis);
    
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft){
        
        
    }else if (orientation == UIInterfaceOrientationLandscapeRight){
        
        
    }
    
}

#pragma mark Notifications

- (void) moviePlayBackDidFinish:(NSNotification*)notification{
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end

