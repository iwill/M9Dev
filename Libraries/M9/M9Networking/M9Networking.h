//
//  M9Networking.h
//  M9Dev
//
//  Created by iwill on 2014-07-01.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9RequestSettings.h"
#import "M9RequestRef.h"
#import "M9Response.h"

/**
 *  M9Networking
 *
 *  !!!: Just for common networking, use AFNetworking or other framework directly for more requirements
 *      e.g. Use AFNetworking for posting multipart form data, @see AFMultipartFormData
 */
@interface M9Networking : NSObject

@property(nonatomic, strong) M9RequestSettings *requestSettings;

+ (instancetype)sharedInstance;
+ (instancetype)instanceWithRequestSettings:(M9RequestSettings *)requestSettings;
- (instancetype)initWithRequestSettings:(M9RequestSettings *)requestSettings;

- (M9RequestRef *)GET:(NSString *)URLString
           parameters:(NSDictionary *)parameters
              success:(void (^)(id<M9Response> response, id responseObject, M9RequestRef *requestRef))success
              failure:(void (^)(id<M9Response> response, NSError *error, M9RequestRef *requestRef))failure;
- (M9RequestRef *)POST:(NSString *)URLString
            parameters:(NSDictionary *)parameters
               success:(void (^)(id<M9Response> response, id responseObject, M9RequestRef *requestRef))success
               failure:(void (^)(id<M9Response> response, NSError *error, M9RequestRef *requestRef))failure;

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
 
 # ???: delegate and selectors
    // !!!: DEPRECATED, use block instead
    @property(nonatomic) SEL successSelector DEPRECATED_ATTRIBUTE, failureSelector DEPRECATED_ATTRIBUTE;
 
 # ???: base url
 
 # deprecated
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    #pragma clang diagnostic pop
 
 */

