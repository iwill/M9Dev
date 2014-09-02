//
//  M9DevTestTableViewController.m
//  M9Dev
//
//  Created by MingLQ on 2014-08-22.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9DevTestTableViewController.h"

#import "NSArray+.h"

#import "VideosCollectionViewController.h"
#import "VideosTableViewController.h"
#import "JSLayoutViewController.h"
#import "M9NetworkingViewController.h"

@interface M9DevTestTableViewController ()

@end

@implementation M9DevTestTableViewController {
    NSArray *viewControllers;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.title = @"M9DevTest";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Class tableViewCellClass = [UITableViewCell class];
    [self.tableView registerClass:tableViewCellClass forCellReuseIdentifier:NSStringFromClass(tableViewCellClass)];
    
    viewControllers =  @[ [M9NetworkingViewController new],
                          [JSLayoutViewController new],
                          [VideosCollectionViewController new],
                          [VideosTableViewController new] ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    /* pop view controller by gesture recognizer
    if (self.clearsSelectionOnViewWillAppear) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    } */
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [viewControllers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    UIViewController *viewController = [viewControllers objectOrNilAtIndex:indexPath.row];
    cell.textLabel.text = viewController.navigationItem.title;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:[viewControllers objectOrNilAtIndex:indexPath.row] animated:YES];
}

@end
