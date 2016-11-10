//
//  M9URLAction.m
//  M9Dev
//
//  Created by MingLQ on 2015-06-12.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "M9URLAction.h"

#import "NSInvocation+M9.h"

static inline NSString *M9URLActionKeyWithScheme(NSString *scheme) {
    return scheme.lowercaseString;
}

static inline NSString *M9URLActionKey(NSString *scheme, NSString *host, NSString *path) {
    if (scheme.length && !host && !path) {
        return M9URLActionKeyWithScheme(scheme);
    }
    scheme = (scheme.length
              ? [scheme.lowercaseString stringByAppendingString:@"://"]
              : @"");
    host = (host.lowercaseString
            ?: @"");
    path = ([path hasPrefix:@"/"]
            ? path
            : [@"/" stringByAppendingString:path ?: @""]);
    return [NSString stringWithFormat:@"%@%@%@", scheme, host, path];
}

static inline NSString *M9URLActionKeyWithURL(NSURL *url, BOOL includeScheme) {
    if (!url) {
        return nil;
    }
    return M9URLActionKey(includeScheme ? url.scheme : nil, url.host, url.path);
}

#pragma mark -

@interface M9URLActionHandlerWrapper : NSObject

@property (nonatomic, copy) M9URLActionHandler handler;

@property (nonatomic) id target;
@property (nonatomic) SEL instance, action;

@end

@implementation M9URLActionHandlerWrapper

+ (instancetype)handlerWithBlock:(M9URLActionHandler)handler {
    M9URLActionHandlerWrapper *actionHandler = [self new];
    actionHandler.handler = handler;
    return actionHandler;
}

+ (instancetype)handlerWithTarget:(id)target instance:(SEL)instance action:(SEL)action {
    M9URLActionHandlerWrapper *actionHandler = [self new];
    actionHandler.target = target;
    actionHandler.instance = instance;
    actionHandler.action = action;
    return actionHandler;
}

- (void)handleAction:(M9URLAction *)action
            userInfo:(id)userInfo
          completion:(M9URLActionHandleCompletion)completion {
    if (self.handler) {
        self.handler(action, userInfo, completion);
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id target = self.target;
    SEL instanceSelector = self.instance OR @selector(self);
    // #import <objc/runtime.h>
    // class_isMetaClass(object_getClass(target))
    if ([target respondsToSelector:instanceSelector]) {
        target = [target performSelector:instanceSelector];
    }
    else if (target == [target class] && [target instancesRespondToSelector:instanceSelector]) {
        target = [[[target class] alloc] performSelector:instanceSelector withObject:nil];
    }
    SEL actionSelector = self.action;
    if ([target respondsToSelector:actionSelector]) {
        [target invokeWithSelector:actionSelector arguments:&action, &userInfo, &completion];
    }
#pragma clang diagnostic pop
}

@end

#pragma mark -

@interface M9URLAction ()

// + (M9URLAction *)actionWithURL:(NSURL *)actionURL;

@end

@implementation M9URLAction

+ (M9URLAction *)actionWithURL:(NSURL *)actionURL {
    if (!actionURL) {
        return nil;
    }
    M9URLAction *action = [M9URLAction new];
    action->_actionURL = actionURL;
    return action;
}

- (NSString *)description {
    return [[super description]
            stringByAppendingFormat:@" : %@ :// %@ %@ ? %@ # %@ = %@",
            self.actionURL.scheme.lowercaseString,
            self.actionURL.host.lowercaseString,
            self.actionURL.path.length ? self.actionURL.path : @"/", // <N/A>
            self.actionURL.queryDictionary,
            self.actionURL.fragment,
            self.actionURL];
}

@end

#pragma mark -

@interface M9URLActionManager ()

@property (nonatomic) NSMutableDictionary<NSString *, M9URLActionHandlerWrapper *> *actionHandlers;

@end

@implementation M9URLActionManager

+ (instancetype)globalActionManager {
    static M9URLActionManager *globalActionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalActionManager = [M9URLActionManager new];
    });
    return globalActionManager;
}

- (void)setValidSchemes:(NSArray<NSString *> *)schemes {
    NSMutableArray *validSchemes = nil;
    for (NSString *scheme in schemes) {
        validSchemes = validSchemes ?: [NSMutableArray new];
        [validSchemes addObject:scheme.lowercaseString];
    }
    self->_validSchemes = [validSchemes copy];
}

