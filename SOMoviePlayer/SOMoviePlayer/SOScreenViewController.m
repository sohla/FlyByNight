//
//  SOScreenViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 12/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOScreenViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface SOScreenViewController ()

@property (weak,nonatomic) AVPlayer *avPlayer;
@property float zoomLevel;
@property (weak, nonatomic) id playerObserver;
@property (retain, nonatomic) UIScrollView              *scrollView;

@end

@implementation SOScreenViewController


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super init];
    if (self) {

        
        _zoomLevel = 1.2f;
        
        CGRect fullFrame = CGRectMake(0.0, 0.0,
                                      frame.size.height,
                                      frame.size.width);

        _scrollView = [[UIScrollView alloc] initWithFrame:fullFrame];
        [self.view addSubview:self.scrollView];
        
        CGRect contentFrame = CGRectMake(0.0, 0.0,
                                    frame.size.height * 2.0f,
                                    frame.size.width * 2.0f);

        [self.scrollView setContentSize:contentFrame.size];
        [self.scrollView setContentOffset:self.scrollView.center animated:NO];
        [self.scrollView setBackgroundColor:[UIColor darkGrayColor]];
        [self.scrollView setScrollEnabled:NO];
        
    }
    return self;
}

-(void)buildPlayerWithURL:(NSURL*)url{
    
    CGRect fullFrame = CGRectMake(0.0, 0.0,
                                  self.view.bounds.size.height * self.zoomLevel,
                                  self.view.bounds.size.width * self.zoomLevel);
    
    
    [self.scrollView addSubview:[[SOScreenView alloc] initWithFrame:fullFrame]];

    // setup avplayer
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    _avPlayer = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
    AVPlayerLayer *frontLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    [frontLayer setFrame:fullFrame];
    frontLayer.opacity = 0.1f;
    //[self.view.layer addSublayer:frontLayer];
    
    // fade in example
    //    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    //    flash.fromValue = [NSNumber numberWithFloat:0.0];
    //    flash.toValue = [NSNumber numberWithFloat:1.0];
    //    flash.duration = 5.0;        // 1 second
    //    flash.autoreverses = NO;    // Back
    //    flash.repeatCount = 0;       // Or whatever
    //
    //    [frontLayer addAnimation:flash forKey:@"fadeIn"];
    
    
//    // add boundry observer
//    CMTime duration = self.avPlayer.currentItem.asset.duration;
//    Float64 durationInSeconds = CMTimeGetSeconds(duration);
//    
//    NSArray *times = @[[NSValue valueWithCMTime:CMTimeMakeWithSeconds(5.0f, self.avPlayer.currentTime.timescale)]];
//    //    __weak SODetailViewController *weakSelf = self;
//    //    [self.avFrontPlayer addBoundaryTimeObserverForTimes:times queue:NULL usingBlock:^(){
//    //        NSLog(@"%f",durationInSeconds);
//    //        //[weakSelf.avFrontPlayer pause];
//    //    }];
//    
//    times = @[[NSValue valueWithCMTime:CMTimeMakeWithSeconds(durationInSeconds - 5.0f, self.avPlayer.currentTime.timescale)]];
//    _playerObserver = [self.avPlayer addBoundaryTimeObserverForTimes:times queue:NULL usingBlock:^(){
//        NSLog(@"fadeOut");
//        CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        flash.fromValue = [NSNumber numberWithFloat:1.0];
//        flash.toValue = [NSNumber numberWithFloat:0.0];
//        flash.duration = 5.0;
//        flash.autoreverses = NO;
//        flash.repeatCount = 0;
//        
//        [frontLayer addAnimation:flash forKey:@"fadeOut"];
//    }];
    
    
    [self play];
    
    
}


-(void)play{
    [self.avPlayer play];
    
}


-(void)pause{
    [self.avPlayer pause];
}
//
//
//[[NSNotificationCenter defaultCenter] addObserver:self
//                                         selector:@selector(moviePlayBackDidFinish:)
//                                             name:AVPlayerItemDidPlayToEndTimeNotification
//                                           object:[self.avPlayer currentItem]];
//
//AVPlayer *avFrontPlayer = self.avPlayer;
//
//[[NSNotificationCenter defaultCenter] removeObserver:self
//                                                name:AVPlayerItemDidPlayToEndTimeNotification
//                                              object:avFrontPlayer];

- (void) moviePlayBackDidFinish:(NSNotification*)notification{
    
    
    //    [self.avFrontPlayer seekToTime:kCMTimeZero];
    //    [self.avBackPlayer seekToTime:kCMTimeZero];
    //    [self.avFrontPlayer play];
    //    [self.avBackPlayer play];
    
}

-(void)destroyPlayer{
    
    [self.avPlayer removeTimeObserver:self.playerObserver];
    [self.avPlayer pause];
    self.avPlayer = nil;
    
}
-(void)scrollTo:(CGPoint)pnt{

    float yawf = pnt.x;
    float roll = pnt.y;
    float xpers = self.view.frame.size.width;
    float ypers = self.view.frame.size.height;
    float xs = 3.0f;
    float ys = 3.0f;
    
    (roll < 0.0f) ? roll *= -1.0f : roll;
    
    float offsetYaw = 0;
    float dyaw = yawf+offsetYaw;
    
    if(dyaw >= M_PI){
        dyaw -= M_PI*2;
    }
    
    yawf = (dyaw / (2.0 * M_PI)) * xs;
    roll = (-roll / (2.0 * M_PI)) * ys;
    
    float offsetx = (xpers * 0.5f * (self.zoomLevel - 1.0));
    float offsety = (ypers * 0.5f * (self.zoomLevel - 1.0));
    xpers = offsetx - (yawf * xpers);
    ypers = offsety + (roll * ypers) + (ypers * 0.25f * ys);
    
    [self.scrollView setContentOffset:(CGPoint){xpers,ypers} animated:NO];
    
}
@end
