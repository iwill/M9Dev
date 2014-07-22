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

#import <AFNetworking/AFNetworking.h>
#import <TMCache/TMCache.h>
#import "NSDate+RFC1123.h"
#import "EXTScope.h"

#import "NSDictionary+Shortcuts.h"
#import "NSDate+.h"

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

typedef void (^M9LoadCachedResponseCallback)(AFHTTPRequestOperation *operation, id responseObject, BOOL expired);

@interface M9Networking ()

@end

@implementation M9Networking {
    AFHTTPRequestOperationManager *_AFN;
    AFHTTPRequestSerializer<AFURLRequestSerialization> *HTTPRequestSerializer;
    AFJSONRequestSerializer<AFURLRequestSerialization> *JSONRequestSerializer;
    AFPropertyListRequestSerializer<AFURLRequestSerialization> *PListRequestSerializer;
}

+ (instancetype)sharedInstance {
    static M9Networking *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
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

- (M9RequestRef *)request:(M9RequestInfo *)requestInfo {
    NSMutableURLRequest *request = [self requestWithRequestInfo:requestInfo];
    [request setAllHTTPHeaderFields:requestInfo.allHTTPHeaderFields];
    
    M9RequestRef *requestRef = [M9RequestRef requestRefWithSender:requestInfo.sender];
    [requestInfo.sender addRequestRef:requestRef];
    
    if (requestInfo.useCachedDataWithoutLoading) {
        // weakify(self);
        [self loadCachedResponseWithRequest:request config:requestInfo callback:^(AFHTTPRequestOperation *operation, id responseObject, BOOL expired)
         { @synchronized(requestRef) {
            // strongify(self);
            if (requestRef.isCancelled) {
                return;
            }
            if (operation) {
                if (requestInfo.success) {
                    id responseInfo = [AFNResponseInfo responseInfoWithRequestOperation:operation requestRef:requestRef];
                    requestInfo.success(responseInfo, responseObject);
                }
            }
            else {
                if (requestInfo.failure) {
                    id responseInfo = [AFNResponseInfo responseInfoWithRequestOperation:operation requestRef:requestRef];
                    requestInfo.failure(responseInfo, nil);
                }
            }
        }}];
    }
    else if (requestInfo.useCachedData) {
        weakify(self);
        [self loadCachedResponseWithRequest:request config:requestInfo callback:^(AFHTTPRequestOperation *operation, id responseObject, BOOL expired)
         { @synchronized(requestRef) {
            strongify(self);
            if (requestRef.isCancelled) {
                return;
            }
            if (operation && !expired) {
                requestRef.usedCachedData = YES;
                if (requestInfo.success) {
                    id responseInfo = [AFNResponseInfo responseInfoWithRequestOperation:operation requestRef:requestRef];
                    requestInfo.success(responseInfo, responseObject);
                }
            }
            else {
                [self sendRequest:request config:requestInfo requestRef:requestRef success:requestInfo.success failure:requestInfo.failure];
            }
        }}];
    }
    else {
        [self sendRequest:request config:requestInfo requestRef:requestRef success:requestInfo.success failure:requestInfo.failure];
    }
    
    return requestRef;
}

- (void)cancelAllWithSender:(id)sender { @synchronized(sender) { // lock: sender.allRequestRefOfSender
    for (M9RequestRef *requestRef in [[sender allRequestRef] copy]) {
        [requestRef cancel];
    }
}}

+ (void)removeAllCachedData {
    [[TMCache sharedCache] removeAllObjects];
}

+ (void)removeCachedDataForURLString:(NSString *)key {
    [[TMCache sharedCache] removeObjectForKey:key];
}

#pragma mark private

- (NSMutableURLRequest *)requestWithRequestInfo:(M9RequestInfo *)requestInfo {
    AFHTTPRequestSerializer<AFURLRequestSerialization> *requestSerializer = nil;
    switch (requestInfo.parametersFormatter) {
        case M9RequestParametersFormatter_JSON:
            if (!JSONRequestSerializer) {
                JSONRequestSerializer = [AFJSONRequestSerializer serializer];
            }
            requestSerializer = JSONRequestSerializer;
            break;
        case M9RequestParametersFormatter_PList:
            if (!PListRequestSerializer) {
                PListRequestSerializer = [AFPropertyListRequestSerializer serializer];
            }
            requestSerializer = PListRequestSerializer;
            break;
        default: // M9RequestParametersFormatter_KeyValue & M9RequestParametersFormatter_KeyJSON
            if (!HTTPRequestSerializer) {
                HTTPRequestSerializer = [AFHTTPRequestSerializer serializer];
            }
            requestSerializer = HTTPRequestSerializer;
            break;
    }
    
    NSString *URLString = [[NSURL URLWithString:requestInfo.URLString relativeToURL:requestInfo.baseURL] absoluteString];
    
    NSDictionary *parameters = nil;
    if (requestInfo.parametersFormatter == M9RequestParametersFormatter_KeyJSON
        || (requestInfo.parametersFormatter != M9RequestParametersFormatter_KeyValue && requestSerializer.HTTPMethodsEncodingParametersInURI)) {
        NSMutableDictionary *formatedParameters = [NSMutableDictionary new];
        for (__strong id key in requestInfo.parameters) {
            id value = parameters[key];
            key = [key description];
            if ([value isKindOfClass:[NSSet class]]) {
                value = [(NSSet *)value allObjects];
            }
            if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:value options:0 error:nil] encoding:NSUTF8StringEncoding];
            }
            else {
                value = [value description];
            }
            [formatedParameters setObject:value OR @"" forKey:key OR @""];
        }
        parameters = formatedParameters;
    }
    else {
        parameters = requestInfo.parameters;
    }
    
    return [requestSerializer requestWithMethod:requestInfo.HTTPMethod OR HTTPGET URLString:URLString parameters:parameters error:nil];
}

