//
//  SOMasterViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 17/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOMasterViewController.h"
#import "SONotifications.h"
#import "SOFloatTransformer.h"
#import "SOScreensContainer.h"
#import "SOBeaconsProtocol.h"


#define kMaxAssetImages 5

@interface SOMasterViewController () <CLLocationManagerDelegate>

@property (retain, nonatomic) NSMutableArray *movieFilePaths;
@property (retain, nonatomic) NSMutableArray *thumbNails;

@property (retain, nonatomic) ALAssetsLibrary           *library;
@property (strong, nonatomic) SOModelStore *modelStore;

@property CLLocationManager *locationManager;
@property NSMutableDictionary *rangedRegions;
@property NSMutableDictionary *beacons;
@property NSMutableArray *triggeredBeacons;
@property (nonatomic) int currentBeacon;
@property (strong, nonatomic) SOBeaconViewController *bvc ;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (assign, nonatomic) id<SOBeaconsProtocol> delegate;

@end


@implementation SOMasterViewController


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
//    UIView *splashView = [[UIView alloc] initWithFrame:self.view.frame];
//    [splashView setBackgroundColor:[UIColor blackColor]];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(self.view.frame, 150.0, 100.0)];
//    [label setBackgroundColor:[UIColor blackColor]];
//    [label setTextColor:[UIColor whiteColor]];
//    [label setText:@"loading..."];
//    [splashView addSubview:label];
//    [self.view addSubview:splashView];
//    [self.view bringSubviewToFront:splashView];

    
    [self.view setHidden:YES];
    [self.navigationController.view setHidden:YES];
    
    self.bvc = [[SOBeaconViewController alloc] initWithNibName:@"SOBeaconViewController" bundle:nil];
    self.delegate = self.bvc;

    [self setupBeaconManager];
    
    
    [self updateEditButton];
    
    [self addObservers];

    _thumbNails = [[NSMutableArray alloc] init];
    
//    [self.tableView setRowHeight:88.0];
    
    self.movieFilePaths = [NSMutableArray arrayWithArray:[self getAllBundleFilesForTypes:@[@"m4v",@"mov",@"wav"]]];

    __block NSMutableArray *paths = self.movieFilePaths;
    __block NSMutableArray *thumbs = self.thumbNails;
    __block SOMasterViewController *blockSelf = self;
    
  
    _modelStore = [[SOModelStore alloc] init];

    
    // get lengths
    if(NO){
        NSArray * files = [self getAllBundleFilesForTypes:@[@"m4v"]];
        [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:obj options:nil];
            NSLog(@"%@ %f",[[asset.URL pathComponents] lastObject],CMTimeGetSeconds(asset.duration) );
        }];
    }
    
    [self collectAssetsWithCompletionBlock:^(NSArray *assets){
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMotionManagerReset object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kResetBeacons object:nil];
        
        SOScreensContainer *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"screenContainer"];
        controller.modelStore = self.modelStore;
        
        //**
        // start
        //**
        
        int start = [[self.modelStore.sessionModel valueForKey:@"start"] intValue];

        
        if(YES){ // auto-start
            [self.navigationController pushViewController:controller animated:NO];
            [controller triggerBeacon:[self.modelStore beaconModelWithMinor:start]];
        }

        // collect all the paths
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            // limit assets count : device could have hundreds of movies!
            if(idx > kMaxAssetImages){
                *stop = YES;
            }else{
                NSURL *url = (NSURL*)obj;
                [paths addObject:url];
            }
        }];
        
        // now lets get all the images
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            
            
            [paths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                NSURL *url = (NSURL*)obj;
                AVAsset *asset = [AVAsset assetWithURL:url];
                AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
                [imageGenerator setMaximumSize:(CGSize){90.0,60.0}];
                
                CMTime time = CMTimeMake(1, 1);
                CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                
                
                // need to check if image has been generated
                if(image){
                    [thumbs addObject:[UIImage imageWithCGImage:imageRef]];
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [blockSelf.view setHidden:NO];
                    [blockSelf.navigationController.view setHidden:NO];
                    [blockSelf.tableView reloadData];

                });
            }];
        });
       
        
    }];
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:kLastBeaconRangingState]){
        [self startRangingBeacons];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kResetBeacons object:nil];
   
//    double delayInSeconds = 0.3f;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
//        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
//        
//        
//    });

    

}

