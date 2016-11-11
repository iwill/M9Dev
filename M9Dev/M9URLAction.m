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

/** scheme:// */
static inline NSString *_M9URLActionKey_scheme(NSString *scheme) {
    if (!scheme.length) {
        return @"";
    }
    return ([scheme hasSuffix:@"://"] ? scheme : [scheme stringByAppendingString:@"://"]);
}

/** host */
static inline NSString *_M9URLActionKey_host(NSString *host) {
    if (!host.length) {
        return @"";
    }
    return host;
}

/** /path or / */
static inline NSString *_M9URLActionKey_path(NSString *path) {
    if (!path.length) {
        return @"/";
    }
    return [path hasPrefix:@"/"] ? path : [@"/" stringByAppendingString:path];
}

/**
 *  URL components combination:
 *      [ scheme:// host /path ]
 *      [ scheme:// host /     ]
 *      [ scheme://      /path ]
 *      [ scheme://      /     ]
 *      [           host /path ]
 *      [           host /     ]
 *      [                /path ]
 *      [                /     ]
 */
static inline NSString *M9URLActionKey(NSString *scheme, NSString *host, NSString *path) {
    return [NSString stringWithFormat:@"%@%@%@",
            _M9URLActionKey_scheme(scheme).lowercaseString ?: @"",
            _M9URLActionKey_host(host).lowercaseString ?: @"",
            _M9URLActionKey_path(path)];
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

// + (M9URLAction *)actionWithURL:(NSURL *)URL;

@end

@implementation M9URLAction

+ (M9URLAction *)actionWithURL:(NSURL *)URL {
    if (!URL) {
        return nil;
    }
    M9URLAction *action = [M9URLAction new];
    action->_URL = URL;
    return action;
}

- (NSString *)description {
    return [[super description]
            stringByAppendingFormat:@" : %@ :// %@ %@ ? %@ # %@ = %@",
            self.URL.scheme.lowercaseString,
            self.URL.host.lowercaseString,
            self.URL.path.length ? self.URL.path : @"/", // <N/A>
            self.URL.queryDictionary,
            self.URL.fragment,
            self.URL];
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

- (BOOL)performActionWithURL:(NSURL *)URL userInfo:(id)userInfo completion:(M9URLActionCompletion)completion {
    if (!URL) {
        return NO;
    }
    
    if (self.validSchemes.count
        && ![self.validSchemes containsObject:URL.scheme.lowercaseString]) {
        return NO;
    }
    
    NSString *key = nil;
    M9URLActionHandlerWrapper *handler = nil;
    
    if (URL.scheme.length) {
        if (URL.host.length) {
            if (URL.path.length) {
                // [ scheme:// host /path ]
                key = M9URLActionKey(URL.scheme, URL.host, URL.path);
                handler = [self.actionHandlers objectForKey:key];
            }
            if (!handler) {
                // [ scheme:// host /     ]
                key = M9URLActionKey(URL.scheme, URL.host, nil);
                handler = [self.actionHandlers objectForKey:key];
            }
        }
        if (!handler) {
            // [ scheme://      /path ]
            key = M9URLActionKey(URL.scheme, nil, URL.path);
            handler = [self.actionHandlers objectForKey:key];
        }
        if (!handler) {
            // [ scheme://      /     ]
            key = M9URLActionKey(URL.scheme, nil, nil);
            handler = [self.actionHandlers objectForKey:key];
        }
    }
    
    if (!handler && URL.host.length) {
        if (URL.path.length) {
            // [           host /path ]
            key = M9URLActionKey(nil, URL.host, URL.path);
            handler = [self.actionHandlers objectForKey:key];
        }
        if (!handler) {
            // [           host /     ]
            key = M9URLActionKey(nil, URL.host, nil);
            handler = [self.actionHandlers objectForKey:key];
        }
    }
    
    if (!handler) {
        // !!!: use / if !URL.path.length
        // [                /path ]
        // [                /     ]
        key = M9URLActionKey(nil, nil, URL.path);
        handler = [self.actionHandlers objectForKey:key];
    }
    
    if (!handler) {
        return NO;
    }
    
    M9URLAction *action = [M9URLAction actionWithURL:URL];
    [handler handleAction:action userInfo:userInfo completion:^(id result) {
        if (completion) completion(action, result);
    }];
    return YES;
}

- (BOOL)performActionWithURLString:(NSString *)URLString completion:(M9URLActionCompletion)completion {
    NSURL *url = [NSURL URLWithString:URLString];
    return [self performActionWithURL:url userInfo:nil completion:completion];
}

@end

@implementation M9URLActionManager (M9Additions)

#pragma mark perform chaining action

- (BOOL)performChainingActionWithURL:(NSURL *)URL userInfo:(id)userInfo completion:(M9URLActionCompletion)completion {
    return [self performActionWithURL:URL userInfo:userInfo completion:^(M9URLAction *action, id result) {
        NSString *fragment = action.URL.fragment;
        NSURL *nextURL = [NSURL URLWithString:[fragment stringByRemovingPercentEncoding]];
        if (nextURL) {
            [self performChainingActionWithURL:nextURL userInfo:result completion:completion];
        }
        else {
            if (completion) completion(action, result);
        }
    }];
}

@end
