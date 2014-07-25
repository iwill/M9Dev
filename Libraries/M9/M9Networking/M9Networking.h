//
//  M9Networking.h
//  M9Dev
//
//  Created by iwill on 2014-07-01.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

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

- (M9RequestRef *)send:(M9RequestInfo *)requestInfo;
- (void)cancelAllWithSender:(id)sender;

+ (void)removeAllCachedData;
+ (void)removeCachedDataForURLString:(NSString *)key;

@end

#pragma mark - simple

@interface M9Networking (simple)

- (M9RequestRef *)GET:(NSString *)URLString success:(M9RequestSuccess)success failure:(M9RequestFailure)failure;
- (M9RequestRef *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(M9RequestSuccess)success failure:(M9RequestFailure)failure;
- (M9RequestRef *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(M9RequestSuccess)success failure:(M9RequestFailure)failure;

- (M9RequestRef *)GET:(NSString *)URLString finish:(M9RequestFinish)finish;
- (M9RequestRef *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters finish:(M9RequestFinish)finish;
- (M9RequestRef *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters finish:(M9RequestFinish)finish;

@end

/*
 
 # check synchronized
 
 ==== TODO: ====
 
 # class cluster: other implementation, like NetRequestManager & AFNNetRequestManager
 
 # use lock instead of synchronized?
 
 */
