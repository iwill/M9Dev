//
//  CallbackRequestInfo.h
//  M9Dev
//
//  Created by MingLQ on 2014-07-17.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9RequestInfo.h"

@interface CallbackRequestInfo : M9RequestInfo

- (void)setSuccessWithCustomCallback:(void (^)(id<M9ResponseInfo> responseInfo, NSDictionary *data))success;
- (void)setFailureWithCustomCallback:(void (^)(id<M9ResponseInfo> responseInfo, NSString *errorMessage))failure;

@end
