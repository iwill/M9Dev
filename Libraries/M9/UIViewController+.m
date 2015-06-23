//
//  UIViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-05-08.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import "UIViewController+.h"

@implementation UIViewController (M9Category)

+ (UIViewController *)gotoRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UITabBarController *tabController = [rootViewController as:[UITabBarController class]];
    UINavigationController *nav = [tabController.selectedViewController OR rootViewController as:[UINavigationController class]];
    [nav popToRootViewControllerAnimated:animated];
    [rootViewController dismissAllViewControllersAnimated:animated completion:completion];
    return rootViewController;
}

- (void)dismissAllViewControllersAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (!self.presentedViewController) {
        if (completion) completion();
        return;
    }
    
    [self dismissViewControllerAnimated:animated completion:^{
        [self dismissAllViewControllersAnimated:NO completion:completion];
    }];
}

- (void)addChildViewController:(UIViewController *)childViewController superview:(UIView *)superview {
    /* The addChildViewController: method automatically calls the willMoveToParentViewController: method
     * of the view controller to be added as a child before adding it.
     */
    [self addChildViewController:childViewController]; // 1
    [superview addSubview:childViewController.view]; // 2
    [childViewController didMoveToParentViewController:self]; // 3
}

- (void)removeFromParentViewControllerAndSuperiew {
    [self willMoveToParentViewController:nil]; // 1
    /* The removeFromParentViewController method automatically calls the didMoveToParentViewController: method
     * of the child view controller after it removes the child.
     */
    [self.view removeFromSuperview]; // 2
    [self removeFromParentViewController]; // 3
}

- (void)transitionFromChildViewController:(UIViewController *)fromViewController
                    toChildViewController:(UIViewController *)toViewController
                                 duration:(NSTimeInterval)duration
                                  options:(UIViewAnimationOptions)options
                               animations:(void (^)(void))animations
                               completion:(void (^)(BOOL))completion {
    // 1
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    // 2
    /* This method automatically adds the new view, performs the animation, and then removes the old view.
     */
    [self transitionFromViewController:fromViewController
                      toViewController:toViewController
                              duration:duration
                               options:options
                            animations:animations
                            completion:^(BOOL finished) {
                                // 3
                                [fromViewController removeFromParentViewController];
                                [toViewController didMoveToParentViewController:self];
                                // end
                                if (completion) completion(finished);
                            }];
}

@end
