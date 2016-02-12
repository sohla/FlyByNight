//
//  SOSessionModel.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 31/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "JSONModel.h"
#import "SOCueModel.h"
#import "SOSceneModel.h"

@interface SOSessionModel : JSONModel

@property (assign, nonatomic) int start;
@property (strong, nonatomic) NSArray<SOCueModel>* cues;
@property (strong, nonatomic) NSArray<SOSceneModel>* scenes;

@end
