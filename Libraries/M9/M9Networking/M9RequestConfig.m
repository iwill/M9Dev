//
//  M9RequestConfig.m
//  M9Dev
//
//  Created by iwill on 2014-07-06.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#if ! __has_feature(objc_arc)
// Add -fobjc-arc or remove -fno-objc-arc: Target > Build Phases > Compile Sources > implementation.m
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import "M9RequestConfig.h"

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
