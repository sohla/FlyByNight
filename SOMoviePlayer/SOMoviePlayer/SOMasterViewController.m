//
//  SOMasterViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 17/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOMasterViewController.h"

#import "SODetailViewController.h"

@interface SOMasterViewController ()
    
@property (retain, nonatomic) NSMutableArray *movieFilePaths;
@property (retain, nonatomic) NSMutableArray *thumbNails;

@property (retain, nonatomic) ALAssetsLibrary           *library;
@end


@implementation SOMasterViewController


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _thumbNails = [NSMutableArray array];
    
    [self.tableView setRowHeight:88.0];
    
    self.movieFilePaths = [NSMutableArray arrayWithArray:[self getAllBundleFilesForTypes:@[@"m4v",@"mov"]]];

    __block NSMutableArray *paths = self.movieFilePaths;
    __block NSMutableArray *thumbs = self.thumbNails;

    [self collectAssetsWithCompletionBlock:^(NSArray *assets){
    
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            
            NSURL *url = (NSURL*)obj;
            [paths addObject:url];
            
        }];

        // now lets get all the images
        
//        [paths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
//        
//            NSURL *url = (NSURL*)obj;
//            
//            AVAsset *asset = [AVAsset assetWithURL:url];
//            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
//            CMTime time = CMTimeMake(1, 1);
//            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
//            [thumbs addObject:[UIImage imageWithCGImage:imageRef]];
//
//        }];
//        
        [self.tableView reloadData];

    }];

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSURL *url = self.movieFilePaths[indexPath.row] ;
    NSString *title = [[url relativeString] lastPathComponent];
    cell.textLabel.text = title;
    
    
    if(self.thumbNails.count){
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
        NSURL *pathA = self.movieFilePaths[indexPath.row];
        NSURL *pathB = self.movieFilePaths[indexPath.row];

        if(indexPath.row < self.movieFilePaths.count - 1){
            pathB = self.movieFilePaths[indexPath.row + 1];
        }
        
        
        [[segue destinationViewController] setMovieFilePathA:pathA pathB:pathB];
        
        
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


@end
