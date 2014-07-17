//
//  CallbackRequestInfo.m
//  M9Dev
//
//  Created by MingLQ on 2014-07-17.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "CallbackRequestInfo.h"

#import "NSDictionary+Shortcuts.h"

@implementation CallbackRequestInfo

- (void)setSuccessWithCustomCallback:(void (^)(id<M9ResponseInfo> responseInfo, NSDictionary *data))success {
    self.success = ^(id<M9ResponseInfo> responseInfo, id responseObject) {
        if (success && [responseObject isKindOfClass:[NSDictionary class]]) {
            success(responseInfo, @{ @"query": [(NSDictionary *)responseObject dictionaryForKey:@"query"] OR [NSNull null],
                                     @"params": [(NSDictionary *)responseObject dictionaryForKey:@"params"] OR [NSNull null]
                                     });
        }
    };
}

- (void)setFailureWithCustomCallback:(void (^)(id<M9ResponseInfo> responseInfo, NSString *errorMessage))failure {
    self.failure = ^(id<M9ResponseInfo> responseInfo, NSError *error) {
        if (failure) {
            failure(responseInfo, [error description]);
        }
    };
}

@end
