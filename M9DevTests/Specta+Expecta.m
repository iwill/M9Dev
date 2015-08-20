//
//  Specta+Expecta.m
//  M9Dev
//
//  Created by MingLQ on 2014-11-12.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

// #import <Kiwi/Kiwi.h>
#import <Specta/Specta.h>

#ifndef EXP_SHORTHAND
    #define EXP_SHORTHAND
#endif
#import <Expecta/Expecta.h>

#import "M9Promise.h"

@interface ExpectaTests : XCTestCase

@end

@implementation ExpectaTests

- (void)testM9Promise {
    expect([M9Promise class]).conformTo(@protocol(M9Thenable));
    
    M9Promise *promise = [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
        fulfill(nil);
    }];
    expect(promise).beInstanceOf([M9Promise class]);
    
    __block BOOL called = NO;
    waitUntil(^(DoneCallback done) {
        [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                called = YES;
                fulfill(nil);
                done();
            });
        }];
    });
    expect(called).equal(YES);
}

@end

#pragma mark -

// SPEC_BEGIN(KiwiAndExpectaTests)
SpecBegin(SpectaAndExpectaTests)

describe(@"promise", ^{
    M9Promise *promise = [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
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
        __block NSString *result = nil;
        [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
            fulfill(@"done");
            reject(@"error");
        }].afterwards(^id (id value) {
            result = value;
            return nil;
        }, ^id (id value) {
            result = value;
            return nil;
        });
        expect(result).will.equal(@"done");
    });
});

// SPEC_END
SpecEnd

