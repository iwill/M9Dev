//
//  M9PromiseTests.m
//  M9Dev
//
//  Created by MingLQ on 2014-11-12.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

// #import <Kiwi/Kiwi.h>
#import <Specta/Specta.h>

#ifndef EXP_SHORTHAND
    #define EXP_SHORTHAND
#endif
#import <Expecta/Expecta.h>

#import "EXTScope.h"
#import "M9Utilities.h"
#import "M9Promise.h"

#import "NSDate+.h"

static inline void waitForSeconds(seconds) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:seconds]];
}

static inline void waitFor(void (^block)(DoneCallback done), NSTimeInterval timeout) {
    __block BOOL complete = NO;
    if (block) block(^{
        complete = YES;
    });
    NSTimeInterval expiredTimeInterval = [NSDate timeIntervalSinceReferenceDate] + timeout;
    while (!complete && [NSDate timeIntervalSinceReferenceDate] > expiredTimeInterval) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    if (!complete) {
        NSLog(@"wait timeout with seconds: %f", timeout);
    }
}

void _describe(NSString *name, void (^block)()) {
    if (block) block();
}

void _it(NSString *name, void (^block)()) {
    if (block) block();
}

typedef void (^WillCallback)(id got);
void itWill(NSString *name, void (^block)(WillCallback done), id expected) {
    it(name, ^{
        waitUntil(^(DoneCallback done) {
            if (block) block(^ (id got) {
                // expect(got).to.equal(expected);
                done();
            });
        });
    });
}

void _itWill(NSString *name, void (^block)(DoneCallback done)) {
    waitUntil(^(DoneCallback done) {
        if (block) block(done);
    });
}

static NSString *sentinel = @"sentinel";

@interface TestThenable : NSObject <M9Thenable>

@property(nonatomic, copy, readwrite) id<M9Thenable> (^then)(M9ThenableCallback fulfillCallback, M9ThenableCallback rejectCallback);

@end

@implementation TestThenable {
    id<M9Thenable> (^_then)(M9ThenableCallback fulfillCallback, M9ThenableCallback rejectCallback);
}

@synthesize then;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.then = ^id<M9Thenable> (M9ThenableCallback fulfillCallback, M9ThenableCallback rejectCallback) {
            dispatch_after_seconds(0.05, ^{
                fulfillCallback(sentinel);
            });
            return nil;
        };
    }
    return self;
}

@end

#pragma mark -

typedef BOOL (^PromiseIsNil)();

// !!!: Specta BUG, some cases failed
// SpecBegin(M9Promise)

// SPEC_BEGIN(M9PromiseTestCase)

@interface M9PromiseTestCase : XCTestCase

@property(nonatomic, weak) M9Promise *promise1;
@property(nonatomic, weak) M9Promise *promise2;
@property(nonatomic, weak) M9Promise *promise3;

@end

@implementation M9PromiseTestCase

- (void)testReferenceCounting {
    _describe(@"promise reference counting", ^{
    
        self.promise1 = [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
            fulfill(nil); // or reject
        }];
        self.promise2 = [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                fulfill(nil); // or reject
            });
        }];
        self.promise3 = [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                fulfill(nil); // or reject
            });
        }];
        
        _it(@"should be nil after fulfill or reject immediately", ^{
            expect(self.promise1).to.beNil();
        });
        
        _it(@"should be nil before fulfill or reject with delay", ^{
            expect(self.promise2).notTo.beNil();
        });
        
        _it(@"should be nil after fulfill or reject with delay", ^{
            waitForSeconds(2);
            expect(self.promise3).to.beNil();
        });
    
    });
}

- (void)testThen {
    _describe(@"then callback should be called after fulfill or reject", ^{
        
        M9Promise *promise = [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
            _it(@"should NOT be nil before calling fulfill or reject", ^{
                waitFor(^(DoneCallback done) {
                    reject(sentinel); // or reject
                    // done();
                }, 10);
            });
        }];
        
        __block id result = nil;
        promise.then(^(id value) {
            result = value;
            return (id)nil;
        }, ^(id value) {
            result = value;
            return (id)nil;
        });
        expect(result).after(2).to.equal(sentinel);
    
    });
}

