//
//  SOCalibrationViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 5/07/2015.
//  Copyright (c) 2015 Stephen OHara. All rights reserved.
//

#import "SOCalibrationViewController.h"

@interface SOCalibrationViewController ()

@property (strong, nonatomic) CADisplayLink             *displayLink;
@property (strong, nonatomic) UIView    *calibrationView;
@property (weak, nonatomic) IBOutlet UILabel *calibrationLabel;

@end

@implementation SOCalibrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGRect rect = CGRectMake(0.0, 0.0, 1.0, 200.0);
    _calibrationView = [[UIView alloc] initWithFrame:rect];
    [self.calibrationView setBackgroundColor:[UIColor greenColor]];
    
    [self.view addSubview:self.calibrationView];

}

-(void)viewDidAppear:(BOOL)animated{
    [self addDisplayLink];
    
    [super viewDidAppear:animated];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [self removeDisplayLink];
    
    [super viewDidDisappear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onExit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
- (IBAction)onReset:(id)sender {
    [[SOMotionManager sharedManager] reset];
}

-(void)addDisplayLink{
    
    if(self.displayLink==nil){
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
}

-(void)removeDisplayLink{
    
    if(self.displayLink!=nil)
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.displayLink = nil;
}


- (void)onDisplayLink:(id)sender {
    
    float yawf = [[SOMotionManager sharedManager] valueForKey:@"yaw"];
    float xpers = 568.0f;
    float yawX = (xpers/2.0) + (yawf / (2.0 * M_PI)) * xpers;
    
    self.calibrationView.center = CGPointMake(yawX, 0);

    NSString *str = [NSString stringWithFormat:@"%.2f ˚",(yawf / (2.0 * M_PI)) * 360.0 ];
    [self.calibrationLabel setText:str];
}

@end
