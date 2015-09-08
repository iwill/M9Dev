//
//  M9DevTestTableViewController.m
//  M9Dev
//
//  Created by MingLQ on 2014-08-22.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "M9DevTestTableViewController.h"

#import "NSArray+M9.h"

#import "M9NetworkingViewController.h"
#import "JSLayoutViewController.h"
#import "VideosOCCollectionViewController.h"
#import "VideosJSCollectionViewController.h"
#import "TestPagingViewController.h"
#import "TestActionViewController.h"
#import "TestClosestAndAccessoryViewController.h"

#import "JRSwizzle.h"

// #if DEBUG
#import <FLEX/FLEXManager.h>
// #endif

/**
 * @see https://corecocoa.wordpress.com/2011/09/17/how-to-disable-floating-header-in-uitableview/
 */
/*
@interface UITableView (private)

@property(nonatomic, readonly) BOOL allowsHeaderViewsToFloat, allowsFooterViewsToFloat;

@end

@implementation UITableView (private)

@dynamic allowsHeaderViewsToFloat, allowsFooterViewsToFloat;

+ (void)load {
    [self jr_swizzleMethod:@selector(allowsHeaderViewsToFloat) withMethod:@selector(jr_swizzle_allowsHeaderViewsToFloat) error:nil];
    [self jr_swizzleMethod:@selector(allowsFooterViewsToFloat) withMethod:@selector(jr_swizzle_allowsFooterViewsToFloat) error:nil];
}

- (BOOL)jr_swizzle_allowsHeaderViewsToFloat {
    return NO;
}

- (BOOL)jr_swizzle_allowsFooterViewsToFloat {
    return NO;
}

@end //*/

@interface M9DevTestTableViewController ()

@end

@implementation M9DevTestTableViewController {
    NSArray *viewControllers;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.title = @"M9DevTest";
        
        self.clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Class tableViewCellClass = [UITableViewCell class];
    [self.tableView registerClass:tableViewCellClass forCellReuseIdentifier:NSStringFromClass(tableViewCellClass)];
    self.tableView.rowHeight = 50;
    
    viewControllers = @[ [TestClosestAndAccessoryViewController new],
                         [TestActionViewController new],
                         ({
                             UIViewController *vc = [TestPagingViewController new];
                             vc.navigationItem.title = @"PagingViewController";
                             _RETURN vc;
                         }),
                         [M9NetworkingViewController new],
                         [JSLayoutViewController new],
                         [VideosOCCollectionViewController new],
                         [VideosJSCollectionViewController new],
                         [FLEXManager sharedManager] ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
    UIViewController *viewController = [[viewControllers objectOrNilAtIndex:indexPath.row] as:[UIViewController class]];
    cell.textLabel.text = viewController ? viewController.navigationItem.title : @"FLEX";
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = [[viewControllers objectOrNilAtIndex:indexPath.row] as:[UIViewController class]];
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        // #if DEBUG
        FLEXManager *flex = [FLEXManager sharedManager];
        if (flex.isHidden) {
            [flex showExplorer];
        }
        else {
            [flex hideExplorer];
        }
        // #endif
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
