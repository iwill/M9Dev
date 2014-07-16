//
//  NSInvocation+.m
//  iM9
//
//  Created by iwill on 2011-06-01.
//  Copyright 2011 M9. All rights reserved.
//

#import "NSInvocation+.h"

@implementation NSInvocation (Repeat)

- (void)repeatInvokeWithInterval:(NSTimeInterval)repeatInterval {
    SEL selector = @selector(repeatInvokeWithIntervalNumber:);
    
    id anArgument = nil;
    if ([[self methodSignature] numberOfArguments] > 2) {
        [self getArgument:&anArgument atIndex:2];
    }
    
    [self performSelector:selector withObject:[NSNumber numberWithDouble:repeatInterval] afterDelay:repeatInterval];
}

- (void)repeatInvokeWithIntervalNumber:(NSNumber *)repeatInterval {
    [self invoke];
    [self repeatInvokeWithInterval:[repeatInterval doubleValue]];
}

- (void)cancelRepeat {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end

#pragma mark -

@implementation NSObject (NSInvocation)

- (NSInvocation *)invocationWithSelector:(SEL)selector {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    [invocation retainArguments];
    return invocation;
}

- (NSInvocation *)invocationWithSelector:(SEL)selector withObject:(void *)object {
    NSInvocation *invocation = [self invocationWithSelector:selector];
    [invocation setArgument:object atIndex:2];
    return invocation;
}

- (NSInvocation *)invocationWithSelector:(SEL)selector withObject:(void *)object1 withObject:(void *)object2 {
    NSInvocation *invocation = [self invocationWithSelector:selector];
    [invocation setArgument:object1 atIndex:2];
    [invocation setArgument:object2 atIndex:3];
    return invocation;
}

- (void)invokeWithSelector:(SEL)selector returnValue:(void *)returnValue {
    NSInvocation *invocation = [self invocationWithSelector:selector];
    [invocation invoke];
    [invocation getReturnValue:returnValue];
}

- (void)invokeWithSelector:(SEL)selector withObject:(void *)object returnValue:(void *)returnValue {
    NSInvocation *invocation = [self invocationWithSelector:selector withObject:object];
    [invocation invoke];
    [invocation getReturnValue:returnValue];
}

- (void)invokeWithSelector:(SEL)selector withObject:(void *)object1 withObject:(void *)object2 returnValue:(void *)returnValue {
    NSInvocation *invocation = [self invocationWithSelector:selector withObject:object1 withObject:object2];
    [invocation invoke];
    [invocation getReturnValue:returnValue];
}

/*
- (NSInvocation *)performSelector:(SEL)selector withObject:(id)anArgument repeatsInterval:(NSTimeInterval)repeatsInterval {
}

- (NSInvocation *)performSelector:(SEL)selector withObject:(id)anArgument repeatsInterval:(NSTimeInterval)repeatsInterval inModes:(NSArray *)modes {
} */

@end

