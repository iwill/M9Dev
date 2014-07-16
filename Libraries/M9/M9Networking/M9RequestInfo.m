//
//  M9RequestInfo.m
//  M9Dev
//
//  Created by MingLQ on 2014-07-16.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9RequestInfo.h"

@implementation M9RequestInfo

- (void)makeCopy:(M9RequestInfo *)copy {
    [super makeCopy:copy];
    copy.URLString = self.URLString;
    copy.parameters = self.parameters;
    copy.success = self.success;
    copy.failure = self.failure;
    copy.sender = self.sender;
    copy.userInfo = self.userInfo;
}

@end
