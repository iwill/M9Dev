//
//  UIViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-05-08.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "UIViewController+M9.h"

#import "UINavigationController+M9.h"

@implementation UIViewController (M9Category)

#pragma mark - layout

- (CGFloat)topLayoutGuideLength {
    return [self respondsToSelector:@selector(topLayoutGuide)] ? self.topLayoutGuide.length : 0;
}

- (CGFloat)bottomLayoutGuideLength {
    return [self respondsToSelector:@selector(bottomLayoutGuide)] ? self.bottomLayoutGuide.length : 0;
}

#pragma mark - child view controller management

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

#pragma mark - view controllers navigation

- (UIViewController *)popViewControllerAnimated {
    return [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissViewControllerAnimated {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissAllViewControllersAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (!self.presentedViewController) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion) completion();
        });
        return;
    }
    
    [self dismissViewControllerAnimated:animated completion:^{
        [self dismissAllViewControllersAnimated:NO completion:completion];
    }];
}

+ (UIViewController *)gotoRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UITabBarController *tabBarController = [rootViewController as:[UITabBarController class]];
    [rootViewController dismissAllViewControllersAnimated:animated completion:^{
        UINavigationController *navigationController = [tabBarController.selectedViewController OR rootViewController as:[UINavigationController class]];
        if (navigationController) {
            [navigationController popToRootViewControllerAnimated:animated completion:completion];
        }
        else {
            if (completion) completion();
        }
    }];
    return rootViewController;
}

+ (UIViewController *)topViewController {
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UITabBarController *tabBarController = [topViewController as:[UITabBarController class]];
    if (tabBarController.selectedViewController) {
        topViewController = tabBarController.selectedViewController;
    }
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    UINavigationController *navigationController = [topViewController as:[UINavigationController class]];
    if ([navigationController.viewControllers count]) {
        topViewController = navigationController.viewControllers.lastObject;
    }
    return topViewController;
}

+ (UIViewController *)rootViewController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

@end
