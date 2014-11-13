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

SpecBegin(M9Promise)

describe(@"promise", ^{
    M9Promise *promise = [M9Promise promise:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
        fulfill(nil);
    }];
    
    it(@"must conform protocol M9Thenable", ^{
        expect(promise).conformTo(@protocol(M9Thenable));
    });
    it(@"must be instance of M9Promise", ^{
        expect(promise).beInstanceOf([M9Promise class]);
    });
});

describe(@"resolver", ^{
    it(@"must be called immediately, before `Promise` returns", ^{
        __block BOOL called = NO;
        [M9Promise promise:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
            called = YES;
        }];
        expect(called).equal(YES);
    });
});

describe(@"Calling resolve(x)", ^{
    describe(@"if promise is resolved", ^{
        it(@"nothing happens", ^{
            waitUntil(^(DoneCallback done) {
                // id<M9Thenable> thenable = [TestThenable new];
                /* temp */
                id<M9Thenable> thenable = [M9Promise promise:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    dispatch_after_seconds(0.05, ^{
                        fulfill(sentinel);
                    });
                }];
                [M9Promise promise:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    dispatch_async_main_queue(^{
                        fulfill(thenable);
                        fulfill(nil);
                    });
                }].done(^id (id value) {
                    expect(value).equal(sentinel);
                    return nil;
                }).then(^id (id value) {
                    done();
                    return nil;
                }, ^id (id value) {
                    expect(value).raise(value);
                    done();
                    return nil;
                });
            });
        });
    });
    
    describe(@"otherwise", ^{
        
    });
});

describe(@"Calling reject(x)", ^{
    describe(@"if promise is resolved", ^{
        
    });
    
    describe(@"otherwise", ^{
        
    });
});

SpecEnd

