//
//  SOSettingsViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 23/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOSettingsViewController.h"
#import "SONotifications.h"

@interface SOSettingsViewController ()
- (IBAction)onResetUp:(id)sender;

@end

@implementation SOSettingsViewController

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
	// Do any additional setup after loading the view.
    NSLog(@"R");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onResetUp:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kMotionManagerReset object:nil];

}
@end
