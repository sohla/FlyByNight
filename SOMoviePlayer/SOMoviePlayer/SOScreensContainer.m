//
//  SODetailViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 17/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOScreensContainer.h"
#import "SONotifications.h"
#import "SOPropertiesViewController.h"
#import "SOScreenViewController.h"
#import "SOFloatTransformer.h"
#import "SOAppDelegate.h"
#import "SOCameraViewController.h"

// SOScreenViewManager
//      has a bunch of screenviews

@interface SOScreensContainer ()



@property (strong, nonatomic) CADisplayLink             *displayLink;
@property (strong, nonatomic) NSMutableDictionary       *screenViewControllers;

@property (strong, nonatomic) SOScreenTransport         *transport;
@property (weak, nonatomic) SOCueModel *selectedCueModel;
@property (assign, nonatomic) SOBeaconModel *currentBeaconModel;
@property (strong, nonatomic) SOCameraViewController *cvc;



-(void)onMotionManagerReset:(NSNotification *)notification;



@end

@implementation SOScreensContainer





#pragma mark - Views

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    self.cvc = [[SOCameraViewController alloc] initWithNibName:@"SOCameraViewController" bundle:nil];
    [self.view addSubview:self.cvc.view];

    [self.view sendSubviewToBack:self.cvc.view];
    
    _screenViewControllers = [[NSMutableDictionary alloc] init];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    //motion
    [self addDisplayLink];

    [self addObservers];

    [self addGestures];
    
    CGRect fullFrame = CGRectMake(0.0, 0.0,
                                  self.view.frame.size.height,
                                  self.view.frame.size.width);

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _transport = [sb instantiateViewControllerWithIdentifier:@"transportVCID"];

    if([[NSUserDefaults standardUserDefaults] boolForKey:kLastEditState]){
        [self addChildViewController:self.transport];
        [self.transport.view setFrame:fullFrame];
        [self.transport.view setAlpha:0.5f];
        [self.view addSubview:self.transport.view];
    }

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
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[self tabBarController].tabBar setHidden:NO];
}

-(void)cleanup{
    
    DLog(@"");
    
    // need to destroy player and it's observers
//    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        [(SOScreenViewController*)obj destroyPlayer];
//    }];
    
    [self removeGestures];
    
    [self removeObservers];
    
//    [self removeDisplayLink];

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

-(void)addDisplayLink{
    
    if(self.displayLink==nil){
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }

}

-(void)removeDisplayLink{

    
    if(self.displayLink!=nil)
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = nil;
    

}



-(void)playCue:(SOCueModel*)cueModel{

    
    SOScreenViewController *svc = [[SOScreenViewController alloc] initWithFrame:self.view.bounds];
    [svc setDelegate:self];
    [svc setCueModel:cueModel];

    [self.screenViewControllers setObject:svc forKey:[cueModel title]];
    
    [self.view addSubview:svc.view];

    [self.view bringSubviewToFront:svc.view];
    [self.view bringSubviewToFront:self.transport.view];
    
    if([cueModel.type isEqualToString:@"audio"]){
        [svc.view setHidden:YES];
    }
    
    [self.view sendSubviewToBack:self.cvc.view];

    
    //• kill other cues?
    
//    if(self.screenViewControllers.count > 0){
//        [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//            
//            [obj stopWithcompletionBlock:^{
//                [self.screenViewControllers setObject:svc forKey:[cueModel title]];
//                
//                [self.view addSubview:svc.view];
//                
//                [self.view bringSubviewToFront:self.transport.view];
//            }];
//        }];
//    }else{
//        
//        [self.screenViewControllers setObject:svc forKey:[cueModel title]];
//        
//        [self.view addSubview:svc.view];
//        
//        [self.view bringSubviewToFront:self.transport.view];
//        
//    }

    
}
-(void)stopCue:(SOCueModel*)cueModel{
    
    SOScreenViewController *svc = [self.screenViewControllers objectForKey:cueModel.title];
    
    if(svc){
        [svc stopWithcompletionBlock:^{
            
        }];
    }
}

#pragma mark - Beacon

-(void)triggerBeacon:(SOBeaconModel*)beaconModel{
    
    DLog(@"TRIGGER %d",beaconModel.minor);
    
    self.currentBeaconModel = beaconModel;
//    SOBeaconModel *beacon = [self.modelStore beaconModelWithMinor:minor];
    
    // if we are a movie
    [beaconModel.cues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        __block SOCueModel *cueModel = [self.modelStore cueModelWithTitle:obj];
        DLog(@"cueing %@",cueModel.path);
        
        //• check type
        
        
        float pre_time = [[SOFloatTransformer transformValue:[NSNumber numberWithFloat:cueModel.pre_time]
                                             valWithPropName:@"pre_time"] floatValue];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, pre_time * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self playCue:cueModel];
        });
        
    }];
    
}

