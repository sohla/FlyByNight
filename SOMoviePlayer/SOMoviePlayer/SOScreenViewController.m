//
//  SOScreenViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 12/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOScreenViewController.h"
#import "SOFloatTransformer.h"

@interface SOScreenViewController ()



@property (strong,nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@property (strong, nonatomic) id periodicObserver;
@property (strong, nonatomic) id fadeInObserver;
@property (strong, nonatomic) id fadeOutObserver;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (assign, nonatomic) SOCueModel *cueModel;

@property (strong, nonatomic) CADisplayLink             *displayLink;


-(void)fadeIn:(float)seconds completionBlock:(void (^)()) block;
-(void)fadeOut:(float)seconds completionBlock:(void (^)()) block;

-(void)scrollTo:(CGPoint)pnt;


-(void)destroyPlayer;


@end

@implementation SOScreenViewController


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super init];
    if (self) {

        
//        self.offset = 0.0f;//(arc4random() % 4 / 4.0) * M_PI ;
        //DLog(@"w:%f h:%f",frame.size.width,frame.size.height);
        float w = 568.0f;
        float h = 320.0f;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        [self.view addSubview:self.scrollView];
        CGRect contentFrame = CGRectMake(0.0, 0.0,w * 2.0f,h * 2.0f);

        [self.scrollView setContentSize:contentFrame.size];
        [self.scrollView setContentOffset:self.scrollView.center animated:NO];
        [self.scrollView setBackgroundColor:[UIColor clearColor]];
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
        sv.layer.borderWidth = 2.0f;
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
    
    [self scrollTo:(CGPoint){0.0,M_PI_2}];

    
}

#pragma mark - Player

-(void)buildPlayerWithURL:(NSURL*)url {
    
    float w = 568.0f;
    float h = 320.0f;

    CGRect fullFrame = CGRectMake(0.0, 0.0,
                                    h * [self.cueModel zoom],
                                    w * [self.cueModel zoom]);

    
    SOScreenView *screenView = [[SOScreenView alloc] initWithFrame:fullFrame];
    [screenView setTag:999];
    [self.scrollView setHidden:YES];
    [self.scrollView addSubview:screenView];

    
    // setup avplayer
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    self.avPlayer = [AVPlayer playerWithPlayerItem:item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    
    DLog(@"building player for : %@",self.cueModel.title);
    
    [screenView.layer addSublayer:self.playerLayer];
    
    if([self.cueModel.type isEqualToString:@"movie"]){
        [self.avPlayer setVolume:0.0f];
    }
    if([self.cueModel.type isEqualToString:@"day"]){
        [self.avPlayer setVolume:0.0f];
    }
    if([self.cueModel.type isEqualToString:@"night"]){
        [self.avPlayer setVolume:0.0f];
    }
    
    [self.playerLayer setFrame:fullFrame];

//    [self.playerLayer setTransform:CATransform3DMakeRotation(3.14/2, 0, 0, 1)];
//    [self.playerLayer setTransform:CATransform3DMakeRotation(3.14, 0, 1, 0)];
    //loop
    //[self.avPlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];

    // observe and notify
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avPlayer currentItem]];

    [item addObserver:self forKeyPath:@"status" options:0 context:nil];
    
}

