//
//  UINavigationController+M9.m
//  M9Dev
//
//  Created by MingLQ on 2011-11-15.
//  Copyright (c) 2011 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import "UINavigationController+M9.h"

/**
 *  为 interactivePopGestureRecognizer-BUG 而生：解决自定义 NavBar、backBarButtonItem 导致的返回手势、动画相关的问题
 */
@interface UINavigationController_M9 : UINavigationController <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

/* !!!: 解决 interactivePopGestureRecognizer-BUG
 */
@property(nonatomic) BOOL isPushAnimating;

@end

#pragma mark -

@implementation UINavigationController_M9

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        /* !!!: 解决 interactivePopGestureRecognizer-BUG
         * 详见 - gestureRecognizerShouldBegin:
         */
        [super setDelegate:self];
    }
    return self;
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* !!!: 解决 interactivePopGestureRecognizer-BUG
     *  iOS7 如果 navigationBar 被隐藏或使用自定义返回按钮，滑动返回会失效，使用以下代码后滑动返回功能正常
     *  但这个办法会引入新的 BUG，详见 - gestureRecognizerShouldBegin:
     * !!!:
     *  init 时 self.interactivePopGestureRecognizer 为空
     */
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        __weak id <UIGestureRecognizerDelegate> wself = self;
        self.interactivePopGestureRecognizer.delegate = wself;
    }
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)resetPushAnimating {
    self.isPushAnimating = NO;
}

#pragma mark override

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (animated) {
        if (self.isPushAnimating) {
            return;
        }
        self.isPushAnimating = YES;
        [self performSelector:@selector(resetPushAnimating) withObject:nil afterDelay:0.5];
    }
    
    [super pushViewController:viewController animated:animated];
}

/*
 - (UIViewController *)popViewControllerAnimated:(BOOL)animated {
 return [super popViewControllerAnimated:animated];
 }
 
 - (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
 return [super popToViewController:viewController animated:animated];
 }
 
 - (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
 return [super popToRootViewControllerAnimated:animated];
 }
 
 - (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
 [super setViewControllers:viewControllers animated:animated];
 } // */

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    /* !!!: 解决 BUG
     *  动画过程中禁止交互，避免各种异常
     * !!!:
     *  present 一个 navigationController 时，navigationController 会调用 willShowViewController，但不会调 didShowViewController
     *  所以延时调用 endIgnoringInteractionEvents，而不是在 didShowViewController 中调用
     */
    if (animated && ![navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [[UIApplication sharedApplication] performSelector:@selector(endIgnoringInteractionEvents) withObject:nil afterDelay:0.5];
    }
}

#pragma mark UIGestureRecognizerDelegate

/* !!!: 解决 interactivePopGestureRecognizer-BUG
 *  原因：
 *      XXViewController 定制了返回按钮或隐藏了导航栏，导致从屏幕左侧的返回手势失效；
 *      清除默认 navigationController.interactivePopGestureRecognizer.delegate 可解决问题；
 *      @see http://stuartkhall.com/posts/ios-7-development-tips-tricks-hacks
 *  BUG：
 *      当 self.viewControllers 只有一个 rootViewController，此时从屏幕左侧滑入，然后快速点击控件 push 进新的 XXViewController；
 *      此时 rootViewController 页面不响应点击、拖动时间，再次从屏幕左侧滑入后显示新的 viewController，但点击返回按钮无响应、并可能发生崩溃；
 *  解决：
 *      navigationController.interactivePopGestureRecognizer.delegate 需实现此方法
 *          UIGestureRecognizerDelegate - gestureRecognizerShouldBegin:
 *      当 gestureRecognizer 是 navigationController.interactivePopGestureRecognizer、并且 [navigationController.viewControllers count] 小于等于 1 时返回 NO；
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if (gestureRecognizer == self.interactivePopGestureRecognizer) {
            return !self.isPushAnimating && [self.viewControllers count] > 1;
        }
    }
    
    return YES;
}

@end

#pragma mark -

@implementation UINavigationController (M9Category)

#pragma mark rootViewController

+ (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rootViewController {
    return [self navigationControllerWithRootViewController:rootViewController
                                         navigationBarClass:nil
                                               toolbarClass:nil];
}

+ (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rootViewController
                                                    navigationBarClass:(nullable Class)navigationBarClass
                                                          toolbarClass:(nullable Class)toolbarClass {
    UINavigationController *navigationController = [[UINavigationController_M9 alloc]
                                                    initWithNavigationBarClass:navigationBarClass ? : [UINavigationBar class]
                                                    toolbarClass:toolbarClass ? : [UIToolbar class]];
    [navigationController pushViewController:rootViewController animated:NO];
    return navigationController;
}

@dynamic rootViewController;
- (UIViewController *)rootViewController {
    return self.viewControllers.firstObject;
}

#pragma mark completion

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (completion) completion();
    }];
    [self pushViewController:viewController animated:animated];
    [CATransaction commit];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    // !!!: iOS7 BUG
    // @see http://jira.sohu-inc.com/browse/IPHONE-3756
    if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"7."]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([CATransaction animationDuration] + 0.01) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion) completion();
        });
        return [self popViewControllerAnimated:animated];
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (completion) completion();
    }];
    UIViewController *poppedViewController = [self popViewControllerAnimated:animated];
    [CATransaction commit];
    return poppedViewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (completion) completion();
    }];
    NSArray *poppedViewControllers = [self popToViewController:viewController animated:animated];
    [CATransaction commit];
    return poppedViewControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (completion) completion();
    }];
    NSArray *poppedViewControllers = [self popToRootViewControllerAnimated:animated];
    [CATransaction commit];
    return poppedViewControllers;
}

@end

#pragma mark -

@implementation UIViewController (UINavigationController)

- (UINavigationController *)wrapWithNavigationController {
    return [UINavigationController navigationControllerWithRootViewController:self];
}

@end
