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
#import "AFNResponseInfo.h"

#import "AFNetworking.h"
#import "TMCache.h"
#import "NSDate+RFC1123.h"
#import "EXTScope.h"

#import "NSDictionary+Shortcuts.h"
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

+ (instancetype)instanceWithRequestConfig:(M9RequestConfig *)config {
    return [[self alloc] initWithRequestConfig:config];
}

- (id)init {
    return [self initWithRequestConfig:[M9RequestConfig new]];
}

- (instancetype)initWithRequestConfig:(M9RequestConfig *)config {
    self = [super init];
    if (self) {
        _AFN = [AFHTTPRequestOperationManager manager];
        self.requestConfig = config;
    }
    return self;
}

#pragma mark public

- (M9RequestRef *)GET:(NSString *)URLString
              success:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject))success
              failure:(void (^)(id<M9ResponseInfo> responseInfo, NSError *error))failure {
    return [self GET:URLString parameters:nil success:success failure:failure];
}

- (M9RequestRef *)GET:(NSString *)URLString
           parameters:(NSDictionary *)parameters
              success:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject))success
              failure:(void (^)(id<M9ResponseInfo> responseInfo, NSError *error))failure {
    URLString = [[NSURL URLWithString:URLString relativeToURL:self.requestConfig.baseURL] absoluteString];
    NSMutableURLRequest *request = [_AFN.requestSerializer requestWithMethod:HTTPGET URLString:URLString parameters:parameters error:nil];
    return [self sendRequest:request config:self.requestConfig success:success failure:failure];
}

- (M9RequestRef *)POST:(NSString *)URLString
            parameters:(NSDictionary *)parameters
               success:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject))success
               failure:(void (^)(id<M9ResponseInfo> responseInfo, NSError *error))failure {
    URLString = [[NSURL URLWithString:URLString relativeToURL:self.requestConfig.baseURL] absoluteString];
    NSMutableURLRequest *request = [_AFN.requestSerializer requestWithMethod:HTTPPOST URLString:URLString parameters:parameters error:nil];
    return [self sendRequest:request config:self.requestConfig success:success failure:failure];
}

#pragma mark private

- (M9RequestRef *)sendRequest:(NSMutableURLRequest *)request
                       config:(M9RequestConfig *)config
                      success:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject))success
                      failure:(void (^)(id<M9ResponseInfo> responseInfo, NSError *error))failure {
    return [self sendRequest:request sender:nil config:config success:success failure:failure];
}

- (M9RequestRef *)sendRequest:(NSMutableURLRequest *)request
                       sender:(id)sender
                       config:(M9RequestConfig *)config
                      success:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject))success
                      failure:(void (^)(id<M9ResponseInfo> responseInfo, NSError *error))failure {
    M9RequestRef *requestRef = [M9RequestRef requestRefWithSender:sender];
    [sender addRequestRef:requestRef];
    
    if (config.useCachedDataWithoutLoading) {
        // weakify(self);
        [self loadCachedResponseWithRequest:request config:config callback:^(AFHTTPRequestOperation *operation, id responseObject, BOOL expired)
         { @synchronized(requestRef) {
            // strongify(self);
            if (requestRef.isCancelled) {
                return;
            }
            if (operation) {
                if (success) {
                    id responseInfo = [AFNResponseInfo responseInfoWithRequestOperation:operation requestRef:requestRef];
                    success(responseInfo, responseObject);
                }
            }
            else {
                if (failure) {
                    id responseInfo = [AFNResponseInfo responseInfoWithRequestOperation:operation requestRef:requestRef];
                    failure(responseInfo, nil);
                }
            }
        }}];
    }
    else if (config.useCachedData) {
        weakify(self);
        [self loadCachedResponseWithRequest:request config:config callback:^(AFHTTPRequestOperation *operation, id responseObject, BOOL expired)
         { @synchronized(requestRef) {
            strongify(self);
            if (requestRef.isCancelled) {
                return;
            }
            if (operation && !expired) {
                requestRef.usedCachedData = YES;
                if (success) {
                    id responseInfo = [AFNResponseInfo responseInfoWithRequestOperation:operation requestRef:requestRef];
                    success(responseInfo, responseObject);
                }
            }
            else {
                [self sendRequest:request config:config requestRef:requestRef success:success failure:failure];
            }
        }}];
    }
    else {
        [self sendRequest:request config:config requestRef:requestRef success:success failure:failure];
    }
    
    return requestRef;
}

