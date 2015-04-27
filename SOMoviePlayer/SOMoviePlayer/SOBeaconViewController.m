//
//  SOBeaconViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 27/07/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOBeaconViewController.h"
#import "SONotifications.h"


@interface SOBeaconViewController ()

@property (weak, nonatomic) IBOutlet UILabel *currentCueLabel;
@property (strong, nonatomic) CADisplayLink             *displayLink;
@property (weak, nonatomic) IBOutlet UILabel *beaconsLabel;

@property (weak, nonatomic) IBOutlet UISwitch *beaconButton;
@end

@implementation SOBeaconViewController

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
    if([[NSUserDefaults standardUserDefaults] boolForKey:kLastBeaconRangingState]){
        [self.beaconButton setOn:YES];
    }else{
        [self.beaconButton setOn:NO];

    }


    [self addDisplayLink];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
#pragma mark - Motion Refresher

- (void)onDisplayLink:(id)sender {
    
//    DLog(@"%@",[self.delegate cu
}


#pragma mark - SOBeaconsProtocol

-(void)currentBeacons:(NSArray *)beacons{
    self.beaconsLabel.numberOfLines = 0;
    self.beaconsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.beaconsLabel.text = [NSString stringWithFormat:@"%@",beacons];
}

-(void)currentBeacon:(NSNumber*)minor{
    self.currentCueLabel.text = [NSString stringWithFormat:@"current minor : %@",minor];
    
}


#pragma mark - UI



- (IBAction)onReset:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kResetBeacons object:nil];
}
- (IBAction)onBeaconButton:(UISwitch*)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kBeaconsRangingOn object:sender];
}

- (IBAction)onExit:(id)sender {

    [self removeDisplayLink];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