- (void)sendRequest:(NSMutableURLRequest *)request config:(M9RequestConfig *)config requestRef:(M9RequestRef *)requestRef success:(M9RequestSuccess)success failure:(M9RequestFailure)failure
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
                    // strongify(self);
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
                        if (failure) {
                            id responseInfo = [AFNResponseInfo responseInfoWithRequestOperation:operation requestRef:requestRef];
                            failure(responseInfo, error);
                        }
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
    if (config.dataParser & M9ResponseDataParser_JSON) {
        [responseSerializers addObject:[AFJSONResponseSerializer serializer]];
    }
    if (config.dataParser & M9ResponseDataParser_Image) {
        [responseSerializers addObject:[AFImageResponseSerializer serializer]];
    }
    if (config.dataParser & M9ResponseDataParser_XML) {
        [responseSerializers addObject:[AFXMLParserResponseSerializer serializer]];
    }
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
    if (config.dataParser & M9ResponseDataParser_XMLDocument) {
        [responseSerializers addObject:[AFXMLDocumentResponseSerializer serializer]];
    }
#endif
    if (config.dataParser & M9ResponseDataParser_PList) {
        [responseSerializers addObject:[AFPropertyListResponseSerializer serializer]];
    }
    if (config.dataParser & M9ResponseDataParser_Data) {
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
    
    // https
    [requestOperation setWillSendRequestForAuthenticationChallengeBlock:self.requestConfig.willSendRequestForAuthenticationChallengeBlock];
    
    requestRef.currentRequestOperation = requestOperation;
    
    [_AFN.operationQueue addOperation:requestOperation];
}}

// callback: responseObject must be nil when operation is nil
- (void)loadCachedResponseWithRequest:(NSMutableURLRequest *)request config:(M9RequestConfig *)config callback:(M9LoadCachedResponseCallback)callback {
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

@end

#pragma mark - simple

@implementation M9Networking (simple)

- (M9RequestRef *)GET:(NSString *)URLString success:(M9RequestSuccess)success failure:(M9RequestFailure)failure {
    return [self GET:URLString parameters:nil success:success failure:failure];
}

- (M9RequestRef *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(M9RequestSuccess)success failure:(M9RequestFailure)failure {
    M9RequestInfo *requestInfo = [M9RequestInfo requestInfoWithRequestConfig:self.requestConfig];
    requestInfo.HTTPMethod = HTTPGET;
    requestInfo.URLString = URLString;
    requestInfo.parameters = parameters;
    requestInfo.success = success;
    requestInfo.failure = failure;
    return [self request:requestInfo];
}

- (M9RequestRef *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(M9RequestSuccess)success failure:(M9RequestFailure)failure {
    M9RequestInfo *requestInfo = [M9RequestInfo requestInfoWithRequestConfig:self.requestConfig];
    requestInfo.HTTPMethod = HTTPPOST;
    requestInfo.URLString = URLString;
    requestInfo.parameters = parameters;
    requestInfo.success = success;
    requestInfo.failure = failure;
    return [self request:requestInfo];
}

- (M9RequestRef *)GET:(NSString *)URLString finish:(M9RequestFinish)finish {
    return [self GET:URLString parameters:nil finish:finish];
}

- (M9RequestRef *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters finish:(M9RequestFinish)finish {
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

- (M9RequestRef *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters finish:(M9RequestFinish)finish {
    return [self POST:URLString parameters:parameters success:^(id<M9ResponseInfo> responseInfo, id responseObject) {
        if (finish) {
            finish(responseInfo, responseObject, nil);
        }
    } failure:^(id<M9ResponseInfo> responseInfo, NSError *error) {
        finish(responseInfo, nil, error);
    }];
}

@end

#pragma mark - M9RequestInfo

@implementation M9RequestInfo (M9RequestConfig)

+ (instancetype)requestInfoWithRequestConfig:(M9RequestConfig *)requestConfig {
    M9RequestInfo *requestInfo = [self new];
    [requestConfig makeCopy:requestInfo];
    return requestInfo;
}

@end
