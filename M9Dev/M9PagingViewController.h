//
//  M9PagingViewController.h
//  M9Dev
//
//  Created by MingLQ on 2015-05-07.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <UIKit/UIKit.h>

#import "M9Utilities.h"
#import "NSArray+M9.h"
#import "M9ScrollViewController.h"
#import "UIViewController+M9.h"

// TODO: UIPageViewController
// TODO: placeholderViewController
@interface M9PagingViewController : M9ScrollViewController

@property(nonatomic, readonly) NSInteger numberOfPages;
@property(nonatomic, readonly) NSInteger currentPage;

/**
 *  call when subclasses - viewDidLoad
 */
- (void)setupWithNumberOfPages:(NSInteger)numberOfPages;

- (UIViewController *)viewControllerOfPage:(NSInteger)page;
- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated;

#pragma mark - subclasses MUST override

/**
 *  automaticallyAdjustsScrollViewInsets of the generated viewControllers will be set to NO
 */
- (UIViewController *)generateViewControllerOfPage:(NSInteger)page;

#pragma mark - subclasses can override

/**
 *  default: UIEdgeInsetsMake(0, 0, 0, 0)
 */
- (UIEdgeInsets)viewInsetsOfPage:(NSInteger)page;
/**
 *  default: UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0)
 */
- (UIEdgeInsets)scrollViewInsets;

- (void)willScrollToPage:(NSInteger)page animated:(BOOL)animated;
- (void)didScrollToPage:(NSInteger)page animated:(BOOL)animated;
// TODO: scroll progress - 1, 1.1, 1.2 ..., 2

@end
