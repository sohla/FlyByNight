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
#import "SOPropertiesViewController.h"
#import "SOScreenViewController.h"
#import "SOAppDelegate.h"

// SOScreenViewManager
//      has a bunch of screenviews

@interface SODetailViewController ()



@property (strong, nonatomic) CADisplayLink             *displayLink;
@property (strong, nonatomic) NSMutableDictionary       *screenViewControllers;

@property (strong, nonatomic) SOScreenTransport         *transport;




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

    [self addGestures];
    
    CGRect fullFrame = CGRectMake(0.0, 0.0,
                                  self.view.frame.size.height,
                                  self.view.frame.size.width);

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _transport = [sb instantiateViewControllerWithIdentifier:@"transportVCID"];
    [self addChildViewController:self.transport];
    [self.transport.view setFrame:fullFrame];
    [self.transport.view setAlpha:0.5f];
    [self.view addSubview:self.transport.view];
    

}
-(void)dealloc{
    DLog(@"");
    //[self.screenViewControllers removeAllObjects];
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [[self tabBarController].tabBar setHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    
//    [[self navigationController] setNavigationBarHidden:NO animated:YES];
//    [[self tabBarController].tabBar setHidden:NO];
}

-(void)cleanup{
    
    DLog(@"");
    
    // need to destroy player and it's observers
//    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        [(SOScreenViewController*)obj destroyPlayer];
//    }];
    
    [self removeGestures];
    
    [self removeObservers];
    
    [self closeMotionManager];

//    [self.screenViewControllers removeAllObjects];
//    self.screenViewControllers = nil;

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
    
    if(self.displayLink==nil){
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }

}

-(void)closeMotionManager{

    
    if(self.displayLink!=nil)
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = nil;
    

}



-(void)addScreenWithCue:(SOCueModel*)cueModel{

    SOScreenViewController *svc = [[SOScreenViewController alloc] initWithFrame:self.view.bounds];
    [svc setDelegate:self];
    [svc setCue:cueModel];

    
    [self.screenViewControllers setObject:svc forKey:[cueModel title]];
    svc.view.alpha = 0.5f;
    [self.view addSubview:svc.view];
    
    
    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj scrollTo:(CGPoint){0.0,M_PI_2}];
    }];

    [self.view bringSubviewToFront:self.transport.view];
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

    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(onSwipeRight:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer: swipeGesture];

}
-(void)removeGestures{
    
    [self.view.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.view removeGestureRecognizer:obj];
    }];

}
-(void)addObservers{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onMotionManagerReset:)
												 name:kMotionManagerReset
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onZoomChanged:)
												 name:kZoomChanged
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onZoomReset:)
												 name:kZoomReset
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onOffsetChanged:)
												 name:kOffsetChanged
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onIsScrolling:)
												 name:kIsScrolling
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onTransportBack:)
												 name:kTransportBack
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onTransportForward:)
												 name:kTransportForward
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onEditModeOn:)
												 name:kEditModeOn
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onEditModeOff:)
												 name:kEditModeOff
											   object:nil];
    


}
-(void)removeObservers{

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMotionManagerReset
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kZoomChanged
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kZoomReset
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kOffsetChanged
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kIsScrolling
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTransportForward
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTransportBack
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kEditModeOn
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kEditModeOff
                                                  object:nil];

}

#pragma mark - Gestures & Notifications
-(void)onEditModeOff:(NSNotification *)notification{

    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj play];
    }];
}
-(void)onEditModeOn:(NSNotification *)notification{


    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj pause];
    }];

    SOPropertiesViewController *props = [[SOPropertiesViewController alloc] initWithNibName:@"SOPropertiesViewController" bundle:nil];
    
    //• use blocks to capture
    // props onValueChangedBlock{}
    // props setLabelWithBlock{}
    

    
    
   // [props setCueModel:self.cueModel];
    
    [self presentViewController:props animated:YES completion:^{
        
    
    }];
    
    
}

- (void)onSwipeRight:(UIGestureRecognizer *)gestureRecognizer{
    
    [self cleanup];
    [self.navigationController popViewControllerAnimated:NO];
    
}
-(void)onOffsetChanged:(NSNotification *)notification{
    
    UISlider *slider = (UISlider*)[notification object];//0..1
    float off = (([slider value] * 2.0f) - 1.0f) * M_PI;// -M_PI..M_PI
    
    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj resetOffsetX:off];
    }];
    
}

-(void)onZoomChanged:(NSNotification *)notification{
    
    UISlider *slider = (UISlider*)[notification object];//0..1
    float z = 0.5 + ([slider value] * 1.5f); // 0.5..2.0
    
    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj resetZoomAt:z];
    }];

    
}
-(void)onIsScrolling:(NSNotification *)notification{
    
    UISwitch *swich = (UISwitch*)[notification object];
    
    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj setIsScrolling:[swich isOn]];
    }];

    
}

-(void)onZoomReset:(NSNotification *)notification{

    float z = 0;
    UISwitch *swch = (UISwitch*)[notification object];
    
    if([swch isOn]){
        z = 2.0f;
    }else{
        z = 1.0f;
    }
    
    //do we reset motion manager?
    //[[NSNotificationCenter defaultCenter] postNotificationName:kMotionManagerReset object:nil];

    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj resetZoomAt:z];
    }];
}
-(void)onMotionManagerReset:(NSNotification *)notification{
    [[SOMotionManager sharedManager] reset];
}

-(void)onTransportForward:(NSNotification *)notification{
    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj jumpForward];
    }];
}
-(void)onTransportBack:(NSNotification *)notification{
    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj jumpBack];
    }];
}

#pragma mark - Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMotionManagerReset object:nil];
}
#pragma mark - Motion Refresher

- (void)onDisplayLink:(id)sender {
    
    float roll = [[SOMotionManager sharedManager] valueForKey:@"roll"];
//    float pitch = [[SOMotionManager sharedManager] valueForKey:@"pitch"];
    float yawf = [[SOMotionManager sharedManager] valueForKey:@"yaw"];
//    float heading = [[SOMotionManager sharedManager] valueForKey:@"heading"];

    [self.transport updateAttitudeWithRoll:roll andYaw:yawf];
    
    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([(SOScreenViewController*)obj isScrolling]){
            [(SOScreenViewController*)obj scrollTo:(CGPoint){yawf,roll}];

        }
    }];

    
}


@end

