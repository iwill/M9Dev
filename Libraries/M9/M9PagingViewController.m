//
//  M9PagingViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-05-07.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import "M9PagingViewController.h"

#define PreloadViewControllers 1

@interface M9PagingViewController ()

@property(nonatomic, readwrite) NSUInteger numberOfPages;
@property(nonatomic, readwrite) NSUInteger currentPage;

@property(nonatomic, strong) NSMutableArray *viewControllers;

@end

@implementation M9PagingViewController

@synthesize numberOfPages = _numberOfPages;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    [self.scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentInset)) options:0 context:NULL];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self updateScrollViewContentSize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    for (NSInteger i = 0; i < [self.viewControllers count]; i++) {
        if (i >= self.currentPage - PreloadViewControllers
            && i <= self.currentPage + PreloadViewControllers) {
            continue;
        }
        [self unloadChildViewControllerOfPage:i];
    }
}

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentInset)) context:NULL];
}

#pragma mark -

- (NSUInteger)numberOfPages {
    return 1;
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    
    [self updateScrollViewContentSize];
    
    for (UIViewController *viewController in self.viewControllers) {
        [[viewController as:[UIViewController class]] removeFromParentViewControllerAndSuperiew];
    }
    
    self.viewControllers = [NSMutableArray array];
    for (NSUInteger index = 0; index < numberOfPages; index++) {
        [self.viewControllers addObject:[NSNull null]];
    }
}

- (void)refreshPages {
    self.numberOfPages = self.numberOfPages;
    [self scrollToPage:self.currentPage animated:YES];
}

- (void)scrollToPage:(NSUInteger)page animated:(BOOL)animated {
    NSUInteger lastPage = self.currentPage;
    self.currentPage = page;
    if (page != lastPage) {
        [self removeChildViewControllerOfPage:lastPage];
    }
    
    [self.scrollView scrollRectToVisible:({
        CGRect bounds = UIEdgeInsetsInsetRect(self.scrollView.bounds, self.scrollView.contentInset);
        bounds.origin.x = CGRectGetWidth(bounds) * page;
        bounds.origin.y = 0;
        _RETURN bounds;
    }) animated:animated];
}

- (void)setCurrentPage:(NSUInteger)page {
    if ((page == self.currentPage && [self viewControllerOfPage:page])
        || page >= self.numberOfPages) {
        return;
    }
    
    [self willScrollToPage:page];
    
    _currentPage = page;
    
    [self loadChildViewControllerOfPage:page];
    [self addChildViewControllerOfPage:page];
    
    for (NSInteger i = 1; i <= PreloadViewControllers; i++) {
        [self loadChildViewControllerOfPage:page + i];
        [self loadChildViewControllerOfPage:page - i];
    }
    
    [self didScrollToPage:page];
}

- (void)willScrollToPage:(NSUInteger)page {
}

- (void)didScrollToPage:(NSUInteger)page {
}

- (UIViewController *)generateViewControllerOfPage:(NSUInteger)page {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (UIViewController *)viewControllerOfPage:(NSUInteger)page {
    return [[self.viewControllers objectOrNilAtIndex:page] as:[UIViewController class]];
}

- (void)loadChildViewControllerOfPage:(NSUInteger)page {
    if (page >= self.numberOfPages) {
        return;
    }
    
    UIViewController *viewController = [self viewControllerOfPage:page];
    if (!viewController) {
        viewController = [self generateViewControllerOfPage:page];
        if (!viewController) {
            return;
        }
        if (!viewController.isViewLoaded) {
            [viewController view];
        }
        [self.viewControllers replaceObjectAtIndex:page withObjectOrNil:viewController];
    }
}

- (void)addChildViewControllerOfPage:(NSUInteger)page {
    UIViewController *viewController = [self viewControllerOfPage:page];
    if (viewController && viewController.view.superview != self.scrollView) {
        [self addChildViewController:viewController superview:self.scrollView];
        
        // UIScrollView And Autolayout
        // @see Technical Note TN2154 - https://developer.apple.com/library/ios/technotes/tn2154/_index.html
        // @see http://adad184.com/2014/09/28/use-masonry-to-quick-solve-autolayout/#4-_[中级]_在UIScrollView顺序排列一些view并自动计算contentSize
        weakify(self);
        [viewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            strongify(self);
            make.left.mas_equalTo(CGRectGetWidth(self.view.bounds) * page);
            make.width.width.equalTo(self.scrollView);
            make.top.equalTo(self.scrollView);
            CGFloat offset = self.scrollView.contentInset.top + self.scrollView.contentInset.bottom;
            make.height.equalTo(self.scrollView).with.offset(- offset);
        }];
    }
}

- (void)removeChildViewControllerOfPage:(NSUInteger)page {
    UIViewController *viewController = [self viewControllerOfPage:page];
    [viewController removeFromParentViewControllerAndSuperiew];
}

- (void)unloadChildViewControllerOfPage:(NSUInteger)page {
    UIViewController *viewController = [self viewControllerOfPage:page];
    if (viewController) {
        [viewController removeFromParentViewControllerAndSuperiew];
        [self.viewControllers replaceObjectAtIndex:page withObjectOrNil:[NSNull null]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self updateScrollViewContentSize];
    
    if (object == self.scrollView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentInset))]) {
        for (UIViewController *viewController in self.viewControllers) {
            if (![viewController isKindOfClass:[UIViewController class]]
                || viewController.view.superview != self.scrollView) {
                continue;
            }
            [viewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
                CGFloat offset = self.scrollView.contentInset.top + self.scrollView.contentInset.bottom;
                make.height.equalTo(self.scrollView).with.offset(- offset);
            }];
        }
    }
}

- (void)updateScrollViewContentSize {
    self.scrollView.contentSize = ({
        CGSize size = UIEdgeInsetsInsetRect(self.scrollView.bounds, self.scrollView.contentInset).size;
        size.width *= self.numberOfPages OR 1;
        _RETURN size;
    });
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView != self.scrollView) {
        return;
    }
    
    [self addChildViewControllerOfPage:self.currentPage - 1];
    [self addChildViewControllerOfPage:self.currentPage + 1];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.scrollView) {
        return;
    }
    
    [self addChildViewControllerOfPage:self.currentPage - 1];
    [self addChildViewControllerOfPage:self.currentPage + 1];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView != self.scrollView) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(scrollView.bounds);
    CGFloat position = self.scrollView.contentOffset.x;
    self.currentPage = round(position / width);
    
    if (!decelerate) {
        for (NSUInteger i = 0; i < self.numberOfPages; i++) {
            if (i != self.currentPage) {
                [self removeChildViewControllerOfPage:i];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.scrollView) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(scrollView.bounds);
    CGFloat position = self.scrollView.contentOffset.x;
    self.currentPage = round(position / width);
    
    for (NSUInteger i = 0; i < self.numberOfPages; i++) {
        if (i != self.currentPage) {
            [self removeChildViewControllerOfPage:i];
        }
    }
}

@end
