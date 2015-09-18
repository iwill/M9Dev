//
//  M9Promise.m
//  M9Dev
//
//  Created by MingLQ on 2014-12-24.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "M9Promise.h"

#import "M9Utilities.h"

@class M9Deferred;

typedef NS_ENUM(NSInteger, M9PromiseState) {
    M9PromiseStatePending = 0,
    M9PromiseStateFulfilled,
    M9PromiseStateRejected
};

#pragma mark -

@interface M9Promise ()

@property(nonatomic) M9PromiseState state;
@property(nonatomic, strong) id value;

@property(nonatomic, weak, readonly) M9PromiseCallback fulfill, reject;

@property(nonatomic, strong) NSMutableArray *deferreds;

@end

@interface M9Deferred : NSObject

@property(nonatomic, copy) M9ThenableCallback fulfillCallback, rejectCallback;
@property(nonatomic, copy) M9PromiseCallback nextFulfill, nextReject;

+ (instancetype)deferred:(M9ThenableCallback)fulfillCallback
                        :(M9ThenableCallback)rejectCallback
                        :(M9PromiseCallback)nextFulfill
                        :(M9PromiseCallback)nextReject;

@end

#pragma mark -

@implementation M9Promise

- (instancetype)initWithBlock:(M9PromiseBlock)block {
    self = [super init];
    if (self) {
        @weakify(self);
        
        _afterwards = ^M9Promise *(M9ThenableCallback fulfillCallback, M9ThenableCallback rejectCallback) {
            @strongify(self);
            return [self then:fulfillCallback fail:rejectCallback];
        };
        
        _then = ^M9Promise *(M9ThenableCallback fulfillCallback) {
            @strongify(self);
            return [self then:fulfillCallback];
        };
        
        _fail = ^M9Promise *(M9ThenableCallback rejectCallback) {
            @strongify(self);
            return [self fail:rejectCallback];
        };
        
        _always = ^M9Promise *(M9ThenableCallback callback) {
            @strongify(self);
            return [self then:callback fail:callback];
        };
        
        M9PromiseCallback fulfill = ^void (id value) {
            if (value == self) {
                self.reject([NSError errorWithDomain:M9PromiseError code:M9PromiseErrorCode_TypeError userInfo:nil]);
                return;
            }
            if ([value conformsToProtocol:@protocol(M9Thenable)]) {
                id<M9Thenable> thanable = (id<M9Thenable>)value;
                // !!!: then callbacks needs capture fulfill and reject callback, because they are not captured by self
                M9PromiseCallback fulfill = self.fulfill, reject = self.reject;
                [thanable then:^id (id value) {
                    fulfill(value);
                    return nil;
                } fail:^id (id value) {
                    reject(value);
                    return nil;
                }];
                return;
            }
            self.state = M9PromiseStateFulfilled;
            self.value = value;
            [self finale];
        }, reject = ^void (id value) {
            if (value == self) {
                self.reject([NSError errorWithDomain:M9PromiseError code:M9PromiseErrorCode_TypeError userInfo:nil]);
            }
            self.state = M9PromiseStateRejected;
            self.value = value;
            [self finale];
        };
        
        _fulfill = fulfill;
        _reject = reject;
        
        __block BOOL done = NO;
        block(^void (id value) {
            if (done) return;
            done = YES;
            fulfill(value);
        }, ^void (id value) {
            if (done) return;
            done = YES;
            reject(value);
        });
    }
    return self;
}

#pragma mark oc-style

- (instancetype)then:(M9ThenableCallback)fulfillCallback fail:(M9ThenableCallback)rejectCallback {
    @weakify(self);
    return [M9Promise when:^(M9PromiseCallback nextFulfill, M9PromiseCallback nextReject) {
        @strongify(self);
        [self handle:[M9Deferred deferred:fulfillCallback :rejectCallback :nextFulfill :nextReject]];
    }];
}

- (instancetype)then:(M9ThenableCallback)fulfillCallback {
    return [self then:fulfillCallback fail:nil];
}

- (instancetype)fail:(M9ThenableCallback)rejectCallback {
    return [self then:nil fail:rejectCallback];
}

