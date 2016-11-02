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
    
    _scrollView = [UIScrollView new];
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    if (self.navigationController.interactivePopGestureRecognizer) {
        [_scrollView.panGestureRecognizer requireGestureRecognizerToFail:
         self.navigationController.interactivePopGestureRecognizer];
    }
    
    /**
     *  subview:
     *  make.left.right.equalTo(@[ self.view, self.scrollView ])
     *      .with.insets(UIEdgeInsetsMake(0, horMargin, 0, horMargin));
     *  make.top.bottom.equalTo(self.scrollView);
     */
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
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
