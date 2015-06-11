//
//  SOFloatPropViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 3/06/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOFloatPropViewController.h"

@interface SOFloatPropViewController ()
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@end

@implementation SOFloatPropViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil withTitle:(NSString*)title atPoint:(CGPoint)pnt{

    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        [self setTitle:title];
        [self.view setFrame:CGRectOffset(self.view.frame, pnt.x, pnt.y)];
        [self.slider.layer setCornerRadius:self.slider.frame.size.height/2.0];

    }
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    [self.titleLabel setText:[self title]];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [self onSliderChanged:self.slider];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setValue:(float)value{
    [self.slider setValue:value];
//    [self onSliderChanged:self.slider];
    
}

- (IBAction)onSliderChanged:(UISlider *)sender {
    
    if(self.valueDidChangeBlock != nil){
        float vl = self.valueDidChangeBlock([sender value]);
        [self.valueLabel setText:[NSString stringWithFormat:@"%.2f | %.2f",vl,[sender value]]];
    }
}


@end