- (void)sendRequest:(NSMutableURLRequest *)request
             config:(M9RequestConfig *)config
         requestRef:(M9RequestRef *)requestRef
            success:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject))success
            failure:(void (^)(id<M9ResponseInfo> responseInfo, NSError *error))failure
{ @synchronized(requestRef) { // lock: requestRef.isCancelled && requestRef.currentRequestOperation
    NSParameterAssert(requestRef);
    
    if (requestRef.isCancelled) {
        return;
    }
    
    request.timeoutInterval = config.timeoutInterval;
    
    // callback
    weakify(self);
    AFHTTPRequestOperation *requestOperation = ({
        _RETURN [_AFN HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject)
         { @synchronized(requestRef) {
            // strongify(self);
            if (requestRef.isCancelled) {
                return;
            }
            if (config.cacheData) {
                [[TMCache sharedCache] setObject:operation forKey:[[request URL] absoluteString] block:nil];
            }
            if (success) {
                id responseInfo = [AFNResponseInfo responseInfoWithRequestOperation:operation requestRef:requestRef];
                success(responseInfo, responseObject);
            }
            [requestRef.sender removeRequestRef:requestRef];
        }} failure:^(AFHTTPRequestOperation *operation, NSError *error)
         { @synchronized(requestRef) {
            strongify(self);
            if (requestRef.isCancelled) {
                return;
            }
            if (error.code == NSURLErrorTimedOut && requestRef.retriedTimes < config.maxRetryTimes) {
                requestRef.retriedTimes++;
                [self sendRequest:request config:config requestRef:requestRef success:success failure:failure];
                return;
            }
            if (config.useCachedDataWhenFailure) {
                [self loadCachedResponseWithRequest:request config:config callback:^(AFHTTPRequestOperation *operation, id responseObject, BOOL expired)
                 { @synchronized(requestRef) {
                    strongify(self);
                    if (requestRef.isCancelled) {
                        return;
                    }
                    // expired || !expired, either is ok
                    if (operation) {
                        if (success) {
                            id responseInfo = [AFNResponseInfo responseInfoWithRequestOperation:operation requestRef:requestRef];
                            success(responseInfo, responseObject);
                        }
                    }
                    else {
                        [self sendRequest:request config:config requestRef:requestRef success:success failure:failure];
                    }
                }}];
            }
            else {
                if (failure) {
                    id responseInfo = [AFNResponseInfo responseInfoWithRequestOperation:operation requestRef:requestRef];
                    failure(responseInfo, error);
                }
            }
            [requestRef.sender removeRequestRef:requestRef];
        }}];
    });
    
    // data parsing
    NSMutableArray *responseSerializers = [NSMutableArray array];
    if (config.responseParseOptions & M9ResponseParseOption_JSON) {
        [responseSerializers addObject:[AFJSONResponseSerializer serializer]];
    }
    if (config.responseParseOptions & M9ResponseParseOption_Image) {
        [responseSerializers addObject:[AFImageResponseSerializer serializer]];
    }
    if (config.responseParseOptions & M9ResponseParseOption_XML) {
        [responseSerializers addObject:[AFXMLParserResponseSerializer serializer]];
    }
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
    if (config.responseParseOptions & M9ResponseParseOption_XMLDocument) {
        [responseSerializers addObject:[AFXMLDocumentResponseSerializer serializer]];
    }
#endif
    if (config.responseParseOptions & M9ResponseParseOption_PList) {
        [responseSerializers addObject:[AFPropertyListResponseSerializer serializer]];
    }
    if (config.responseParseOptions & M9ResponseParseOption_Data) {
        [responseSerializers addObject:[AFHTTPResponseSerializer serializer]];
    }
    if ([responseSerializers count] == 1) {
        requestOperation.responseSerializer = [responseSerializers firstObject];
    }
    else if ([responseSerializers count] > 1) {
        requestOperation.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:responseSerializers];
    }
    
    // disable NSURLCache
    [requestOperation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
        return nil;
    }];
    
    // !!!: sohu https
    [requestOperation setWillSendRequestForAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
        id<NSURLAuthenticationChallengeSender> sender = [challenge sender];
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            [sender useCredential:credential forAuthenticationChallenge:challenge];
        }
        else {
            [sender continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    }];
    
    requestRef.currentRequestOperation = requestOperation;
    
    [_AFN.operationQueue addOperation:requestOperation];
}}

// callback: responseObject must be nil when operation is nil
- (void)loadCachedResponseWithRequest:(NSMutableURLRequest *)request
                               config:(M9RequestConfig *)config
                             callback:(void (^)(AFHTTPRequestOperation *operation, id responseObject, BOOL expired))callback {
    if (!callback) {
        return;
    }
    // weakify(self);
    [[TMCache sharedCache] objectForKey:[[request URL] absoluteString] block:^(TMCache *cache, NSString *key, id object) {
        if ([object isKindOfClass:[AFHTTPRequestOperation class]]) {
            AFHTTPRequestOperation *cachedOperation = (AFHTTPRequestOperation *)object;
            
            id responseObject = [cachedOperation responseObject];
            // !!!: [cachedOperation responseObject] maybe nil when cache is loaded from disk
            if (!responseObject) {
                AFHTTPResponseSerializer<AFURLResponseSerialization> *responseSerializer = cachedOperation.responseSerializer OR _AFN.responseSerializer;
                responseObject = [responseSerializer responseObjectForResponse:[cachedOperation response] data:[cachedOperation responseData] error:nil];
            }
            
            BOOL expired = [self isResponseExpired:[cachedOperation response]];
            
            dispatch_async_main_queue(^{
                callback(cachedOperation, responseObject, expired);
            });
            return;
        }
        callback(nil, nil, NO);
    }];
}

