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


    
    //• loop thru
    
        //• new float prop vc : title = prop name
    
        //• setValueBlock
    
            //• setCueValue:val withKey:prop name
    
    NSArray *props = [SOModelStore arrayOfFloatPropertiesForClass:[SOCueModel class]];
    
    [props enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        
        NSString *propName = (NSString*)obj;
        
        DLog(@"%@",propName);
        
        SOFloatPropViewController *propVC = [[SOFloatPropViewController alloc] initWithNibName:@"SOFloatPropViewController"
                                                                                     withTitle:propName
                                                                                       atPoint:(CGPoint){0.0f,100.0f + (90.0f * idx )}];
//        [propVC setValueDidChangeBlock:^float(float val) {
//            
        //
//            return result;
//        }];
        
        [self.contentView addSubview:propVC.view];
        [self addChildViewController:propVC];
    
     }];
    
//    float value = ((offset * 2.0f) - 1.0f) * M_PI;// -M_PI..M_PI

    NSString *formula = @"((val * 2.0) - 1.0) * pi";//@"(val * 180.0 * 2.0) - 180.0";
    
    NSExpression *expr = [NSExpression expressionWithFormat:formula];
    NSDictionary *object = @{
                             @"val": @0.5,
                             @"pi": @(M_PI)
                             };
    
    
    
    float result = [[expr expressionValueWithObject:object context:nil] floatValue];
    
    DLog(@"%f",result);

    
    
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
