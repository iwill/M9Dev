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

#import "M9Promise.h"

@interface M9PromiseTests : XCTestCase

@end

@implementation M9PromiseTests

- (void)testM9Promise {
    expect([M9Promise class]).conformTo(@protocol(M9Thenable));
    
    M9Promise *promise = [M9Promise promise:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
        fulfill(nil);
    }];
    expect(promise).beInstanceOf([M9Promise class]);
    
    __block BOOL called = NO;
    [M9Promise promise:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
        called = YES;
    }];
    expect(called).equal(YES);
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

SpecEnd

