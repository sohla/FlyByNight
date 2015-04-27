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
@property (weak, nonatomic) IBOutlet UILabel *batteryLevel;

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
    
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryLevelChanged:)
                                                 name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryStateChanged:)
                                                 name:UIDeviceBatteryStateDidChangeNotification object:nil];
    
    
    [self updateBatteryLevel];
}

- (void)batteryLevelChanged:(NSNotification *)notification
{
    [self updateBatteryLevel];
}

- (void)batteryStateChanged:(NSNotification *)notification
{
    [self updateBatteryLevel];
    [self updateBatteryState];
}
- (void)updateBatteryLevel
{
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    if (batteryLevel < 0.0) {
        // -1.0 means battery state is UIDeviceBatteryStateUnknown
        self.batteryLevel.text = NSLocalizedString(@"Unknown", @"");
    }
    else {
        static NSNumberFormatter *numberFormatter = nil;
        if (numberFormatter == nil) {
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
            [numberFormatter setMaximumFractionDigits:1];
        }
        
        NSNumber *levelObj = [NSNumber numberWithFloat:batteryLevel];
        NSString *levelStr = [numberFormatter stringFromNumber:levelObj];
        self.batteryLevel.text = [NSString stringWithFormat:@"Batt : %@",levelStr];
    }
}

- (void)updateBatteryState{
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
