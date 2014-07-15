//
//  M9Networking.h
//  M9Dev
//
//  Created by iwill on 2014-07-01.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9RequestConfig.h"
#import "M9RequestRef.h"
#import "M9ResponseRef.h"

#import "M9Utilities.h"

// TODO: Key_Value, JSON, Key_JSON

/**
 *  M9Networking
 *
 *  !!!: Just for common networking, use AFNetworking or other framework directly for more requirements
 *      e.g. Use AFNetworking for posting multipart form data, @see AFMultipartFormData
 */

#define M9NETWORKING [M9Networking sharedInstance]

@interface M9Networking : NSObject

@property(nonatomic, strong) M9RequestConfig *requestConfig;

+ (instancetype)sharedInstance;
+ (instancetype)instanceWithRequestConfig:(M9RequestConfig *)requestConfig;
- (instancetype)initWithRequestConfig:(M9RequestConfig *)requestConfig;

- (M9RequestRef *)GET:(NSString *)URLString
              success:(void (^)(id<M9ResponseRef> responseRef, id responseObject))success
              failure:(void (^)(id<M9ResponseRef> responseRef, NSError *error))failure;
- (M9RequestRef *)GET:(NSString *)URLString
           parameters:(NSDictionary *)parameters
              success:(void (^)(id<M9ResponseRef> responseRef, id responseObject))success
              failure:(void (^)(id<M9ResponseRef> responseRef, NSError *error))failure;
- (M9RequestRef *)POST:(NSString *)URLString
            parameters:(NSDictionary *)parameters
               success:(void (^)(id<M9ResponseRef> responseRef, id responseObject))success
               failure:(void (^)(id<M9ResponseRef> responseRef, NSError *error))failure;

- (void)cancelAllWithSender:(id)sender;

@end

#pragma mark -

@interface M9Networking (M9RequestInfo)

- (M9RequestRef *)GET:(M9RequestInfo *)requestInfo;
- (M9RequestRef *)POST:(M9RequestInfo *)requestInfo;

@end

/*
 
 # synchronized
 
 # cancel & isCancelled
 
 ==== TODO: ====
 
 # baseURL
 
 # class cluster: other implementation, like NetRequestManager & AFNNetRequestManager
 
 # use lock instead of synchronized?
 
 # ???: delegate and selectors
    // !!!: DEPRECATED, use block instead
    @property(nonatomic) SEL successSelector DEPRECATED_ATTRIBUTE, failureSelector DEPRECATED_ATTRIBUTE;
 
 ==== Keynote ====
 
 # 80-20: 80% requirements
 
 # general solution: AFN
 
 # M9Networking: get/post url & parameters, timeout, retry, cache, parse, callback, cancel & cancel by sender
 
 # extend: subclass M9RequestInfo + helper
    validate arguments, arguments to parameters: M9RequestInfo subclass or helper
    json to objects: M9RequestInfo subclass or helper
    delegate(sender) & selectors
 
 */
