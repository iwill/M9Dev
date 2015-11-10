//
//  M9ScrollViewController.m
//  M9Dev
//
//  Created by MingLQ on 2012-06-12.
//  Copyright (c) 2012 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "M9ScrollViewController.h"

@interface M9ScrollViewController ()

@property(nonatomic, strong, readwrite) UIScrollView *scrollView;

@end

#pragma mark -

@implementation M9ScrollViewController

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

@synthesize scrollView = _scrollView;
- (UIScrollView *)scrollView {
    if (![self isViewLoaded]) {
        [self view];
    }
    if (_scrollView) {
        return _scrollView;
    }
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.delegate = self;
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.height.equalTo(self.view);
    }];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    return _scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self scrollView];
}

- (void)dealloc {
    _scrollView.delegate = nil;
}

#pragma mark -

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if ([self respondsToSelector:@selector(scrollViewDidEndScrolling:)]) {
            [self scrollViewDidEndScrolling:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self respondsToSelector:@selector(scrollViewDidEndScrolling:)]) {
        [self scrollViewDidEndScrolling:scrollView];
    }
}

@end

#pragma mark - UIScrollView+M9Category

@implementation UIScrollView (M9Category)

- (void)scrollToTopAnimated:(BOOL)animated {
    [self scrollRectToVisible:CGRectMake(self.contentOffset.x, 0, 1, 1) animated:animated];
}

- (void)scrollToLeftAnimated:(BOOL)animated {
    [self scrollRectToVisible:CGRectMake(0, self.contentOffset.y, 1, 1) animated:animated];
}

- (void)scrollToLeftTopAnimated:(BOOL)animated {
    [self scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:animated];
}

@end
