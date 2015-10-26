//
//  NSInvocation+M9.h
//  M9Dev
//
//  Created by MingLQ on 2011-06-01.
//  Copyright (c) 2011 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (Repeat)

// NSDefaultRunLoopMode
- (void)repeatInvokeWithInterval:(NSTimeInterval)repeatInterval;
// NSRunLoopCommonModes = NSDefaultRunLoopMode + UITrackingRunLoopMode
- (void)repeatInvokeWithInterval:(NSTimeInterval)repeatInterval inModes:(NSArray/* <NSString *> */ *)modes;
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

