//
//  M9PromiseTests.m
//  M9Dev
//
//  Created by MingLQ on 2014-11-12.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <Specta/Specta.h>

#ifndef EXP_SHORTHAND
    #define EXP_SHORTHAND
#endif
#import <Expecta/Expecta.h>

#import "EXTScope.h"
#import "M9Utilities.h"
#import "M9Promise.h"

static NSString *sentinel = @"sentinel";

@interface TestThenable : NSObject <M9Thenable>

@end

@implementation TestThenable {
    id<M9Thenable> (^_then)(M9ThenableCallback fulfillCallback, M9ThenableCallback rejectCallback);
}

@synthesize then;

- (instancetype)init {
    self = [super init];
    if (self) {
        _then = ^id<M9Thenable> (M9ThenableCallback fulfillCallback, M9ThenableCallback rejectCallback) {
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

// !!!: bug, some cases failed
// SpecBegin(M9Promise)
// SpecEnd

typedef BOOL (^PromiseIsNil)();

@interface M9PromiseTestCase : XCTestCase

@end

@implementation M9PromiseTestCase

- (void)testPromise {
    describe(@"promise reference counting", ^{
        
        static PromiseIsNil isPromiseNil = nil;
        
        __weak M9Promise *promise = [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                it(@"should NOT be nil before calling fulfill or reject", ^{
                    expect(isPromiseNil()).to.beFalsy();
                    fulfill(nil); // or reject
                });
            });
        }];
        
        weakify(promise);
        isPromiseNil = ^BOOL () {
            strongify(promise);
            return promise == nil;
        };
        
        it(@"should NOT be nil after define promise", ^{
            expect(isPromiseNil()).to.beFalsy();
        });
        
        promise.then(^(id value) {
            NSLog(@"%@ - %@", _HERE, value);
            return (id)nil;
        }, ^(id value) {
            NSLog(@"%@ - %@", _HERE, value);
            return (id)nil;
        });
        
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                it(@"should be nil after all", ^{
                    expect(isPromiseNil()).to.beTruthy();
                    done();
                });
            });
        });
    });
    
    describe(@"promise", ^{
        M9Promise *promise = [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
            fulfill(nil);
        }];
        
        it(@"must conform protocol M9Thenable", ^{
            expect(promise).to.conformTo(@protocol(M9Thenable));
        });
        it(@"must be instance of M9Promise", ^{
            expect(promise).to.beInstanceOf([M9Promise class]);
        });
    });
    
    describe(@"resolver", ^{
        it(@"must be called immediately, before `Promise` returns", ^{
            __block BOOL called = NO;
            [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                called = YES;
            }];
            expect(called).to.equal(YES);
        });
    });
    
    describe(@"Calling resolve(x)", ^{
        describe(@"if promise is resolved", ^{
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
        });
        
        describe(@"otherwise", ^{
            describe(@"if x is a thenable", ^{
                it(@"assimilates the thenable", ^{
                });
            });
            describe(@"otherwise", ^{
                // !!!: bug, this it does not work
                // it(@"is fulfilled with x as the fulfillment value", ^{
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
                            expect(YES).to.equal(NO);
                            done();
                            return nil;
                        });
                    });
                // });
            });
        });
    });
    
    describe(@"Calling reject(x)", ^{
        describe(@"if promise is resolved", ^{
            
        });
        
        describe(@"otherwise", ^{
            
        });
    });
}

@end