-(void)destroyPlayer{
    
    DLog(@"killing player for : %@",self.cueModel.title);

//    AVPlayerLayer *avPlayerLayer = self.playerLayer;
    
    if(self.playerLayer != nil){
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
    
    
//    AVPlayer *avFrontPlayer = self.avPlayer;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.avPlayer];
    
    
    if(self.avPlayer != nil){
        
        // !don't forget to remove that observer!
        [[self.avPlayer currentItem] removeObserver:self forKeyPath:@"status"];
        
        [self.avPlayer removeTimeObserver:self.periodicObserver];
        [self.avPlayer removeTimeObserver:self.fadeInObserver];
        [self.avPlayer removeTimeObserver:self.fadeOutObserver];
        
        [self.avPlayer pause];
        _avPlayer = nil;
        
//        [self.delegate onScreenViewPlayerDidEnd:self];

    }
    
}

-(BOOL)isPlaying{
    return ([self.avPlayer rate] != 0.0);
}

-(void)begin{
    [self.avPlayer play];
}

-(void)play{
    [self.avPlayer play];
}


-(void)pause{
    [self.avPlayer pause];
}

-(void)stopWithcompletionBlock:(void (^)()) block{

    float fadeout_time = [[SOFloatTransformer transformValue:[NSNumber numberWithFloat:self.cueModel.fadeout_time]
                                             valWithPropName:@"fadeout_time"] floatValue];

    
    __weak SOScreenViewController *weakSelf = self;
    
     [weakSelf fadeOut:fadeout_time completionBlock:^{
        [weakSelf destroyPlayer];
        block();
    }];

}

-(void)killWithcompletionBlock:(void (^)()) block{
    
    __weak SOScreenViewController *weakSelf = self;
    
    [weakSelf fadeOut:0.3 completionBlock:^{
        [weakSelf destroyPlayer];
        block();
    }];
    
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

-(void)fadeIn:(float)seconds completionBlock:(void (^)()) block{

    SOScreenView *sv = (SOScreenView*)[self.scrollView viewWithTag:999];
    sv.alpha = 0.0f;

    [UIView animateWithDuration:seconds animations:^{
        sv.alpha = 1.0f;
        //self.avPlayer.volume = 1.0f;
    } completion:^(BOOL finished) {
        if(block) block();
    }];
    
}

-(void)fadeOut:(float)seconds completionBlock:(void (^)()) block{

    SOScreenView *sv = (SOScreenView*)[self.scrollView viewWithTag:999];
    sv.alpha = 1.0f;
    
    if([self.cueModel.type isEqualToString:@"audio"]){
        [self fadeAudio];
    }
    if([self.cueModel.type isEqualToString:@"movieaudio"]){
        [self fadeAudio];
    }
    
    if(seconds > 0.0){
        [UIView animateWithDuration:seconds animations:^{
            
            sv.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if(block) block();
        }];
    }else{
        if(block) block();
        
    }
    
}

-(void)fadeAudio{

    self.avPlayer.volume -= 0.2;
    
    if(self.avPlayer.volume > 0.0){
        [self performSelector:@selector(fadeAudio) withObject:nil afterDelay:0.002];
    }else{
        self.avPlayer.volume = 0.0;
    }

    //DLog(@"%f",self.avPlayer.volume);
}

-(void)setVolume:(float)vol{
    
    if(vol < 0.0) vol = 0.0;
    if(vol > 1.0) vol = 1.0;
    
    self.avPlayer.volume = vol;
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
                                                                       
                                                                       //• chcek where we are
                                                                       //• call stradegy to change state
                                                                       //• states :
                                                                       //• init,fadein,play,fadeout
                                                                       //• 
                                                            
                                                                   }];



    // don't fade if we are looping
    if(self.cueModel.loop != 1){
        // place a boundry observer to do a fade out
        float fadeTime = self.cueModel.fadeout_time * 1000.0f;
        float fadeValue = (totalTime * 1000.0f) - fadeTime;
        NSArray *fadeOutFime = @[[NSValue valueWithCMTime:CMTimeMake(fadeValue,1000)]];
        self.fadeOutObserver = [self.avPlayer addBoundaryTimeObserverForTimes:fadeOutFime queue:NULL usingBlock:^(){
//            float fadeout_time = [[SOFloatTransformer transformValue:[NSNumber numberWithFloat:weakSelf.cueModel.fadeout_time]
//                                                 valWithPropName:@"fadeout_time"] floatValue];

//            [weakSelf fadeOut:fadeout_time completionBlock:nil];
            
            [weakSelf stopWithcompletionBlock:^{
                
            }];
        }];
    }
    
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
                    //DLog(@"player item status is ready to play");
                    

                    [self.avPlayer prerollAtRate:1.0f completionHandler:^(BOOL finished) {
                        
                        
                        // let's add stuff
                        [self addPlayerObservers];
                        
                        [self.scrollView setHidden:NO];

                        float fadein_time = [[SOFloatTransformer transformValue:[NSNumber numberWithFloat:self.cueModel.fadein_time]
                                                                 valWithPropName:@"fadein_time"] floatValue];

                        [self fadeIn:fadein_time completionBlock:nil];
                        
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

       // [self fadeIn:0.0];
//   [self.avPlayer seekToTime:[self.avPlayer.currentItem duration]];
//    [self.avPlayer pause];

//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:AVPlayerItemDidPlayToEndTimeNotification
//                                                  object:[self.avPlayer currentItem]];
//
//    
//    [self.delegate onScreenViewPlayerDidEnd:self];

    
    
//     float fadein_time = [[SOFloatTransformer transformValue:[NSNumber numberWithFloat:self.cueModel.fadein_time]
//                                            valWithPropName:@"fadein_time"] floatValue];


    
    if(self.cueModel.loop){
        
        // lets loop movie for now
        [self fadeIn:0.0 completionBlock:nil];
        AVPlayerItem *p = [notification object];
        
//        CMTime duration = [p duration];
//        CMTime back = CMTimeMakeWithSeconds(1, 1200);
//        CMTime start = CMTimeSubtract(duration, back);
        
        [p seekToTime:kCMTimeZero];
        [self.avPlayer play];
   
    }else{
        [self destroyPlayer];
        [self.delegate onScreenViewPlayerDidEnd:self];


    }

    
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
    
    NSNumber *zn = [SOFloatTransformer transformValue:[NSNumber numberWithFloat:zoom] valWithPropName:@"zoom"];
    float z = [zn floatValue];
    
    SOScreenView *screenView = (SOScreenView*)[self.scrollView viewWithTag:999];
    
    float w = 568.0f;
    float h = 320.0f;

    CGRect fullFrame = CGRectMake(0.0, 0.0, w * z, h * z);
    
    [screenView setFrame:fullFrame];//•not working?
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    [CATransaction setDisableActions:YES];

    [self.playerLayer setFrame:fullFrame];

    [CATransaction commit];
}

-(void)scrollTo:(CGPoint)pnt{

//    DLog(@"%f %f",pnt.x,pnt.y);
    float yawX = pnt.x;
    float rollY = pnt.y;
    float xpers = 568.0f;
    float ypers = 320.0f;

    float scroll_dx = [[SOFloatTransformer transformValue:[NSNumber numberWithFloat:self.cueModel.scroll_dx]
                                     valWithPropName:@"scroll_dx"] floatValue];
    float scroll_dy = [[SOFloatTransformer transformValue:[NSNumber numberWithFloat:self.cueModel.scroll_dy]
                                   valWithPropName:@"scroll_dy"] floatValue];

    float offset_x = [[SOFloatTransformer transformValue:[NSNumber numberWithFloat:self.cueModel.offset_x]
                                     valWithPropName:@"offset_x"] floatValue];
    float offset_y = [[SOFloatTransformer transformValue:[NSNumber numberWithFloat:self.cueModel.offset_y]
                                     valWithPropName:@"offset_y"] floatValue];
    
    float zoom = [[SOFloatTransformer transformValue:[NSNumber numberWithFloat:self.cueModel.zoom]
                                     valWithPropName:@"zoom"] floatValue];

    
    (rollY < 0.0f) ? rollY *= -1.0f : rollY;
    

    // add the offsets
    yawX = yawX + offset_x;
    rollY = rollY + offset_y;
    
    // check bourndries
    if(yawX >= M_PI){
        yawX -= M_PI*2;
    }
    
    //• droll boundry check not done
    
    
    // scale (ie. how much do we actually move)
    yawX = (yawX / (2.0 * M_PI)) * scroll_dx;
    rollY = (-rollY / (2.0 * M_PI)) * scroll_dy;
    

    // scale again for zoom
    float zoomX = (xpers * 0.5f * (zoom - 1.0));
    float zoomY = (ypers * 0.5f * (zoom - 1.0));//-60.0f

    // put it all together
    xpers = zoomX - (yawX * xpers);
    ypers = zoomY + (rollY * ypers) + (ypers * 0.25f * scroll_dy);

//    DLog(@"%f :%f",xpers,ypers);
    
    [self.scrollView setContentOffset:(CGPoint){xpers,ypers} animated:NO];
    
    
}
@end
