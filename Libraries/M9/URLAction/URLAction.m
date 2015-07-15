//
//  URLAction.m
//  M9Dev
//
//  Created by MingLQ on 2015-06-12.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import "URLAction.h"

#import "NSURL+M9Categories.h"

@interface URLActionSetting ()
@property(nonatomic, copy) URLActionBlock actionBlock;
@property(nonatomic) id target;
@property(nonatomic) SEL instanceSelector;
@property(nonatomic) SEL actionSelector;
- (void)performWithAction:(URLAction *)action finish:(URLActionFinishBlock)finish;
@end

#pragma mark -

@interface URLAction ()

@property(nonatomic, copy) NSURL *URL;
@property(nonatomic, copy) NSString *scheme;
@property(nonatomic, copy) NSString *key;
@property(nonatomic, copy) NSDictionary *parameters;
@property(nonatomic, copy) NSString *nextURLString;

@property(nonatomic, copy) URLActionSetting *setting;
@property(nonatomic, copy) URLActionCompletion completion;

@property(nonatomic, strong) URLAction *prevAction;
@property(nonatomic, copy) NSDictionary *prevActionResult;

@end

@implementation URLAction

static NSArray *ValidSchemes = nil;

+ (NSArray *)validSchemes
{ @synchronized(self) {
    return ValidSchemes;
}}

+ (void)setValidSchemes:(NSArray *)validSchemes
{ @synchronized(self) {
    ValidSchemes = [validSchemes copy];
}}

static NSDictionary *ActionSettings = nil;

+ (NSDictionary *)actionSettings
{ @synchronized(self) {
    return ActionSettings;
}}

+ (void)setActionSettings:(NSDictionary *)actionSettings
{ @synchronized(self) {
    ActionSettings = [actionSettings copy];
}}

+ (instancetype)performActionWithURL:(NSURL *)actionURL completion:(URLActionCompletion)completion {
    URLAction *action = [self actionWithURL:actionURL completion:completion];
    return [action perform] ? action : nil;
}

+ (instancetype)performActionWithURLString:(NSString *)actionURLString completion:(URLActionCompletion)completion {
    NSURL *url = [NSURL URLWithString:actionURLString];
    return [self performActionWithURL:url completion:completion];
}

+ (instancetype)actionWithURL:(NSURL *)actionURL completion:(URLActionCompletion)completion {
    if (!actionURL) {
        NSLog(@"NO Action URL @ %@", _HERE);
        return nil;
    }
    
    URLAction *action = [self new];
    
    action.URL = actionURL;
    action.scheme = actionURL.scheme;
    action.key = [actionURL.host lowercaseString];
    action.parameters = actionURL.queryDictionary;
    action.nextURLString = [actionURL.fragment stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    action.setting = [[URLAction actionSettings] objectForKey:action.key class:[URLActionSetting class]];
    action.completion = completion;
    
    return action;
}

- (BOOL)perform {
    NSArray *validSchemes = [URLAction validSchemes];
    if (validSchemes.count && ![validSchemes containsObject:self.scheme]) {
        return NO;
    }
    
    // !!!: DONOT weakify self
    [self.setting performWithAction:self finish:^(/* BOOL success, */NSDictionary *result) {
        BOOL isTheLast = ![self performNextWithResult:result completion:self.completion];
        if (isTheLast && self.completion) self.completion(/* success */);
    }];
    
    return !!self.setting;
}

- (BOOL)performNextWithResult:(NSDictionary *)result completion:(URLActionCompletion)completion {
    NSURL *nextActionURL = [NSURL URLWithString:self.nextURLString];
    URLAction *nextAction = [URLAction actionWithURL:nextActionURL completion:completion];
    nextAction.prevAction = self;
    nextAction.prevActionResult = result;
    return [nextAction perform];
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" : %@ > %@ ? %@ # %@", self.URL, self.key, self.parameters, self.nextURLString];
}

@end

#pragma mark -

@implementation URLActionSetting

+ (instancetype)actionSettingWithBlock:(URLActionBlock)actionBlock {
    URLActionSetting *actionSetting = [self new];
    actionSetting.actionBlock = actionBlock;
    return actionSetting;
}

+ (instancetype)actionSettingWithTarget:(id)target actionSelector:(SEL)actionSelector {
    return [self actionSettingWithTarget:target instanceSelector:@selector(self) actionSelector:actionSelector];
}

+ (instancetype)actionSettingWithTarget:(id)target instanceSelector:(SEL)instanceSelector actionSelector:(SEL)actionSelector {
    URLActionSetting *actionSetting = [self new];
    actionSetting.target = target;
    actionSetting.instanceSelector = instanceSelector;
    actionSetting.actionSelector = actionSelector;
    return actionSetting;
}

@M9MakeCopyWithZone;
- (void)makeCopy:(URLActionSetting *)copy {
    copy.actionBlock = self.actionBlock;
    copy.target = self.target;
    copy.instanceSelector = self.instanceSelector;
    copy.actionSelector = self.actionSelector;
}

- (void)performWithAction:(URLAction *)action finish:(URLActionFinishBlock)finish {
    if (self.actionBlock) {
        self.actionBlock(action, finish);
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
        [target performSelector:actionSelector withObject:action withObject:finish];
    }
#pragma clang diagnostic pop
}

@end
