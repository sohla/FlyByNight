//
//  SOSceneModel.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 20/07/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "JSONModel.h"

@protocol SOSceneModel
@end

@interface SOSceneModel : JSONModel


@property (assign, nonatomic) int minor;
@property (assign, nonatomic) float threshold;
@property (strong, nonatomic) NSString *action;
@property (strong, nonatomic) NSArray *cues;

@property (assign, nonatomic) int prox;

@end
