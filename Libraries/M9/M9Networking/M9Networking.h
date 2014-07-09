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

/**
 *  M9Networking
 *
 *  !!!: Just for common networking, use AFNetworking or other framework directly for more requirements
 *      e.g. Use AFNetworking for posting multipart form data, @see AFMultipartFormData
 */
@interface M9Networking : NSObject

@property(nonatomic, strong) M9RequestConfig *requestConfig;

+ (instancetype)sharedInstance;
+ (instancetype)instanceWithRequestConfig:(M9RequestConfig *)requestConfig;
- (instancetype)initWithRequestConfig:(M9RequestConfig *)requestConfig;

// if no error success, else failure
- (M9RequestRef *)GET:(NSString *)URLString
           parameters:(NSDictionary *)parameters
               finish:(void (^)(id<M9ResponseRef> responseRef, id responseObject, NSError *error))finish;
- (M9RequestRef *)POST:(NSString *)URLString
            parameters:(NSDictionary *)parameters
                finish:(void (^)(id<M9ResponseRef> responseRef, id responseObject, NSError *error))finish;

- (M9RequestRef *)GET:(NSString *)URLString
           parameters:(NSDictionary *)parameters
              success:(void (^)(id<M9ResponseRef> responseRef, id responseObject))success
              failure:(void (^)(id<M9ResponseRef> responseRef, NSError *error))failure;
- (M9RequestRef *)POST:(NSString *)URLString
            parameters:(NSDictionary *)parameters
               success:(void (^)(id<M9ResponseRef> responseRef, id responseObject))success
               failure:(void (^)(id<M9ResponseRef> responseRef, NSError *error))failure;

- (M9RequestRef *)GET:(M9RequestInfo *)requestInfo;
- (M9RequestRef *)POST:(M9RequestInfo *)requestInfo;

- (void)cancelAllWithSender:(id)sender;

@end

#define M9N [M9Networking sharedInstance]

/*
 
 # synchronized
    TODO: use lock instead of synchronized
 
 # cancel & isCancelled
 
 # cache
    pod install AFNetworking & TMCache
 
 ==== TODO: ====
 
 # naming
    M9RequestInfo?
 
 # M9Networking & Other implementation, like NetRequestManager
 
 # ???: delegate and selectors
    // !!!: DEPRECATED, use block instead
    @property(nonatomic) SEL successSelector DEPRECATED_ATTRIBUTE, failureSelector DEPRECATED_ATTRIBUTE;
 
 # ???: base url
 
 # deprecated
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    #pragma clang diagnostic pop
 
 */

