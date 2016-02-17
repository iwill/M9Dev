//
//  UINavigationController+M9.h
//  M9Dev
//
//  Created by MingLQ on 2011-11-15.
//  Copyright (c) 2011 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (M9Category)

@property(nonatomic, strong, readonly, nullable) UIViewController *rootViewController;

// !!!: the delegate and interactivePopGestureRecognizer.delegate of the returned navigationController is itself
+ (UINavigationController *)navigationControllerWithRootViewController:(nullable UIViewController *)rootViewController;
+ (UINavigationController *)navigationControllerWithRootViewController:(nullable UIViewController *)rootViewController
                                                    navigationBarClass:(nullable Class)navigationBarClass
                                                          toolbarClass:(nullable Class)toolbarClass;

// push&pop completion
- (void)pushViewController:(nullable UIViewController *)viewController
                  animated:(BOOL)animated
                completion:(void (^ __nullable)(void))completion;

- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated
                                              completion:(void (^ __nullable)(void))completion;
- (nullable NSArray *)popToViewController:(UIViewController *)viewController
                                 animated:(BOOL)animated
                               completion:(void (^ __nullable)(void))completion;
- (nullable NSArray *)popToRootViewControllerAnimated:(BOOL)animated
                                           completion:(void (^ __nullable)(void))completion;

@end

#pragma mark -

@interface UIViewController (UINavigationController)

// !!!: @see - [UINavigationController navigationControllerWithRootViewController:self];
- (UINavigationController *)wrapWithNavigationController;

@end

NS_ASSUME_NONNULL_END
