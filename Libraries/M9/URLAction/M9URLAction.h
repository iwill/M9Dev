//
//  M9URLAction.h
//  M9Dev
//
//  Created by MingLQ on 2015-06-12.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EXTScope+M9.h"
#import "M9Utilities.h"
#import "UIViewController+M9.h"

@class M9URLActionSetting;

@interface M9URLAction : NSObject

// TODO: MingLQ - <#task#>
// typedef void (^M9URLActionProccess)(M9URLAction *action, NSInteger depth);
typedef void (^M9URLActionCompletion)(/* BOOL success */);

#pragma mark - settings

+ (NSArray *)validSchemes;
+ (void)setValidSchemes:(NSArray *)validSchemes;

+ (NSDictionary *)actionSettings;
+ (void)setActionSettings:(NSDictionary *)actionSettings;

#pragma mark - perform action

/**
 *  @return M9URLAction if perform success
 */
+ (instancetype)performActionWithURL:(NSURL *)actionURL completion:(M9URLActionCompletion)completion;
+ (instancetype)performActionWithURLString:(NSString *)actionURLString completion:(M9URLActionCompletion)completion;

#pragma mark - parameters

@property(nonatomic, copy, readonly) NSURL *URL;
@property(nonatomic, copy, readonly) NSString *scheme;
@property(nonatomic, copy, readonly) NSString *key;
@property(nonatomic, copy, readonly) NSDictionary *parameters;
@property(nonatomic, copy, readonly) NSString *nextURLString;

@property(nonatomic, copy, readonly) M9URLActionSetting *setting;
@property(nonatomic, copy, readonly) M9URLActionCompletion completion;

@property(nonatomic, strong, readonly) M9URLAction *prevAction;
@property(nonatomic, copy, readonly) NSDictionary *prevActionResult;

@end

#pragma mark -

@interface M9URLActionSetting : NSObject <M9MakeCopy>

typedef void (^M9URLActionFinishBlock)(/* BOOL success, */NSDictionary *result);
typedef void (^M9URLActionBlock)(M9URLAction *action, M9URLActionFinishBlock finish);

#pragma mark - action setting with block

/**
 *  ignore class-target-action if has actionBlock
 *  
 *  call finish when completed
 *      if (finish) finish(<#result#>);
 */
@property(nonatomic, copy, readonly) M9URLActionBlock actionBlock;
+ (instancetype)actionSettingWithBlock:(M9URLActionBlock)actionBlock;

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
 *  selector of method with two parameters M9URLAction *action and M9URLActionFinishBlock finish
 *  e.g.
 *      + (void)performAction:(M9URLAction *)action finish:(M9URLActionFinishBlock)finish;
 *      - (void)performAction:(M9URLAction *)action finish:(M9URLActionFinishBlock)finish;
 *  
 *  call finish when completed
 *      if (finish) finish(<#result#>);
 */
@property(nonatomic, readonly) SEL actionSelector;
+ (instancetype)actionSettingWithTarget:(id)target actionSelector:(SEL)actionSelector;
+ (instancetype)actionSettingWithTarget:(id)target instanceSelector:(SEL)instanceSelector actionSelector:(SEL)actionSelector;

@end