#pragma mark config with block

- (void)configWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path handler:(M9URLActionHandler)handler {
    self.actionHandlers = self.actionHandlers ?: [NSMutableDictionary new];
    
    M9URLActionHandlerWrapper *handlerWrapper = [M9URLActionHandlerWrapper handlerWithBlock:handler];
    [self.actionHandlers setObject:handlerWrapper forKey:M9URLActionKey(scheme, host, path)];
}

- (void)configWithScheme:(NSString *)scheme handler:(M9URLActionHandler)handler {
    [self configWithScheme:scheme host:nil path:nil handler:handler];
}

- (void)configWithHost:(NSString *)host path:(NSString *)path handler:(M9URLActionHandler)handler {
    [self configWithScheme:nil host:host path:path handler:handler];
}

#pragma mark config with target[-instance]-action

- (void)configWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path target:(id)target instance:(SEL)instance action:(SEL)action {
    self.actionHandlers = self.actionHandlers ?: [NSMutableDictionary new];
    
    M9URLActionHandlerWrapper *handlerWrapper = [M9URLActionHandlerWrapper handlerWithTarget:target instance:instance action:action];
    [self.actionHandlers setObject:handlerWrapper forKey:M9URLActionKey(scheme, host, path)];
}

- (void)configWithScheme:(NSString *)scheme target:(id)target instance:(SEL)instance action:(SEL)action {
    [self configWithScheme:scheme host:nil path:nil target:target instance:instance action:action];
}

- (void)configWithHost:(NSString *)host path:(NSString *)path target:(id)target instance:(SEL)instance action:(SEL)action {
    [self configWithScheme:nil host:host path:path target:target instance:instance action:action];
}

#pragma mark remove config

- (void)removeConfigWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path {
    [self.actionHandlers removeObjectForKey:M9URLActionKey(scheme, host, path)];
}

#pragma mark perform action

- (BOOL)performActionWithURL:(NSURL *)actionURL userInfo:(id)userInfo completion:(M9URLActionCompletion)completion {
    NSArray<NSString *> *validSchemes = self.validSchemes;
    if (validSchemes.count && ![validSchemes containsObject:actionURL.scheme.lowercaseString]) {
        return NO;
    }
    
    // matching: scheme://[host]/path
    NSString *key = M9URLActionKeyWithURL(actionURL, YES);
    M9URLActionHandlerWrapper *handler = [self.actionHandlers objectForKey:key];
    if (!handler) {
        if (actionURL.scheme.length) {
            // matching: scheme
            key = M9URLActionKeyWithScheme(actionURL.scheme);
            handler = [self.actionHandlers objectForKey:key];
        }
        if (!handler) {
            // matching: [host]/path
            key = M9URLActionKeyWithURL(actionURL, NO);
            handler = [self.actionHandlers objectForKey:key];
        }
        if (!handler) {
            return NO;
        }
    }
    
    M9URLAction *action = [M9URLAction actionWithURL:actionURL];
    [handler handleAction:action userInfo:userInfo completion:^(id result) {
        if (completion) completion(action, result);
    }];
    return YES;
}

- (BOOL)performActionWithURLString:(NSString *)actionURLString completion:(M9URLActionCompletion)completion {
    NSURL *url = [NSURL URLWithString:actionURLString];
    return [self performActionWithURL:url userInfo:nil completion:completion];
}

@end

@implementation M9URLActionManager (M9Additions)

#pragma mark perform chaining action

- (BOOL)performChainingActionWithURL:(NSURL *)actionURL userInfo:(id)userInfo completion:(M9URLActionCompletion)completion {
    return [self performActionWithURL:actionURL userInfo:userInfo completion:^(M9URLAction *action, id result) {
        NSString *fragment = action.actionURL.fragment;
        NSURL *nextActionURL = [NSURL URLWithString:[fragment stringByRemovingPercentEncoding]];
        if (nextActionURL) {
            [self performChainingActionWithURL:nextActionURL userInfo:result completion:completion];
        }
        else {
            if (completion) completion(action, result);
        }
    }];
}

@end
