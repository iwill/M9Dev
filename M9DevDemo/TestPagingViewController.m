//
//  TestPagingViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-05-08.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "TestPagingViewController.h"

#import "EXTScope.h"

@interface TestPagingViewController ()

// @optional
@property(nonatomic, strong) NSMutableDictionary *viewControllersPool;

@end

@implementation TestPagingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.viewControllersPool = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupWithNumberOfPages:6];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.viewControllersPool removeAllObjects];
}

#pragma mark - M9PagingViewController

- (UIViewController *)generateViewControllerOfPage:(NSInteger)page {
    UIViewController *viewController = [self.viewControllersPool objectForKey:@(page)];
    if (viewController) {
        return viewController;
    }
    
    viewController = [UIViewController new];
    {
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
        
        viewController.view.backgroundColor = [UIColor colorWithWhite:(10.0 - page - 1) / 10 alpha:1.0];
    }
    
    [self.viewControllersPool setObject:viewController forKey:@(page)];
    return viewController;
}

- (UIEdgeInsets)viewInsetOfPage:(NSInteger)page {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

@end
