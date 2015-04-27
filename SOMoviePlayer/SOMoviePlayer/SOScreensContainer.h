//
//  SODetailViewController.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 17/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "SOScreenViewControllerProtocol.h"

#import "SOMotionManager.h"
#import "SOModelStore.h"
#import "SOCueModel.h"


@interface SOScreensContainer : UIViewController <SOScreenViewControllerProtocol>

@property (assign, nonatomic) SOModelStore *modelStore;

-(void)playCue:(SOCueModel*)cueModel;
-(void)stopCue:(SOCueModel*)cueModel;

-(void)triggerBeacon:(SOBeaconModel*)beaconModel;


@end
