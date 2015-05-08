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

@interface M9PagingViewController : M9ScrollViewController

@property(nonatomic, readonly) NSUInteger numberOfPages;
@property(nonatomic, readwrite) NSUInteger currentPage;

// subclasses MUST override
- (UIViewController *)viewControllerOfPage:(NSUInteger)page;

@end
