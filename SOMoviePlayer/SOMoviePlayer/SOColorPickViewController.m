//
//  SOColorPickViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 18/08/2015.
//  Copyright (c) 2015 Stephen OHara. All rights reserved.
//

#import "SOColorPickViewController.h"

@interface SOColorPickViewController ()

@end

@implementation SOColorPickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view setBackgroundColor:[UIColor blueColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    [self.view setBackgroundColor:
     [UIColor colorWithHue:(point.x / self.view.frame.size.width)
                saturation:(point.y / self.view.frame.size.height)
                brightness:1.0
                     alpha:1.0]];
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    [self.view setBackgroundColor:
     [UIColor colorWithHue:(point.x / self.view.frame.size.width)
                saturation:(point.y / self.view.frame.size.height)
                brightness:1.0
                     alpha:1.0]];

}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
@end
