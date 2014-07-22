//
//  M9Networking.h
//  M9Dev
//
//  Created by iwill on 2014-07-01.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9RequestConfig.h"
#import "M9RequestInfo.h"
#import "M9RequestRef.h"
#import "M9ResponseInfo.h"

#import "M9Utilities.h"

/**
 *  M9Networking
 *
 *  !!!: ONLY used for common requirements, or use AFNetworking or other framework directly
 *      e.g. Use AFNetworking for posting multipart form data, @see AFMultipartFormData
 *
 *  ???: send all request via M9RequestInfo
 */

#define M9NETWORKING [M9Networking sharedInstance]

@interface M9Networking : NSObject

@property(nonatomic, strong) M9RequestConfig *requestConfig;

+ (instancetype)sharedInstance;
+ (instancetype)instanceWithRequestConfig:(M9RequestConfig *)requestConfig;
- (instancetype)initWithRequestConfig:(M9RequestConfig *)requestConfig;

- (M9RequestRef *)GET:(NSString *)URLString success:(M9RequestSuccess)success failure:(M9RequestFailure)failure;
- (M9RequestRef *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(M9RequestSuccess)success failure:(M9RequestFailure)failure;
- (M9RequestRef *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(M9RequestSuccess)success failure:(M9RequestFailure)failure;

- (void)cancelAllWithSender:(id)sender;

+ (void)removeAllCachedData;
+ (void)removeCachedDataForKey:(NSString *)key;

@end

#pragma mark - finish

typedef void (^M9RequestFinish)(id<M9ResponseInfo> responseInfo, id responseObject, NSError *error);

@interface M9Networking (finish)

- (M9RequestRef *)GET:(NSString *)URLString finish:(M9RequestFinish)finish;
- (M9RequestRef *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters finish:(M9RequestFinish)finish;
- (M9RequestRef *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters finish:(M9RequestFinish)finish;

@end

#pragma mark - M9RequestInfo

@interface M9Networking (M9RequestInfo)

// @see - [M9RequestInfo requestInfoWithRequestConfig:]
- (M9RequestRef *)GET:(M9RequestInfo *)requestInfo;
- (M9RequestRef *)POST:(M9RequestInfo *)requestInfo;

@end

@interface M9RequestInfo (M9RequestConfig)

+ (instancetype)requestInfoWithRequestConfig:(M9RequestConfig *)requestConfig;

@end

/*
 
 # check synchronized
 
 ==== TODO: ====
 
 # class cluster: other implementation, like NetRequestManager & AFNNetRequestManager
 
 # use lock instead of synchronized?
 
 */
