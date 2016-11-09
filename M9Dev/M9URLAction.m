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

static inline NSString *M9URLActionKey(NSString *host, NSString *path) {
    if (![path hasPrefix:@"/"]) {
        path = [@"/" stringByAppendingString:path ?: @""];
    }
    return [NSString stringWithFormat:@"%@%@", host ?: @"", path];
}

static inline NSString *M9URLActionKeyWithURL(NSURL *url) {
    return url ? M9URLActionKey(url.host, url.path) : nil;
}

@interface M9URLActionHandlerWrapper : NSObject <M9MakeCopy>

#pragma mark block

+ (instancetype)handlerWithBlock:(M9URLActionHandler)handler;

@property (nonatomic, copy, readonly) M9URLActionHandler handler;

#pragma mark target[-instance]-action

+ (instancetype)handlerWithTarget:(id)target actionSelector:(SEL)actionSelector;
+ (instancetype)handlerWithTarget:(id)target instanceSelector:(SEL)instanceSelector actionSelector:(SEL)actionSelector;

@property (nonatomic, readonly) id target;
@property (nonatomic, readonly) SEL instanceSelector;
@property (nonatomic, readonly) SEL actionSelector;

@end

@interface M9URLActionHandlerWrapper ()

@property (nonatomic, copy) M9URLActionHandler handler;

@property (nonatomic) id target;
@property (nonatomic) SEL instanceSelector;
@property (nonatomic) SEL actionSelector;

- (void)handleAction:(M9URLAction *)action
            userInfo:(id)userInfo
          completion:(M9URLActionHandlerCompletion)completion;

@end

@implementation M9URLActionHandlerWrapper

+ (instancetype)handlerWithBlock:(M9URLActionHandler)handler {
    M9URLActionHandlerWrapper *actionHandler = [self new];
    actionHandler.handler = handler;
    return actionHandler;
}

+ (instancetype)handlerWithTarget:(id)target
                   actionSelector:(SEL)actionSelector {
    return [self handlerWithTarget:target
                  instanceSelector:@selector(self)
                    actionSelector:actionSelector];
}

+ (instancetype)handlerWithTarget:(id)target
                 instanceSelector:(SEL)instanceSelector
                   actionSelector:(SEL)actionSelector {
    M9URLActionHandlerWrapper *actionHandler = [self new];
    actionHandler.target = target;
    actionHandler.instanceSelector = instanceSelector;
    actionHandler.actionSelector = actionSelector;
    return actionHandler;
}

@M9MakeCopyWithZone;
- (void)makeCopy:(M9URLActionHandlerWrapper *)copy {
    copy.handler = self.handler;
    copy.target = self.target;
    copy.instanceSelector = self.instanceSelector;
    copy.actionSelector = self.actionSelector;
}

- (void)handleAction:(M9URLAction *)action
            userInfo:(id)userInfo
          completion:(M9URLActionHandlerCompletion)completion {
    if (self.handler) {
        self.handler(action, userInfo, completion);
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id target = self.target;
    SEL instanceSelector = self.instanceSelector OR @selector(self);
    // #import <objc/runtime.h>
    // class_isMetaClass(object_getClass(target))
    if ([target respondsToSelector:instanceSelector]) {
        target = [target performSelector:instanceSelector];
    }
    else if (target == [target class] && [target instancesRespondToSelector:instanceSelector]) {
        target = [[[target class] alloc] performSelector:instanceSelector withObject:nil];
    }
    SEL actionSelector = self.actionSelector;
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
            self.actionURL.scheme,
            self.actionURL.host,
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

- (void)configActionWithURLHost:(NSString *)host path:(NSString *)path handler:(M9URLActionHandler)handler {
    self.actionHandlers = self.actionHandlers ?: [NSMutableDictionary new];
    
    M9URLActionHandlerWrapper *handlerWrapper = [M9URLActionHandlerWrapper handlerWithBlock:handler];
    [self.actionHandlers setObject:handlerWrapper forKey:M9URLActionKey(host, path)];
}

- (void)configActionWithURLHost:(NSString *)host
                           path:(NSString *)path
                         target:(id)target
                 actionSelector:(SEL)actionSelector {
    [self configActionWithURLHost:host
                             path:path
                           target:target
                 instanceSelector:@selector(self)
                   actionSelector:actionSelector];
}

- (void)configActionWithURLHost:(NSString *)host
                           path:(NSString *)path
                         target:(id)target
               instanceSelector:(SEL)instanceSelector
                 actionSelector:(SEL)actionSelector {
    self.actionHandlers = self.actionHandlers ?: [NSMutableDictionary new];
    
    M9URLActionHandlerWrapper *handlerWrapper = [M9URLActionHandlerWrapper handlerWithTarget:target
                                                                            instanceSelector:instanceSelector
                                                                              actionSelector:actionSelector];
    [self.actionHandlers setObject:handlerWrapper forKey:M9URLActionKey(host, path)];
}

- (void)removeActionWithURLHost:(NSString *)host path:(NSString *)path {
    [self.actionHandlers removeObjectForKey:M9URLActionKey(host, path)];
}

- (BOOL)performActionWithURLString:(NSString *)actionURLString completion:(M9URLActionCompletion)completion {
    NSURL *url = [NSURL URLWithString:actionURLString];
    return [self performActionWithURL:url completion:completion];
}

- (BOOL)performActionWithURL:(NSURL *)actionURL completion:(M9URLActionCompletion)completion {
    return [self performActionWithURL:actionURL userInfo:nil completion:completion];
}

- (BOOL)performActionWithURL:(NSURL *)actionURL userInfo:(id)userInfo completion:(M9URLActionCompletion)completion {
    NSArray<NSString *> *validSchemes = self.validSchemes;
    if (validSchemes.count && ![validSchemes containsObject:actionURL.scheme]) {
        return NO;
    }
    NSString *key = M9URLActionKeyWithURL(actionURL);
    M9URLActionHandlerWrapper *handler = [self.actionHandlers objectForKey:key];
    if (!handler) {
        return NO;
    }
    M9URLAction *action = [M9URLAction actionWithURL:actionURL];
    [handler handleAction:action userInfo:userInfo completion:^(id result) {
        if (completion) completion(action, result);
    }];
    return YES;
}

@end

@implementation M9URLActionManager (M9ChainingViaURLFragment)

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
