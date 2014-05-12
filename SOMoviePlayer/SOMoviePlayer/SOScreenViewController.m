//
//  SOScreenViewController.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 12/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOScreenViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface SOScreenViewController ()

@property (retain,nonatomic) AVPlayer *avPlayer;
@property float zoomLevel;

@end

@implementation SOScreenViewController


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        
        _view = [[SOScreenView alloc] initWithFrame:frame];
    }
    return self;
}
@end
