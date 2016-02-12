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
+(NSArray*)arrayOfFloatPropertiesForClass:(Class)c;

-(void)saveLatest;
-(void)loadCuesWithCompletionBlock:(void(^)())completionBlock;

-(SOSceneModel*)sceneModelWithMinor:(int)minor;
-(SOCueModel*)cueModelAtIndex:(int)index;
-(SOCueModel*)cueModelWithTitle:(NSString*)title;


@end
