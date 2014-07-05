//
//  M9Networking.m
//  iM9
//
//  Created by MingLQ on 2014-07-01.
//  Copyright (c) 2014年 SOHU. All rights reserved.
//

#if ! __has_feature(objc_arc)
// Add -fobjc-arc or remove -fno-objc-arc: Target > Build Phases > Compile Sources > implementation.m
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import "M9Networking.h"

#import "AFNetworking.h"

#import "NSObject+AssociatedValues.h"

#define HTTPGET @"GET"
#define HTTPPOST @"POST"

@interface M9RequestRef ()

@property(nonatomic, readwrite) NSInteger requestID;
@property(nonatomic, readwrite) NSInteger retryTimes;
@property(nonatomic, readwrite) BOOL usedCachedData;
@property(nonatomic, readwrite) AFHTTPRequestOperation *currentRequestOperation;

- (instancetype)initWithSender:(id)sender;
+ (instancetype)requestRefWithSender:(id)sender;

@property(nonatomic, readwrite, setter = setCancelled:) BOOL isCancelled;
- (void)cancel;

- (void)addToSender;
- (void)removeFromSender;
+ (NSMutableArray *)allRequestRefOfSender:(id)sender;

@end

#pragma mark -

@interface AFHTTPRequestOperation (M9Response) <M9Response>

@end

@implementation AFHTTPRequestOperation (M9Response)

+ (void)load {
    NSAssert([self instancesRespondToSelector:@selector(request)],
             @"AFHTTPRequestOperation doesNotRecognizeSelector:request");
    NSAssert([self instancesRespondToSelector:@selector(response)],
             @"AFHTTPRequestOperation doesNotRecognizeSelector:response");
    NSAssert([self instancesRespondToSelector:@selector(responseData)],
             @"AFHTTPRequestOperation doesNotRecognizeSelector:responseData");
    NSAssert([self instancesRespondToSelector:@selector(responseString)],
             @"AFHTTPRequestOperation doesNotRecognizeSelector:responseString");
    NSAssert([self instancesRespondToSelector:@selector(responseObject)],
             @"AFHTTPRequestOperation doesNotRecognizeSelector:responseObject");
    NSAssert([self instancesRespondToSelector:@selector(error)],
             @"AFHTTPRequestOperation doesNotRecognizeSelector:error");
}

@end

#pragma mark -

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

+ (instancetype)instanceWithRequestSettings:(M9RequestSettings *)requestSettings {
    return [[self alloc] initWithRequestSettings:requestSettings];
}

- (id)init {
    return [self initWithRequestSettings:[M9RequestSettings new]];
}

- (instancetype)initWithRequestSettings:(M9RequestSettings *)requestSettings {
    self = [super init];
    if (self) {
        _AFN = [AFHTTPRequestOperationManager manager];
        self.requestSettings = requestSettings;
    }
    return self;
}

#pragma mark request

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

- (M9RequestRef *)sendRequest:(NSMutableURLRequest *)request
                     settings:(M9RequestSettings *)requestSettings
                      success:(void (^)(id<M9Response> response, id responseObject, M9RequestRef *requestRef))success
                      failure:(void (^)(id<M9Response> response, NSError *error, M9RequestRef *requestRef))failure {
    return [self sendRequest:request sender:nil settings:requestSettings success:success failure:failure];
}

- (M9RequestRef *)sendRequest:(NSMutableURLRequest *)request
                       sender:(id)sender
                     settings:(M9RequestSettings *)requestSettings
                      success:(void (^)(id<M9Response> response, id responseObject, M9RequestRef *requestRef))success
                      failure:(void (^)(id<M9Response> response, NSError *error, M9RequestRef *requestRef))failure {
    M9RequestRef *requestRef = [M9RequestRef requestRefWithSender:sender];
    if (sender) {
        [requestRef addToSender];
    }
    [self sendRequest:request settings:requestSettings requestRef:requestRef success:success failure:failure];
    return requestRef;
}

#pragma mark send & cancel request

- (void)sendRequest:(NSMutableURLRequest *)request
           settings:(M9RequestSettings *)requestSettings
         requestRef:(M9RequestRef *)requestRef
            success:(void (^)(id<M9Response> response, id responseObject, M9RequestRef *requestRef))success
            failure:(void (^)(id<M9Response> response, NSError *error, M9RequestRef *requestRef))failure
{ @synchronized(requestRef) { // lock: requestRef.isCancelled && requestRef.currentRequestOperation
    NSParameterAssert(requestRef);
    
    if (requestRef.isCancelled) {
        return;
    }
    
    // callback
    requestRef.currentRequestOperation = [_AFN HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (requestRef.isCancelled) {
            return;
        }
        success(operation, responseObject, requestRef);
        [requestRef removeFromSender];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (requestRef.isCancelled) {
            return;
        }
        if (requestRef.retryTimes < requestSettings.maxRetryTimes) {
            requestRef.retryTimes++;
            [self sendRequest:request settings:requestSettings requestRef:requestRef success:success failure:failure];
            return;
        }
        failure(operation, error, requestRef);
        [requestRef removeFromSender];
    }];
    
    // data parsing
    NSMutableArray *responseSerializers = [NSMutableArray array];
    if (requestSettings.responseParseOptions & M9ResponseParseOption_Data) {
        [responseSerializers addObject:[AFHTTPResponseSerializer serializer]];
    }
    if (requestSettings.responseParseOptions & M9ResponseParseOption_JSON) {
        [responseSerializers addObject:[AFJSONResponseSerializer serializer]];
    }
    if (requestSettings.responseParseOptions & M9ResponseParseOption_XML) {
        [responseSerializers addObject:[AFXMLParserResponseSerializer serializer]];
    }
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
    if (requestSettings.responseParseOptions & M9ResponseParseOption_XMLDocument) {
        [responseSerializers addObject:[AFXMLDocumentResponseSerializer serializer]];
    }
#endif
    if (requestSettings.responseParseOptions & M9ResponseParseOption_PList) {
        [responseSerializers addObject:[AFPropertyListResponseSerializer serializer]];
    }
    if (requestSettings.responseParseOptions & M9ResponseParseOption_Image) {
        [responseSerializers addObject:[AFImageResponseSerializer serializer]];
    }
    if ([responseSerializers count] == 1) {
        requestRef.currentRequestOperation.responseSerializer = [responseSerializers firstObject];
    }
    else if ([responseSerializers count] > 1) {
        requestRef.currentRequestOperation.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:responseSerializers];
    }
    
    // send request
    [_AFN.operationQueue addOperation:requestRef.currentRequestOperation];
}}

