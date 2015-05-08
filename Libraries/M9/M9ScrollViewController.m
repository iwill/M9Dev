//
//  M9ScrollViewController.m
//  iPhoneVideo
//
//  Created by Ming LQ on 2012-06-12.
//  Copyright (c) 2012年 M9. All rights reserved.
//

#import "M9ScrollViewController.h"

@interface M9ScrollViewController ()

@property (nonatomic, readwrite, retain) UIScrollView *scrollView;

@end

#pragma mark -

@implementation M9ScrollViewController

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

/* A: loadView - self.view == self.scrollView
- (void)loadView {
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.delegate = self;
    self.scrollView = scrollView;
    
    self.view = scrollView;
} //*/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    weakify(self);
    
    //* B: addSubview: - [self.view addSubview:scrollView]
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.delegate = self;
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self);
        make.left.top.width.height.equalTo(self.view);
    }]; //*/
}

- (void)dealloc {
}

@end
