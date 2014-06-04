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
//@property (strong, nonatomic) SOFloatPropViewController *
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


    SOFloatPropViewController *propVC = [[SOFloatPropViewController alloc] initWithNibName:@"SOFloatPropViewController"
                                                                                 withTitle:@"x_axis"
                                                                                   atPoint:(CGPoint){0.0f,100.0f}];
    [propVC setValueDidChangeBlock:^float(float val) {
        
        NSString *formula = @"(val * 180.0 * 2.0) - 180.0";
        
        NSExpression *expr = [NSExpression expressionWithFormat:formula];
        NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithFloat:val], @"val", nil];
        
        float result = [[expr expressionValueWithObject:object context:nil] floatValue];

        return result;
    }];

    [self.contentView addSubview:propVC.view];
    [self addChildViewController:propVC];
    
    
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

    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kEditModeOff object:nil];
        
    }];
    

}

@end
