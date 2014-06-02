//
//  SOCueStore.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 31/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSessionModel.h"

@interface SOModelStore : NSObject

@property (strong, nonatomic)   SOSessionModel *sessionModel;

- (instancetype)init;
-(void)loadJSONCuesWithPath:(NSString*)path completionBlock:(void (^)(NSError *error)) block;


-(SOCueModel*)cueModelAtIndex:(int)index;
-(void)saveCuesAsJsonWithTitle:(NSString*)title;

@end
