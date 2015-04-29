//
//  SOLogger.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 29/04/2015.
//  Copyright (c) 2015 Stephen OHara. All rights reserved.
//

#import "SOLogger.h"

@implementation SOLogger

+ (NSFileHandle *)logFileHandle {
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [directories objectAtIndex:0];
    NSString *logFilePath = [docDir stringByAppendingPathComponent:@"battery-log.txt"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:logFilePath] == NO) {
        [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil];
    }
    NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath:logFilePath];
    return fh;
}

+ (void)logWithString:(NSString *)msg {
    NSFileHandle *fileHandle = [SOLogger logFileHandle];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[[msg stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
}
@end
