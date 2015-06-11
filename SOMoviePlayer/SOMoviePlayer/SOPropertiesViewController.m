//
//  SOPropertiesViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 3/06/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOPropertiesViewController.h"
#import "SONotifications.h"
#import <AVFoundation/AVFoundation.h>

#import "SOFloatPropViewController.h"
#import "SOFloatTransformer.h"

@interface SOPropertiesViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *assetLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;

@end

@implementation SOPropertiesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.alpha = 0.9;
    [self.scrollView setContentSize:self.contentView.frame.size];
    [self.scrollView addSubview:self.contentView];

    [self.titleLabel setText:[NSString stringWithFormat:@"Title : %@",[self.cueModel title]]];
    [self.assetLabel setText:[NSString stringWithFormat:@"Path : %@",[self.cueModel path]]];
    
    NSString *path = [self.cueModel path];
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:[path stringByDeletingPathExtension]
                                                         ofType:[path pathExtension]];
    NSURL *sourceMovieURL = [NSURL fileURLWithPath:fullPath];
    AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
    [self.lengthLabel setText:[NSString stringWithFormat:@"Length : %.2f",CMTimeGetSeconds(sourceAsset.duration)]];
    
    //• loop thru
    
        //• new float prop vc : title = prop name
    
        //• setValueBlock
    
            //• setCueValue:val withKey:prop name
    
    NSArray *props = [SOModelStore arrayOfFloatPropertiesForClass:[SOCueModel class]];
    
    [props enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        
        NSString *propName = (NSString*)obj;
        
        SOFloatPropViewController *propVC = [[SOFloatPropViewController alloc] initWithNibName:@"SOFloatPropViewController"
                                                                                     withTitle:propName
                                                                                       atPoint:(CGPoint){0.0f,100.0f + (70.0f * idx )}];

        
//        propVC.view.bounds = self.view.bounds;
        // set the ui
        NSNumber *val= [self.cueModel valueForKey:propName];
        [propVC setValue:[val floatValue]];
        
        [propVC setValueDidChangeBlock:^float(float val) {

            [self.cueModel setValue:[NSNumber numberWithFloat:val] forKey:propName];
            
            NSNumber *uiVal = [SOFloatTransformer transformValue:[NSNumber numberWithFloat:val] valWithPropName:propName];
           return [uiVal floatValue];
        }];
        [self.contentView addSubview:propVC.view];
        [self addChildViewController:propVC];
    
     }];
    

    
    
}


/*
x = (y * 180.0 * 2.0) - 180.0
 
y = (x + 180.0) / (180.0 * 2.0)
 
 
 
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onExit:(UIButton *)sender {

    self.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    
    [UIView animateWithDuration:0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.transform = CGAffineTransformMakeTranslation(0.0, 320.0);
                     }
                     completion:^(BOOL  complete){
                         [self.view removeFromSuperview];
                         [self removeFromParentViewController];
                         
                         [[NSNotificationCenter defaultCenter] postNotificationName:kEditModeOff object:nil];

                     }];
}
- (IBAction)onResetMotion:(UIButton *)sender {
//    [[NSNotificationCenter defaultCenter] postNotificationName:kMotionManagerReset object:nil];
}

@end
