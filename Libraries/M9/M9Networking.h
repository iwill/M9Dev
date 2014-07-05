//
//  M9Networking.h
//  iM9
//
//  Created by MingLQ on 2014-07-01.
//  Copyright (c) 2014年 SOHU. All rights reserved.
//

#import "M9Utilities.h"

typedef NS_OPTIONS(NSUInteger, M9ResponseParseOptions) {
    M9ResponseParseOption_Data  = 1 << 0,
    M9ResponseParseOption_JSON  = 1 << 1,
    M9ResponseParseOption_XML   = 1 << 2,
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
    M9ResponseParseOption_XMLDocument = 1 << 3,
#endif
    M9ResponseParseOption_PList = 1 << 4,
    M9ResponseParseOption_Image = 1 << 5,
    M9ResponseParseOption_All   = 0xFFFFFFFF
};

@interface M9RequestSettings : NSObject <M9MakeCopy>

@property(nonatomic) M9ResponseParseOptions responseParseOptions;

@property(nonatomic) NSTimeInterval timeoutInterval; // default: 10 per request / retry, AFNetworking: 60

@property(nonatomic) NSInteger maxRetryTimes; // default: 2, AFNetworking: 0

@property(nonatomic) BOOL cacheData; // default: YES
@property(nonatomic) BOOL useCachedData; // default: YES
@property(nonatomic) BOOL useCachedDataWhenFailure; // default: NO

@end

#pragma mark -

@class M9RequestRef;
@protocol M9Response;

@interface M9RequestInfo : M9RequestSettings

@property(nonatomic, strong) NSString *URLString;
@property(nonatomic, strong) NSDictionary *parameters;
@property(nonatomic, copy) void (^success)(id<M9Response> response, id responseObject, M9RequestRef *requestRef);
@property(nonatomic, copy) void (^failure)(id<M9Response> response, NSError *error, M9RequestRef *requestRef);

@property(nonatomic, weak) id sender; // for cancel all requests by sender

+ (instancetype)requestInfoWithSettings:(M9RequestSettings *)requestSettings;

@end

#pragma mark -

@interface M9RequestRef : NSObject

@property(nonatomic, readonly) NSInteger retryTimes;
@property(nonatomic, readonly) BOOL usedCache;

- (BOOL)isCancelled;
- (void)cancel;

@end

#pragma mark -

@protocol M9Response <NSObject>

@property(nonatomic, strong) NSURLRequest *request;
@property(nonatomic, strong) NSHTTPURLResponse *response;

@property(nonatomic, strong) NSData *responseData;
@property(nonatomic, strong) NSString *responseString;
@property(nonatomic, strong) id responseObject;
@property(nonatomic, strong) NSError *error;

@end

#pragma mark -

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
 
 ==== TODO: ====
 
 # cache
    pod install AFNetworking & TMCache
 
 # ???: delegate and selectors
    // !!!: DEPRECATED, use block instead
    @property(nonatomic) SEL successSelector DEPRECATED_ATTRIBUTE, failureSelector DEPRECATED_ATTRIBUTE;
 
 # ???: base url
 
 # deprecated
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    #pragma clang diagnostic pop
 
 */