-(void)viewDidAppear:(BOOL)animated{
    
//    [self performSegueWithIdentifier:@"showDetail" sender:self];
//    [self addObservers];
 
}

-(void)viewDidDisappear:(BOOL)animated{
//    [self removeObservers];
}
-(void)viewWillAppear:(BOOL)animated{
    
//    [[self navigationController] setNavigationBarHidden:YES animated:YES];
//    [[self tabBarController].tabBar setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Beacons

-(void)setupBeaconManager{
    
    self.currentBeacon = 0;
    
    self.beacons = [[NSMutableDictionary alloc] init];
    
    self.triggeredBeacons = [[NSMutableArray alloc] init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Populate the regions we will range once.
    self.rangedRegions = [[NSMutableDictionary alloc] init];
    
    NSArray *supportedProximityUUIDs = @[[[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"]
                                         ];
    
    for (NSUUID *uuid in supportedProximityUUIDs)
    {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        self.rangedRegions[region] = [NSArray array];
    }
    
}

-(void)startRangingBeacons{
    DLog(@"");
    for (CLBeaconRegion *region in self.rangedRegions){
        [self.locationManager startRangingBeaconsInRegion:region];
    }
 
}
-(void)stopRangingBeacons{
    DLog(@"");
    
    for (CLBeaconRegion *region in self.rangedRegions){
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
    
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

#pragma mark - Notifications

-(void)addObservers{
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onEditModeOff:)
												 name:kEditModeOff
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
											 selector:@selector(onResetBeacons:)
												 name:kResetBeacons
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onBeaconsRangingOn:)
												 name:kBeaconsRangingOn
											   object:nil];

    
}
-(void)removeObservers{

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kEditModeOff
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTransportForward
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTransportBack
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kResetBeacons
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kBeaconsRangingOn
                                                  object:nil];
}

-(void)onTransportForward:(NSNotification *)notification{
    

}
-(void)onTransportBack:(NSNotification *)notification{
}

-(void)onEditModeOff:(NSNotification *)notification{
    
    [self.modelStore saveLatest];
    
}

-(void)onResetBeacons:(NSNotification *)notification{
    
    DLog(@"RESET");
    [self.triggeredBeacons removeAllObjects];
    self.currentBeacon = 0;
    
    [self.delegate currentBeacon:[NSNumber numberWithInt:0]];
    
}

-(void)onBeaconsRangingOn:(NSNotification *)notification{

    UISwitch *sw = (UISwitch*)[notification object];
    
    if(sw.isOn){
        [self startRangingBeacons];
    }else{
        [self stopRangingBeacons];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(sw.isOn)  forKey:kLastBeaconRangingState];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

-(NSArray*)getAllBundleFilesForTypes:(NSArray*)types{
    
    NSError *err = nil;
    
    NSMutableArray *collect = [[NSMutableArray alloc] init] ;
    NSArray *rc = [[NSFileManager defaultManager]
                   contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:&err];
    
    if(err){
        NSLog(@"%@ : %@ : %@",
              [err localizedFailureReason],
              [err localizedDescription],
              [err localizedRecoverySuggestion]);
    }
    
    // get all files with correct extensions
    for(NSString *title in [rc pathsMatchingExtensions:types]){
        NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:title];
        [collect addObject:[NSURL fileURLWithPath:path]];
    }
    
    return collect;
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.modelStore.sessionModel.beacons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // get the beacon with minor id
    SOBeaconModel *beacon = [self.modelStore beaconModelWithMinor:(int)indexPath.row+1];
    
    __block NSString *title = @"";
    __block SOMasterViewController *weakSelf = self;
     [beacon.cues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         title = [[title stringByAppendingString:[[weakSelf.modelStore cueModelWithTitle:obj] title]] stringByAppendingString:@" | "];
     }];
        
    cell.textLabel.text = [NSString stringWithFormat:@"Chapter %d  :  %@",
                           beacon.minor,
                           title
                           ];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [[NSNotificationCenter defaultCenter] postNotificationName:kMotionManagerReset object:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:kResetBeacons object:nil];

    SOScreensContainer *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"screenContainer"];
    controller.modelStore = self.modelStore;
    [self.navigationController pushViewController:controller animated:NO];

//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    NSString *text = cell.textLabel.text;
//    NSRange range = [text rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
//    NSString *digit = [text substringWithRange:range];
    [controller triggerBeacon:[self.modelStore beaconModelWithMinor:(int)indexPath.row+1]];

}

