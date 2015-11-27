//
//  M9Networking.m
//  M9Dev
//
//  Created by MingLQ on 2014-07-01.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
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

#import "NSDictionary+M9.h"
#import "NSDate+M9.h"

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

- (M9RequestRef *)send:(M9RequestInfo *)requestInfo {
    M9RequestRef *requestRef = [M9RequestRef requestRefWithOwner:requestInfo.owner];
    [requestInfo.owner addRequestRef:requestRef];
    
    NSMutableURLRequest *request = [self requestWithRequestInfo:requestInfo];
    [request setAllHTTPHeaderFields:requestInfo.allHTTPHeaderFields];
    
    M9RequestConfig *config = requestInfo;
    
    M9RequestParsing parsing = requestInfo.parsing;
    M9RequestSuccess success = parsing ? ^(id<M9ResponseInfo> responseInfo, id responseObject) {
        NSError *error = nil;
        responseObject = parsing(responseInfo, responseObject, &error);
        if (!error) {
            if (requestInfo.success) {
                requestInfo.success(responseInfo, responseObject);
            }
        }
        else {
            if (requestInfo.failure) {
                requestInfo.failure(responseInfo, error);
            }
        }
    } : requestInfo.success;
    M9RequestFailure failure = requestInfo.failure;
    
    if (!requestInfo.useCachedDataWithoutLoading && !requestInfo.useCachedData) {
        [self sendRequest:request config:config requestRef:requestRef success:success failure:failure];
        return requestRef;
    }
    
    @weakify(self);
    [self loadCachedResponseWithRequest:request callback:^(AFHTTPRequestOperation *operation, id responseObject, BOOL expired)
     { @synchronized(requestRef) {
        @strongify(self);
        if (requestRef.isCancelled) {
            return;
        }
        if (operation && (!expired || requestInfo.useCachedDataWithoutLoading)) {
            requestRef.usedCachedData = YES;
            if (success) {
                id responseInfo = [AFNResponseInfo responseInfoWithRequestOperation:operation requestRef:requestRef];
                success(responseInfo, responseObject);
            }
        }
        else if (requestInfo.useCachedDataWithoutLoading) {
            if (failure) {
                id responseInfo = [AFNResponseInfo responseInfoWithRequestOperation:operation requestRef:requestRef];
                failure(responseInfo, nil);
            }
        }
        else {
            [self sendRequest:request config:config requestRef:requestRef success:success failure:failure];
        }
    }}];
    
    return requestRef;
}

- (void)cancelAllWithOwner:(id)owner { @synchronized(owner) { // lock: owner.allRequestRefOfOwner
    [[owner allRequestRef] makeObjectsPerformSelector:@selector(cancel)];
    [owner removeAllRequestRef];
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
    
    NSDictionary *parameters = requestInfo.parameters;
    if (requestInfo.parametersFormatter == M9RequestParametersFormatter_KeyJSON
        || (requestInfo.parametersFormatter != M9RequestParametersFormatter_KeyValue && requestSerializer.HTTPMethodsEncodingParametersInURI)) {
        NSMutableDictionary *formatedParameters = [NSMutableDictionary new];
        for (__strong id key in parameters) {
            id value = parameters[key];
            
            key = [key description] OR [NSString stringWithFormat:@"%@", key];
            
            if ([value isKindOfClass:[NSSet class]]) {
                value = [(NSSet *)value allObjects];
            }
            if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:value options:0 error:nil] encoding:NSUTF8StringEncoding];
            }
            else {
                value = [value description];
            }
            
            [formatedParameters setObject:value OR @"" forKey:key];
        }
        parameters = formatedParameters;
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
    @weakify(self);
    AFHTTPRequestOperation *requestOperation = ({
        _RETURN [_AFN HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject)
         { @synchronized(requestRef) {
            // @strongify(self);
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
            [requestRef.owner removeRequestRef:requestRef];
        }} failure:^(AFHTTPRequestOperation *operation, NSError *error)
         { @synchronized(requestRef) {
            @strongify(self);
            if (requestRef.isCancelled) {
                return;
            }
            if (error.code == NSURLErrorTimedOut && requestRef.retriedTimes < config.maxRetryTimes) {
                requestRef.retriedTimes++;
                [self sendRequest:request config:config requestRef:requestRef success:success failure:failure];
                return;
            }
            if (config.useCachedDataWhenFailure) {
                [self loadCachedResponseWithRequest:request callback:^(AFHTTPRequestOperation *operation, id responseObject, BOOL expired)
                 { @synchronized(requestRef) {
                    // @strongify(self);
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
            [requestRef.owner removeRequestRef:requestRef];
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
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
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
- (void)loadCachedResponseWithRequest:(NSMutableURLRequest *)request callback:(M9LoadCachedResponseCallback)callback {
    if (!callback) {
        return;
    }
    // @weakify(self);
    [[TMCache sharedCache] objectForKey:[[request URL] absoluteString] block:^(TMCache *cache, NSString *key, id object) {
        AFHTTPRequestOperation *cachedOperation = nil;
        id responseObject = nil;
        BOOL expired = NO;
        
        if ([object isKindOfClass:[AFHTTPRequestOperation class]]) {
            cachedOperation = (AFHTTPRequestOperation *)object;
            
            responseObject = [cachedOperation responseObject];
            // !!!: [cachedOperation responseObject] maybe nil when cache is loaded from disk
            if (!responseObject) {
                AFHTTPResponseSerializer<AFURLResponseSerialization> *responseSerializer = cachedOperation.responseSerializer OR _AFN.responseSerializer;
                responseObject = [responseSerializer responseObjectForResponse:[cachedOperation response] data:[cachedOperation responseData] error:nil];
            }
            
            expired = [self isResponseExpired:[cachedOperation response]];
        }
        
        dispatch_async_main_queue(^{
            callback(cachedOperation, responseObject, expired);
        });
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
    [requestInfo setHTTPMethod:HTTPGET URLString:URLString parameters:parameters];
    [requestInfo setSuccess:success failure:failure];
    return [self send:requestInfo];
}

- (M9RequestRef *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(M9RequestSuccess)success failure:(M9RequestFailure)failure {
    M9RequestInfo *requestInfo = [M9RequestInfo requestInfoWithRequestConfig:self.requestConfig];
    [requestInfo setHTTPMethod:HTTPPOST URLString:URLString parameters:parameters];
    [requestInfo setSuccess:success failure:failure];
    return [self send:requestInfo];
}

- (M9RequestRef *)GET:(NSString *)URLString finish:(M9RequestFinish)finish {
    return [self GET:URLString parameters:nil finish:finish];
}

- (M9RequestRef *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters finish:(M9RequestFinish)finish {
    M9RequestInfo *requestInfo = [M9RequestInfo requestInfoWithRequestConfig:self.requestConfig];
    [requestInfo setHTTPMethod:HTTPGET URLString:URLString parameters:parameters];
    [requestInfo setSuccessAndFailureByFinish:finish];
    return [self send:requestInfo];
}

- (M9RequestRef *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters finish:(M9RequestFinish)finish {
    M9RequestInfo *requestInfo = [M9RequestInfo requestInfoWithRequestConfig:self.requestConfig];
    [requestInfo setHTTPMethod:HTTPPOST URLString:URLString parameters:parameters];
    [requestInfo setSuccessAndFailureByFinish:finish];
    return [self send:requestInfo];
}

@end
