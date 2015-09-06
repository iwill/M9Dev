//
//  M9ResponseInfo.h
//  M9Dev
//
//  Created by MingLQ on 2014-07-06.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <Foundation/Foundation.h>

@protocol M9ResponseInfo <NSObject>

@property(nonatomic, strong, readonly) NSURLRequest *request;
@property(nonatomic, strong, readonly) NSHTTPURLResponse *response;

@property(nonatomic, strong, readonly) NSData *responseData;
@property(nonatomic, strong, readonly) NSString *responseString;
@property(nonatomic, strong, readonly) id responseObject;
@property(nonatomic, strong, readonly) NSError *error;

@property(nonatomic, readonly) NSInteger retriedTimes;
@property(nonatomic, readonly) BOOL usedCachedData;
// @property(nonatomic, readonly) NSTimeInterval loadingDuration;

@end
