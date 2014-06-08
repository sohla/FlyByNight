//
//  SOScreenViewController.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 12/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SOMotionManager.h"
#import "SOScreenView.h"
#import "SOScreenViewControllerProtocol.h"
#import "SOScreenTransport.h"

#import "SOCueModel.h"

@interface SOScreenViewController : UIViewController

@property (assign, nonatomic) id<SOScreenViewControllerProtocol> delegate;


- (instancetype)initWithFrame:(CGRect)frame;


-(void)setCueModel:(SOCueModel*)cueModel;
-(SOCueModel*)getCueModel;

-(void)destroyPlayer;

-(void)play;
-(void)pause;

-(void)jumpBack:(float)secs;
-(void)jumpForward:(float)secs;

-(void)scrollTo:(CGPoint)pnt;

-(void)fadeIn:(float)ms;
-(void)fadeOut:(float)ms;

-(CGRect)visibleFrame;

-(void)setViewIsSelected:(BOOL)selected;
@end
