//
//  M9TableViewController.h
//  M9Dev
//
//  Created by MingLQ on 2015-05-12.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "M9ScrollViewController.h"

@interface M9TableViewController : M9ScrollViewController {
@protected
    UITableView *_tableView;
}

// UITableViewStylePlain by default
@property(nonatomic, readonly) UITableViewStyle style;
// !!!: dataSource & delegate are nil by default
@property(nonatomic, strong, readonly) UITableView *tableView;
@property(nonatomic) BOOL clearsSelectionOnViewWillAppear;

- (instancetype)init; // UITableViewStyleGrouped
- (instancetype)initWithStyle:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end
