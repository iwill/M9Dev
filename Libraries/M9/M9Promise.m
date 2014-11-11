//
//  M9Promise.m
//  M9Dev
//
//  Created by MingLQ on 2014-11-10.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9Promise.h"

#import "EXTScope.h"

#import "M9Utilities.h"

@class M9Deferred;

typedef void (^M9PromiseHandle)(M9Deferred *deferred);
typedef void (^M9PromiseFinale)();

#pragma mark -

@interface M9Promise ()

@property(nonatomic, strong) id value;

@property(nonatomic, copy, readonly) M9PromiseCall fulfill;
@property(nonatomic, copy, readonly) M9PromiseCall reject;

@property(nonatomic, copy, readonly) M9PromiseHandle handle;
@property(nonatomic, copy, readonly) M9PromiseFinale finale;

@property(nonatomic, strong) NSMutableArray *deferreds;

@end

@interface M9Deferred : NSObject

@property(nonatomic, copy) M9PromiseCallback fulfillCallback, rejectCallback;
@property(nonatomic, copy) M9PromiseCall fulfill, reject;

+ (instancetype)deferred:(M9PromiseCallback)fulfillCallback
                        :(M9PromiseCallback)rejectCallback
                        :(M9PromiseCall)fulfill
                        :(M9PromiseCall)reject;

@end

#pragma mark -

@implementation M9Promise {
    M9PromiseThen _then;
    M9PromiseDone _done;
    M9PromiseCatch _catch;
    
    M9PromiseCall _fulfill;
    M9PromiseCall _reject;
    
    M9PromiseHandle _handle;
    M9PromiseFinale _finale;
}

+ (instancetype)promise:(M9PromiseTask)task {
    return [[self alloc] initWithTask:task];
}

- (instancetype)init {
    return [self initWithTask:nil];
}

- (instancetype)initWithTask:(M9PromiseTask)task {
    self = [super init];
    if (self) {
        weakify(self);
        
        _handle = ^void (M9Deferred *deferred) {
            strongify(self);
            if (self.state == M9PromiseStatePending) {
                [self.deferreds addObject:deferred];
                return;
            }
            dispatch_async_main_queue(^() {
                M9PromiseCallback callback = nil;
                M9PromiseCall call = nil;
                if (self.state == M9PromiseStateFulfilled) {
                    callback = deferred.fulfillCallback;
                    call = deferred.fulfill;
                }
                else if (self.state == M9PromiseStateRejected) {
                    callback = deferred.rejectCallback;
                    call = deferred.reject;
                }
                if (callback) {
                    id value = callback(self.value);
                    deferred.fulfill(value);
                }
                else {
                    call(self.value);
                }
            });
        };
        _finale = ^void () {
            strongify(self);
            for (M9Deferred *deferred in self.deferreds) {
                self.handle(deferred);
            }
            self.deferreds = nil;
        };
        
        _then = ^M9Promise *(M9PromiseCallback fulfillCallback, M9PromiseCallback rejectCallback) {
            return [M9Promise promise:^(M9PromiseCall fulfill, M9PromiseCall reject) {
                strongify(self);
                self.handle([M9Deferred deferred:fulfillCallback :rejectCallback :fulfill :reject]);
            }];
        };
        
        _done = ^M9Promise *(M9PromiseCallback fulfillCallback) {
            strongify(self);
            return self.then(fulfillCallback, nil);
        };
        
        _catch = ^M9Promise *(M9PromiseCallback rejectCallback) {
            strongify(self);
            return self.then(nil, rejectCallback);
        };
        
        _fulfill = ^void (id value) {
            strongify(self);
            if (self.state != M9PromiseStatePending) {
                return;
            }
            if (value == self) {
                self.reject([NSError errorWithDomain:M9PromiseError code:M9PromiseErrorCode_TypeError userInfo:nil]);
                return;
            }
            if ([value isKindOfClass:[M9Promise class]]) {
                M9Promise *newPromise = (M9Promise *)value;
                newPromise.then(^id (id value) {
                    self.fulfill(value);
                    return nil; // ???:
                }, ^id (id value) {
                    self.reject(value);
                    return nil; // ???:
                });
                return;
            }
            self.state = M9PromiseStateFulfilled;
            self.value = value;
            self.finale();
        };
        
        _reject = ^void (id value) {
            strongify(self);
            if (self.state != M9PromiseStatePending) {
                return;
            }
            if (value == self) {
                self.reject([NSError errorWithDomain:M9PromiseError code:M9PromiseErrorCode_TypeError userInfo:nil]);
            }
            self.state = M9PromiseStateRejected;
            self.value = value;
            self.finale();
        };
        
        task(self.fulfill, self.reject);
    }
    return self;
}

+ (instancetype)all:(id)first, ... {
    M9Promise *promise = [self new];
    // TODO: NSMutableArray *tasks = va_array(id, first);
    return promise;
}

+ (instancetype)any:(id)first, ... {
    M9Promise *promise = [self new];
    // TODO: NSMutableArray *tasks = va_array(id, first);
    return promise;
}

@end

@implementation M9Deferred

+ (instancetype)deferred:(M9PromiseCallback)fulfillCallback
                        :(M9PromiseCallback)rejectCallback
                        :(M9PromiseCall)fulfill
                        :(M9PromiseCall)reject {
    M9Deferred *deferred = [self new];
    deferred.fulfillCallback = fulfillCallback;
    deferred.rejectCallback = rejectCallback;
    deferred.fulfill = fulfill;
    deferred.reject = reject;
    return deferred;
}

@end
