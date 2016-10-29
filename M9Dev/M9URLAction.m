//
//  M9URLAction.m
//  M9Dev
//
//  Created by MingLQ on 2015-06-12.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <libextobjc/EXTScope.h>

#import "M9URLAction.h"

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

- (void)handleAction:(M9URLAction *)action completion:(M9URLActionHandlerCompletion)completion;

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

- (void)handleAction:(M9URLAction *)action completion:(M9URLActionHandlerCompletion)completion {
    if (self.handler) {
        self.handler(action, completion);
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
    else if (target == [target class] && [[target class] instancesRespondToSelector:instanceSelector]) {
        target = [[[target class] alloc] performSelector:instanceSelector withObject:nil];
    }
    SEL actionSelector = self.actionSelector;
    if ([target respondsToSelector:actionSelector]) {
        [target performSelector:actionSelector withObject:action withObject:completion];
    }
#pragma clang diagnostic pop
}

@end

#pragma mark -

@interface M9URLAction ()

@property (nonatomic, readwrite, copy) NSURL *actionURL;

@property (nonatomic, readwrite, copy) NSString *nextURLString;

@property (nonatomic, readwrite) M9URLAction *prevAction;
@property (nonatomic, readwrite, copy) NSDictionary *prevActionResult;

+ (M9URLAction *)actionWithURL:(NSURL *)actionURL;

@end

@implementation M9URLAction

+ (M9URLAction *)actionWithURL:(NSURL *)actionURL {
    if (!actionURL) {
        return nil;
    }
    M9URLAction *action = [M9URLAction new];
    action.actionURL = actionURL;
    action.nextURLString = [actionURL.fragment stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return action;
}

@dynamic originalAction;
- (M9URLAction *)originalAction {
    return self.prevAction ? self.prevAction.originalAction : self;
}

- (NSString *)description {
    return [[super description]
            stringByAppendingFormat:@" : %@ = %@ ? %@ # %@",
            self.actionURL, self.actionURL.host, self.actionURL.queryDictionary, self.nextURLString];
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

- (void)configActionWithURLHost:(NSString *)host handler:(M9URLActionHandler)handler {
    self.actionHandlers = self.actionHandlers ?: [NSMutableDictionary new];
    
    M9URLActionHandlerWrapper *handlerWrapper = [M9URLActionHandlerWrapper handlerWithBlock:handler];
    [self.actionHandlers setObject:handlerWrapper forKey:host];
}

- (void)configActionWithURLHost:(NSString *)host
                         target:(id)target
                 actionSelector:(SEL)actionSelector {
    [self configActionWithURLHost:host
                           target:target
                 instanceSelector:@selector(self)
                   actionSelector:actionSelector];
}

- (void)configActionWithURLHost:(NSString *)host
                         target:(id)target
               instanceSelector:(SEL)instanceSelector
                 actionSelector:(SEL)actionSelector {
    self.actionHandlers = self.actionHandlers ?: [NSMutableDictionary new];
    
    M9URLActionHandlerWrapper *handlerWrapper = [M9URLActionHandlerWrapper handlerWithTarget:target
                                                                            instanceSelector:instanceSelector
                                                                              actionSelector:actionSelector];
    [self.actionHandlers setObject:handlerWrapper forKey:host];
}

- (void)removeActionWithURLHost:(NSString *)host {
    [self.actionHandlers removeObjectForKey:host];
}

- (BOOL)performActionWithURL:(NSURL *)actionURL completion:(M9URLActionCompletion)completion {
    NSArray<NSString *> *validSchemes = self.validSchemes;
    if (validSchemes.count && ![validSchemes containsObject:actionURL.scheme]) {
        return NO;
    }
    M9URLActionHandlerWrapper *handler = [self.actionHandlers objectForKey:actionURL.host];
    if (!handler) {
        return NO;
    }
    M9URLAction *action = [M9URLAction actionWithURL:actionURL];
    [self performAction:action handler:handler completion:completion];
    return YES;
}

- (void)performAction:(M9URLAction *)action handler:(M9URLActionHandlerWrapper *)handler completion:(M9URLActionCompletion)completion {
    weakdef(self);
    [handler handleAction:action completion:^(NSDictionary *result) {
        strongdef(self);
        NSURL *nextActionURL = [NSURL URLWithString:action.nextURLString];
        M9URLActionHandlerWrapper *handler = [self.actionHandlers objectForKey:nextActionURL.host];
        if (handler) {
            M9URLAction *nextAction = [M9URLAction actionWithURL:nextActionURL];
            nextAction.prevAction = action;
            nextAction.prevActionResult = result;
            [self performAction:nextAction handler:handler completion:completion];
        }
        else {
            if (completion) completion(action, result);
        }
    }];
}

- (BOOL)performActionWithURLString:(NSString *)actionURLString completion:(M9URLActionCompletion)completion {
    NSURL *url = [NSURL URLWithString:actionURLString];
    return [self performActionWithURL:url completion:completion];
}

@end
