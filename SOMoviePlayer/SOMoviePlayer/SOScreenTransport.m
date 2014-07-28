//
//  SOScreenTransport.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 30/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOScreenTransport.h"

@interface SOScreenTransport ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UILabel *attitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *beaconLabel;


@end

@implementation SOScreenTransport

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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBackButton:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTransportBack object:sender];

}
- (IBAction)onForwardButton:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTransportForward object:sender];
}
- (IBAction)onStopButton:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTransportStop object:sender];
}
- (IBAction)onNextButton:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTransportNext object:sender];
}

-(void)updateAttitudeWithRoll:(float)roll andYaw:(float)yaw{
    self.attitudeLabel.text = [NSString stringWithFormat:@"roll %.2f yaw %.2f",roll,yaw];
}

-(IBAction)onEditButton:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:kEditModeOn object:nil];

}

-(void)currentBeacons:(NSArray*)beacons{
    
}
-(void)currentBeacon:(NSNumber*)minor{
    self.beaconLabel.text = [minor description];
}


@end
