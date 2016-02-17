//
//  M9PagingViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-05-07.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "M9PagingViewController.h"

static const NSInteger PreloadViewControllers = 1;

@interface M9PagingViewController ()

@property(nonatomic, strong) NSMutableArray *viewControllers;

@end

@implementation M9PagingViewController {
    NSInteger _currentPage, _numberOfPages;
}

static void *KVOContext_M9PagingViewController = &KVOContext_M9PagingViewController;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.bounces = YES;
    self.scrollView.bouncesZoom = NO;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    [self.scrollView addObserver:self
                      forKeyPath:NSStringFromSelector(@selector(contentInset))
                         options:0
                         context:KVOContext_M9PagingViewController];
}

/* - (void)updateViewConstraints {
    [super updateViewConstraints];
} */

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scrollView.contentInset = [self scrollViewInsets];
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
    
    [self updateScrollViewContentSize];
    
    // !!!: iOS7 bug - self.scrollView.contentOffset is set to (0, 0)
    [self scrollToPage:self.currentPage animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    for (NSInteger i = 0; i < [self.viewControllers count]; i++) {
        if (i < self.currentPage - PreloadViewControllers
            || i > self.currentPage + PreloadViewControllers) {
            [self unloadChildViewControllerOfPage:i];
        }
    }
}

- (void)dealloc {
    [_scrollView removeObserver:self
                     forKeyPath:NSStringFromSelector(@selector(contentInset))
                        context:KVOContext_M9PagingViewController];
}

#pragma mark -

- (void)setupWithNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    
    for (UIViewController *viewController in self.viewControllers) {
        [[viewController as:[UIViewController class]] removeFromParentViewControllerAndSuperiew];
    }
    
    self.viewControllers = [NSMutableArray array];
    for (NSInteger index = 0; index < self.numberOfPages; index++) {
        [self.viewControllers addObject:[NSNull null]];
    }
    [self scrollToPage:self.currentPage animated:NO];
    
    /* [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded]; */
}

- (UIViewController *)viewControllerOfPage:(NSInteger)page {
    return [[self.viewControllers objectOrNilAtIndex:page] as:[UIViewController class]];
}

- (UIViewController *)generateViewControllerOfPage:(NSInteger)page {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (UIEdgeInsets)viewInsetsOfPage:(NSInteger)page {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (UIEdgeInsets)scrollViewInsets {
    return UIEdgeInsetsMake(self.topLayoutGuideLength, 0,
                            self.bottomLayoutGuideLength, 0);
}

- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated {
    NSInteger lastPage = self.currentPage;
    [self setCurrentPage:page animated:animated];
    if (self.currentPage != lastPage) {
        [self removeChildViewControllerOfPage:lastPage];
    }
    
    [self.scrollView scrollRectToVisible:({
        CGRect bounds = UIEdgeInsetsInsetRect(self.scrollView.bounds, self.scrollView.contentInset);
        bounds.origin.x = CGRectGetWidth(bounds) * page;
        bounds.origin.y = 0;
        _RETURN bounds;
    }) animated:NO/* !!!: always NO */];
}

- (void)willScrollToPage:(NSInteger)page animated:(BOOL)animated {
}

- (void)didScrollToPage:(NSInteger)page animated:(BOOL)animated {
}

#pragma mark - private

- (void)setCurrentPage:(NSInteger)page {
    [self setCurrentPage:page animated:NO];
}

- (void)setCurrentPage:(NSInteger)page animated:(BOOL)animated {
    if ((page == self.currentPage && [self viewControllerOfPage:page])
        || page >= self.numberOfPages) {
        return;
    }
    
    [self loadChildViewControllerOfPage:page];
    [self willScrollToPage:page animated:animated];
    _currentPage = page;
    [self addChildViewControllerOfPage:page];
    [self didScrollToPage:page animated:animated];
    
    /**
     *  @see http://stackoverflow.com/a/19711940/456536
     */
    [self setNeedsStatusBarAppearanceUpdate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NSInteger i = 1; i <= PreloadViewControllers; i++) {
            [self loadChildViewControllerOfPage:page + i];
            [self loadChildViewControllerOfPage:page - i];
        }
    });
}