- (void)cancelAllWithSender:(id)sender { @synchronized(sender) { // lock: sender.allRequestRefOfSender
    for (M9RequestRef *requestRef in [[M9RequestRef allRequestRefOfSender:sender] copy]) {
        [requestRef cancel];
    }
}}

@end

#pragma mark -

/**
 * AFN
 *  cache:
 *      http://nshipster.com/nsurlcache/
 *      http://stackoverflow.com/questions/10250055/sdurlcache-with-afnetworking-and-offline-mode-not-working
 *      http://blog.originate.com/blog/2014/02/20/afimagecache-vs-nsurlcache/
 *  retry:
 *      https://github.com/AFNetworking/AFNetworking/issues/393
 */

@implementation M9RequestSettings

@M9MakeCopyWithZone;

- (id)init {
    self = [super init];
    if (self) {
        self.timeoutInterval = 10;
        self.maxRetryTimes = 2;
        self.cacheData = YES;
        self.useCachedData = YES;
        self.useCachedDataWhenFailure = NO;
    }
    return self;
}

- (void)makeCopy:(M9RequestSettings *)copy {
    copy.timeoutInterval = self.timeoutInterval;
    copy.maxRetryTimes = self.maxRetryTimes;
    copy.cacheData = self.cacheData;
    copy.useCachedData = self.useCachedData;
    copy.useCachedDataWhenFailure = self.useCachedDataWhenFailure;
}

@end

@implementation M9RequestInfo

- (void)makeCopy:(M9RequestInfo *)copy {
    [super makeCopy:copy];
    copy.URLString = self.URLString;
    copy.parameters = self.parameters;
    copy.success = self.success;
    copy.failure = self.failure;
    copy.sender = self.sender;
}

+ (instancetype)requestInfoWithSettings:(M9RequestSettings *)requestSettings {
    M9RequestInfo *requestInfo = [self new];
    [requestSettings makeCopy:requestInfo];
    return requestInfo;
}

@end

@implementation M9RequestRef {
    __weak id _sender;
}

+ (instancetype)requestRefWithSender:(id)sender {
    return [[self alloc] initWithSender:sender];
}

- (instancetype)initWithSender:(id)sender {
    self = [super init];
    if (self) {
        @synchronized([self class]) {
            static NSInteger M9RequestID = 1;
            self.requestID = M9RequestID++;
            _sender = sender;
        }
    }
    return self;
}

- (NSUInteger)hash {
    return self.requestID;
}

- (BOOL)isEqual:(id)object {
    return ([object isMemberOfClass:[self class]]
            && ((M9RequestRef *)object).requestID == self.requestID);
}

- (BOOL)isCancelled { @synchronized(self) { // lock: requestRef.isCancelled && requestRef.currentRequestOperation
    return _isCancelled;
}}

- (void)cancel { @synchronized(self) { // lock: requestRef.isCancelled && requestRef.currentRequestOperation
    self.isCancelled = YES;
    [self.currentRequestOperation cancel];
}}

#pragma mark - sender.allRequestRefOfSender

static void *const M9RequestRef_allRequestRefOfSender = (void *)&M9RequestRef_allRequestRefOfSender;

- (void)addToSender { @synchronized(_sender) { // lock: sender.allRequestRefOfSender
    if (!_sender) {
        return;
    }
    NSMutableArray *allRequestRefOfSender = [[self class] allRequestRefOfSender:_sender];
    if (!allRequestRefOfSender) {
        allRequestRefOfSender = [NSMutableArray array];
        [_sender associateValue:allRequestRefOfSender withKey:M9RequestRef_allRequestRefOfSender];
    }
    [allRequestRefOfSender addObject:self];
}}

- (void)removeFromSender { @synchronized(_sender) { // lock: sender.allRequestRefOfSender
    if (!_sender) {
        return;
    }
    NSMutableArray *allRequestRefOfSender = [[self class] allRequestRefOfSender:_sender];
    [allRequestRefOfSender removeObject:self];
    if (![allRequestRefOfSender count]) {
        [_sender associateValue:nil withKey:M9RequestRef_allRequestRefOfSender];
    }
}}

+ (NSMutableArray *)allRequestRefOfSender:(id)sender { @synchronized(sender) { // lock: sender.allRequestRefOfSender
    if (!sender) {
        return nil;
    }
    return [sender associatedValueForKey:M9RequestRef_allRequestRefOfSender class:[NSMutableArray class]];
}}

@end

