//
//  URLAction.h
//  M9Dev
//
//  Created by MingLQ on 2015-06-12.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

@class URLAction;

typedef NS_ENUM(NSInteger, URLActionNavigationType) {
    URLActionNavigationTypeGoto,
    URLActionNavigationTypeOpen,
    URLActionNavigationTypeReload
};

@protocol URLActionSource <NSObject>
@optional
- (UINavigationController *)navigationControllerWithActionURL:(NSString *)actionURL targetViewController:(UIViewController *)targetViewController;
- (UIViewController *)presentingViewControllerWithActionURL:(NSString *)actionURL targetViewController:(UIViewController *)targetViewController;
- (void)gotoRootViewControllerWithActionURL:(NSString *)actionURL targetViewController:(UIViewController *)targetViewController;
@end

@protocol URLActionTarget <NSObject>
@optional
- (URLActionNavigationType)navigationTypeWithActionURL:(NSString *)actionURL sourceViewController:(UIViewController *)sourceViewController;
@end

#pragma mark -

@interface URLActionInfo : NSObject

@property(nonatomic, strong) id/* <URLActionSource> */ source;
@property(nonatomic) BOOL success;
@property(nonatomic, strong) id result;
@property(nonatomic, strong) NSString *nextAction;

@end

@interface URLActionSetting : NSObject

@property(nonatomic, readonly) Class clazz;
// selector of method to get instance, @selector(self) for class
@property(nonatomic, readonly) SEL target;
// selector of method with two parameters URLAction *action and URLActionInfo *actionInfo, returning ....
// ???: return what
@property(nonatomic, readonly) SEL action;

// class-target-action first
@property(nonatomic, copy) void (^block)(URLAction *action, URLActionInfo *actionInfo);

+ (instancetype)actionSettingWithClass:(Class)clazz target:(SEL)target action:(SEL)action;
+ (instancetype)actionSettingWithBlock:(void (^)(URLAction *action, URLActionInfo *actionInfo))block;

@end

@interface URLAction : NSObject

+ (NSDictionary *)actionSettings;
+ (void)setActionSettings:(NSDictionary *)actionSettings;

/* private
+ (instancetype)actionWithURL:(NSString *)actionURL actionInfo:(URLActionInfo *)actionInfo;
+ (void)performActionWithURL:(NSString *)actionURL actionInfo:(URLActionInfo *)actionInfo completion:(void (^)(void))completion; */

+ (void)performActionWithURL:(NSString *)actionURL completion:(void (^)(void))completion;

@property(nonatomic, copy, readonly) NSString *actionURL, *nextActionURL;
@property(nonatomic, copy, readonly) URLActionSetting *actionSetting;

- (void)actionWithCompletion:(void (^)(void))completion;

@end
