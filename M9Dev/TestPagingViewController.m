//
//  TestPagingViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-05-08.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import "TestPagingViewController.h"

@implementation TestPagingViewController

- (NSUInteger)numberOfPages {
    return 6;
}

- (UIViewController *)viewControllerOfPage:(NSUInteger)page {
    UIViewController *viewController  = [UIViewController new];
    viewController.view.backgroundColor = [UIColor colorWithWhite:(10.0 - page - 1) / 10 alpha:1.0];
    
    UILabel *label = [UILabel new];
    label.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    label.font = [UIFont boldSystemFontOfSize:32];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSStringFromValue(page + 1);
    [viewController.view addSubview:label];
    weakify(viewController);
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(viewController);
        make.edges.equalTo(viewController.view).with.insets(UIEdgeInsetsMake(2, 2, - 2, 2));
    }];
    return viewController;
}

@end
