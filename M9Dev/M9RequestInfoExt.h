//
//  M9RequestInfoExt.h
//  M9Dev
//
//  Created by MingLQ on 2014-08-06.
//  Copyright (c) 2014年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "M9RequestInfo.h"

@interface M9RequestInfoDelegateExt : M9RequestInfo

@property(nonatomic, strong) id userInfo;

/* just an alias of owner
 */
@property(nonatomic, weak) id delegate;
/* 3 arguments: DelegateRequestInfo *requestInfo, id<M9ResponseInfo> responseInfo, id responseObject
 * e.g. - (void)successWithRequestInfo:(DelegateRequestInfo *)requestInfo responseInfo:(id<M9ResponseInfo>)responseInfo responseObject:(id)responseObject
 */
@property(nonatomic) SEL successSelector;
/* 3 arguments: DelegateRequestInfo *requestInfo, id<M9ResponseInfo> responseInfo, NSError *error
 * e.g. - (void)failureWithRequestInfo:(DelegateRequestInfo *)requestInfo responseInfo:(id<M9ResponseInfo>)responseInfo error:(NSError *)error
 */
@property(nonatomic) SEL failureSelector;

- (void)setDelegate:(id)delegate successSelector:(SEL)successSelector failureSelector:(SEL)failureSelector;

- (void)setSuccess:(void (^)(id<M9ResponseInfo>, id))success DEPRECATED_ATTRIBUTE;
- (void)setFailure:(void (^)(id<M9ResponseInfo>, NSError *))failure DEPRECATED_ATTRIBUTE;

@end

#pragma mark -

// !!!: just a demo
@interface M9RequestInfoCallbackExt : M9RequestInfo

- (void)setSuccessWithCustomCallback:(void (^)(id<M9ResponseInfo> responseInfo, NSArray *dataList))success;
- (void)setFailureWithCustomCallback:(void (^)(id<M9ResponseInfo> responseInfo, NSString *errorMessage))failure;

@end
