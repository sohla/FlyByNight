//
//  SOMasterViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 17/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOMasterViewController.h"

#import "SODetailViewController.h"


#define kMaxAssetImages 5
#define kBGQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface SOMasterViewController ()
    
@property (retain, nonatomic) NSMutableArray *movieFilePaths;
@property (retain, nonatomic) NSMutableArray *thumbNails;

@property (retain, nonatomic) ALAssetsLibrary           *library;

@property (nonatomic, strong)   NSDictionary *cuesStore;


@end


@implementation SOMasterViewController


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    
    [self loadJSONCuesWithPath:path completionBlock:^(NSError *error) {
        
        if(error){
            NSLog(@"%@",error.localizedDescription);
        }
    }];

    _thumbNails = [[NSMutableArray alloc] init];
    
    [self.tableView setRowHeight:88.0];
    
    self.movieFilePaths = [NSMutableArray arrayWithArray:[self getAllBundleFilesForTypes:@[@"m4v",@"mov"]]];

    __block NSMutableArray *paths = self.movieFilePaths;
    __block NSMutableArray *thumbs = self.thumbNails;
    __block SOMasterViewController *blockSelf = self;
    
    
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
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return self.movieFilePaths.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    __block NSURL *url = self.movieFilePaths[indexPath.row] ;
    NSString *title = [[url relativeString] lastPathComponent];
    cell.textLabel.text = title;
    
    if(indexPath.row < self.thumbNails.count){
        cell.imageView.image = self.thumbNails[indexPath.row];
    }else{
        cell.imageView.image = [UIImage imageNamed:@"default.png"];
    }
    return cell;
}
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        //• pass in cue model 
        NSURL *url = self.movieFilePaths[indexPath.row];
        [[segue destinationViewController] addScreenWithURL:url];
        NSURL *urlb = self.movieFilePaths[indexPath.row + 1];
        [[segue destinationViewController] addScreenWithURL:urlb];
    }
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


-(void)loadJSONCuesWithPath:(NSString*)path completionBlock:(void (^)(NSError *error)) block{
    
    
    NSURL *url = [NSURL fileURLWithPath:path];
    dispatch_async(kBGQueue, ^{
        
        NSError *err;
        NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&err];
        
        if(err){
            block(err);
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //parse out the json data and store
                NSError *error;
                _cuesStore = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&error];
                
                if(error)
                    block(error);
  
                
                DLog(@"%@",self.cuesStore);

                DLog(@"%@",self.cuesStore[@"cues"][0][@"title"]);

//                [self buildStates];
            });
        }
        
    });
}


@end
