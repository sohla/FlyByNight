//
//  SOCueModel.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 31/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "JSONModel.h"

@protocol SOCueModel
@end

@interface SOCueModel : JSONModel


@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *type;

@property (assign, nonatomic) float zoom;

@property (assign, nonatomic) float offset_x;
@property (assign, nonatomic) float offset_y;

@property (assign, nonatomic) float scroll_dx;
@property (assign, nonatomic) float scroll_dy;

@property (assign, nonatomic) float pre_time;
@property (assign, nonatomic) float fadein_time;
@property (assign, nonatomic) float fadeout_time;





@end