- (instancetype)always:(M9ThenableCallback)callback {
    return [self then:callback fail:callback];
}

- (void)finale {
    for (M9Deferred *deferred in self.deferreds) {
        [self handle:deferred];
    }
    self.deferreds = nil;
}

- (void)handle:(M9Deferred *)deferred {
    if (self.state == M9PromiseStatePending) {
        self.deferreds = self.deferreds OR [NSMutableArray new];
        [self.deferreds addObject:deferred];
        return;
    }
    
    dispatch_async_main_queue(^() {
        M9ThenableCallback callback = nil;
        M9PromiseCallback nextCall = nil;
        if (self.state == M9PromiseStateFulfilled) {
            callback = deferred.fulfillCallback;
            nextCall = deferred.nextFulfill;
        }
        else if (self.state == M9PromiseStateRejected) {
            callback = deferred.rejectCallback;
            nextCall = deferred.nextReject;
        }
        if (callback) {
            id value = callback(self.value);
            if (deferred.nextFulfill) deferred.nextFulfill(value);
        }
        else {
            if (nextCall) nextCall(self.value);
        }
    });
}

#pragma mark when

+ (instancetype)when:(M9PromiseBlock)block {
    return [[self alloc] initWithBlock:block];
}

+ (instancetype)some:(NSInteger)minFulfilled ofBlocks:(NSArray *)blocks {
    NSInteger count = [blocks count];
    
    if (minFulfilled > count) {
        return [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
            reject(nil);
        }];
    }
    
    if (minFulfilled <= 0) {
        minFulfilled = count;
    }
    NSInteger maxRejected = count - minFulfilled;
    
    return [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
        // ???: fulfill with fulfilledValues, reject with rejectedValues
        NSMutableDictionary *fulfilledValues = [NSMutableDictionary new], *rejectedValues = [NSMutableDictionary new];
        __block NSInteger fulfilled = 0, rejected = 0;
        
        NSInteger index = 0;
        for (M9PromiseBlock block in blocks) {
            [[M9Promise when:block] then:^id (id value) {
                [fulfilledValues setObject:value forKey:@(index)];
                fulfilled++;
                if (fulfilled >= minFulfilled) {
                    fulfill([fulfilledValues copy]);
                }
                return nil;
            } fail:^id (id value) {
                [rejectedValues setObject:value forKey:@(index)];
                rejected++;
                if (rejected > maxRejected) {
                    reject([rejectedValues copy]);
                }
                return nil;
            }];
            index++;
        }
    }];
}

+ (instancetype)all:(M9PromiseBlock)first, ... {
    NSMutableArray *blocks = [NSMutableArray new];
    va_each(M9PromiseBlock, first, ^void (M9PromiseBlock block) {
        [blocks addObject:[block copy]];
    });
    return [self some:0 ofBlocks:blocks];
}

+ (instancetype)any:(M9PromiseBlock)first, ... {
    NSMutableArray *blocks = [NSMutableArray new];
    va_each(M9PromiseBlock, first, ^ (M9PromiseBlock block) {
        [blocks addObject:[block copy]];
    });
    return [self some:1 ofBlocks:blocks];
}

+ (instancetype)some:(NSInteger)howMany of:(M9PromiseBlock)first, ... {
    NSMutableArray *blocks = [NSMutableArray new];
    va_each(M9PromiseBlock, first, ^ (M9PromiseBlock block) {
        [blocks addObject:[block copy]];
    });
    return [self some:howMany ofBlocks:blocks];
}

@end

@implementation M9Deferred

+ (instancetype)deferred:(M9ThenableCallback)fulfillCallback
                        :(M9ThenableCallback)rejectCallback
                        :(M9PromiseCallback)nextFulfill
                        :(M9PromiseCallback)nextReject {
    M9Deferred *deferred = [self new];
    deferred.fulfillCallback = fulfillCallback;
    deferred.rejectCallback = rejectCallback;
    deferred.nextFulfill = nextFulfill;
    deferred.nextReject = nextReject;
    return deferred;
}

@end
