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

@interface M9Promise ()

@property(nonatomic, copy) M9PromiseTask task;
@property(nonatomic, strong) id value;
@property(nonatomic, strong) M9Promise *next;

@property(nonatomic, copy, readonly) M9PromiseCallback fulfill;
@property(nonatomic, copy, readonly) M9PromiseCallback reject;

@property(nonatomic, strong) NSMutableArray *fulfillCallbacks, *rejectCallbacks;

@end

void resolveNext(M9Promise *nextPromise, id xValue) {
    if (xValue == nextPromise) {
        nextPromise.reject([NSError errorWithDomain:M9PromiseError code:M9PromiseErrorCode_TypeError userInfo:nil]);
    }
    
    if ([xValue isKindOfClass:[M9Promise class]]) {
        M9Promise *xPromise = (M9Promise *)xValue;
        if (xPromise.state == M9PromiseStateFulfilled) {
            nextPromise.fulfill(xPromise.value);
        }
        else if (xPromise.state == M9PromiseStateRejected) {
            nextPromise.reject(xPromise.value);
        }
        else if (xPromise.state == M9PromiseStatePending) {
            xPromise.then(nextPromise.fulfill, nextPromise.reject);
        }
    }
    else {
        nextPromise.fulfill(xValue);
    }
};

void fire(M9Promise *promise) {
    NSArray *callbacks = nil;
    if (promise.state == M9PromiseStateFulfilled) {
        callbacks = promise.fulfillCallbacks;
    }
    else if (promise.state == M9PromiseStateRejected) {
        callbacks = promise.rejectCallbacks;
    }
    id value = promise.value;
    
    for (id (^callback)(id value) in callbacks) {
        resolveNext(promise.next, callback(value));
    }
    [promise.fulfillCallbacks removeAllObjects];
    [promise.rejectCallbacks removeAllObjects];
}

@implementation M9Promise {
    M9Then _then;
    M9Done _done;
    M9Catch _catch;
    
    M9PromiseCallback _fulfill;
    M9PromiseCallback _reject;
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
        
        self.task = [task copy];
        
        _then = ^M9Promise *(M9PromiseCallback fulfillCallback, M9PromiseCallback rejectCallback) {
            strongify(self);
            
            self.next = [M9Promise new];
            
            dispatch_async_main_queue(^() {
                if (self.state == M9PromiseStateFulfilled) {
                    resolveNext(self.next, fulfillCallback(self.value));
                }
                else if (self.state == M9PromiseStateRejected) {
                    resolveNext(self.next, rejectCallback(self.value));
                }
                else if (self.state == M9PromiseStatePending) {
                    if (fulfillCallback) {
                        self.fulfillCallbacks = self.fulfillCallbacks OR [NSMutableArray new];
                        [self.fulfillCallbacks addObject:[fulfillCallback copy]];
                    }
                    if (rejectCallback) {
                        self.rejectCallbacks = self.rejectCallbacks OR [NSMutableArray new];
                        [self.rejectCallbacks addObject:[rejectCallback copy]];
                    }
                }
            });
            
            /* TODO:
            self.next = [M9Promise promise:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
            }]; */
            
            return self.next;
        };
        
        _done = ^M9Promise *(M9PromiseCallback fulfillCallback) {
            strongify(self);
            return self.then(fulfillCallback, nil);
        };
        
        _catch = ^M9Promise *(M9PromiseCallback rejectCallback) {
            strongify(self);
            return self.then(nil, rejectCallback);
        };
        
        _fulfill = ^id (id value) {
            strongify(self);
            if (self.state == M9PromiseStateRejected) {
                @throw [NSException exceptionWithName:M9PromiseException reason:@"Illegal call." userInfo:nil];
            }
            self.state = M9PromiseStateFulfilled;
            self.value = value;
            fire(self);
            return self;
        };
        
        _reject = ^id (id reason) {
            strongify(self);
            if (self.state == M9PromiseStateFulfilled) {
                @throw [NSException exceptionWithName:M9PromiseException reason:@"Illegal call." userInfo:nil];
            }
            self.state = M9PromiseStateRejected;
            self.value = reason;
            fire(self);
            return self;
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
