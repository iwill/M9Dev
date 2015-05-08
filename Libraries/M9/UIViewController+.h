//
//  UIViewController+.h
//  M9Dev
//
//  Created by MingLQ on 2015-05-08.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (M9Category)

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
