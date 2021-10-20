//
//  SOCueStore.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 31/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOModelStore.h"
#import <objc/runtime.h>


#define kLastFileSaved @"kLastFileSaved"
#define kBGQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface SOModelStore ()


@property (assign, nonatomic)   SOCueModel *currentCueModel;

@end

@implementation SOModelStore


- (instancetype)init{

    self = [super init];
    if (self) {

//        [self loadCues];
    }
    return self;
}

-(void)loadCuesWithCompletionBlock:(void(^)())completionBlock{

    
    if(YES) {
 //   if(![[NSUserDefaults standardUserDefaults] stringForKey:kLastFileSaved] ) {
        
        DLog(@"Loading default data file...");
 //       NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"data_2014729_1525m4a" ofType:@"json"];
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"data_220515" ofType:@"json"];

//        // master
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"data_190715" ofType:@"json"];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"data_slv1" ofType:@"json"];

        
        
        [self loadJSONCuesWithPath:path completionBlock:^(NSError *error) {
            
            if(error){
                NSLog(@"%@",error.localizedDescription);
            }else{
                
                [self saveLatest];

                //** get all used assets
                
                NSMutableArray *assetsUsed = [[NSMutableArray alloc] init];
//                DLog(@"%@",[self.sessionModel.scenes   valueForKeyPath:@"cues"]);

                NSArray *cueTitles = [self.sessionModel.scenes   valueForKeyPath:@"cues"];
                
                [cueTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                   
                    
                    NSArray *titles = obj;
                    
                    [titles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                       
                        
                        NSString *path = [[self cueModelWithTitle:obj] valueForKey:@"path"];
                        
                        [assetsUsed addObject:path];
                    }];
                    
                    
                }];
                DLog(@"%@",assetsUsed);
                
                completionBlock();
//                DLog(@"%@",[self sceneModelWithMinor:2]);
                
                //DLog(@"%@",[self cueModelWithTitle:@"drinking tap"]);
            }
            
        }];
        
        
        

    }else{
    
        NSString *latestFile = [[NSUserDefaults standardUserDefaults] stringForKey:kLastFileSaved];
        NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [docsDirectory stringByAppendingPathComponent:latestFile];
        
        DLog(@"Loading %@",latestFile);

        [self loadJSONCuesWithPath:path completionBlock:^(NSError *error) {
            
            if(error){
                NSLog(@"%@",error.localizedDescription);
            }
        }];
        

        
    }

}


-(SOSceneModel*)sceneModelWithMinor:(int)minor{
    
    NSArray *minors = [self.sessionModel.scenes   valueForKeyPath:@"minor"];
    __block SOSceneModel *scene;
    [minors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if([obj integerValue] == minor){
            scene = self.sessionModel.scenes[idx];
        }
        
    }];
    
    return scene;
    
    
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

                block(nil);

            });
        }
        
    });
}

-(void)saveLatest{
    
    NSDate	*now = [NSDate date];
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	NSDateComponents *comp = [currentCalendar components:
							  (NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|
							   NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond)
												fromDate:now];
    
    
	// form string for file name using current date to form unique file name
    NSString* newFileName = [[NSString stringWithFormat:
                              @"%@_%ld%ld%ld_%ld%ld%ld",
                              @"data",
                              (long)[comp year],(long)[comp month],(long)[comp day],
                              (long)[comp hour],(long)[comp minute],(long)[comp second]] stringByAppendingPathExtension:@"json"];
    
    [self saveCuesAsJsonWithTitle:newFileName];
    
    [[NSUserDefaults standardUserDefaults] setObject:newFileName forKey:kLastFileSaved];
    [[NSUserDefaults standardUserDefaults] synchronize];


}

-(void)saveCuesAsJsonWithTitle:(NSString*)title{
    
    DLog(@"Saving %@",title);

    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [NSString stringWithFormat:@"%@",title];
    NSString *path = [docsDirectory stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil]) {
        //        NSError *error = [NSError errorWithDomain:@"writeToFile"
        //                                             code:1
        //                                         userInfo:[NSDictionary dictionaryWithObject:@"Can't create file" forKey:NSLocalizedDescriptionKey]
        //                          ];
        //        NSAssert(error==noErr,@"Can't create file");
    }
    
    
    NSString *jsonString = [self.sessionModel toJSONString];
    [jsonString writeToFile:path atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    
    //DLog(@"%@",jsonString);

}


-(SOCueModel*)cueModelWithTitle:(NSString*)title{
    
  
    __block SOCueModel *cueModel;
    
    [self.sessionModel.cues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        if([[obj title] isEqualToString:title]){
            cueModel = obj;
        }
        
    }];
    
    return cueModel;
    
}

-(SOCueModel*)cueModelAtIndex:(int)index{
    return self.sessionModel.cues[index];
}


+(NSArray*)arrayOfFloatPropertiesForClass:(Class)c{

    NSMutableArray *array = [NSMutableArray array];
    unsigned int count;
    objc_property_t* props = class_copyPropertyList(c, &count);
    
    for (int i = 0; i < count; i++) {
    
        objc_property_t property = props[i];
        const char * name = property_getName(property);
        NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        const char * type = property_getAttributes(property);
//        NSString *attr = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        
        NSString * typeString = [NSString stringWithUTF8String:type];
        NSArray * attributes = [typeString componentsSeparatedByString:@","];
        NSString * typeAttribute = [attributes objectAtIndex:0];
        NSString * propertyType = [typeAttribute substringFromIndex:1];
        const char * rawPropertyType = [propertyType UTF8String];
        
        
        if (strcmp(rawPropertyType, @encode(float)) == 0) {
            [array addObject:propertyName];
            
        } else if (strcmp(rawPropertyType, @encode(int)) == 0) {
            //it's an int
        } else if (strcmp(rawPropertyType, @encode(id)) == 0) {
            //it's some sort of object
        } else {
            // According to Apples Documentation you can determine the corresponding encoding values
        }
        
        if ([typeAttribute hasPrefix:@"T@"]) {
            NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];  //turns @"NSDate" into NSDate
            Class typeClass = NSClassFromString(typeClassName);
            if (typeClass != nil) {
                // Here is the corresponding class even for nil values
            }
        }
        
    }
    free(props);
    
    return array;
}

@end
