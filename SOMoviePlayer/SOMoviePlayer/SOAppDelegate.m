//
//  SOAppDelegate.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 17/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOAppDelegate.h"
#import "CocoaLumberjack.h"

@interface SOAppDelegate  ()


@end

@implementation SOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Setup Lumberjack logging
    //
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
     
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    [DDLog addLogger:fileLogger];
    
    
    // Install notification to report batterly level from anywhere
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLogBatteryLevel:)
                                                 name:kLogBatteryLevel
                                               object:nil];
    


    
    
    DLog(@"Fly by Night");
    DLog(@"device name : %@",[[UIDevice currentDevice] name]);

    [[NSNotificationCenter defaultCenter] postNotificationName:kLogBatteryLevel object:@"app start"];

    // Need motion
    [[SOMotionManager sharedManager] buildMotionManager];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [[NSNotificationCenter defaultCenter] postNotificationName:kTransportStop object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[SOMotionManager sharedManager] reset];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLogBatteryLevel
                                                  object:nil];

    [[SOMotionManager sharedManager] destroyMotionManager];

}


-(void)onLogBatteryLevel:(NSNotification *)notification{

    NSString *msg = [notification object];
    NSString *levelStr = @"";

    [UIDevice currentDevice].batteryMonitoringEnabled = YES;

    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    if (batteryLevel < 0.0) {
        // -1.0 means battery state is UIDeviceBatteryStateUnknown
        levelStr = NSLocalizedString(@"Unknown", @"");
    }
    else {
        static NSNumberFormatter *numberFormatter = nil;
        if (numberFormatter == nil) {
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
            [numberFormatter setMaximumFractionDigits:1];
        }
        
        NSNumber *levelObj = [NSNumber numberWithFloat:batteryLevel];
        levelStr = [NSString stringWithFormat:@"Batt : %@",[numberFormatter stringFromNumber:levelObj]];
    }
    
    DLog(@"Battery Level [%@] : %@",msg,levelStr);
    
    [UIDevice currentDevice].batteryMonitoringEnabled = NO;
   
}

@end
