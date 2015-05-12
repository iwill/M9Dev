//
//  M9TableViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-05-12.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import "M9TableViewController.h"

@interface M9TableViewController ()

@property(nonatomic, readwrite, retain) UITableView *tableView;

@end

@implementation M9TableViewController

@dynamic scrollView;

- (UIScrollView *)scrollView {
    return self.tableView;
}

- (void)loadScrollView {
    UITableView *tableView = [UITableView new];
    // tableView.delegate = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    weakify(self);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self);
        make.left.top.width.height.equalTo(self.view);
    }];
}

- (void)dealloc {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

@end