- (void)loadChildViewControllerOfPage:(NSInteger)page {
    if (page < 0 || page >= self.numberOfPages) {
        return;
    }
    
    UIViewController *viewController = [self viewControllerOfPage:page];
    if (!viewController) {
        viewController = [self generateViewControllerOfPage:page];
        /* `if` for iOS6 */
        if ([viewController respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
            viewController.automaticallyAdjustsScrollViewInsets = NO;
        }
        if (!viewController) {
            return;
        }
        if (!viewController.isViewLoaded) {
            [viewController view];
        }
        [self.viewControllers replaceObjectAtIndex:page withObjectOrNil:viewController];
    }
}

- (void)addChildViewControllerOfPage:(NSInteger)page {
    UIViewController *viewController = [self viewControllerOfPage:page];
    if (viewController && viewController.view.superview != self.scrollView) {
        [self addChildViewController:viewController superview:self.scrollView];
        [self updateChildViewControllerOfPage:page];
    }
}

- (void)updateChildViewControllerOfPage:(NSInteger)page {
    UIViewController *viewController = [self viewControllerOfPage:page];
    if (viewController.view.superview != self.scrollView) {
        return;
    }
    
    // for calling from - viewDidLayoutSubviews
    UIEdgeInsets viewInset = [self viewInsetsOfPage:page];
    CGFloat left = CGRectGetWidth(self.scrollView.bounds) * page + viewInset.left;
    CGFloat top = viewInset.top;
    CGFloat width = CGRectGetWidth(self.scrollView.bounds) - viewInset.left - viewInset.right;
    CGFloat height = self.scrollView.contentSize.height - viewInset.top - viewInset.bottom;
    viewController.view.frame = CGRectMake(left, top, width, height);
    
    // for calling from - updateViewConstraints
    /* UIScrollView And Autolayout
     * @see Technical Note TN2154 - https://developer.apple.com/library/ios/technotes/tn2154/_index.html
     * @see http://adad184.com/2014/09/28/use-masonry-to-quick-solve-autolayout/#4-_[中级]_在UIScrollView顺序排列一些view并自动计算contentSize
     */
    /* [viewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets viewInset = [self viewInsetsOfPage:page];
        CGFloat left = CGRectGetWidth(self.scrollView.bounds) * page + viewInset.left;
        CGFloat top = viewInset.top;
        CGFloat width = CGRectGetWidth(self.scrollView.bounds) - viewInset.left - viewInset.right;
        CGFloat height = self.scrollView.contentSize.height - viewInset.top - viewInset.bottom;
        make.left.mas_equalTo(left);
        make.top.mas_equalTo(top);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }]; */
}

- (void)removeChildViewControllerOfPage:(NSInteger)page {
    UIViewController *viewController = [self viewControllerOfPage:page];
    [viewController removeFromParentViewControllerAndSuperiew];
}

- (void)unloadChildViewControllerOfPage:(NSInteger)page {
    UIViewController *viewController = [self viewControllerOfPage:page];
    if (viewController) {
        [viewController removeFromParentViewControllerAndSuperiew];
        [self.viewControllers replaceObjectAtIndex:page withObjectOrNil:[NSNull null]];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != KVOContext_M9PagingViewController) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if (object != self.scrollView) {
        return;
    }
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentInset))]) {
        [self updateScrollViewContentSize];
    }
}

- (void)updateScrollViewContentSize {
    self.scrollView.contentSize = ({
        CGSize size = UIEdgeInsetsInsetRect(self.view.bounds, self.scrollView.contentInset).size;
        size.width *= self.numberOfPages OR 1;
        _RETURN size;
    });
    
    [self.viewControllers enumerateObjectsUsingBlock:^(id object, NSUInteger page, BOOL *stop) {
        [self updateChildViewControllerOfPage:page];
    }];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([[_THIS_CLASS superclass] instancesRespondToSelector:_cmd]) {
        [super scrollViewWillBeginDragging:scrollView];
    }
    
    if (scrollView != self.scrollView) {
        return;
    }
    
    /* a. add +/- 2:
     *  for (NSInteger page = self.currentPage - 2;
     *       page <= self.currentPage + 2 && page < self.numberOfPages;
     *       page++)
     * b. add all:
     *  for (NSInteger page = 0; page < self.numberOfPages; page++)
     */
    for (NSInteger page = 0; page < self.numberOfPages; page++) {
        if (page != self.currentPage) {
            [self addChildViewControllerOfPage:page];
        }
    }
}

/* - (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([[_THIS_CLASS superclass] instancesRespondToSelector:_cmd]) {
        [super scrollViewWillBeginDecelerating:scrollView];
    }
    
    if (scrollView != self.scrollView) {
        return;
    }
    
    [self addChildViewControllerOfPage:self.currentPage - 1];
    [self addChildViewControllerOfPage:self.currentPage + 1];
} */

- (void)scrollViewDidEndScrolling:(UIScrollView *)scrollView {
    if ([[_THIS_CLASS superclass] instancesRespondToSelector:_cmd]) {
        [super scrollViewDidEndScrolling:scrollView];
    }
    
    if (scrollView != self.scrollView) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(scrollView.bounds);
    CGFloat position = self.scrollView.contentOffset.x;
    [self setCurrentPage:round(position / width) animated:YES];
    
    for (NSInteger page = 0; page < self.numberOfPages; page++) {
        if (page != self.currentPage) {
            [self removeChildViewControllerOfPage:page];
        }
    }
}

@end

#pragma mark -

/**
 *  @see http://stackoverflow.com/a/19711940/456536
 */

@interface M9PagingViewController (UIStatusBarStyle)

@end

@implementation M9PagingViewController (UIStatusBarStyle)

- (UIViewController *)childViewControllerForStatusBarStyle {
    return [self viewControllerOfPage:self.currentPage];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return [self viewControllerOfPage:self.currentPage];
}

@end
