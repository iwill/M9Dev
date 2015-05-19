//
//  M9ScrollViewController.m
//  iPhoneVideo
//
//  Created by Ming LQ on 2012-06-12.
//  Copyright (c) 2012年 M9. All rights reserved.
//

#import "M9ScrollViewController.h"

@interface M9ScrollViewController ()

@property(nonatomic, readwrite, strong) UIScrollView *scrollView;

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

//* B: loadScrollView - self.view == self.scrollView.superview
- (void)loadScrollView {
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.delegate = self;
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    weakify(self);
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self);
        make.left.top.width.height.equalTo(self.view);
    }];
} //*/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadScrollView];
}

- (void)dealloc {
    self.scrollView.delegate = nil;
}

#pragma mark -

/*
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if ([scrollView.delegate respondsToSelector:@selector(scrollViewDidEndScrolling:)]) {
            [(id<M9ScrollViewDelegate>)scrollView.delegate scrollViewDidEndScrolling:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView.delegate respondsToSelector:@selector(scrollViewDidEndScrolling:)]) {
        [(id<M9ScrollViewDelegate>)scrollView.delegate scrollViewDidEndScrolling:scrollView];
    }
} */

@end

#pragma mark - UIScrollView+M9Category

@implementation UIScrollView (M9Category)

- (void)scrollToTopAnimated:(BOOL)animated {
    [self scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:animated];
}

@end
