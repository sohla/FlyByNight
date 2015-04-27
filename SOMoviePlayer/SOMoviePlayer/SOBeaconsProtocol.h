//
//  SOBeaconsProtocol.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 27/07/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SOBeaconsProtocol <NSObject>



-(void)currentBeacons:(NSArray*)beacons;
-(void)currentBeacon:(NSNumber*)minor;
@end
