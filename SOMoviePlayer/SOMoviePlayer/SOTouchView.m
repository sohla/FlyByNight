//
//  SOTouchView.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 30/04/2015.
//  Copyright (c) 2015 Stephen OHara. All rights reserved.
//

#import "SOTouchView.h"
#import "SONotifications.h"


@interface SOTouchView ()

@property (strong, nonatomic)UISwipeGestureRecognizer *swipeRightGesture;
@property (strong, nonatomic)UISwipeGestureRecognizer *swipeLeftGesture;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end

@implementation SOTouchView

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {

        [self addGestures];
        
//        NSURL *audioPath = [NSURL fileURLWithPath: [[NSBundle mainBundle]  pathForResource:@"00 TC Atmos (loop)_converted" ofType:@"m4a"]];
//        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioPath error:NULL];
//        [[self audioPlayer] setNumberOfLoops:-1];
        

    }
    return self;
}



-(void)dealloc{
    
    [self removeGestures];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

}




- (void)addGestures{
    
    // gestures
    _swipeRightGesture = [[UISwipeGestureRecognizer alloc]
                          initWithTarget:self
                          action:@selector(onSwipeRight:)];
    [self.swipeRightGesture setNumberOfTouchesRequired:1];
    [self.swipeRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    
    _swipeLeftGesture = [[UISwipeGestureRecognizer alloc]
                         initWithTarget:self
                         action:@selector(onSwipeLeft:)];
    [self.swipeLeftGesture setNumberOfTouchesRequired:1];
    [self.swipeLeftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];

    [self addGestureRecognizer:self.swipeRightGesture];
    

    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(onDoubleTap:)];
    
    [doubleTapGesture setNumberOfTapsRequired:3];
    [doubleTapGesture setNumberOfTouchesRequired:1];
    
    [self addGestureRecognizer:doubleTapGesture];

}

-(void)removeGestures{
    
    [self.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeGestureRecognizer:obj];
    }];
    
}


- (void)onDoubleTap:(UIGestureRecognizer *)gestureRecognizer{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kGotoCues object:nil];
    
}

- (void)onSwipeLeft:(UIGestureRecognizer *)gestureRecognizer{
    
    DLog(@"");
    [[self audioPlayer] stop];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kContinueCue object:nil];
    
    [self addGestureRecognizer:self.swipeRightGesture];
    [self removeGestureRecognizer:self.swipeLeftGesture];
    
}
- (void)onSwipeRight:(UIGestureRecognizer *)gestureRecognizer{
    
    DLog(@"");
    [[self audioPlayer] play];

    [[NSNotificationCenter defaultCenter] postNotificationName:kPauseCue object:nil];
    
    [self addGestureRecognizer:self.swipeLeftGesture];
    [self removeGestureRecognizer:self.swipeRightGesture];
    
}



@end