#pragma mark - then/promise test cases
// @see https://github.com/then/promise/blob/master/test/resolver-tests.js

- (void)testPromise {
    _describe(@"promise", ^{
        
        M9Promise *promise = [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
            fulfill(nil);
        }];
        
        _it(@"must conform protocol M9Thenable", ^{
            expect(promise).to.conformTo(@protocol(M9Thenable));
        });
        _it(@"must be instance of M9Promise", ^{
            expect(promise).to.beInstanceOf([M9Promise class]);
        });
        
    });
}

- (void)testResolver {
    _describe(@"resolver", ^{
        
        _it(@"must be called immediately, before `Promise` returns", ^{
            __block BOOL called = NO;
            [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                called = YES;
            }];
            expect(called).to.beTruthy();
        });
        
    });
}

- (void)testCallingResolveX {
    _describe(@"Calling resolve(x)", ^{
        
        _describe(@"if promise is resolved", ^{
            __block BOOL did = 0;
            _itWill(@"nothing happens", ^(DoneCallback done) {
                [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    dispatch_async_main_queue(^{
                        fulfill([TestThenable new]);
                        fulfill(nil);
                    });
                }].done(^id (id value) {
                    expect(value).to.equal(sentinel);
                    return [NSString stringWithFormat:@"new-%@", sentinel];
                }).then(^id (id value) {
                    expect(value).to.equal([NSString stringWithFormat:@"new-%@", sentinel]);
                    did = 1;
                    done();
                    return nil;
                }, ^id (id value) {
                    did = - 1;
                    done();
                    return nil;
                });
            });
            expect(did).to.equal(1);
        });
        
        _describe(@"otherwise", ^{
            _describe(@"if x is a thenable", ^{
                _it(@"assimilates the thenable", ^{
                });
            });
            _describe(@"otherwise", ^{
                // !!!: Specta BUG, this it does not work
                __block BOOL did = 0;
                _itWill(@"is fulfilled with x as the fulfillment value", ^(DoneCallback done) {
                    [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                        fulfill(sentinel);
                    }].done(^id (id value) {
                        expect(value).to.equal(sentinel);
                        return [NSString stringWithFormat:@"new-%@", sentinel];
                    }).then(^id (id value) {
                        expect(value).to.equal([NSString stringWithFormat:@"new-%@", sentinel]);
                        did = 1;
                        done();
                        return nil;
                    }, ^id (id value) {
                        did = - 1;
                        done();
                        return nil;
                    });
                });
                expect(did).to.equal(1);
            });
        });
        
    });
}

- (void)testCallingRejectX {
    _describe(@"Calling reject(x)", ^{
        _describe(@"if promise is resolved", ^{
            __block BOOL did = 0;
            _itWill(@"nothing happens", ^(DoneCallback done) {
                [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    dispatch_async_main_queue(^{
                        fulfill([TestThenable new]);
                        reject(@"foo");
                    });
                }].done(^id (id value) {
                    expect(value).to.equal(sentinel);
                    return [NSString stringWithFormat:@"new-%@", sentinel];
                }).then(^id (id value){
                    expect(value).to.equal([NSString stringWithFormat:@"new-%@", sentinel]);
                    did = 1;
                    done();
                    return nil;
                }, ^id (id error) {
                    did = - 1;
                    done();
                    return nil;
                });
            });
            expect(did).to.equal(1);
        });
        
        _describe(@"otherwise", ^{
            __block BOOL did = 0;
            _itWill(@"is rejected with x as the rejection reason", ^(DoneCallback done) {
                [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    reject(sentinel);
                }].then(nil, ^id (id value) {
                    expect(value).to.equal(sentinel);
                    return [NSString stringWithFormat:@"new-%@", sentinel];
                }).then(^id (id value){
                    expect(value).to.equal([NSString stringWithFormat:@"new-%@", sentinel]);
                    did = 1;
                    done();
                    return nil;
                }, ^id (id error) {
                    did = - 1;
                    done();
                    return nil;
                });
            });
            expect(did).to.equal(1);
        });
    });
}

@end

// SPEC_END

// SpecEnd
