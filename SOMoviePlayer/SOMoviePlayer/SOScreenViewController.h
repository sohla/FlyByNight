//
//  SOScreenViewController.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 12/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOScreenView.h"
#import "SOScreenViewControllerProtocol.h"

@interface SOScreenViewController : UIViewController

@property (assign, nonatomic) id<SOScreenViewControllerProtocol> delegate;

- (instancetype)initWithFrame:(CGRect)frame;
-(void)buildPlayerWithURL:(NSURL*)url;
-(void)play;
-(void)pause;

-(void)destroyPlayer;

-(void)scrollTo:(CGPoint)pnt;
-(void)resetZoomAt:(float)zoom;

@end
