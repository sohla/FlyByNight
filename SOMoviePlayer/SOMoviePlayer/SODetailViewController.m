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


@property (retain, nonatomic) NSMutableDictionary       *screenViewControllers;





-(void)onMotionManagerReset:(NSNotification *)notification;



@end

@implementation SODetailViewController





#pragma mark - Views

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    _screenViewControllers = [[NSMutableDictionary alloc] init];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    //motion
    [self setupMotionManager];

    [self addObservers];

    // attitude label
    [self.view bringSubviewToFront:self.attitudeLabel];
    [self.attitudeLabel setHidden:NO];

    [self addGestures];
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
    
    // need to destroy player and it's observers
    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj destroyPlayer];
    }];
    

    [self.view.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.view removeGestureRecognizer:obj];
    }];
    
    [self removeObservers];
    
    self.screenViewControllers = nil;
    
    [self closeMotionManager];
    
}
- (void)viewDidUnload{
    
    [self cleanup];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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


-(void)addScreenWithURL:(NSURL*)url{
    
    SOScreenViewController *svc = [[SOScreenViewController alloc] initWithFrame:self.view.bounds];
    svc.delegate = self;
    [svc buildPlayerWithURL:url];

    [self.screenViewControllers setObject:svc forKey:[url lastPathComponent]];
    svc.view.alpha = 0.5f;
    [self.view addSubview:svc.view];
    
}

-(void)onScreenViewPlayerDidBegin:(SOScreenViewController*)svc{
    DLog(@"");
}

-(void)onScreenViewPlayerDidEnd:(SOScreenViewController*)svc{
    DLog(@"");
    
}

#pragma mark - Setup

- (void)addGestures{

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

}

-(void)addObservers{
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


    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMotionManagerReset
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kZoomReset
                                                  object:nil];

}

#pragma mark - Gestures & Notifications

- (void)onDoubleTap:(UIGestureRecognizer *)gestureRecognizer{
    
    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj pause];
    }];
    
    [self.attitudeLabel setHidden:NO];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    SOSettingsViewController *settingsVC = [sb instantiateViewControllerWithIdentifier:@"settingsVCID"];
    [self addChildViewController:settingsVC];
    [settingsVC.view setFrame:self.view.frame];
    [self.view addSubview:settingsVC.view];
    [settingsVC.view setTransform:CGAffineTransformMakeTranslation(0.0,320.0f)];
    
    __block SODetailViewController *blockSelf = self;
    [settingsVC setOnCloseUpBlock:^(){
        
        [blockSelf.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [(SOScreenViewController*)obj play];
        }];
       
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

    float z = 0;
    UISwitch *swch = (UISwitch*)[notification object];
    
    if([swch isOn]){
        z = 2.0f;
    }else{
        z = 1.0f;
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:kMotionManagerReset object:nil];

    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj resetZoomAt:z];
    }];
    



}
-(void)onMotionManagerReset:(NSNotification *)notification{
    
    [self closeMotionManager];
    [self setupMotionManager];
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
     
    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj scrollTo:(CGPoint){yawf,roll}];
    }];

    
}


@end

