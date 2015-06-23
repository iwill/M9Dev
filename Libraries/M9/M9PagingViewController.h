//
//  M9PagingViewController.h
//  M9Dev
//
//  Created by MingLQ on 2015-05-07.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "M9Utilities.h"
#import "NSArray+.h"
#import "M9ScrollViewController.h"
#import "UIViewController+.h"

// TODO: MingLQ - UIPageViewController
@interface M9PagingViewController : M9ScrollViewController

@property(nonatomic, readonly) NSUInteger numberOfPages;
@property(nonatomic, readonly) NSUInteger currentPage;

/**
 *  call refreshPages or scrollToPage:animated: in viewDidLoad
 */
- (void)refreshPages;
- (void)scrollToPage:(NSUInteger)page animated:(BOOL)animated;

// TODO: scroll progress - 1, 1.1, 1.2 ..., 2
- (void)willScrollToPage:(NSUInteger)page;
- (void)didScrollToPage:(NSUInteger)page;

- (UIViewController *)viewControllerOfPage:(NSUInteger)page;
// subclasses MUST override
- (UIViewController *)generateViewControllerOfPage:(NSUInteger)page;

@end
