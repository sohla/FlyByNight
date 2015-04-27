//
//  SOScreenViewControllerProtocol.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 14/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SOScreenViewController;

@protocol SOScreenViewControllerProtocol <NSObject>



-(void)onScreenViewPlayerDidBegin:(SOScreenViewController*)svc;
-(void)onScreenViewPlayerDidEnd:(SOScreenViewController*)svc;


@end
