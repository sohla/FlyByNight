//
//  SOMasterViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 17/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOMasterViewController.h"
#import "SONotifications.h"

#import "SOScreensContainer.h"


#define kMaxAssetImages 5

@interface SOMasterViewController ()
    
@property (retain, nonatomic) NSMutableArray *movieFilePaths;
@property (retain, nonatomic) NSMutableArray *thumbNails;

@property (retain, nonatomic) ALAssetsLibrary           *library;

@property (strong, nonatomic) SOModelStore *modelStore;


@end


@implementation SOMasterViewController


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addObservers];

    _thumbNails = [[NSMutableArray alloc] init];
    
    [self.tableView setRowHeight:88.0];
    
    self.movieFilePaths = [NSMutableArray arrayWithArray:[self getAllBundleFilesForTypes:@[@"m4v",@"mov"]]];

    __block NSMutableArray *paths = self.movieFilePaths;
    __block NSMutableArray *thumbs = self.thumbNails;
    __block SOMasterViewController *blockSelf = self;
    
  
    _modelStore = [[SOModelStore alloc] init];

//    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
//    [self.modelStore loadJSONCuesWithPath:path completionBlock:^(NSError *error) {
//        
//        if(error){
//            NSLog(@"%@",error.localizedDescription);
//        }
//    }];

    
    [self collectAssetsWithCompletionBlock:^(NSArray *assets){
        
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
                    [blockSelf.tableView reloadData];
                });
            }];
        });
       
        
    }];
    

}

-(void)viewDidAppear:(BOOL)animated{
    
//    [self performSegueWithIdentifier:@"showDetail" sender:self];
//    [self addObservers];
 
    
}

-(void)viewDidDisappear:(BOOL)animated{
//    [self removeObservers];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [[self tabBarController].tabBar setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modelStore.sessionModel.cues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

//    __block NSURL *url = self.movieFilePaths[indexPath.row] ;
//    NSString *title = [[url relativeString] lastPathComponent];
//    cell.textLabel.text = title;
//    
//    if(indexPath.row < self.thumbNails.count){
//        cell.imageView.image = self.thumbNails[indexPath.row];
//    }else{
//        cell.imageView.image = [UIImage imageNamed:@"default.png"];
//    }
    
    cell.textLabel.text = [[self.modelStore cueModelAtIndex:indexPath.row] title];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    __block SOScreensContainer *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"screenContainer"];

    __block SOCueModel *cueModel = [self.modelStore cueModelAtIndex:[indexPath row]];
   // [controller addScreenWithCue:cueModel];

    [self.navigationController pushViewController:controller animated:YES];


    __weak SOMasterViewController *weakSelf = self;
//    cueModel = [weakSelf.modelStore cueModelAtIndex:[indexPath row] + 1];
//    [controller addScreenWithCue:cueModel];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [controller addScreenWithCue:cueModel];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        cueModel = [weakSelf.modelStore cueModelAtIndex:[indexPath row]  + 1 ];
        [controller addScreenWithCue:cueModel];
    });

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



@end