#pragma mark - ScreenView Protocol

-(void)onScreenViewPlayerDidBegin:(SOScreenViewController*)svc{
    DLog(@"");
}

-(void)onScreenViewPlayerDidEnd:(SOScreenViewController*)svc{

    [self.screenViewControllers removeObjectForKey:[[svc getCueModel] title]];
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
											 selector:@selector(onTransportBack:)
												 name:kTransportBack
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onTransportForward:)
												 name:kTransportForward
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onTransportStop:)
												 name:kTransportStop
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onTransportNext:)
												 name:kTransportNext
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
                                                    name:kTransportForward
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTransportStop
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTransportBack
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTransportNext
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
    
    [self addDisplayLink];
}
-(void)onEditModeOn:(NSNotification *)notification{


    [self removeDisplayLink];
    
    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        SOScreenViewController *svc = (SOScreenViewController*)obj;
        [svc pause];
    }];

    SOPropertiesViewController *props = [[SOPropertiesViewController alloc] initWithNibName:@"SOPropertiesViewController" bundle:nil];
    
    [props setCueModel:self.selectedCueModel];
    
    [self.view addSubview:props.view];
    
    [self addChildViewController:props];
    props.view.transform = CGAffineTransformMakeTranslation(0.0, 320.0);
    
    [UIView animateWithDuration:0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         props.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                     }
                     completion:nil];
    
}

- (void)onSwipeRight:(UIGestureRecognizer *)gestureRecognizer{
    
    [self cleanup];
    [self.navigationController popViewControllerAnimated:NO];
    
 //   [self dismissViewControllerAnimated:NO completion:nil];
    
}

-(void)onMotionManagerReset:(NSNotification *)notification{
    [[SOMotionManager sharedManager] reset];
}

-(void)onTransportStop:(NSNotification *)notification{
    
    __block int count = 0;
    
    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        [obj stopWithcompletionBlock:^{
           
            count++;
            
            if(count == self.screenViewControllers.count){
                // last one
                
                [self cleanup];
                [self.navigationController popViewControllerAnimated:NO];
                
            }
        }];
    }];


}

-(void)onTransportNext:(NSNotification *)notification{
    
    
    
   // __block SOBeaconModel *beacon = [self.modelStore beaconModelWithMinor:self.currentBeaconModel.minor];
    int nextMinor = self.currentBeaconModel.minor + 1;
    
    
    [self.currentBeaconModel.cues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        __block SOCueModel *cueModel = [self.modelStore cueModelWithTitle:obj];
        
        [[self.screenViewControllers objectForKey:cueModel.title] stopWithcompletionBlock:^{
            
            DLog(@"killing %@",cueModel.title);
            [self.screenViewControllers removeObjectForKey:cueModel.title];
        }];
    
    }];

    
   // [self.mod.beacons valueForKeyPath:@"minor"]
    
    
    [self triggerBeacon:[self.modelStore beaconModelWithMinor:nextMinor]];

    

    
}

-(void)onTransportForward:(NSNotification *)notification{
    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj jumpForward:5.0f];
    }];
}
-(void)onTransportBack:(NSNotification *)notification{
    [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(SOScreenViewController*)obj jumpBack:5.0f];
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
    float yawf = [[SOMotionManager sharedManager] valueForKey:@"yaw"];

//    float pitch = [[SOMotionManager sharedManager] valueForKey:@"pitch"];
//    float heading = [[SOMotionManager sharedManager] valueForKey:@"heading"];

    [self.transport updateAttitudeWithRoll:roll andYaw:yawf];
    
    // hack for picking a current svc by where it's scrollview is positioned
    float threshold = 100.0f;
    self.selectedCueModel = nil;

    if([[NSUserDefaults standardUserDefaults] boolForKey:kLastEditState]){

        [self.screenViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            SOScreenViewController *svc = (SOScreenViewController*)obj;
            
            // don't test for audio cues
            if(![[[svc getCueModel] type] isEqualToString:@"audio"]){
            
                CGRect vr = [svc visibleFrame];
                
                if(vr.origin.x <= threshold && vr.origin.x >= -threshold){
                    [svc setViewIsSelected:YES];
                    self.selectedCueModel = [svc getCueModel];
                }else{
                    [svc setViewIsSelected:NO];
                }
            }
        
        }];
        
        if(self.selectedCueModel != nil){
            [[_transport selectedLabel] setText:[self.selectedCueModel title]];
            [[_transport editButton] setEnabled:YES];
        }else{
            [[_transport selectedLabel] setText:@"-"];
            [[_transport editButton] setEnabled:NO];
        }        
    }
}


@end

