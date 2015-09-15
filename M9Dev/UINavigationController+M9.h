//
//  UINavigationController+M9.h
//  M9Dev
//
//  Created by MingLQ on 2011-11-15.
//  Copyright (c) 2011 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (M9Category)

@property(nonatomic, strong, readonly) UIViewController *rootViewController;

// !!!: the delegate and interactivePopGestureRecognizer.delegate of the returned navigationController is itself
+ (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rootViewController;

// push&pop completion
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;

// for @selector(popViewController<#Animated#>/<#NonAnimated#>)
- (UIViewController *)popViewControllerAnimated;
- (UIViewController *)popViewControllerNonAnimated;

@end

#pragma mark -

@interface UIViewController (UINavigationController)

// !!!: @see - [UINavigationController navigationControllerWithRootViewController:self];
- (UINavigationController *)wrapWithNavigationController;

- (UIViewController *)popFromNavigationControllerAnimated;
- (UIViewController *)popFromNavigationControllerNonAnimated;

@end

