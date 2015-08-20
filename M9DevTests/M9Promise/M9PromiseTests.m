//
//  M9PromiseTests.m
//  M9Dev
//
//  Created by MingLQ on 2014-11-12.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

// #import <Kiwi/Kiwi.h>
// #import <Specta/Specta.h>
#import "SpectaAlternative.h"

#ifndef EXP_SHORTHAND
    #define EXP_SHORTHAND
#endif
#import <Expecta/Expecta.h>

#import "EXTScope+M9.h"
#import "M9Utilities.h"
#import "M9Promise.h"

#import "NSDate+M9.h"

#define sentinel @"sentinel"

@interface TestThenable : NSObject <M9Thenable>

@property(nonatomic, copy, readwrite) id<M9Thenable> (^afterwards)(M9ThenableCallback fulfillCallback, M9ThenableCallback rejectCallback);

@end

@implementation TestThenable {
}

@synthesize afterwards;

- (instancetype)init {
    self = [super init];
    if (self) {
        weakify(self);
        self.afterwards = ^id<M9Thenable> (M9ThenableCallback fulfillCallback, M9ThenableCallback rejectCallback) {
            strongify(self);
            return [self then:fulfillCallback fail:rejectCallback];
        };
    }
    return self;
}

- (id<M9Thenable>)then:(M9ThenableCallback)fulfillCallback fail:(M9ThenableCallback)rejectCallback {
    dispatch_after_seconds(0.05, ^{
        fulfillCallback(sentinel);
    });
    return nil;
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
            _waitForSeconds(2);
            expect(self.promise3).to.beNil();
        });
    
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
            _itWill(@"nothing happens", ^(StateCallback doneWithState) {
                [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    dispatch_async_main_queue(^{
                        fulfill([TestThenable new]);
                        fulfill(nil);
                    });
                }].then(^id (id value) {
                    expect(value).to.equal(sentinel);
                    return [NSString stringWithFormat:@"new-%@", sentinel];
                }).afterwards(^id (id value) {
                    expect(value).to.equal([NSString stringWithFormat:@"new-%@", sentinel]);
                    doneWithState(1);
                    return nil;
                }, ^id (id value) {
                    doneWithState(- 1);
                    return nil;
                });
            }, ^(NSInteger state) {
                expect(state).equal(1);
            });
        });
        
        _describe(@"otherwise", ^{
            _describe(@"if x is a thenable", ^{
                _it(@"assimilates the thenable", ^{
                });
            });
            _describe(@"otherwise", ^{
                // !!!: Specta BUG, this it does not work
                _itWill(@"is fulfilled with x as the fulfillment value", ^(StateCallback doneWithState) {
                    [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                        fulfill(sentinel);
                    }].then(^id (id value) {
                        expect(value).to.equal(sentinel);
                        return [NSString stringWithFormat:@"new-%@", sentinel];
                    }).afterwards(^id (id value) {
                        expect(value).to.equal([NSString stringWithFormat:@"new-%@", sentinel]);
                        doneWithState(1);
                        return nil;
                    }, ^id (id value) {
                        doneWithState(- 1);
                        return nil;
                    });
                }, ^(NSInteger state) {
                    expect(state).equal(1);
                });
            });
        });
        
    });
}

- (void)testCallingRejectX {
    _describe(@"Calling reject(x)", ^{
        _describe(@"if promise is resolved", ^{
            _itWill(@"nothing happens", ^(StateCallback doneWithState) {
                [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    dispatch_async_main_queue(^{
                        fulfill([TestThenable new]);
                        reject(@"foo");
                    });
                }].then(^id (id value) {
                    expect(value).to.equal(sentinel);
                    return [NSString stringWithFormat:@"new-%@", sentinel];
                }).afterwards(^id (id value){
                    expect(value).to.equal([NSString stringWithFormat:@"new-%@", sentinel]);
                    doneWithState(1);
                    return nil;
                }, ^id (id error) {
                    doneWithState(- 1);
                    return nil;
                });
            }, ^(NSInteger state) {
                expect(state).equal(1);
            });
        });
        
        _describe(@"otherwise", ^{
            _itWill(@"is rejected with x as the rejection reason", ^(StateCallback doneWithState) {
                [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    reject(sentinel);
                }].afterwards(nil, ^id (id value) {
                    expect(value).to.equal(sentinel);
                    return [NSString stringWithFormat:@"new-%@", sentinel];
                }).afterwards(^id (id value){
                    expect(value).to.equal([NSString stringWithFormat:@"new-%@", sentinel]);
                    doneWithState(1);
                    return nil;
                }, ^id (id error) {
                    doneWithState(- 1);
                    return nil;
                });
            }, ^(NSInteger state) {
                expect(state).equal(1);
            });
        });
    });
}

@end

// SPEC_END

// SpecEnd