-(void)collectAssetsWithCompletionBlock:(void(^)(NSArray*))completionBlock{
    
    _library = [[ALAssetsLibrary alloc] init];
    __block NSMutableArray *assets = [NSMutableArray array];
    
    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                usingBlock:^(ALAssetsGroup *group, BOOL *stop){
                                    
                                    ALAssetsFilter *allVideosFilter = [ALAssetsFilter allVideos];
                                    [group setAssetsFilter:allVideosFilter];
                                    
                                    [group enumerateAssetsUsingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop){
                                        
                                        if (alAsset){
                                            ALAssetRepresentation *representation =[alAsset defaultRepresentation];
                                            NSURL *url = [representation url];
                                            [assets addObject:url];
                                        }else{
                                            completionBlock(assets);
                                        }
                                    }];
                                }
                              failureBlock:^(NSError *error){
                                  
                              }];
}
- (IBAction)onBeacon:(id)sender {

    [self presentViewController:self.bvc animated:YES completion:nil];

}
- (IBAction)onEdit:(id)sender {
    
    BOOL state = ![[NSUserDefaults standardUserDefaults] boolForKey:kLastEditState];

    [[NSUserDefaults standardUserDefaults] setObject:@(state)  forKey:kLastEditState];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateEditButton];
}

-(void)updateEditButton{

    BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:kLastEditState];
    
    if(state){
        self.navigationController.navigationBar.topItem.rightBarButtonItem.title = @"Edit Mode ON";
        self.navigationController.navigationBar.topItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.0 green:183.0/255.0 blue:122.0/255.0 alpha:1.0];
    }else{
        self.navigationController.navigationBar.topItem.rightBarButtonItem.title = @"Edit Mode OFF";
        self.navigationController.navigationBar.topItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];

    }

}
#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    
    
    self.rangedRegions[region] = beacons;
    [self.beacons removeAllObjects];
    
    NSMutableArray *allBeacons = [NSMutableArray array];
    NSMutableArray *cleanBeacons = [NSMutableArray array];
    
    for (NSArray *regionResult in [self.rangedRegions allValues])
    {
        [allBeacons addObjectsFromArray:regionResult];
        
    }
    
    [allBeacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    
        
        CLBeacon *beacon = (CLBeacon*)obj;
        
        
        NSString *s = [NSString stringWithFormat:@"Minor : %@  Prox : %d  Rssi : %d",
                                    [beacon minor],
                                   [beacon proximity],
                       [beacon rssi]];
        
        [cleanBeacons addObject:s];
        
           
        
    }];
    
    if(self.delegate){
        if([self.delegate respondsToSelector:@selector(currentBeacons:)]){
            [self.delegate currentBeacons:cleanBeacons];
            
        }
    
    }
    

    
    NSSortDescriptor *rssiSD = [NSSortDescriptor sortDescriptorWithKey: @"rssi" ascending: NO];
    NSArray *closest = [allBeacons sortedArrayUsingDescriptors:@[rssiSD]];
    CLBeacon *beacon = [closest firstObject];
    NSNumber *closestMinor = beacon.minor;
    CLLocationAccuracy distance = beacon.accuracy;
    CLProximity prox = beacon.proximity;
    NSString *proxStr = @"-";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *proxs = @[@"unknown",@"Immediate",@"Near",@"Far"];
    proxStr = proxs[prox];
    
    if(closestMinor != NULL){
        
        if([self.triggeredBeacons indexOfObject:closestMinor] == NSNotFound){
            
            if(distance > 0.0f){

                if(prox == CLProximityFar || prox == CLProximityNear){
                    
                    // must be NEXT minor
                   // if([closestMinor intValue] == self.currentBeacon + 1){
                    
                    SOBeaconModel *beaconModel = [self.modelStore beaconModelWithMinor:[closestMinor intValue]];

                    if(beaconModel.prox >= prox){
                        
                        self.currentBeacon = [closestMinor intValue];
                        
                        [self.triggeredBeacons addObject:closestMinor];
                        
                        NSLog(@"TRIGGER %@",closestMinor);
                        
                        [self.delegate currentBeacon:closestMinor];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTransportCue object:closestMinor];
                        
                        
                        //SOCueModel *cm = [self.modelStore cueModelAtIndex:self.currentBeacon];

                    }
                    
                        
                                          
                  //  }
                }
            }
        }else{
            
        }
        
        
    }else{
        
        
    }
    
}





@end

