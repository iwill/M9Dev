//
//  URLAction.h
//  M9Dev
//
//  Created by MingLQ on 2015-06-12.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EXTScope+M9.h"
#import "M9Utilities.h"
#import "UIViewController+.h"

@class URLActionSetting;

@interface URLAction : NSObject

// TODO: MingLQ - <#task#>
// typedef void (^URLActionProccess)(URLAction *action, NSInteger depth);
typedef void (^URLActionCompletion)(/* BOOL success */);

#pragma mark - settings

+ (NSArray *)validSchemes;
+ (void)setValidSchemes:(NSArray *)validSchemes;

+ (NSDictionary *)actionSettings;
+ (void)setActionSettings:(NSDictionary *)actionSettings;

#pragma mark - perform action

/**
 *  @return URLAction if perform success
 */
+ (instancetype)performActionWithURL:(NSURL *)actionURL completion:(URLActionCompletion)completion;
+ (instancetype)performActionWithURLString:(NSString *)actionURLString completion:(URLActionCompletion)completion;

#pragma mark - parameters

@property(nonatomic, copy, readonly) NSURL *URL;
@property(nonatomic, copy, readonly) NSString *scheme;
@property(nonatomic, copy, readonly) NSString *key;
@property(nonatomic, copy, readonly) NSDictionary *parameters;
@property(nonatomic, copy, readonly) NSString *nextURLString;

@property(nonatomic, copy, readonly) URLActionSetting *setting;
@property(nonatomic, copy, readonly) URLActionCompletion completion;

@property(nonatomic, strong, readonly) URLAction *prevAction;
@property(nonatomic, copy, readonly) NSDictionary *prevActionResult;

@end

#pragma mark -

@interface URLActionSetting : NSObject <M9MakeCopy>

typedef void (^URLActionFinishBlock)(/* BOOL success, */NSDictionary *result);
typedef void (^URLActionBlock)(URLAction *action, URLActionFinishBlock finish);

#pragma mark - action setting with block

/**
 *  ignore class-target-action if has actionBlock
 *  
 *  call finish when completed
 *      if (finish) finish(<#result#>);
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
 *  selector of method with two parameters URLAction *action and URLActionFinishBlock finish
 *  e.g.
 *      + (void)performAction:(URLAction *)action finish:(URLActionFinishBlock)finish;
 *      - (void)performAction:(URLAction *)action finish:(URLActionFinishBlock)finish;
 *  
 *  call finish when completed
 *      if (finish) finish(<#result#>);
 */
@property(nonatomic, readonly) SEL actionSelector;
+ (instancetype)actionSettingWithTarget:(id)target actionSelector:(SEL)actionSelector;
+ (instancetype)actionSettingWithTarget:(id)target instanceSelector:(SEL)instanceSelector actionSelector:(SEL)actionSelector;

@end
