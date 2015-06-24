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
- (id)performActionWithObject:(id)object1 withObject:(id)object2;
@end

#pragma mark -

@interface URLAction ()

@property(nonatomic, copy) NSURL *actionURL;
@property(nonatomic, copy) NSString *actionKey;
@property(nonatomic, copy) NSDictionary *parameters;
@property(nonatomic, copy) NSString *nextActionURL;

@property(nonatomic, copy) URLActionSetting *actionSetting;
@property(nonatomic, weak) id/* <URLActionSource> */ source; // <URLActionSource> OR UIViewController

@property(nonatomic, strong) URLAction *prevAction;
@property(nonatomic, copy) NSDictionary *prevActionResult;

@end

@implementation URLAction

static NSDictionary *ActionSettings = nil;

+ (NSDictionary *)actionSettings {@synchronized(self) {
    return ActionSettings;
}}

+ (void)setActionSettings:(NSDictionary *)actionSettings {@synchronized(self) {
    ActionSettings = [actionSettings copy];
}}

+ (BOOL)performActionWithURL:(NSURL *)actionURL source:(id/* <URLActionSource> */)source {
    URLAction *action = [self actionWithURL:actionURL source:source];
    return [action perform];
}

+ (BOOL)performActionWithURLString:(NSString *)actionURLString source:(id/* <URLActionSource> */)source {
    NSURL *url = [NSURL URLWithString:actionURLString];
    return [self performActionWithURL:url source:source];
}

+ (instancetype)actionWithURL:(NSURL *)actionURL source:(id/* <URLActionSource> */)source {
    if (!actionURL) {
        NSLog(@"NO Action URL @ %@", _HERE);
        return nil;
    }
    
    URLAction *action = [self new];
    action.actionURL = actionURL;
    
    action.actionKey = [actionURL.host lowercaseString];
    action.parameters = actionURL.queryDictionary;
    action.nextActionURL = actionURL.fragment;
    
    action.actionSetting = [[URLAction actionSettings] objectForKey:action.actionKey class:[URLActionSetting class]];
    action.source = source;
    
    return action;
}

- (BOOL)perform {
    weakify(self);
    __block id target = [self.actionSetting performActionWithObject:self withObject:^(BOOL success, NSDictionary *result) {
        strongify(self);
        if (success) {
            [self performNextWithResult:result source:target];
        }
    }];
    return !!self.actionSetting;
}

- (BOOL)performNextWithResult:(NSDictionary *)result source:(id/* <URLActionSource> */)source {
    NSURL *nextActionURL = [NSURL URLWithString:self.nextActionURL];
    URLAction *nextAction = [URLAction actionWithURL:nextActionURL source:source];
    nextAction.prevAction = self;
    nextAction.prevActionResult = result;
    return [nextAction perform];
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

- (id)performActionWithObject:(id)object1 withObject:(id)object2 {
    if (self.actionBlock) {
        return self.actionBlock(object1, object2);
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id target = self.target;
    SEL instanceSelector = self.instanceSelector OR @selector(self);
    if ([target respondsToSelector:instanceSelector]) {
        target = [target performSelector:instanceSelector];
        SEL actionSelector = self.actionSelector;
        if ([target respondsToSelector:actionSelector]) {
            return [target performSelector:actionSelector withObject:object1 withObject:object2] OR target;
        }
    }
    return target;
#pragma clang diagnostic pop
}

@end
