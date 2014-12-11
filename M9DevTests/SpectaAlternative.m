//
//  SpectaAlternative.m
//  M9Dev
//
//  Created by MingLQ on 2014-12-11.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Specta/Specta.h>

#import "SpectaAlternative.h"

void _waitForSeconds(NSTimeInterval seconds) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:seconds]];
}

void _waitFor(void (^block)(DoneCallback done), NSTimeInterval timeout) {
    __block BOOL complete = NO;
    if (block) block(^{
        complete = YES;
    });
    NSTimeInterval expiredTimeInterval = [NSDate timeIntervalSinceReferenceDate] + timeout;
    while (!complete && (timeout < 0 || expiredTimeInterval > [NSDate timeIntervalSinceReferenceDate])) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    if (!complete) {
        NSLog(@"wait timeout with seconds: %f", timeout);
    }
}

void _waitUntil(void (^block)(DoneCallback done)) {
    _waitFor(block, - 1.0);
}

void _describe(NSString *name, void (^block)()) {
    if (block) block();
}

void _it(NSString *name, void (^block)()) {
    if (block) block();
}

void _itWill(NSString *name, void (^block)(StateCallback doneWithState), ValidateCallback validate) {
    _it(name, ^{
        _waitUntil(^(DoneCallback done) {
            if (block) block(^ (NSInteger got) {
                validate(got);
                done();
            });
        });
    });
}
