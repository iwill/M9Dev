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

#pragma mark - settings

+ (NSDictionary *)actionSettings;
+ (void)setActionSettings:(NSDictionary *)actionSettings;

#pragma mark - perform action

/**
 *  @return URLAction if perform success
 */
+ (instancetype)performActionWithURL:(NSURL *)actionURL source:(id/* <URLActionSource> */)source;
+ (instancetype)performActionWithURLString:(NSString *)actionURLString source:(id/* <URLActionSource> */)source;

#pragma mark - parameters

@property(nonatomic, copy, readonly) NSURL *actionURL;
@property(nonatomic, copy, readonly) NSString *actionKey;
@property(nonatomic, copy, readonly) NSDictionary *parameters;
@property(nonatomic, copy, readonly) NSString *nextActionURL;

@property(nonatomic, copy, readonly) URLActionSetting *actionSetting;
@property(nonatomic, weak, readonly) id/* <URLActionSource> */ source; // (id<URLActionSource>) OR (UIViewController *)

@property(nonatomic, strong, readonly) URLAction *prevAction;
@property(nonatomic, copy, readonly) NSDictionary *prevActionResult;

#pragma mark - helper

- (UIViewController *)sourceViewControllerForTargetViewController:(UIViewController *)targetViewController;

@end

#pragma mark -

@interface URLActionSetting : NSObject <M9MakeCopy>

typedef void (^URLActionCompletionBlock)(BOOL success, NSDictionary *result);
/**
 *  @return source of the next action, (id<URLActionSource>) OR (UIViewController *)
 */
typedef id (^URLActionBlock)(URLAction *action, URLActionCompletionBlock completion);

#pragma mark - action setting with block

/**
 *  ignore class-target-action if has actionBlock
 */
@property(nonatomic, copy, readonly) URLActionBlock actionBlock;
+ (instancetype)actionSettingWithBlock:(URLActionBlock)actionBlock;

#pragma mark - action setting with target[-instance]-action

@property(nonatomic, readonly) id target;
/**
 *  selector of class method to get instance, or @selector(self) to get itself
 */
@property(nonatomic, readonly) SEL instanceSelector;
/**
 *  selector of method with two parameters URLAction *action and URLActionCompletionBlock completion
 *  @return source of the next action, (id<URLActionSource>) OR (UIViewController *)
 *  e.g.
 *      + (id)performAction:(URLAction *)action completion:(URLActionCompletionBlock)completion;
 *      - (id)performAction:(URLAction *)action completion:(URLActionCompletionBlock)completion;
 */
@property(nonatomic, readonly) SEL actionSelector;
+ (instancetype)actionSettingWithTarget:(id)target actionSelector:(SEL)actionSelector;
+ (instancetype)actionSettingWithTarget:(id)target instanceSelector:(SEL)instanceSelector actionSelector:(SEL)actionSelector;

@end

#pragma mark -

@protocol URLActionSource <NSObject>
@optional

/**
 *  do clear or log with action url/parameters
 */
- (void)willPerformAction:(URLAction *)action;
/**
 *  use source if does not implement this method
 */
- (UIViewController *)sourceViewControllerForAction:(URLAction *)action targetViewController:(UIViewController *)targetViewController;

@end
