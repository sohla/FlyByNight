//
//  SOFloatPropViewController.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 3/06/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef float (^ValueChangeBlock)(float val);



@interface SOFloatPropViewController : UIViewController


@property (copy, nonatomic) ValueChangeBlock valueDidChangeBlock;




- (id)initWithNibName:(NSString *)nibNameOrNil withTitle:(NSString*)title atPoint:(CGPoint)pnt;

-(void)setValueDidChangeBlock:(ValueChangeBlock)block;
-(void)setValue:(float)value;
@end
