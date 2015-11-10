//
//  M9TableViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-05-12.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
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
    self = [super initWithNibName:nil bundle:nil];
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
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.height.equalTo(self.view);
    }];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.clearsSelectionOnViewWillAppear) {
        NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
        for (NSIndexPath *indexPath in indexPaths) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
        }
    }
}

- (void)dealloc {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

@end
