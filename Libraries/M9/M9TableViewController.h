//
//  M9TableViewController.h
//  M9Dev
//
//  Created by MingLQ on 2015-05-12.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import "M9ScrollViewController.h"

@interface M9TableViewController : M9ScrollViewController

// dataSource & delegate is nil by default
@property(nonatomic, readonly, retain) UITableView *tableView;

@end
