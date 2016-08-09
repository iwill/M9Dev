//
//  UIControl+M9EventCallback.m
//  M9Dev
//
//  Created by MingLQ on 2015-08-11.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "UIControl+M9EventCallback.h"

@interface M9EventCallbackWrapper : NSObject

@property (nonatomic, copy) M9EventCallback eventCallback;

- (void)callbackWithSender:(id)sender;

+ (instancetype)wrapperWithCallback:(M9EventCallback)eventCallback;

@end

@implementation M9EventCallbackWrapper

- (void)callbackWithSender:(id)sender {
    if (self.eventCallback) self.eventCallback(sender);
}

+ (instancetype)wrapperWithCallback:(M9EventCallback)eventCallback {
    M9EventCallbackWrapper *callbackWrapper = [self new];
    callbackWrapper.eventCallback = eventCallback;
    return callbackWrapper;
}

@end

#pragma mark -

@implementation UIControl (M9EventCallback)

static void *M9EventCallbackWrappers = &M9EventCallbackWrappers;

- (void)addEventCallback:(M9EventCallback)eventCallback
        forControlEvents:(UIControlEvents)controlEvents {
    NSMutableDictionary *callbackWrapperGroups = [self associatedValueForKey:M9EventCallbackWrappers];
    if (!callbackWrapperGroups) {
        callbackWrapperGroups = [NSMutableDictionary dictionary];
        [self associateValue:callbackWrapperGroups withKey:M9EventCallbackWrappers];
    }
    
    NSMutableArray *callbackWrappers = [callbackWrapperGroups objectForKey:@(controlEvents)];
    if (!callbackWrappers) {
        callbackWrappers = [NSMutableArray array];
        [callbackWrapperGroups setObject:callbackWrappers forKey:@(controlEvents)];
    }
    
    M9EventCallbackWrapper *callbackWrapper = [M9EventCallbackWrapper wrapperWithCallback:eventCallback];
    [callbackWrappers addObject:callbackWrapper];
    
    [self addTarget:callbackWrapper action:@selector(callbackWithSender:) forControlEvents:controlEvents];
}

- (void)removeEventCallbackForControlEvents:(UIControlEvents)controlEvents {
    NSMutableDictionary *callbackWrapperGroups = [self associatedValueForKey:M9EventCallbackWrappers];
    NSMutableArray *callbackWrappers = [callbackWrapperGroups objectForKey:@(controlEvents)];
    
    [callbackWrappers enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        M9EventCallbackWrapper *callbackWrapper = [object as:[M9EventCallbackWrapper class]];
        [self removeTarget:callbackWrapper action:@selector(callbackWithSender:) forControlEvents:controlEvents];
    }];
    
    [callbackWrapperGroups removeObjectForKey:@(controlEvents)];
}

@end
