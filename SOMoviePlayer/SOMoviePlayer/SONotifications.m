//
//  SONotifications.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 23/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SONotifications.h"


@implementation SONotifications

NSString* const kMotionManagerReset = @"kMotionManagerReset";
//NSString* const kZoomReset = @"kZoomReset";
//NSString* const kZoomChanged = @"kZoomChanged";
//NSString* const kOffsetChanged = @"kOffsetChanged";
//NSString* const kIsScrolling = @"kIsScrolling";
NSString* const kTransportBack = @"kTransportBack";
NSString* const kTransportForward = @"kTransportForward";
NSString* const kTransportNext = @"kTransportNext";
NSString* const kTransportStop = @"kTransportStop";
NSString* const kTransportCue = @"kTransportCue";
NSString* const kEditModeOn = @"kEditModeOn";
NSString* const kEditModeOff = @"kEditModeOff";
NSString* const kContinueCue = @"kContinueCue";
NSString* const kPauseCue = @"kPauseCue";
NSString* const kGotoCues = @"kGotoCues";

NSString* const kLogBatteryLevel = @"kLogBatteryLevel";


@end
