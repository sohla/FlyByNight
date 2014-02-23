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

@interface SODetailViewController ()

@property (retain, nonatomic) CMMotionManager           *motionManager;
@property (retain, nonatomic) CADisplayLink             *motionDisplayLink;

@property (weak, nonatomic) IBOutlet UILabel            *attitudeLabel;

@property (retain,nonatomic) MPMoviePlayerController    *player;
@property (retain, nonatomic) UIScrollView              *scrollView;


-(void)onMotionManagerReset:(NSNotification *)notification;



@end

@implementation SODetailViewController


#pragma mark - Managing the detail item

-(void)setupMotionManager{
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 0.02;  // 50 Hz
    
    self.motionDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(motionRefresh:)];
    [self.motionDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
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


- (void)configureView{

    CGRect aspectFrame = CGRectMake(0.0, 0.0,
                                  self.view.bounds.size.height,
                                  self.view.bounds.size.width);

    self.scrollView = [[UIScrollView alloc] initWithFrame:aspectFrame];
    
    
    
    NSURL *url  = [NSURL fileURLWithPath:self.movieFilePath];
    self.player = [[MPMoviePlayerController alloc] initWithContentURL: url];
//    [self.player setControlStyle:MPMovieControlStyleNone];
    [self.player setScalingMode:MPMovieScalingModeAspectFit];
    [self.player prepareToPlay];
    [self.player setFullscreen:YES animated:YES];
    [self addObservers];
    
    
    CGRect fullFrame = CGRectMake(0.0, 0.0,
                                   self.view.bounds.size.height * 2,
                                   self.view.bounds.size.width * 2);

    self.scrollView.contentSize = fullFrame.size;
    [self.scrollView setContentOffset:(CGPoint){0,0} animated:NO];
    [self.scrollView setBackgroundColor:[UIColor blackColor]];
    [self.scrollView setScrollEnabled:NO];
    
    self.player.view.frame = fullFrame;
    [self.player.view setUserInteractionEnabled:NO];
    
    [self.scrollView addSubview:self.player.view];
    [self.view addSubview:self.scrollView];
    
    [self.view sendSubviewToBack:self.scrollView];
    
    [self.player play];
    [self.player setCurrentPlaybackRate:1.0];

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
    
    [self.attitudeLabel setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1]];
    [self.attitudeLabel setTextColor:[UIColor whiteColor]];
    [self.view bringSubviewToFront:self.attitudeLabel];
    [self.attitudeLabel setHidden:YES];

    // set view port to middle
    CGPoint pnt = CGPointMake(240, 160);
    [self.scrollView setContentOffset:pnt animated:NO];


}
- (void)onDoubleTap:(UIGestureRecognizer *)gestureRecognizer{
    
    [self.player pause];
    
    [self.attitudeLabel setHidden:NO];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    SOSettingsViewController *settingsVC = [sb instantiateViewControllerWithIdentifier:@"settingsVCID"];
    [self addChildViewController:settingsVC];
    [settingsVC.view setFrame:self.view.frame];
    [self.view addSubview:settingsVC.view];
    [settingsVC.view setTransform:CGAffineTransformMakeTranslation(0.0,320.0f)];
    
    __block SODetailViewController *blockSelf = self;
    [settingsVC setOnCloseUpBlock:^(){
        [blockSelf.player play];
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
-(void)addObservers{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onMotionManagerReset:)
												 name:kMotionManagerReset
											   object:nil];


}
-(void)removeObservers{

    MPMoviePlayerController *player = self.player;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:player];
    

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMotionManagerReset
                                                  object:nil];



}


-(void)onMotionManagerReset:(NSNotification *)notification{
    
    
    [self closeMotionManager];
    [self setupMotionManager];
}


-(void)setMovieFilePath:(NSString *)movieFilePath{
    
    if (_movieFilePath != movieFilePath) {
        _movieFilePath = movieFilePath;
        
        // Update the view.
        [self configureView];
    }
}

#pragma mark Views
-(void)viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [[self tabBarController].tabBar setHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[self tabBarController].tabBar setHidden:NO];
}
- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
 

    [self.view setBackgroundColor:[UIColor blackColor]];
    [self setupMotionManager];
    
}

-(void)cleanup{
 
    [self removeObservers];
    
    [self.player stop];
    self.player = nil;
    
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

#pragma mark Orientation
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

#pragma mark Motion Refresher

- (void)motionRefresh:(id)sender {
    
    float roll = self.motionManager.deviceMotion.attitude.roll;
    float pitch = self.motionManager.deviceMotion.attitude.pitch;
    float yawf = self.motionManager.deviceMotion.attitude.yaw;
    float heading = self.motionManager.deviceMotion.magneticField.field.y;
    
    self.attitudeLabel.text = [NSString stringWithFormat:@"roll %.2f pitch %.2f yaw %.2f h %.2f",roll,pitch,yawf,heading];
    
    float xpers = 340;
    float ypers = 220;
    
    if(roll > 0){
        roll = -roll;
    }
    
    CGPoint pnt = CGPointMake((-yawf * xpers) + 240, 160 -(-roll - 1.5) * ypers);
    
    [self.scrollView setContentOffset:pnt animated:NO];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft){
        
        
    }else if (orientation == UIInterfaceOrientationLandscapeRight){
        
        
    }
    
}

#pragma mark Notifications

- (void) moviePlayBackDidFinish:(NSNotification*)notification{
    
    [self cleanup];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

