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


@property (assign, nonatomic)   SOCueModel *currentCueModel;

@end

@implementation SOModelStore


- (instancetype)init{

    self = [super init];
    if (self) {


    }
    return self;
}

-(void)loadCues{

    NSString* const kFirstTimeRun = @"kFirstTimeRun";
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kFirstTimeRun] ) {
        
        
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kFirstTimeRun];
        [[NSUserDefaults standardUserDefaults] synchronize];
    };

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
                

                _sessionModel = [[SOSessionModel alloc] initWithData:data error:&err];
                
                self.currentCueModel = self.sessionModel.cues[0];

                [self saveCuesAsJsonWithTitle:@"testJson"];
            });
        }
        
    });
}


-(void)saveCuesAsJsonWithTitle:(NSString*)title{
    
    NSArray *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = docsPath[0];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.",title];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[fileName stringByAppendingString:@"json"]];
    
    if (![[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil]) {
        //        NSError *error = [NSError errorWithDomain:@"writeToFile"
        //                                             code:1
        //                                         userInfo:[NSDictionary dictionaryWithObject:@"Can't create file" forKey:NSLocalizedDescriptionKey]
        //                          ];
        //        NSAssert(error==noErr,@"Can't create file");
    }
    
    
    NSString *jsonString = [self.sessionModel toJSONString];
    
    DLog(@"%@",jsonString);
    [jsonString writeToFile:path atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];

}

-(SOCueModel*)cueModelAtIndex:(int)index{
    return self.sessionModel.cues[index];
}

@end
