//
//  M9TableViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-05-12.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "M9TableViewController.h"

@interface M9TableViewController ()

@property(nonatomic, readwrite) UITableViewStyle style;
@property(nonatomic, strong, readwrite) UITableView *tableView;

@end

@implementation M9TableViewController

- (instancetype)init {
    return [self initWithStyle:UITableViewStylePlain];
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super init];
    if (self) {
        self.style = style;
    }
    return self;
}

@dynamic scrollView;
- (UIScrollView *)scrollView {
    return self.tableView;
}

@synthesize tableView = _tableView;
- (UITableView *)tableView {
    if (![self isViewLoaded]) {
        [self view];
    }
    if (_tableView) {
        return _tableView;
    }
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    // tableView.delegate = self;
    // tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    weakify(self);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self);
        make.left.top.width.height.equalTo(self.view);
    }];
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tableView];
}

- (void)dealloc {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

@end
