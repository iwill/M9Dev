//
//  M9RequestInfo.m
//  M9Dev
//
//  Created by MingLQ on 2014-07-16.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9RequestInfo.h"

@implementation M9RequestInfo

+ (instancetype)requestInfoWithRequestConfig:(M9RequestConfig *)requestConfig {
    M9RequestInfo *requestInfo = [self new];
    [requestConfig makeCopy:requestInfo];
    return requestInfo;
}

- (void)setHTTPMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters {
    self.HTTPMethod = method;
    self.URLString = URLString;
    self.parameters = parameters;
}

- (void)setSuccess:(M9RequestSuccess)success failure:(M9RequestFailure)failure {
    self.success = success;
    self.failure = failure;
}

- (void)makeCopy:(M9RequestInfo *)copy {
    [super makeCopy:copy];
    copy.HTTPMethod = self.HTTPMethod;
    copy.URLString = self.URLString;
    copy.parameters = self.parameters;
    copy.allHTTPHeaderFields = self.allHTTPHeaderFields;
    copy.success = self.success;
    copy.failure = self.failure;
    copy.sender = self.sender;
}

@end
