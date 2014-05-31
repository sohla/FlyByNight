//
//  SOSessionModel.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 31/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "JSONModel.h"
#import "SOCueModel.h"

@interface SOSessionModel : JSONModel


@property (strong, nonatomic) NSArray<SOCueModel>* cues;

@end
