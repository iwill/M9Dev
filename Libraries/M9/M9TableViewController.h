//
//  M9TableViewController.h
//  M9Dev
//
//  Created by MingLQ on 2015-05-12.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "M9ScrollViewController.h"

@interface M9TableViewController : M9ScrollViewController

// UITableViewStylePlain by default
@property(nonatomic, readonly) UITableViewStyle style;
// !!!: dataSource & delegate are nil by default
@property(nonatomic, readonly, retain) UITableView *tableView;

- (instancetype)initWithStyle:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER;

@end
