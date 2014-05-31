//
//  SOCueStore.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 31/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOModelStore.h"

#define kBGQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface SOModelStore ()

@property (strong, nonatomic)   NSDictionary *cuesStore;

@property (assign, nonatomic)   SOCueModel *currentCueModel;

@end

@implementation SOModelStore


- (instancetype)init{

    self = [super init];
    if (self) {


    }
    return self;
}


-(void)loadJSONCuesWithPath:(NSString*)path completionBlock:(void (^)(NSError *error)) block{
    
    
    NSURL *url = [NSURL fileURLWithPath:path];
    if(url == nil){
        
        NSError *err = [NSError errorWithDomain:@"fileURLWithPath"
                                           code:1
                                         userInfo:[NSDictionary dictionaryWithObject:@"Could not find file at path"
                                                                              forKey:NSLocalizedDescriptionKey]];

        block(err);
    }
    
    
    dispatch_async(kBGQueue, ^{
        
        __block NSError *err;
        __block NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&err];
        
        if(err){
            block(err);
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //parse out the json data and store
                NSError *error;
                _cuesStore = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&error];
                
                if(error)
                    block(error);
                

                _sessionModel = [[SOSessionModel alloc] initWithData:data error:&err];
                
                self.currentCueModel = self.sessionModel.cues[0];

                
            });
        }
        
    });
}

-(SOCueModel*)cueModelAtIndex:(int)index{
    return self.sessionModel.cues[index];
}

@end
