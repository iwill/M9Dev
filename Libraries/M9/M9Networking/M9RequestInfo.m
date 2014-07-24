//
//  M9RequestInfo.m
//  M9Dev
//
//  Created by MingLQ on 2014-07-16.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9RequestInfo.h"

@implementation M9RequestConfig

@M9MakeCopyWithZone;

- (id)init {
    self = [super init];
    if (self) {
        self.parametersFormatter = M9RequestParametersFormatter_KeyJSON;
        self.timeoutInterval = 10;
        self.maxRetryTimes = 2;
        self.cacheData = YES;
        self.useCachedData = YES;
        self.useCachedDataWithoutLoading = NO;
        self.useCachedDataWhenFailure = NO;
        self.dataParser = M9ResponseDataParser_JSON;
    }
    return self;
}

- (void)makeCopy:(M9RequestConfig *)copy {
    copy.baseURL = self.baseURL;
    copy.parametersFormatter = self.parametersFormatter;
    copy.timeoutInterval = self.timeoutInterval;
    copy.maxRetryTimes = self.maxRetryTimes;
    copy.cacheData = self.cacheData;
    copy.useCachedData = self.useCachedData;
    copy.useCachedDataWithoutLoading = self.useCachedDataWithoutLoading;
    copy.useCachedDataWhenFailure = self.useCachedDataWhenFailure;
    copy.dataParser = self.dataParser;
    copy.willSendRequestForAuthenticationChallengeBlock = self.willSendRequestForAuthenticationChallengeBlock;
}

@end

#pragma mark -

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
    copy.parsing = self.parsing;
    copy.success = self.success;
    copy.failure = self.failure;
    copy.sender = self.sender;
}

@end
