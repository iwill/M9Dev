//
//  DelegateRequestInfo.h
//  M9Dev
//
//  Created by MingLQ on 2014-07-17.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9RequestInfo.h"

@interface DelegateRequestInfo : M9RequestInfo

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
