//
//  DEPRECATEDRequestInfo.m
//  M9Dev
//
//  Created by MingLQ on 2014-07-16.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "DEPRECATEDRequestInfo.h"

@implementation DEPRECATEDRequestInfo

@dynamic delegate;

- (id)init {
    self = [super init];
    if (self) {
        weakify(self);
        [super setSuccess:^(id<M9ResponseRef> responseRef, id responseObject) {
            strongify(self);
            if ([self.delegate respondsToSelector:self.successSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:self.successSelector withObject:responseRef withObject:responseObject];
#pragma clang diagnostic pop
            }
        }];
        [super setFailure:^(id<M9ResponseRef> responseRef, NSError *error) {
            strongify(self);
            if ([self.delegate respondsToSelector:self.failureSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:self.failureSelector withObject:responseRef withObject:error];
#pragma clang diagnostic pop
            }
        }];
    }
    return self;
}

- (id)delegate {
    return self.sender;
}

- (void)setDelegate:(id)delegate {
    self.sender = delegate;
}

- (void)setDelegate:(id)delegate successSelector:(SEL)successSelector failureSelector:(SEL)failureSelector {
    self.delegate = delegate;
    self.successSelector = successSelector;
    self.failureSelector = failureSelector;
}

- (void)setSuccess:(void (^)(id<M9ResponseRef>, id))success {
}

- (void)setFailure:(void (^)(id<M9ResponseRef>, NSError *))failure {
}

- (void)makeCopy:(DEPRECATEDRequestInfo *)copy {
    [super makeCopy:copy];
    copy.delegate = self.delegate;
    copy.successSelector = self.successSelector;
    copy.failureSelector = self.failureSelector;
}

@end
