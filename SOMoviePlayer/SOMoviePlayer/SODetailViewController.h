//
//  SODetailViewController.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 17/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import "SOScreenViewControllerProtocol.h"
@interface SODetailViewController : UIViewController <SOScreenViewControllerProtocol>


-(void)addScreenWithURL:(NSURL*)url;


@end
