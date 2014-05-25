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
@property (assign, nonatomic) float offset;// -M_PI..M_PI 

- (instancetype)initWithFrame:(CGRect)frame;

-(void)buildPlayerWithURL:(NSURL*)url;
-(void)destroyPlayer;

-(void)play;
-(void)pause;


-(void)scrollTo:(CGPoint)pnt;
-(void)resetZoomAt:(float)zoom;

@end
