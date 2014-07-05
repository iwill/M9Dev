//
//  M9RequestSettings.m
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

#import "M9RequestSettings.h"

@implementation M9RequestSettings

@M9MakeCopyWithZone;

- (id)init {
    self = [super init];
    if (self) {
        self.timeoutInterval = 10;
        self.maxRetryTimes = 2;
        self.cacheData = YES;
        self.useCachedData = YES;
        self.useCachedDataWhenFailure = NO;
    }
    return self;
}

- (void)makeCopy:(M9RequestSettings *)copy {
    copy.timeoutInterval = self.timeoutInterval;
    copy.maxRetryTimes = self.maxRetryTimes;
    copy.cacheData = self.cacheData;
    copy.useCachedData = self.useCachedData;
    copy.useCachedDataWhenFailure = self.useCachedDataWhenFailure;
}

@end

@implementation M9RequestInfo

- (void)makeCopy:(M9RequestInfo *)copy {
    [super makeCopy:copy];
    copy.URLString = self.URLString;
    copy.parameters = self.parameters;
    copy.success = self.success;
    copy.failure = self.failure;
    copy.sender = self.sender;
}

+ (instancetype)requestInfoWithSettings:(M9RequestSettings *)requestSettings {
    M9RequestInfo *requestInfo = [self new];
    [requestSettings makeCopy:requestInfo];
    return requestInfo;
}

@end
