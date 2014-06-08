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

@property (strong, nonatomic) CADisplayLink             *displayLink;


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
        
        [self addDisplayLink];


    }
    return self;
}

-(void)dealloc{
}

#pragma mark - Views

-(void)viewWillAppear:(BOOL)animated{
    
}

-(void)viewDidDisappear:(BOOL)animated{

    [self removeDisplayLink];
    
    [self destroyPlayer];

}

-(void)viewWillDisappear:(BOOL)animated{
}


-(CGRect)visibleFrame{
    SOScreenView *sv = (SOScreenView*)[self.scrollView viewWithTag:999];
    return [self.scrollView convertRect:self.scrollView.bounds toView:sv];
}

-(void)setViewIsSelected:(BOOL)selected{
    
    SOScreenView *sv = (SOScreenView*)[self.scrollView viewWithTag:999];
    sv.layer.borderColor = [[UIColor greenColor] CGColor];
    
    if(selected){
        sv.layer.borderWidth = 5.0f;
    }else{
        sv.layer.borderWidth = 0.0f;
    }
}


#pragma mark - Model

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

#pragma mark - Player

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
//    self.playerLayer.opacity = 0.3f;
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


-(void)play{
    [self.avPlayer play];
}


-(void)pause{
    [self.avPlayer pause];
}

-(void)jumpBack:(float)secs{
    
    CMTime current = [self.avPlayer currentTime];
    CMTime jump = CMTimeMakeWithSeconds(secs,self.avPlayer.currentTime.timescale);
    CMTime newTime = CMTimeSubtract(current, jump);
    [self.avPlayer seekToTime:newTime];
    
}
-(void)jumpForward:(float)secs{
    
    CMTime current = [self.avPlayer currentTime];
    CMTime jump = CMTimeMakeWithSeconds(secs,self.avPlayer.currentTime.timescale);
    CMTime newTime = CMTimeAdd(current, jump);
    [self.avPlayer seekToTime:newTime];
}

-(void)fadeIn:(float)ms{

    SOScreenView *sv = (SOScreenView*)[self.scrollView viewWithTag:999];
    sv.alpha = 0.0f;

    [UIView animateWithDuration:1.0 animations:^{

        sv.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
        
    }];
    
}

-(void)fadeOut:(float)ms{
    
    SOScreenView *sv = (SOScreenView*)[self.scrollView viewWithTag:999];
    sv.alpha = 1.0f;
    
    [UIView animateWithDuration:1.0 animations:^{
        
        sv.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        
    }];
    
}
#pragma mark - Player Observers

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



#pragma mark - Motion Manager

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

    float roll = [[SOMotionManager sharedManager] valueForKey:@"roll"];
    //    float pitch = [[SOMotionManager sharedManager] valueForKey:@"pitch"];
    float yawf = [[SOMotionManager sharedManager] valueForKey:@"yaw"];
    //    float heading = [[SOMotionManager sharedManager] valueForKey:@"heading"];

    [self scrollTo:(CGPoint){yawf,roll}];

    [self zoomTo:self.cueModel.zoom];
 
}

-(void)zoomTo:(float)zoom{
    
    float z = 0.5 + (zoom * 1.5f); // 0.5..2.0
    
    SOScreenView *screenView = (SOScreenView*)[self.scrollView viewWithTag:999];
    
    CGRect fullFrame = CGRectMake(0.0, 0.0,
                                  self.view.bounds.size.width * z,
                                  self.view.bounds.size.height * z);
    
    [screenView setFrame:fullFrame];//•not working?
    
    [self.playerLayer setFrame:fullFrame];
    
}

-(void)scrollTo:(CGPoint)pnt{

//    DLog(@"%f %f",pnt.x,pnt.y);
    float yawX = pnt.x;
    float rollY = pnt.y;
    float xpers = self.view.frame.size.width;
    float ypers = self.view.frame.size.height;
    
    //            NSNumber *uiVal = [SOFloatTransformer transformValue:[NSNumber numberWithFloat:val] valWithPropName:propName];

    float xs = M_PI * [self.cueModel scroll_dx];
    float ys = M_PI * [self.cueModel scroll_dy];
    
    (rollY < 0.0f) ? rollY *= -1.0f : rollY;
    
//    float offsetYaw = 0;//-(M_PI/4);
    
    //• could also just have all translations here....everyting coming in is 0..1
    
    float xoff = ((self.cueModel.offset_x * 2.0f) - 1.0f) * M_PI;// -M_PI..M_PI
    float yoff = ((self.cueModel.offset_y * 2.0f) - 1.0f) * M_PI;// -M_PI..M_PI

    // add the offsets
    yawX = yawX + xoff + 1.8;
    rollY = rollY + yoff;
    
    // check bourndries
    if(yawX >= M_PI){
        yawX -= M_PI*2;
    }
    
    //• droll boundry check not done
    
    
    // scale (ie. how much do we actually move)
    yawX = (yawX / (2.0 * M_PI)) * xs;
    rollY = (-rollY / (2.0 * M_PI)) * ys;
    
    // scale again for zoom
    float zoomX = (xpers * 0.5f * ([self.cueModel zoom] - 1.0));
    float zoomY = (ypers * 0.5f * ([self.cueModel zoom] - 1.0));//-60.0f

    // put it all together
    xpers = zoomX - (yawX * xpers);
    ypers = zoomY + (rollY * ypers) + (ypers * 0.25f * ys);

//    DLog(@"%f :%f",xpers,ypers);
    
    [self.scrollView setContentOffset:(CGPoint){xpers,ypers} animated:NO];
    
    
}
@end
