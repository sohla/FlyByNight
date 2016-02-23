//
//  SOMotionManager.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 25/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOMotionManager.h"
#import "DeviceUtil.h"

@interface SOMotionManager ()

@property (strong, nonatomic) CMMotionManager           *motionManager;
@property (strong, nonatomic) CLLocationManager         *locationManager;

@property (strong, nonatomic) CMAttitude *firstAttitude;
@property (strong, nonatomic) CMAttitude *calAtt;

@property float storedYaw;
@property float storedRoll;
@property float storedHeading;

//@property (nonatomic) BOOL firstCal;

@property (nonatomic) float heading;

@end


@implementation SOMotionManager


+ (SOMotionManager*)sharedManager{
    
    static SOMotionManager *_sharedManager;
    if(!_sharedManager) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _sharedManager = [[super allocWithZone:nil] init];
        });
    }
    
    return _sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    
    return [self sharedManager];
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}


#pragma mark - Motion
-(void)buildMotionManager{
    
    if(self.motionManager == nil){
        _motionManager = [[CMMotionManager alloc] init];
    }
    
    if(self.locationManager == nil){
        _locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
        
    }
    
    
    self.motionManager.deviceMotionUpdateInterval = 0.033;//30hz
    
    if ([self.motionManager isDeviceMotionAvailable]) {
        
        
        if([DeviceUtil isAnIPod]){

            DLog(@"Device is an iPod");
            [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
            DLog(@"Device Motion : CMAttitudeReferenceFrameXArbitraryZVertical");

        }else{

            [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
            DLog(@"Device Motion : CMAttitudeReferenceFrameXArbitraryCorrectedZVertical");

        }
        

        
//        self.firstAttitude = [self.motionManager.deviceMotion.attitude copy];
        
        
//        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
//                                                                toQueue:[NSOperationQueue currentQueue]
//                                                            withHandler:^(CMDeviceMotion *motion, NSError *error) {
//                                                                
//                                                                if(self.firstAttitude == nil){
//                                                                    self.firstAttitude = [motion.attitude copy];
//                                                                }
//                                                                [motion.attitude multiplyByInverseOfAttitude:self.firstAttitude];
//                                                                
//                                                                self.calAtt = [motion.attitude copy];
//            
//        }];
    }
    
    
    
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDelegate:self];
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
    
}

-(void)destroyMotionManager{

    [self.motionManager stopDeviceMotionUpdates];
    
    
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
    
    if(self.motionManager!=nil)
        self.motionManager = nil;

    if(self.locationManager!=nil)
        self.locationManager = nil;

}

-(void)reset{
    
    DLog(@"");
    [self destroyMotionManager];
    //self.firstCal = NO;
    [self buildMotionManager];
}

-(float)valueForKey:(NSString*)key{
    
//    if(!self.firstCal){
//        self.firstCal = YES;
//        self.firstAttitude = [self.motionManager.deviceMotion.attitude copy];
//    }
//    
//    if(self.firstAttitude){
//        [self.motionManager.deviceMotion.attitude multiplyByInverseOfAttitude:self.firstAttitude];
//    }
    
    CMAttitude *att = self.motionManager.deviceMotion.attitude;
    
    self.storedRoll = att.roll;//self.storedRoll - (0.025 * (self.storedRoll - att.roll));
    self.storedYaw = att.yaw;//self.storedYaw - (0.025 * (self.storedYaw - att.yaw));
    self.storedHeading = self.storedHeading - (0.025 * (self.storedHeading - self.heading));
    
    
    if([key isEqualToString:@"roll"]){
        return self.storedRoll;
    }
    if([key isEqualToString:@"pitch"]){
        return att.pitch;
    }
    if([key isEqualToString:@"yaw"]){
        
//        DLog(@"%f %f %f",att.yaw, self.heading,self.firstAttitude.yaw);
        return self.storedYaw;
    }
    if([key isEqualToString:@"heading"]){
        return self.motionManager.deviceMotion.magneticField.field.y;
    }
    
    
    return 0.0f;
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
        self.heading = (newHeading.magneticHeading / 360.0) * ( -2.0 * M_PI) + M_PI;
}
@end
