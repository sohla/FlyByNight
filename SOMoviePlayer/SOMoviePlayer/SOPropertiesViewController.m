//
//  SOPropertiesViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 3/06/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOPropertiesViewController.h"
#import "SONotifications.h"

#import "SOFloatPropViewController.h"

@interface SOPropertiesViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIView *contentView;
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
    
    [self.scrollView setContentSize:self.contentView.frame.size];
    
    [self.scrollView addSubview:self.contentView];


    SOFloatPropViewController *propVC = [[SOFloatPropViewController alloc] initWithNibName:@"SOFloatPropViewController" bundle:nil];
    
    [self.contentView addSubview:propVC.view];
    [propVC.view setFrame:CGRectOffset(propVC.view.frame, 0.0f, 100.0f)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onExit:(UIButton *)sender {

    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kEditModeOff object:nil];
        
    }];
    

}

@end
