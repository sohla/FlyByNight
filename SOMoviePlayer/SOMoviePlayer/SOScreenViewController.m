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
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@property (strong, nonatomic) id periodicObserver;
@property (strong, nonatomic) id fadeInObserver;
@property (strong, nonatomic) id fadeOutObserver;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (assign, nonatomic) SOCueModel *cueModel;



@end

@implementation SOScreenViewController


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super init];
    if (self) {

        
//        self.offset = 0.0f;//(arc4random() % 4 / 4.0) * M_PI ;
//        DLog(@"%f",self.offset);
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

-(void)resetOffsetX:(float)offset{

    float value = ((offset * 2.0f) - 1.0f) * M_PI;// -M_PI..M_PI
    [self.cueModel setOffset_x:value];
    
    
 //•   [self.cueModel setValue:[NSNumber numberWithFloat:value] forKey:@"offset_x"];
    
}


-(void)resetZoomAt:(float)zoom{

    float z = 0.5 + (zoom * 1.5f); // 0.5..2.0

    //[self.cueModel setZoom:z];
    
    SOScreenView *screenView = [self.scrollView.subviews firstObject];
    
    CGRect fullFrame = CGRectMake(0.0, 0.0,
                                  self.view.bounds.size.width * z,
                                  self.view.bounds.size.height * z);
    
    [screenView setFrame:fullFrame];//•not working?
    
    [self.playerLayer setFrame:fullFrame];
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    DLog(@"");//••FIX DESTROY
    
//    self.scrollView = nil;
//    [self destroyPlayer];


}

-(SOCueModel*)getCueModel{
    return _cueModel;
}
-(void)setCueModel:(SOCueModel*)cueModel{

    _cueModel = cueModel;
    
    NSString *path = [cueModel path];
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:[path stringByDeletingPathExtension]
                                                         ofType:[path pathExtension]];
    
    if(fullPath != nil){
        NSURL *url = [NSURL fileURLWithPath:fullPath];
        [self buildPlayerWithURL:url];
    }
    
    
    
}
-(void)buildPlayerWithURL:(NSURL*)url {
    
    CGRect fullFrame = CGRectMake(0.0, 0.0,
                                    self.view.bounds.size.height * [self.cueModel zoom],
                                    self.view.bounds.size.width * [self.cueModel zoom]);

    
    SOScreenView *screenView = [[SOScreenView alloc] initWithFrame:fullFrame];
    [screenView setTag:999];
    [self.scrollView addSubview:screenView];

    // setup avplayer
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    __weak AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    self.avPlayer = [AVPlayer playerWithPlayerItem:item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    [self.playerLayer setFrame:fullFrame];
//    self.playerLayer.opacity = 0.0f;
    [screenView.layer addSublayer:self.playerLayer];
    screenView.alpha = 0.1;
    [self.avPlayer setVolume:0.0f];
    [self.avPlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];//loop

    
    // observe and notify
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avPlayer currentItem]];

    [item addObserver:self forKeyPath:@"status" options:0 context:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([object isKindOfClass:[AVPlayerItem class]]){
        
        AVPlayerItem *item = (AVPlayerItem *)object;

        if ([keyPath isEqualToString:@"status"]){
        
            switch(item.status){
            
                case AVPlayerItemStatusFailed:{
                    DLog(@"player item status failed");
                }break;
                
                case AVPlayerItemStatusReadyToPlay:{
                    DLog(@"player item status is ready to play");
                    
                    [self.avPlayer prerollAtRate:1.0f completionHandler:^(BOOL finished) {

                        // let's add stuff
                        [self addPlayerObservers];

                        [self fadeIn:1.0f];

                        [self play];
                        
                        [self.delegate onScreenViewPlayerDidBegin:self];
                    }];
                }break;
                    
                case AVPlayerItemStatusUnknown:{
                    DLog(@"player item status is unknown");
                }break;
            }
        }
    }
    if ([object isKindOfClass:[self class]]){

        if([keyPath isEqualToString:@"cueModel"]){
            DLog(@"cue model changed");
        }
        
        
    }
    
}

-(void)fadeIn:(float)ms{

    SOScreenView *sv = (SOScreenView*)[self.scrollView viewWithTag:999];
    sv.alpha = 0.0f;

    [UIView animateWithDuration:1.0 animations:^{

        sv.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
        
    }];
    
}

-(void)isSelected:(BOOL)selected{
 
    SOScreenView *sv = (SOScreenView*)[self.scrollView viewWithTag:999];
    sv.layer.borderColor = [[UIColor greenColor] CGColor];

    if(selected){
        sv.layer.borderWidth = 5.0f;
    }else{
        sv.layer.borderWidth = 0.0f;
    }
}
-(CGRect)screenFrame{
    SOScreenView *sv = (SOScreenView*)[self.scrollView viewWithTag:999];
    return sv.frame;
}

