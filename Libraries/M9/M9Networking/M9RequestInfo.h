//
//  M9RequestInfo.h
//  M9Dev
//
//  Created by MingLQ on 2014-07-16.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9RequestConfig.h"

@protocol M9ResponseInfo;

@interface M9RequestInfo : M9RequestConfig

@property(nonatomic, strong) NSString *URLString;
@property(nonatomic, strong) NSDictionary *parameters;
@property(nonatomic, strong) NSDictionary *allHTTPHeaderFields;
@property(nonatomic, copy) void (^success)(id<M9ResponseInfo> responseInfo, id responseObject);
@property(nonatomic, copy) void (^failure)(id<M9ResponseInfo> responseInfo, NSError *error);

@property(nonatomic, weak) id sender; // for cancel all requests by sender

@end
