//
//  UIViewController+.h
//  M9Dev
//
//  Created by MingLQ on 2015-05-08.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "M9Utilities.h"

@interface UIViewController (M9Category)

+ (UIViewController *)rootViewController;
+ (UIViewController *)topViewController;

/**
 *  __block UIViewController *rootViewController = [UIViewController gotoRootViewControllerAnimated:YES/NO completion:^{
 *      [rootViewController presentViewController:viewController animated:YES/NO completion:nil];
 *  }];
 */
+ (UIViewController *)gotoRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissAllViewControllersAnimated:(BOOL)animated completion:(void (^)(void))completion;

/**
 *  Adding and Removing a Child
 *  @see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/1048/featuredarticles/ViewControllerPGforiPhoneOS/CreatingCustomContainerViewControllers/CreatingCustomContainerViewControllers.html
 */
- (void)addChildViewController:(UIViewController *)childController superview:(UIView *)superview;
- (void)removeFromParentViewControllerAndSuperiew;
- (void)transitionFromChildViewController:(UIViewController *)fromViewController
                    toChildViewController:(UIViewController *)toViewController
                                 duration:(NSTimeInterval)duration
                                  options:(UIViewAnimationOptions)options
                               animations:(void (^)(void))animations
                               completion:(void (^)(BOOL))completion;

@end
