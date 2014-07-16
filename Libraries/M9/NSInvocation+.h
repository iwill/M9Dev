//
//  NSInvocation+.h
//  iM9
//
//  Created by iwill on 2011-06-01.
//  Copyright 2011 M9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (Repeat)

- (void)repeatInvokeWithInterval:(NSTimeInterval)repeatInterval;
- (void)cancelRepeat;

@end

#pragma mark -

@interface NSObject (NSInvocation)

/* invocation with selector and arguments */
- (NSInvocation *)invocationWithSelector:(SEL)selector;
- (NSInvocation *)invocationWithSelector:(SEL)selector withObject:(void *)object;
- (NSInvocation *)invocationWithSelector:(SEL)selector withObject:(void *)object1 withObject:(void *)object2;

/* invoke with selector, arguments and return-value */
- (void)invokeWithSelector:(SEL)selector returnValue:(void *)returnValue;
- (void)invokeWithSelector:(SEL)selector withObject:(void *)object returnValue:(void *)returnValue;
- (void)invokeWithSelector:(SEL)selector withObject:(void *)object1 withObject:(void *)object2 returnValue:(void *)returnValue;

@end

