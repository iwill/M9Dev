//
//  M9ScrollViewController.h
//  iPhoneVideo
//
//  Created by Ming LQ on 2012-06-12.
//  Copyright (c) 2012年 M9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

#import "EXTScope+M9.h"
#import "M9Utilities.h"

/*
@protocol M9ScrollViewDelegate <UITableViewDelegate>
@optional
- (void)scrollViewWillBeginScrolling:(UIScrollView *)scrollView;
- (void)scrollViewDidEndScrolling:(UIScrollView *)scrollView;
@end */

@interface M9ScrollViewController : UIViewController <UIScrollViewDelegate>

@property(nonatomic, readonly, strong) UIScrollView *scrollView;

// !!!: @protected
/**
 *  Creates the scrollView and add to the view controller's view.
 *
 *  The view controller calls this method in - viewDidLoad.
 *
 *  You should never call this method directly.
 *  You can override this method in order to create your scrollView.
 *  Your custom implementation of this method should not call super.
 */
- (void)loadScrollView;

@end

#pragma mark - UIScrollView+M9Category

@interface UIScrollView (M9Category)

- (void)scrollToTopAnimated:(BOOL)animated;

@end
