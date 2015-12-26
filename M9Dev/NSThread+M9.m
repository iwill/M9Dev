//
//  NSThread+M9.m
//  M9Dev
//
//  Created by MingLQ on 2015-12-15.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "NSThread+M9.h"

@implementation NSThread (M9)

- (BOOL)suspend {
    if ([self isMainThread]) {
        return NO;
    }
    if (CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent())) {
        return NO;
    }
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
    CFRunLoopRun();
    return YES;
}

- (void)resume {
    if ([NSThread currentThread] == self) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
        CFRunLoopStop(CFRunLoopGetCurrent());
    }
    else {
        // waitUntilDone:YES maybe better
        [self performSelector:_cmd onThread:self withObject:nil waitUntilDone:YES];
    }
}

@end
