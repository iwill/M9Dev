//
//  M9Networking.m
//  M9Dev
//
//  Created by iwill on 2014-07-01.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#if ! __has_feature(objc_arc)
// Add -fobjc-arc or remove -fno-objc-arc: Target > Build Phases > Compile Sources > implementation.m
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import "M9Networking.h"
#import "M9RequestRef+Private.h"
#import "AFHTTPRequestOperation+M9Response.h"

#import "AFNetworking.h"
#import "TMCache.h"
#import "NSDate+RFC1123.h"
#import "EXTScope.h"

#import "NSDate+.h"

#define HTTPGET     @"GET"
#define HTTPPOST    @"POST"
#define HTTPExpires @"Expires"

/**
 * AFN
 *  cache:
 *      http://nshipster.com/nsurlcache/
 *      http://stackoverflow.com/questions/10250055/sdurlcache-with-afnetworking-and-offline-mode-not-working
 *      http://blog.originate.com/blog/2014/02/20/afimagecache-vs-nsurlcache/
 *  retry:
 *      https://github.com/AFNetworking/AFNetworking/issues/393
 */

@interface M9Networking ()

@end

@implementation M9Networking {
    AFHTTPRequestOperationManager *_AFN;
}

+ (instancetype)sharedInstance {
    static M9Networking *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

+ (instancetype)new {
    return [[self alloc] init];
}

+ (instancetype)instanceWithRequestSettings:(M9RequestSettings *)settings {
    return [[self alloc] initWithRequestSettings:settings];
}

- (id)init {
    return [self initWithRequestSettings:[M9RequestSettings new]];
}

- (instancetype)initWithRequestSettings:(M9RequestSettings *)settings {
    self = [super init];
    if (self) {
        _AFN = [AFHTTPRequestOperationManager manager];
        self.requestSettings = settings;
    }
    return self;
}

#pragma mark public

- (M9RequestRef *)GET:(NSString *)URLString
           parameters:(NSDictionary *)parameters
              success:(void (^)(id<M9Response> response, id responseObject, M9RequestRef *requestRef))success
              failure:(void (^)(id<M9Response> response, NSError *error, M9RequestRef *requestRef))failure {
    URLString = [[NSURL URLWithString:URLString relativeToURL:_AFN.baseURL] absoluteString];
    NSMutableURLRequest *request = [_AFN.requestSerializer requestWithMethod:HTTPGET URLString:URLString parameters:parameters error:nil];
    return [self sendRequest:request settings:self.requestSettings success:success failure:failure];
}

- (M9RequestRef *)POST:(NSString *)URLString
            parameters:(NSDictionary *)parameters
               success:(void (^)(id<M9Response> response, id responseObject, M9RequestRef *requestRef))success
               failure:(void (^)(id<M9Response> response, NSError *error, M9RequestRef *requestRef))failure {
    URLString = [[NSURL URLWithString:URLString relativeToURL:_AFN.baseURL] absoluteString];
    NSMutableURLRequest *request = [_AFN.requestSerializer requestWithMethod:HTTPPOST URLString:URLString parameters:parameters error:nil];
    return [self sendRequest:request settings:self.requestSettings success:success failure:failure];
}

- (M9RequestRef *)GET:(M9RequestInfo *)requestInfo {
    NSString *URLString = [[NSURL URLWithString:requestInfo.URLString relativeToURL:_AFN.baseURL] absoluteString];
    NSMutableURLRequest *request = [_AFN.requestSerializer requestWithMethod:HTTPGET URLString:URLString parameters:requestInfo.parameters error:nil];
    return [self sendRequest:request sender:requestInfo.sender settings:requestInfo success:requestInfo.success failure:requestInfo.failure];
}

- (M9RequestRef *)POST:(M9RequestInfo *)requestInfo {
    NSString *URLString = [[NSURL URLWithString:requestInfo.URLString relativeToURL:_AFN.baseURL] absoluteString];
    /* constructingBodyBlock
    NSMutableURLRequest *request = (requestInfo.constructingBodyBlock
                                    ? [_AFN.requestSerializer multipartFormRequestWithMethod:HTTPPOST URLString:URLString parameters:requestInfo.parameters constructingBodyWithBlock:requestInfo.constructingBodyBlock error:nil]
                                    : [_AFN.requestSerializer requestWithMethod:HTTPPOST URLString:URLString parameters:requestInfo.parameters error:nil]); */
    NSMutableURLRequest *request = [_AFN.requestSerializer requestWithMethod:HTTPPOST URLString:URLString parameters:requestInfo.parameters error:nil];
    return [self sendRequest:request sender:requestInfo.sender settings:requestInfo success:requestInfo.success failure:requestInfo.failure];
}

#pragma mark private

- (M9RequestRef *)sendRequest:(NSMutableURLRequest *)request
                     settings:(M9RequestSettings *)settings
                      success:(void (^)(id<M9Response> response, id responseObject, M9RequestRef *requestRef))success
                      failure:(void (^)(id<M9Response> response, NSError *error, M9RequestRef *requestRef))failure {
    return [self sendRequest:request sender:nil settings:settings success:success failure:failure];
}

- (M9RequestRef *)sendRequest:(NSMutableURLRequest *)request
                       sender:(id)sender
                     settings:(M9RequestSettings *)settings
                      success:(void (^)(id<M9Response> response, id responseObject, M9RequestRef *requestRef))success
                      failure:(void (^)(id<M9Response> response, NSError *error, M9RequestRef *requestRef))failure {
    M9RequestRef *requestRef = [M9RequestRef requestRefWithSender:sender];
    [sender addRequestRef:requestRef];
    if (settings.useCachedData) {
        weakify(self);
        [self loadCachedResponseWithRequest:request settings:settings callback:^(id<M9Response> response, BOOL expired)
         { @synchronized(requestRef) {
            strongify(self);
            if (requestRef.isCancelled) {
                return;
            }
            if (response && !expired) {
                if (success) success(response, [response responseObject], requestRef);
            }
            else {
                [self sendRequest:request settings:settings requestRef:requestRef success:success failure:failure];
            }
        }}];
    }
    else {
        [self sendRequest:request settings:settings requestRef:requestRef success:success failure:failure];
    }
    return requestRef;
}

- (void)sendRequest:(NSMutableURLRequest *)request
           settings:(M9RequestSettings *)settings
         requestRef:(M9RequestRef *)requestRef
            success:(void (^)(id<M9Response> response, id responseObject, M9RequestRef *requestRef))success
            failure:(void (^)(id<M9Response> response, NSError *error, M9RequestRef *requestRef))failure
{ @synchronized(requestRef) { // lock: requestRef.isCancelled && requestRef.currentRequestOperation
    NSParameterAssert(requestRef);
    
    if (requestRef.isCancelled) {
        return;
    }
    
    // callback
    weakify(self);
    requestRef.currentRequestOperation = ({
        _RETURN [_AFN HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject)
         { @synchronized(requestRef) {
            // strongify(self);
            if (requestRef.isCancelled) {
                return;
            }
            if (settings.cacheData) {
                [[TMCache sharedCache] setObject:operation forKey:[[request URL] absoluteString] block:nil];
            }
            if (success) success(operation, responseObject, requestRef);
            [requestRef.sender removeRequestRef:requestRef];
        }} failure:^(AFHTTPRequestOperation *operation, NSError *error)
         { @synchronized(requestRef) {
            strongify(self);
            if (requestRef.isCancelled) {
                return;
            }
            if (requestRef.retryTimes < settings.maxRetryTimes) {
                requestRef.retryTimes++;
                [self sendRequest:request settings:settings requestRef:requestRef success:success failure:failure];
                return;
            }
            if (settings.useCachedDataWhenFailure) {
                [self loadCachedResponseWithRequest:request settings:settings callback:^(id<M9Response> response, BOOL expired)
                 { @synchronized(requestRef) {
                    strongify(self);
                    if (requestRef.isCancelled) {
                        return;
                    }
                    // expired || !expired, either is ok
                    if (response) {
                        if (success) success(response, [response responseObject], requestRef);
                    }
                    else {
                        [self sendRequest:request settings:settings requestRef:requestRef success:success failure:failure];
                    }
                }}];
            }
            else {
                if (failure) failure(operation, error, requestRef);
            }
            [requestRef.sender removeRequestRef:requestRef];
        }}];
    });
    
    // data parsing
    NSMutableArray *responseSerializers = [NSMutableArray array];
    if (settings.responseParseOptions & M9ResponseParseOption_Data) {
        [responseSerializers addObject:[AFHTTPResponseSerializer serializer]];
    }
    if (settings.responseParseOptions & M9ResponseParseOption_JSON) {
        [responseSerializers addObject:[AFJSONResponseSerializer serializer]];
    }
    if (settings.responseParseOptions & M9ResponseParseOption_XML) {
        [responseSerializers addObject:[AFXMLParserResponseSerializer serializer]];
    }
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
    if (settings.responseParseOptions & M9ResponseParseOption_XMLDocument) {
        [responseSerializers addObject:[AFXMLDocumentResponseSerializer serializer]];
    }
#endif
    if (settings.responseParseOptions & M9ResponseParseOption_PList) {
        [responseSerializers addObject:[AFPropertyListResponseSerializer serializer]];
    }
    if (settings.responseParseOptions & M9ResponseParseOption_Image) {
        [responseSerializers addObject:[AFImageResponseSerializer serializer]];
    }
    if ([responseSerializers count] == 1) {
        requestRef.currentRequestOperation.responseSerializer = [responseSerializers firstObject];
    }
    else if ([responseSerializers count] > 1) {
        requestRef.currentRequestOperation.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:responseSerializers];
    }
    
    // disable NSURLCache
    [requestRef.currentRequestOperation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
        return nil;
    }];
    
    // send request
    [_AFN.operationQueue addOperation:requestRef.currentRequestOperation];
}}

- (void)loadCachedResponseWithRequest:(NSMutableURLRequest *)request
                             settings:(M9RequestSettings *)settings
                             callback:(void (^)(id<M9Response> response, BOOL expired))callback {
    if (!callback) {
        return;
    }
    // weakify(self);
    [[TMCache sharedCache] objectForKey:[[request URL] absoluteString] block:^(TMCache *cache, NSString *key, id object) {
        if ([object isKindOfClass:[AFHTTPRequestOperation class]]) {
            AFHTTPRequestOperation *cachedOperation = (AFHTTPRequestOperation *)object;
            NSString *expiresOn = [[cachedOperation response] allHeaderFields][HTTPExpires];
            NSDate *expiresOnDate = [NSDate dateFromRFC1123:expiresOn];
            BOOL expired = [NSDate timeIntervalSinceDate:expiresOnDate] > 0;
            callback(cachedOperation, expired);
            return;
        }
        callback(nil, NO);
    }];
}

- (void)cancelAllWithSender:(id)sender { @synchronized(sender) { // lock: sender.allRequestRefOfSender
    for (M9RequestRef *requestRef in [[sender allRequestRef] copy]) {
        [requestRef cancel];
    }
}}

@end