- (BOOL)isResponseExpired:(NSHTTPURLResponse *)response {
    NSString *expiresOn = [[response allHeaderFields] stringForKey:HTTPExpires];
    NSDate *expiresOnDate = [NSDate dateFromRFC1123:expiresOn];
    return !expiresOnDate || [NSDate timeIntervalSinceDate:expiresOnDate] > 0;
}

- (void)cancelAllWithSender:(id)sender { @synchronized(sender) { // lock: sender.allRequestRefOfSender
    for (M9RequestRef *requestRef in [[sender allRequestRef] copy]) {
        [requestRef cancel];
    }
}}

+ (void)removeAllCachedData {
    [[TMCache sharedCache] removeAllObjects];
}

+ (void)removeCachedDataForKey:(NSString *)key {
    [[TMCache sharedCache] removeObjectForKey:key];
}

@end

#pragma mark -

@implementation M9Networking (finish)

- (M9RequestRef *)GET:(NSString *)URLString
               finish:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject, NSError *error))finish {
    return [self GET:URLString parameters:nil finish:finish];
}

- (M9RequestRef *)GET:(NSString *)URLString
           parameters:(NSDictionary *)parameters
               finish:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject, NSError *error))finish {
    return [self GET:URLString parameters:parameters success:^(id<M9ResponseInfo> responseInfo, id responseObject) {
        if (finish) {
            finish(responseInfo, responseObject, nil);
        }
    } failure:^(id<M9ResponseInfo> responseInfo, NSError *error) {
        if (finish) {
            finish(responseInfo, nil, error);
        }
    }];
}

- (M9RequestRef *)POST:(NSString *)URLString
            parameters:(NSDictionary *)parameters
                finish:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject, NSError *error))finish {
    return [self POST:URLString parameters:parameters success:^(id<M9ResponseInfo> responseInfo, id responseObject) {
        if (finish) {
            finish(responseInfo, responseObject, nil);
        }
    } failure:^(id<M9ResponseInfo> responseInfo, NSError *error) {
        finish(responseInfo, nil, error);
    }];
}

@end

#pragma mark -

@implementation M9Networking (M9RequestInfo)

- (M9RequestRef *)GET:(M9RequestInfo *)requestInfo {
    NSString *URLString = [[NSURL URLWithString:requestInfo.URLString relativeToURL:requestInfo.baseURL] absoluteString];
    NSMutableURLRequest *request = [_AFN.requestSerializer requestWithMethod:HTTPGET URLString:URLString parameters:requestInfo.parameters error:nil];
    [request setAllHTTPHeaderFields:requestInfo.allHTTPHeaderFields];
    return [self sendRequest:request sender:requestInfo.sender config:requestInfo success:requestInfo.success failure:requestInfo.failure];
}

- (M9RequestRef *)POST:(M9RequestInfo *)requestInfo {
    NSString *URLString = [[NSURL URLWithString:requestInfo.URLString relativeToURL:requestInfo.baseURL] absoluteString];
    /* constructingBodyBlock
     NSMutableURLRequest *request = (requestInfo.constructingBodyBlock
     ? [_AFN.requestSerializer multipartFormRequestWithMethod:HTTPPOST URLString:URLString parameters:requestInfo.parameters constructingBodyWithBlock:requestInfo.constructingBodyBlock error:nil]
     : [_AFN.requestSerializer requestWithMethod:HTTPPOST URLString:URLString parameters:requestInfo.parameters error:nil]); */
    NSMutableURLRequest *request = [_AFN.requestSerializer requestWithMethod:HTTPPOST URLString:URLString parameters:requestInfo.parameters error:nil];
    [request setAllHTTPHeaderFields:requestInfo.allHTTPHeaderFields];
    return [self sendRequest:request sender:requestInfo.sender config:requestInfo success:requestInfo.success failure:requestInfo.failure];
}

@end

@implementation M9RequestInfo (M9RequestConfig)

+ (instancetype)requestInfoWithRequestConfig:(M9RequestConfig *)requestConfig {
    M9RequestInfo *requestInfo = [self new];
    [requestConfig makeCopy:requestInfo];
    return requestInfo;
}

@end
