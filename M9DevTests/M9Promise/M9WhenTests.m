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

#import "EXTScope+M9.h"
#import "M9Utilities.h"
#import "M9Promise.h"

@interface M9WhenTests : XCTestCase

@end

@implementation M9WhenTests

- (void)testWhen {
    _describe(@"when", ^{
        
        _describe(@"if fulfill", ^{
            _it(@"'s done should be called", ^{
                __block NSInteger state = 0;
                __block id result = nil;
                [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    fulfill(@"done");
                }].afterwards(^id(id value) {
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
        });
        
        _describe(@"if rejected", ^{
            _it(@"'s done should be called", ^{
                __block NSInteger state = 0;
                __block id result = nil;
                [M9Promise when:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    reject(@"error");
                }].afterwards(^id(id value) {
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
        
    });
}

- (void)testAll {
    _describe(@"all", ^{
        
        _describe(@"if all fulfilled", ^{
            
            __block NSInteger state = 0;
            __block id result = nil;
            _it(@"should be fulfilled", ^{
                [M9Promise all:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    fulfill(@"a");
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        fulfill(@"b");
                    });
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    fulfill(@"c");
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    fulfill(@"d");
                }, nil].afterwards(^id (id value) {
                    state = 1;
                    result = value;
                    return nil;
                }, ^id (id value) {
                    state = - 1;
                    result = value;
                    return nil;
                });
            });
            expect(state).after(2).equal(1);
            expect(result).after(2).equal(@{ @0: @"a", @1: @"b", @2: @"c", @3: @"d" });
            
        });
        
        _describe(@"if any reject", ^{
            
            __block NSInteger state = 0;
            __block id result = nil;
            _it(@"should be rejected", ^{
                [M9Promise all:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    fulfill(@"a");
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        reject(@"b");
                    });
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    fulfill(@"c");
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    fulfill(@"d");
                }, nil].afterwards(^id (id value) {
                    state = 1;
                    result = value;
                    return nil;
                }, ^id (id value) {
                    state = - 1;
                    result = value;
                    return nil;
                });
            });
            expect(state).after(2).equal(- 1);
            expect(result).after(2).equal(@{ @1: @"b" });
            
        });
        
    });
}

- (void)testAny {
    _describe(@"any", ^{
        
        _describe(@"if any fulfilled", ^{
            
            __block NSInteger state = 0;
            __block id result = nil;
            _it(@"should be fulfilled", ^{
                [M9Promise any:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    reject(@"a");
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        fulfill(@"b");
                    });
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    reject(@"c");
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    reject(@"d");
                }, nil].afterwards(^id (id value) {
                    state = 1;
                    result = value;
                    return nil;
                }, ^id (id value) {
                    state = - 1;
                    result = value;
                    return nil;
                });
            });
            expect(state).after(2).equal(1);
            expect(result).after(2).haveCountOf(1);
            
        });
        
        _describe(@"if all rejected", ^{
            
            __block NSInteger state = 0;
            __block id result = nil;
            _it(@"should be rejected", ^{
                [M9Promise any:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    reject(@"a");
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        reject(@"b");
                    });
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    reject(@"c");
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    reject(@"d");
                }, nil].afterwards(^id (id value) {
                    state = 1;
                    result = value;
                    return nil;
                }, ^id (id value) {
                    state = - 1;
                    result = value;
                    return nil;
                });
            });
            expect(state).after(2).equal(- 1);
            expect(result).after(2).equal(@{ @0: @"a", @1: @"b", @2: @"c", @3: @"d" });
            
        });
        
    });
}

- (void)testSome {
    _describe(@"some", ^{
        
        _describe(@"if fulfilled >= 2", ^{
            
            __block NSInteger state = 0;
            __block id result = nil;
            _it(@"should be fulfilled", ^{
                [M9Promise some:2 of:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    fulfill(@"a");
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        fulfill(@"b");
                    });
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    fulfill(@"c");
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    reject(@"d");
                }, nil].afterwards(^id (id value) {
                    state = 1;
                    result = value;
                    return nil;
                }, ^id (id value) {
                    state = - 1;
                    result = value;
                    return nil;
                });
            });
            expect(state).after(2).equal(1);
            expect(result).after(2).equal(@{ @0: @"a", @2: @"c" });
            
        });
        
        _describe(@"if fulfilled < 2", ^{
            
            __block NSInteger state = 0;
            __block id result = nil;
            _it(@"should be rejected", ^{
                [M9Promise some:2 of:^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    reject(@"a");
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        fulfill(@"b");
                    });
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    reject(@"c");
                }, ^(M9PromiseCallback fulfill, M9PromiseCallback reject) {
                    reject(@"d");
                }, nil].afterwards(^id (id value) {
                    state = 1;
                    result = value;
                    return nil;
                }, ^id (id value) {
                    state = - 1;
                    result = value;
                    return nil;
                });
            });
            expect(state).after(2).equal(- 1);
            expect(result).after(2).equal(@{ @0: @"a", @2: @"c", @3: @"d" });
            
        });
        
    });
}

@end
