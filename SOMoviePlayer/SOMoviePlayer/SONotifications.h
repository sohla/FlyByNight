//
//  SONotifications.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 23/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kLastEditState @"kLastEditState"
#define kLastBeaconRangingState @"kLastBeaconRangingState"


@interface SONotifications : NSObject

extern NSString* const kMotionManagerReset;
//extern NSString* const kZoomReset;
//extern NSString* const kZoomChanged;
//extern NSString* const kOffsetChanged;
//extern NSString* const kIsScrolling;
extern NSString* const kTransportStop;
extern NSString* const kTransportBack;
extern NSString* const kTransportForward;
extern NSString* const kTransportNext;
extern NSString* const kTransportCue;
extern NSString* const kEditModeOn;
extern NSString* const kEditModeOff;

extern NSString* const kResetBeacons;

extern NSString* const kBeaconsRangingOn;


@end
