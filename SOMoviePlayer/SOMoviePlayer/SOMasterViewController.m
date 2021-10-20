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
#import "SOCalibrationViewController.h"

#define kMaxAssetImages 5

@interface SOMasterViewController () <CLLocationManagerDelegate>

@property (retain, nonatomic) NSMutableArray *movieFilePaths;
@property (retain, nonatomic) NSMutableArray *thumbNails;

@property (strong, nonatomic) SOModelStore *modelStore;

@property CLLocationManager *locationManager;
@property NSMutableDictionary *rangedRegions;
@property NSMutableDictionary *scenes;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *calibrationButton;



@property (retain, nonatomic) SOCalibrationViewController *calibrationVC;
@end


@implementation SOMasterViewController


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // hide ui
    [self.view setHidden:YES];
    [self.navigationController.view setHidden:YES];
    
    [self updateEditButton];
    
    [self addObservers];

    // get assets and data
    self.movieFilePaths = [NSMutableArray arrayWithArray:[self getAllBundleFilesForTypes:@[@"m4v",@"mov",@"wav"]]];
    _modelStore = [[SOModelStore alloc] init];

    _calibrationVC = [[SOCalibrationViewController alloc] initWithNibName:@"SOCalibrationViewController" bundle:nil];

    
    [[self modelStore] loadCuesWithCompletionBlock:^{
        
        [self.tableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMotionManagerReset object:nil];
        
        // create our screens manager
        SOScreensContainer *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"screenContainer"];
        controller.modelStore = self.modelStore;
        [[controller view] setFrame:CGRectMake(0, 0, 320.0, 568.0)];

        
        
        // start
//        int start = [[self.modelStore.sessionModel valueForKey:@"start"] intValue];
//        [self.navigationController pushViewController:controller animated:NO];
//        [controller triggerScene:[self.modelStore sceneModelWithMinor:start]];

        [self.view setHidden:NO];
        [self.navigationController.view setHidden:NO];

    }];
    
    [self.editButton setTintColor:[UIColor clearColor]];
    [self.calibrationButton setTintColor:[UIColor clearColor]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

}

-(void)onTransportForward:(NSNotification *)notification{
    

}
-(void)onTransportBack:(NSNotification *)notification{
}

-(void)onEditModeOff:(NSNotification *)notification{
    
    [self.modelStore saveLatest];
    
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 160;
}
#pragma mark - Table View


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell.backgroundColor = [UIColor blackColor];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.modelStore.sessionModel.scenes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // get the scene with minor id
    SOSceneModel *scene = [self.modelStore sceneModelWithMinor:(int)indexPath.row+1];
    
    __block NSString *title = @"";
    __block SOMasterViewController *weakSelf = self;
     [scene.cues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         title = [[title stringByAppendingString:[[weakSelf.modelStore cueModelWithTitle:obj] title]] stringByAppendingString:@" | "];
     }];

    NSArray *colors = @[
        [UIColor systemGreenColor],
        [UIColor systemOrangeColor],
        [UIColor systemBlueColor],
       [UIColor systemPinkColor],
       [UIColor systemYellowColor]
    ];
    UIImageView *imageView = [[UIImageView alloc]  initWithImage:[UIImage imageNamed:scene.image]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.alpha = 0.5;
    imageView.clipsToBounds = YES;
    cell.backgroundView = imageView;
    cell.backgroundView.frame = CGRectInset(cell.backgroundView.frame, 0.0f, 10.0f);
    cell.textLabel.textColor = colors[indexPath.row];
    cell.textLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:64];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", scene.title];
    
    UIView *gapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.backgroundView.frame.size.width, 8.0)];
    [gapView setBackgroundColor:[UIColor blackColor]];
    [cell.backgroundView addSubview:gapView];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [[NSNotificationCenter defaultCenter] postNotificationName:kMotionManagerReset object:nil];

    SOScreensContainer *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"screenContainer"];
    controller.modelStore = self.modelStore;
    [self.navigationController pushViewController:controller animated:NO];

    [controller triggerScene:[self.modelStore sceneModelWithMinor:(int)indexPath.row+1]];

}

- (IBAction)onCalibrate:(id)sender {

    
    [self.navigationController presentViewController:self.calibrationVC animated:YES completion:^{
        
    }];

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



@end

