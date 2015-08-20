//
//  UIScrollViewController.m
//  M9Dev
//
//  Created by MingLQ on 2014-08-22.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "UIScrollViewController.h"

@implementation UIAutoResizeScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    
    CGSize contentSize = self.contentSize;
    if (self.autoResizeWidth) {
        contentSize.width = MAX(contentSize.width, CGRectGetMaxX(view.frame) + self.marginRight);
    }
    if (self.autoResizeHeight) {
        contentSize.height = MAX(contentSize.height, CGRectGetMaxY(view.frame) + self.marginBottom);
    }
    self.contentSize = contentSize;
}

@end

#pragma mark -

@interface UIScrollViewController ()

@end

@implementation UIScrollViewController

- (void)loadView {
    UIAutoResizeScrollView *scrollView = [[UIAutoResizeScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    scrollView.scrollsToTop = YES;
    self.scrollView = scrollView;
    self.view = scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
