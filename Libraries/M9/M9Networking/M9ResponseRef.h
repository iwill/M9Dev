//
//  M9ResponseRef.h
//  M9Dev
//
//  Created by iwill on 2014-07-06.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol M9ResponseRef <NSObject>

@property(nonatomic, strong, readonly) NSURLRequest *request;
@property(nonatomic, strong, readonly) NSHTTPURLResponse *response;

@property(nonatomic, strong, readonly) NSData *responseData;
@property(nonatomic, strong, readonly) NSString *responseString;
@property(nonatomic, strong, readonly) id responseObject;
@property(nonatomic, strong, readonly) NSError *error;

@property(nonatomic, readonly) NSInteger retriedTimes;
@property(nonatomic, readonly) BOOL usedCache;

@end
