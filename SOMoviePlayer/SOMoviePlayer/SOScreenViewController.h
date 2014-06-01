//
//  SOScreenViewController.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 12/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SOScreenView.h"
#import "SOScreenViewControllerProtocol.h"
#import "SOScreenTransport.h"

#import "SOCueModel.h"

@interface SOScreenViewController : UIViewController

@property (assign, nonatomic) id<SOScreenViewControllerProtocol> delegate;
@property (nonatomic) Boolean isScrolling;

- (instancetype)initWithFrame:(CGRect)frame;


-(void)setCue:(SOCueModel*)cueModel;

-(void)destroyPlayer;

-(void)play;
-(void)pause;

-(void)jumpBack;
-(void)jumpForward;

-(void)scrollTo:(CGPoint)pnt;
-(void)resetOffsetX:(float)offset;

-(void)resetZoomAt:(float)zoom;

@end
