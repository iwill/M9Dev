//
//  TestClosestAndAccessoryViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-09-08.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "TestClosestAndAccessoryViewController.h"

#import "UIView+M9.h"
#import "UIControl+M9EventCallback.h"
#import "UITableViewCell+M9AccessoryButton.h"

@implementation TestClosestAndAccessoryViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.title = @"ClosestAndAccessory";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    UIButton *testClosestButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    [testClosestButton setTitle:@"testClosest" forState:UIControlStateNormal];
    [testClosestButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [testClosestButton addEventCallback:^(UIButton *button) {
        NSLog(@"nil: %@", [button closestResponderOfClass:[NSObject class]]);
        
        NSLog(@"nil: %@", [button closestResponderOfClass:[UIButton class]]);
        NSLog(@"UIButton: %@", [button closestResponderOfClass:[UIButton class] includeSelf:YES]);
        NSLog(@"UIScrollView: %@", [button closestResponderOfClass:[UIScrollView class]]);
        NSLog(@"UIViewController: %@", [button closestResponderOfClass:[UIViewController class]]);
        NSLog(@"UIWindow: %@", [button closestResponderOfClass:[UIWindow class]]);
        NSLog(@"UIApplication: %@", [button closestResponderOfClass:[UIApplication class]]);
        
        NSLog(@"nil: %@", [button closestViewOfClass:[UIButton class]]);
        NSLog(@"UIButton: %@", [button closestViewOfClass:[UIButton class] includeSelf:YES]);
        NSLog(@"UIScrollView: %@", [button closestViewOfClass:[UIScrollView class]]);
        NSLog(@"nil: %@", [button closestViewOfClass:[UIViewController class]]);
        NSLog(@"nil: %@", [button closestViewOfClass:[UIWindow class]]);
        NSLog(@"nil: %@", [button closestViewOfClass:[UIApplication class]]);
        
        NSLog(@"UIViewController: %@", [button closestViewController]);
    } forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = testClosestButton;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%lu-%lu", indexPath.section, indexPath.row];
    // this should be set in cell
    cell.accessoryButton = ({
        UIButton *button = [UIButton new];
        [button setTitle:@"accessory >" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        [button sizeToFit]
        _RETURN button;
    });
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@ - %@", NSStringFromSelector(_cmd),  indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@ - %@", NSStringFromSelector(_cmd),  indexPath);
}

@end
