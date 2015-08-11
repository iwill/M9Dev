//
//  M9DevTests.m
//  M9DevTests
//
//  Created by MingLQ on 2014-07-05.
//  Copyright (c) 2014年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <XCTest/XCTest.h>

#ifndef EXP_SHORTHAND
#define EXP_SHORTHAND
#endif
#import <Expecta/Expecta.h>

@interface M9DevTests : XCTestCase

@end

@implementation M9DevTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    [self measureBlock:^{
    }];
}

- (void)testExpect {
    expect(YES).to.equal(YES);
}

@end
