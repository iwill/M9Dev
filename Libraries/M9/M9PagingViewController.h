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

// TODO: UIPageViewController
// TODO: placeholderViewController
@interface M9PagingViewController : M9ScrollViewController

@property(nonatomic, readonly) NSInteger numberOfPages;
@property(nonatomic, readonly) NSInteger currentPage;

/**
 *  call setupWithNumberOfPages: when viewDidLoad
 */
- (void)setupWithNumberOfPages:(NSInteger)numberOfPages;
- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated;

// TODO: scroll progress - 1, 1.1, 1.2 ..., 2
- (void)willScrollToPage:(NSInteger)page animated:(BOOL)animated;
- (void)didScrollToPage:(NSInteger)page animated:(BOOL)animated;

- (UIViewController *)viewControllerOfPage:(NSInteger)page;
// subclasses MUST override
- (UIViewController *)generateViewControllerOfPage:(NSInteger)page;

@end
