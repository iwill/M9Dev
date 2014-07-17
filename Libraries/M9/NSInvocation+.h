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
- (NSInvocation *)invocationWithSelector:(SEL)selector argument:(void *)argument;
- (NSInvocation *)invocationWithSelector:(SEL)selector arguments:(void *)argument, ...;

/* invoke with selector, arguments */
- (void)invokeWithSelector:(SEL)selector;
- (void)invokeWithSelector:(SEL)selector argument:(void *)argument;
- (void)invokeWithSelector:(SEL)selector arguments:(void *)argument, ...;

/* invoke with selector, arguments and return-value */
- (void)invokeWithSelector:(SEL)selector returnValue:(void *)returnValue;
- (void)invokeWithSelector:(SEL)selector returnValue:(void *)returnValue argument:(void *)argument;
- (void)invokeWithSelector:(SEL)selector returnValue:(void *)returnValue arguments:(void *)argument, ...;

@end

