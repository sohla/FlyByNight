//
//  SOTouchView.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 30/04/2015.
//  Copyright (c) 2015 Stephen OHara. All rights reserved.
//

#import "SOTouchView.h"
#import "SONotifications.h"


@interface SOTouchView ()

@property (nonatomic) Boolean isPaused;
@end

@implementation SOTouchView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    self.isPaused = !self.isPaused;

    if(self.isPaused){
        [[NSNotificationCenter defaultCenter] postNotificationName:kPauseCue object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kContinueCue object:nil];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

@end
