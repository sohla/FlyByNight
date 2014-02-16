//
//  SODetailViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 17/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SODetailViewController.h"

@interface SODetailViewController ()

@property (retain,nonatomic) MPMoviePlayerController *player;

@end

@implementation SODetailViewController


#pragma mark - Managing the detail item

- (void)configureView{

    NSURL *url  = [NSURL fileURLWithPath:self.movieFilePath];
    self.player = [[MPMoviePlayerController alloc] initWithContentURL: url];
    [self.player setControlStyle:MPMovieControlStyleNone];
    [self.player setScalingMode:MPMovieScalingModeAspectFit];
    [self.player prepareToPlay];
    [self.player setFullscreen:YES animated:YES];

    [self addObservers];
    
    // flip it to landscape ratio
    self.player.view.frame = CGRectMake(0.0, 0.0,
                                        self.view.bounds.size.height,
                                        self.view.bounds.size.width);
    
    [self.view addSubview:self.player.view];


    [self.player play];
}

-(void)addObservers{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.player];

}
-(void)removeObservers{

    MPMoviePlayerController *player = self.player;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:player];



}
-(void)setMovieFilePath:(NSString *)movieFilePath{
    
    if (_movieFilePath != movieFilePath) {
        _movieFilePath = movieFilePath;
        
        // Update the view.
        [self configureView];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self removeObservers];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Notifications

- (void) moviePlayBackDidFinish:(NSNotification*)notification{
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end

