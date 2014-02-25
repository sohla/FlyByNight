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

@property (retain, nonatomic) UIScrollView              *scrollView;

@property (retain,nonatomic) AVPlayer *avPlayer;

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


    CGRect fullFrame = CGRectMake(0.0, 0.0,
                                  self.view.bounds.size.height * 2,
                                  self.view.bounds.size.width * 2);

    
    CGRect doubleFrame = CGRectMake(0.0, 0.0,
                                  self.view.bounds.size.height * 2,
                                  self.view.bounds.size.width * 4);

    
    // setup scroll view
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:aspectFrame];
    [self.scrollView setContentSize:doubleFrame.size];
    [self.scrollView setContentOffset:(CGPoint){0,0} animated:NO];
    [self.scrollView setScrollEnabled:NO];
    [self.view addSubview:self.scrollView];
    
    UIView *secondView = [[UIView alloc] initWithFrame:fullFrame];
    [secondView setFrame:CGRectOffset(secondView.frame, fullFrame.size.width, 0.0)];
    [secondView setBackgroundColor:[UIColor greenColor]];
    [self.scrollView addSubview:secondView];
    
    
    
    // setup avplayer
    
    NSURL *url  = [NSURL fileURLWithPath:self.movieFilePath];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    _avPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];

    [playerLayer setFrame:fullFrame];
    [self.scrollView.layer addSublayer:playerLayer];
    
    [self.avPlayer play];
   
    // set view port to middle
    CGPoint pnt = CGPointMake(240, 160);
    [self.scrollView setContentOffset:pnt animated:NO];

    
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


    //
    [self addObservers];
    
    
  

}
- (void)onDoubleTap:(UIGestureRecognizer *)gestureRecognizer{
    
    [self.avPlayer pause];
    
    [self.attitudeLabel setHidden:NO];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    SOSettingsViewController *settingsVC = [sb instantiateViewControllerWithIdentifier:@"settingsVCID"];
    [self addChildViewController:settingsVC];
    [settingsVC.view setFrame:self.view.frame];
    [self.view addSubview:settingsVC.view];
    [settingsVC.view setTransform:CGAffineTransformMakeTranslation(0.0,320.0f)];
    
    __block SODetailViewController *blockSelf = self;
    [settingsVC setOnCloseUpBlock:^(){
        [blockSelf.avPlayer play];
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

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(moviePlayBackDidFinish:)
//                                                 name:MPMoviePlayerPlaybackDidFinishNotification
//                                               object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avPlayer currentItem]];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onMotionManagerReset:)
												 name:kMotionManagerReset
											   object:nil];


}
-(void)removeObservers{

//    MPMoviePlayerController *player = self.player;
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerPlaybackDidFinishNotification
//                                                  object:player];
    
    
    AVPlayer *avPlayer = self.avPlayer;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:avPlayer];

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
    
    [self.avPlayer pause];
    self.avPlayer = nil;
    
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

