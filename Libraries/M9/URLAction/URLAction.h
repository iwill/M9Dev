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

+ (NSArray *)validSchemes;
+ (void)setValidSchemes:(NSArray *)validSchemes;

+ (NSDictionary *)actionSettings;
+ (void)setActionSettings:(NSDictionary *)actionSettings;

#pragma mark - perform action

/**
 *  @return URLAction if perform success
 */
+ (instancetype)performActionWithURL:(NSURL *)actionURL source:(id/* <URLActionSource> */)source;
+ (instancetype)performActionWithURLString:(NSString *)actionURLString source:(id/* <URLActionSource> */)source;

#pragma mark - parameters

@property(nonatomic, copy, readonly) NSURL *URL;
@property(nonatomic, copy, readonly) NSString *scheme;
@property(nonatomic, copy, readonly) NSString *key;
@property(nonatomic, copy, readonly) NSDictionary *parameters;
@property(nonatomic, copy, readonly) NSString *nextURLString;

@property(nonatomic, copy, readonly) URLActionSetting *setting;
@property(nonatomic, weak, readonly) id/* <URLActionSource> */ source; // (id<URLActionSource>) OR (UIViewController *)

@property(nonatomic, strong, readonly) URLAction *prevAction;
@property(nonatomic, copy, readonly) NSDictionary *prevActionResult;

#pragma mark - helper

- (UIViewController *)sourceViewControllerForTargetViewController:(UIViewController *)targetViewController;

@end

#pragma mark -

@interface URLActionSetting : NSObject <M9MakeCopy>

typedef void (^URLActionNextBlock)(NSDictionary *result);
typedef void (^URLActionBlock)(URLAction *action, URLActionNextBlock next);

#pragma mark - action setting with block

/**
 *  ignore class-target-action if has actionBlock
 *  
 *  call next when completed
 *      if (next) next(<#result#>);
 */
@property(nonatomic, copy, readonly) URLActionBlock actionBlock;
+ (instancetype)actionSettingWithBlock:(URLActionBlock)actionBlock;

#pragma mark - action setting with target[-instance]-action

/**
 *  class or object
 */
@property(nonatomic, readonly) id target;
/**
 *  selector of class method to get instance, or @selector(self) to get itself
 */
@property(nonatomic, readonly) SEL instanceSelector;
/**
 *  selector of method with two parameters URLAction *action and URLActionNextBlock next
 *  e.g.
 *      + (void)performAction:(URLAction *)action next:(URLActionNextBlock)next;
 *      - (void)performAction:(URLAction *)action next:(URLActionNextBlock)next;
 *  
 *  call next when completed
 *      if (next) next(<#result#>);
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