-(CGRect)visibleFrame{
    SOScreenView *sv = (SOScreenView*)[self.scrollView viewWithTag:999];
    return [self.scrollView convertRect:self.scrollView.bounds toView:sv];
}

-(void)fadeOut:(float)ms{
    
    SOScreenView *sv = (SOScreenView*)[self.scrollView viewWithTag:999];
    sv.alpha = 1.0f;
    
    [UIView animateWithDuration:1.0 animations:^{
        
        sv.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        
    }];
    
}

-(void)addPlayerObservers{
    
    float totalTime = CMTimeGetSeconds([self.avPlayer.currentItem duration]);

    // custom progress of player
    __weak SOScreenViewController *weakSelf = self;
    self.periodicObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(60, 1000)
                                                                        queue:dispatch_get_main_queue()
                                                                   usingBlock:^(CMTime time) {
                                                                       
                                                                       float current = CMTimeGetSeconds(time);
                                                                       float progress = current / totalTime;
                                                                       //DLog(@"%f %f",current,totalTime);
                                                                       
                                                                       if(isnan(progress)) progress = 0;
                                                                       
                                                                       for(SOScreenView *sv in weakSelf.scrollView.subviews){
                                                                           
                                                                           if([sv isKindOfClass:[SOScreenView class]]){
                                                                               [sv setProgress:progress];
                                                                           }
                                                                       }
                                                                   }];



    // place a boundry observer to do a fade out
    float fadeTime = 1000.0f;
    float fadeValue = (totalTime * 1000.0f) - fadeTime;
    NSArray *fadeOutFime = @[[NSValue valueWithCMTime:CMTimeMake(fadeValue,1000)]];
    self.fadeOutObserver = [self.avPlayer addBoundaryTimeObserverForTimes:fadeOutFime queue:NULL usingBlock:^(){
        [weakSelf fadeOut:1.0f];
    }];
    
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


    [self fadeIn:1.0f];

    // lets loop movie for now
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    [self.avPlayer play];

    
}

-(void)destroyPlayer{
    
    AVPlayerLayer *avPlayerLayer = self.playerLayer;
    
    if(avPlayerLayer != nil){
        [avPlayerLayer removeFromSuperlayer];
        _playerLayer = nil;
    }
    
    
    AVPlayer *avFrontPlayer = self.avPlayer;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:avFrontPlayer];

    
    if(self.avPlayer != nil){

        // !don't forget to remove that observer!
        [[self.avPlayer currentItem] removeObserver:self forKeyPath:@"status"];

        [self.avPlayer removeTimeObserver:self.periodicObserver];
        [self.avPlayer removeTimeObserver:self.fadeInObserver];
        [self.avPlayer removeTimeObserver:self.fadeOutObserver];

        [self.avPlayer pause];
        _avPlayer = nil;
    }
    
}
-(void)scrollTo:(CGPoint)pnt{

//    DLog(@"%f %f",pnt.x,pnt.y);
    float yawf = pnt.x;
    float roll = pnt.y;
    float xpers = self.view.frame.size.width;
    float ypers = self.view.frame.size.height;
    float xs = M_PI * [self.cueModel scroll_dx];
    float ys = M_PI * [self.cueModel scroll_dy];
    
    (roll < 0.0f) ? roll *= -1.0f : roll;
    
//    float offsetYaw = 0;//-(M_PI/4);
    
    //• could also just have all translations here....everyting coming in is 0..1
    
    float xoff = ((self.cueModel.offset_x * 2.0f) - 1.0f) * M_PI;// -M_PI..M_PI

    float dyaw = yawf + xoff + 1.8;
    
    if(dyaw >= M_PI){
        dyaw -= M_PI*2;
    }
    
    yawf = (dyaw / (2.0 * M_PI)) * xs;
    roll = (-roll / (2.0 * M_PI)) * ys;
    
    
    float offsetx = (xpers * 0.5f * ([self.cueModel zoom] - 1.0));
    float offsety = (ypers * 0.5f * ([self.cueModel zoom] - 1.0));//-60.0f
    xpers = offsetx - (yawf * xpers);
    ypers = offsety + (roll * ypers) + (ypers * 0.25f * ys);
//    DLog(@"%f :%f",self.offset,ypers);
    
    [self.scrollView setContentOffset:(CGPoint){xpers,ypers} animated:NO];
    
}
@end
