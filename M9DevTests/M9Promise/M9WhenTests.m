//
//  M9WhenTests.m
//  M9Dev
//
//  Created by MingLQ on 2014-12-11.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SpectaAlternative.h"

#ifndef EXP_SHORTHAND
#define EXP_SHORTHAND
#endif
#import <Expecta/Expecta.h>

#import "EXTScope.h"
#import "M9Utilities.h"
#import "M9Promise.h"

@interface M9WhenTests : XCTestCase

@end

@implementation M9WhenTests

- (void)testWhen {
    _describe(@"when", ^{
        
        _it(@"'s done should be called when fulfill", ^{
            __block NSInteger state = 0;
            __block id result = nil;
            [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                fulfill(@"done");
            }].then(^id(id value) {
                state = 1;
                result = value;
                return nil;
            }, ^id(id value) {
                state = - 1;
                result = value;
                return nil;
            });
            expect(state).will.equal(1);
            expect(result).will.equal(@"done");
        });
        
        _it(@"'s done should be called when reject", ^{
            __block NSInteger state = 0;
            __block id result = nil;
            [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                reject(@"error");
            }].then(^id(id value) {
                state = 1;
                result = value;
                return nil;
            }, ^id(id value) {
                state = - 1;
                result = value;
                return nil;
            });
            expect(state).will.equal(- 1);
            expect(result).will.equal(@"error");
        });
        
    });
}

- (void)testAll {
    _describe(@"all", ^{
        
        __block NSInteger state = 0;
        __block id result = nil;
        _it(@"should be fulfilled if all fulfilled", ^{
            [M9Promise all:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                fulfill(@"a");
            }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                fulfill(@"b");
            }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                fulfill(@"c");
            }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                fulfill(@"d");
            }].then(^id (id value) {
                state = 1;
                result = value;
                return nil;
            }, ^id (id value) {
                state = - 1;
                result = value;
                return nil;
            });
        });
        expect(state).after(1).equal(1);
        expect(result).after(1).equal(@[ @"a", @"b", @"c", @"d" ]);
        
    });
}

- (void)testAny {
}

- (void)testSome {
}

@end
