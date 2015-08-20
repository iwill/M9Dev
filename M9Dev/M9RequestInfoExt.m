//
//  M9RequestInfoExt.m
//  M9Dev
//
//  Created by MingLQ on 2014-08-06.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "M9RequestInfoExt.h"

#import "EXTScope+M9.h"
#import "NSInvocation+M9.h"
#import "NSDictionary+M9.h"

@implementation M9RequestInfoDelegateExt

@dynamic delegate;

- (id)init {
    self = [super init];
    if (self) {
        weakify(self);
        [super setSuccess:^(id<M9ResponseInfo> responseInfo, id responseObject) {
            strongify(self);
            if ([self.delegate respondsToSelector:self.successSelector]) {
                M9RequestInfo *requestInfo = self;
                /* NOTE:
                 *  save requestItem as self.requestItem when send request
                 *  make responseItem from self.requestItem and callback here
                 */
                [self.delegate invokeWithSelector:self.successSelector arguments:&requestInfo, &responseInfo, &responseObject];
            }
        }];
        [super setFailure:^(id<M9ResponseInfo> responseInfo, NSError *error) {
            strongify(self);
            if ([self.delegate respondsToSelector:self.failureSelector]) {
                M9RequestInfo *requestInfo = self;
                [self.delegate invokeWithSelector:self.failureSelector arguments:&requestInfo, &responseInfo, &error];
            }
        }];
    }
    return self;
}

- (void)setSuccess:(void (^)(id<M9ResponseInfo>, id))success {
}

- (void)setFailure:(void (^)(id<M9ResponseInfo>, NSError *))failure {
}

- (id)delegate {
    return self.owner;
}

- (void)setDelegate:(id)delegate {
    self.owner = delegate;
}

- (void)setDelegate:(id)delegate successSelector:(SEL)successSelector failureSelector:(SEL)failureSelector {
    self.delegate = delegate;
    self.successSelector = successSelector;
    self.failureSelector = failureSelector;
}

- (void)makeCopy:(M9RequestInfoDelegateExt *)copy {
    copy.userInfo = self.userInfo;
    copy.delegate = self.delegate;
    copy.successSelector = self.successSelector;
    copy.failureSelector = self.failureSelector;
}

@end

#pragma mark -

@implementation M9RequestInfoCallbackExt

- (void)setSuccessWithCustomCallback:(void (^)(id<M9ResponseInfo> responseInfo, NSArray *data))success {
    weakify(self);
    self.success = ^(id<M9ResponseInfo> responseInfo, id responseObject) {
        strongify(self);
        NSDictionary *dataDict = [responseObject as:[NSDictionary class]];
        if (dataDict) {
            if (success) {
                success(responseInfo, @[ [dataDict dictionaryForKey:@"query"] OR [NSNull null],
                                         [dataDict dictionaryForKey:@"params"] OR [NSNull null] ]);
            }
        }
        else {
            if (self.failure) {
                self.failure(responseInfo, [NSError errorWithDomain:@"M9TestErrorDomain" code:0 userInfo:nil]);
            }
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
