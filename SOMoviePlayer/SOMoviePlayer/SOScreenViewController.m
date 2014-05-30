//
//  SOScreenViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 12/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOScreenViewController.h"

@interface SOScreenViewController ()

@property (strong,nonatomic) AVPlayer *avPlayer;
@property (weak, nonatomic) id playerObserver;
@property (strong, nonatomic) UIScrollView              *scrollView;
@property (weak, nonatomic) AVPlayerLayer *playerLayer;

@property float zoomLevel;


@end

@implementation SOScreenViewController


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super init];
    if (self) {

        
        _zoomLevel = 1.0f;
        
        self.offset = 0.0f;//(arc4random() % 4 / 4.0) * M_PI ;
        DLog(@"%f",self.offset);
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

-(void)dealloc{
    DLog(@"");
    [self destroyPlayer];
}
-(void)resetZoomAt:(float)zoom{

    self.zoomLevel = zoom;
    
    SOScreenView *screenView = [self.scrollView.subviews firstObject];
    
    CGRect fullFrame = CGRectMake(0.0, 0.0,
                                  self.view.bounds.size.width * self.zoomLevel,
                                  self.view.bounds.size.height * self.zoomLevel);
    
    [screenView setFrame:fullFrame];
    [self.playerLayer setFrame:fullFrame];
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    DLog(@"");//••FIX DESTROY
    
//    self.scrollView = nil;
//    [self destroyPlayer];


}
-(void)buildPlayerWithURL:(NSURL*)url{
    
    CGRect fullFrame = CGRectMake(0.0, 0.0,
                                  self.view.bounds.size.height * self.zoomLevel,
                                  self.view.bounds.size.width * self.zoomLevel);
    
    SOScreenView *screenView = [[SOScreenView alloc] initWithFrame:fullFrame];

    // setup avplayer
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    __weak AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    [item addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    _avPlayer = [AVPlayer playerWithPlayerItem:item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    [self.playerLayer setFrame:fullFrame];
    self.playerLayer.opacity = 1.0f;
    [screenView.layer addSublayer:self.playerLayer];
    
    [self.avPlayer setVolume:0.0f];
    [self.avPlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];//loop

    [self.scrollView addSubview:screenView];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avPlayer currentItem]];


    // custom progress of player
    __weak SOScreenViewController *weakSelf = self;
    _playerObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(60, 1000)
                                                queue:dispatch_get_main_queue()
                                           usingBlock:^(CMTime time) {
                                               
                                               float current = CMTimeGetSeconds(time);
                                               float total = CMTimeGetSeconds([item duration]);
                                               float progress = current / total;
                                               //DLog(@"%f %f",current,total);
                                               
                                               if(progress < 0) progress = 0;
                                               
                                               for(SOScreenView *sv in weakSelf.scrollView.subviews){
                                                   
                                                   if([sv isKindOfClass:[SOScreenView class]]){
                                                       [sv setProgress:progress];
                                                   }
                                               }
    }];
    
    
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
    
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([object isKindOfClass:[AVPlayerItem class]]){
        
        AVPlayerItem *item = (AVPlayerItem *)object;
        __weak SOScreenViewController *weakSelf = self;
        if ([keyPath isEqualToString:@"status"]){
            switch(item.status){
                case AVPlayerItemStatusFailed:{
                    DLog(@"player item status failed");
                    }
                    break;
                case AVPlayerItemStatusReadyToPlay:{
                    DLog(@"player item status is ready to play");
                    [self.avPlayer prerollAtRate:1.0f completionHandler:^(BOOL finished) {
                        [weakSelf play];
                        [weakSelf.delegate onScreenViewPlayerDidBegin:self];
                    }];
                    
                    
                    

                    }
                    break;
                case AVPlayerItemStatusUnknown:{
                    DLog(@"player item status is unknown");
                    }
                    break;
            }
        }
    }
}



-(void)play{
    [self.avPlayer play];
    
}


-(void)pause{
    [self.avPlayer pause];
}


-(void)jumpBack{
    
    CMTime current = [self.avPlayer currentTime];
    CMTime jump = CMTimeMakeWithSeconds(5.0f,self.avPlayer.currentTime.timescale);
    CMTime newTime = CMTimeSubtract(current, jump);
    [self.avPlayer seekToTime:newTime];

}
-(void)jumpForward{

    CMTime current = [self.avPlayer currentTime];
    CMTime jump = CMTimeMakeWithSeconds(5.0f,self.avPlayer.currentTime.timescale);
    CMTime newTime = CMTimeAdd(current, jump);
    [self.avPlayer seekToTime:newTime];
}


- (void) moviePlayBackDidFinish:(NSNotification*)notification{
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:AVPlayerItemDidPlayToEndTimeNotification
//                                                  object:[self.avPlayer currentItem]];
//    [self.delegate onScreenViewPlayerDidEnd:self];

    // lets loop movie for now
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    [self.avPlayer play];

    
}

-(void)destroyPlayer{
    

    if(self.playerLayer != nil){
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
    
    
    AVPlayer *avFrontPlayer = self.avPlayer;
    if(self.avPlayer != nil){

        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:avFrontPlayer];

        [self.avPlayer removeTimeObserver:self.playerObserver];
        [self.avPlayer pause];
        self.avPlayer = nil;
    }
    
}
//-(void)setOffset:(float)offset{
//    _offset = offset;
//}
-(void)scrollTo:(CGPoint)pnt{

    DLog(@"%f %f",pnt.x,pnt.y);
    float yawf = pnt.x;
    float roll = pnt.y;
    float xpers = self.view.frame.size.width;
    float ypers = self.view.frame.size.height;
    float xs = 3.0f;
    float ys = 3.0f;
    
    (roll < 0.0f) ? roll *= -1.0f : roll;
    
//    float offsetYaw = 0;//-(M_PI/4);
    float dyaw = yawf + self.offset;
    
    if(dyaw >= M_PI){
        dyaw -= M_PI*2;
    }
    
    yawf = (dyaw / (2.0 * M_PI)) * xs;
    roll = (-roll / (2.0 * M_PI)) * ys;
    
    float offsetx = (xpers * 0.5f * (self.zoomLevel - 1.0));
    float offsety = (ypers * 0.5f * (self.zoomLevel - 1.0));//-60.0f
    xpers = offsetx - (yawf * xpers);
    ypers = offsety + (roll * ypers) + (ypers * 0.25f * ys);
    
//    DLog(@"%f :%f",self.offset,ypers);
    [self.scrollView setContentOffset:(CGPoint){xpers,ypers} animated:NO];
    
}
@end
