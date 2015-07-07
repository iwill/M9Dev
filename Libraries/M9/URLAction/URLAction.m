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
- (void)performWithAction:(URLAction *)action next:(URLActionNextBlock)next;
@end

#pragma mark -

@interface URLAction ()

@property(nonatomic, copy) NSURL *URL;
@property(nonatomic, copy) NSString *scheme;
@property(nonatomic, copy) NSString *key;
@property(nonatomic, copy) NSDictionary *parameters;
@property(nonatomic, copy) NSString *nextURLString;

@property(nonatomic, copy) URLActionSetting *setting;
@property(nonatomic, weak) id/* <URLActionSource> */ source; // <URLActionSource> OR UIViewController

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

+ (instancetype)performActionWithURL:(NSURL *)actionURL source:(id/* <URLActionSource> */)source {
    URLAction *action = [self actionWithURL:actionURL source:source];
    return [action perform] ? action : nil;
}

+ (instancetype)performActionWithURLString:(NSString *)actionURLString source:(id/* <URLActionSource> */)source {
    NSURL *url = [NSURL URLWithString:actionURLString];
    return [self performActionWithURL:url source:source];
}

+ (instancetype)actionWithURL:(NSURL *)actionURL source:(id/* <URLActionSource> */)source {
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
    action.source = source;
    
    return action;
}

- (BOOL)perform {
    NSArray *validSchemes = [URLAction validSchemes];
    if (validSchemes.count && ![validSchemes containsObject:self.scheme]) {
        return NO;
    }
    
    // !!!: DONOT weakify self
    [self.setting performWithAction:self next:^(NSDictionary *result) {
        // !!!: NO source for next
        [self performNextWithResult:result source:nil];
        // NOTE: else perform another action here
    }];
    
    return !!self.setting;
}

- (BOOL)performNextWithResult:(NSDictionary *)result source:(id/* <URLActionSource> */)source {
    NSURL *nextActionURL = [NSURL URLWithString:self.nextURLString];
    URLAction *nextAction = [URLAction actionWithURL:nextActionURL source:source];
    nextAction.prevAction = self;
    nextAction.prevActionResult = result;
    return [nextAction perform];
}

- (UIViewController *)sourceViewControllerForTargetViewController:(UIViewController *)targetViewController {
    if ([self.source respondsToSelector:@selector(sourceViewControllerForAction:targetViewController:)]) {
        return [self.source sourceViewControllerForAction:self
                                     targetViewController:targetViewController];
    }
    return [self.source as:[UIViewController class]];
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

- (void)performWithAction:(URLAction *)action next:(URLActionNextBlock)next {
    if ([action.source respondsToSelector:@selector(willPerformAction:)]) {
        [action.source willPerformAction:action];
    }
    
    if (self.actionBlock) {
        self.actionBlock(action, next);
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id target = self.target;
    SEL instanceSelector = self.instanceSelector OR @selector(self);
    // #import <objc/runtime.h>
    // class_isMetaClass(object_getClass(target))
    if (target == [target class] && [[target class] instancesRespondToSelector:instanceSelector]) {
        target = [[[target class] alloc] performSelector:instanceSelector withObject:nil];
    }
    else if ([target respondsToSelector:instanceSelector]) {
        target = [target performSelector:instanceSelector];
    }
    SEL actionSelector = self.actionSelector;
    if ([target respondsToSelector:actionSelector]) {
        [target performSelector:actionSelector withObject:action withObject:next];
    }
#pragma clang diagnostic pop
}

@end
