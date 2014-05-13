//
//  SOScreenViewController.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 12/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOScreenView.h"

@interface SOScreenViewController : NSObject

@property (retain, nonatomic) SOScreenView *view;

- (instancetype)initWithFrame:(CGRect)frame;
-(void)buildPlayerWithURL:(NSURL*)url;
-(void)play;
-(void)pause;

-(void)destroyPlayer;

@end
