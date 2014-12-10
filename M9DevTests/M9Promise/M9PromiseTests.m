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

static NSString *sentinel = @"sentinel";

//@interface TestThenable : NSObject <M9Thenable>
//
//@end
//
//@implementation TestThenable {
//    id<M9Thenable> (^_then)(M9ThenableCallback fulfillCallback, M9ThenableCallback rejectCallback);
//}
//
//@synthesize then;
//
//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        _then = ^id<M9Thenable> (M9ThenableCallback fulfillCallback, M9ThenableCallback rejectCallback) {
//            dispatch_after_seconds(0.05, ^{
//                fulfillCallback(sentinel);
//            });
//            return nil;
//        };
//    }
//    return self;
//}
//
//@end

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

- (void)setUpReferenceCounting {
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
}

- (void)testReferenceCounting {
// describe(@"promise reference counting", ^{
    
    [self setUpReferenceCounting];
    
    // it(@"should be nil after fulfill or reject immediately", ^{
    expect(self.promise1).to.beNil();
    // });
    
    // it(@"should be nil before fulfill or reject with delay", ^{
    expect(self.promise2).notTo.beNil();
    // });
    
    // it(@"should be nil after fulfill or reject with delay", ^{
    waitForSeconds(2);
    expect(self.promise3).to.beNil();
    // });
    
// });
}


- (void)testThen {
// describe(@"then callback should be called after fulfill or reject", ^{
    
    M9Promise *promise = [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
        // it(@"should NOT be nil before calling fulfill or reject", ^{
        waitFor(^(DoneCallback done) {
            reject(sentinel); // or reject
            // done();
        }, 10);
        // });
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
    
    // });
}

#pragma mark - then/promise test cases
// @see https://github.com/then/promise/blob/master/test/resolver-tests.js

- (void)testPromise {
// describe(@"promise", ^{
    M9Promise *promise = [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
        fulfill(nil);
    }];
    
    it(@"must conform protocol M9Thenable", ^{
        expect(promise).to.conformTo(@protocol(M9Thenable));
    });
    it(@"must be instance of M9Promise", ^{
        expect(promise).to.beInstanceOf([M9Promise class]);
    });
// });
}

- (void)testResolver {
// describe(@"resolver", ^{
    it(@"must be called immediately, before `Promise` returns", ^{
        __block BOOL called = NO;
        [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
            called = YES;
        }];
        expect(called).to.beTruthy();
    });
// });
}

- (void)testCallingResolveX {
// describe(@"Calling resolve(x)", ^{
    
    // describe(@"if promise is resolved", ^{
        it(@"nothing happens", ^{
            waitUntil(^(DoneCallback done) {
                // id<M9Thenable> thenable = [TestThenable new];
                /* temp */
                id<M9Thenable> thenable = [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    dispatch_after_seconds(0.05, ^{
                        fulfill(sentinel);
                    });
                }];
                [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    dispatch_async_main_queue(^{
                        fulfill(thenable);
                        fulfill(nil);
                    });
                }].done(^id (id value) {
                    expect(value).to.equal(sentinel);
                    return nil;
                }).then(^id (id value) {
                    done();
                    return nil;
                }, ^id (id value) {
                    expect(value).to.raise(value);
                    done();
                    return nil;
                });
            });
        });
    // });
    
    // describe(@"otherwise", ^{
        // describe(@"if x is a thenable", ^{
            it(@"assimilates the thenable", ^{
            });
        // });
        // describe(@"otherwise", ^{
            // !!!: Specta BUG, this it does not work
            it(@"is fulfilled with x as the fulfillment value", ^{
                waitUntil(^(DoneCallback done) {
                    [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                        fulfill(sentinel);
                    }].done(^id (id value) {
                        expect(value).to.equal(sentinel);
                        NSLog(@"fulfill with value: %@", value);
                        return @"new value";
                    }).then(^id (id value) {
                        NSLog(@"fulfill with value: %@", value);
                        done();
                        return nil;
                    }, ^id (id value) {
                        NSLog(@"reject with error: %@", value OR @"Promise rejected");
                        expect(YES).to.beFalsy();
                        done();
                        return nil;
                    });
                });
            });
        // });
    // });
    
// });
}

- (void)testCallingRejectX {
// describe(@"Calling reject(x)", ^{
    // describe(@"if promise is resolved", ^{
        
    // });
    
    // describe(@"otherwise", ^{
        
    // });
// });
}

@end

// SPEC_END

// SpecEnd
