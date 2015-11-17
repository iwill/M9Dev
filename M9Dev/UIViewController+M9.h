//
//  UIViewController+M9.h
//  M9Dev
//
//  Created by MingLQ on 2015-05-08.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <UIKit/UIKit.h>

#import "M9Utilities.h"

@interface UIViewController (M9Category)

#pragma mark - layout

// TODO: for iOS6
@property(nonatomic, readonly) CGFloat topLayoutGuideLength, bottomLayoutGuideLength;

#pragma mark - child view controller management

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

#pragma mark - view controllers navigation

// for @selector(popViewControllerAnimated)
- (UIViewController *)popViewControllerAnimated;

// for @selector(dismissViewControllerAnimated)
- (void)dismissViewControllerAnimated;

/**
 *  __block UIViewController *rootViewController = [UIViewController gotoRootViewControllerAnimated:YES/NO completion:^{
 *      [rootViewController presentViewController:viewController animated:YES/NO completion:nil];
 *  }];
 */
- (void)dismissAllViewControllersAnimated:(BOOL)animated completion:(void (^)(void))completion;

+ (UIViewController *)gotoRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;

+ (UIViewController *)topViewController;
+ (UIViewController *)rootViewController;

@end
