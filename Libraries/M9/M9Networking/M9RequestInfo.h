//
//  M9RequestInfo.h
//  M9Dev
//
//  Created by MingLQ on 2014-07-16.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9RequestConfig.h"

#define HTTPGET     @"GET"
#define HTTPPOST    @"POST"

@protocol M9ResponseInfo;

typedef void (^M9RequestSuccess)(id<M9ResponseInfo> responseInfo, id responseObject);
typedef void (^M9RequestFailure)(id<M9ResponseInfo> responseInfo, NSError *error);

@interface M9RequestInfo : M9RequestConfig

@property(nonatomic, copy) NSString *HTTPMethod; // default: GET, use GET if nil
@property(nonatomic, copy) NSString *URLString;
@property(nonatomic, strong) NSDictionary *parameters;
@property(nonatomic, strong) NSDictionary *allHTTPHeaderFields;
@property(nonatomic, copy) M9RequestSuccess success;
@property(nonatomic, copy) M9RequestFailure failure;

@property(nonatomic, weak) id sender; // for cancel all requests by sender

+ (instancetype)requestInfoWithRequestConfig:(M9RequestConfig *)requestConfig;

- (void)setHTTPMethod:(NSString *)HTTPMethod URLString:(NSString *)URLString parameters:(NSDictionary *)parameters;
- (void)setSuccess:(M9RequestSuccess)success failure:(M9RequestFailure)failure;

@end
