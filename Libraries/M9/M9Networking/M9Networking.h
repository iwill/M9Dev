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

// TODO: Key_Value, JSON, Key_JSON

/**
 *  M9Networking
 *
 *  !!!: ONLY used for common requirements, or use AFNetworking or other framework directly
 *      e.g. Use AFNetworking for posting multipart form data, @see AFMultipartFormData
 */

#define M9NETWORKING [M9Networking sharedInstance]

@interface M9Networking : NSObject

@property(nonatomic, strong) M9RequestConfig *requestConfig;

+ (instancetype)sharedInstance;
+ (instancetype)instanceWithRequestConfig:(M9RequestConfig *)requestConfig;
- (instancetype)initWithRequestConfig:(M9RequestConfig *)requestConfig;

- (M9RequestRef *)GET:(NSString *)URLString
              success:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject))success
              failure:(void (^)(id<M9ResponseInfo> responseInfo, NSError *error))failure;
- (M9RequestRef *)GET:(NSString *)URLString
           parameters:(NSDictionary *)parameters
              success:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject))success
              failure:(void (^)(id<M9ResponseInfo> responseInfo, NSError *error))failure;
- (M9RequestRef *)POST:(NSString *)URLString
            parameters:(NSDictionary *)parameters
               success:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject))success
               failure:(void (^)(id<M9ResponseInfo> responseInfo, NSError *error))failure;

- (void)cancelAllWithSender:(id)sender;

+ (void)removeAllCachedData;
+ (void)removeCachedDataForKey:(NSString *)key;

@end

#pragma mark - finish

@interface M9Networking (finish)

- (M9RequestRef *)GET:(NSString *)URLString
               finish:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject, NSError *error))finish;
- (M9RequestRef *)GET:(NSString *)URLString
           parameters:(NSDictionary *)parameters
               finish:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject, NSError *error))finish;
- (M9RequestRef *)POST:(NSString *)URLString
            parameters:(NSDictionary *)parameters
                finish:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject, NSError *error))finish;

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
 
 ==== Keynote ====
 
 # 80-20: 80% requirements
 
 # general solution: AFN
 
 # M9Networking: get/post url & parameters, timeout, retry, cache, parse, callback, cancel & cancel by sender
 
 # extend: subclass M9RequestInfo + helper
    validate arguments, arguments to parameters: M9RequestInfo subclass or helper
    json to objects: M9RequestInfo subclass or helper
    delegate(sender) & selectors
 
 */
