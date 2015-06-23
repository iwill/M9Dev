//
//  URLAction.h
//  M9Dev
//
//  Created by MingLQ on 2015-06-12.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EXTScope.h"
#import "M9Utilities.h"
#import "UIViewController+.h"

@class URLActionSetting;

@interface URLAction : NSObject

+ (NSDictionary *)actionSettings;
+ (void)setActionSettings:(NSDictionary *)actionSettings;

+ (BOOL)performActionWithURL:(NSURL *)actionURL source:(id/* <URLActionSource> */)source;
+ (BOOL)performActionWithURLString:(NSString *)actionURLString source:(id/* <URLActionSource> */)source;

@property(nonatomic, copy, readonly) NSURL *actionURL;
@property(nonatomic, copy, readonly) NSString *actionKey;
@property(nonatomic, copy, readonly) NSDictionary *parameters;
@property(nonatomic, copy, readonly) NSString *nextActionURL;

@property(nonatomic, copy, readonly) URLActionSetting *actionSetting;
@property(nonatomic, weak, readonly) id/* <URLActionSource> */ source; // (id<URLActionSource>) OR (UIViewController *)

@property(nonatomic, strong, readonly) URLAction *prevAction;
@property(nonatomic, copy, readonly) NSDictionary *prevActionResult;

@end

#pragma mark -

typedef void (^URLActionCompletionBlock)(BOOL success, NSDictionary *result);
// @return source of the next action, (id<URLActionSource>) OR (UIViewController *)
typedef id/* <URLActionSource> */ (^URLActionBlock)(URLAction *action, URLActionCompletionBlock completion);

@interface URLActionSetting : NSObject <M9MakeCopy>

// ignore class-target-action if has actionBlock
@property(nonatomic, copy, readonly) URLActionBlock actionBlock;

+ (instancetype)actionSettingWithBlock:(URLActionBlock)actionBlock;

@property(nonatomic, readonly) id target;
// selector of class method to get instance, or @selector(self) to get itself
@property(nonatomic, readonly) SEL instanceSelector;
// selector of method with two parameters URLAction *action and URLActionCompletionBlock completion
// @return source of the next action, (id<URLActionSource>) OR (UIViewController *)
// + (id)performAction:(URLAction *)action completion:(URLActionCompletionBlock)completion;
// - (id)performAction:(URLAction *)action completion:(URLActionCompletionBlock)completion;
@property(nonatomic, readonly) SEL actionSelector;

+ (instancetype)actionSettingWithTarget:(id)target actionSelector:(SEL)actionSelector;
+ (instancetype)actionSettingWithTarget:(id)target instanceSelector:(SEL)instanceSelector actionSelector:(SEL)actionSelector;

@end

#pragma mark -

@protocol URLActionSource <NSObject>

@optional
- (UIViewController *)sourceViewControllerForActionURL:(NSString *)actionURL targetViewController:(UIViewController *)targetViewController;
- (void)closeViewControllerForActionURL:(NSString *)actionURL targetViewController:(UIViewController *)targetViewController;

@end
