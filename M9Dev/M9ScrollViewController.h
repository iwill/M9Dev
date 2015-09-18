//
//  M9ScrollViewController.h
//  M9Dev
//
//  Created by MingLQ on 2012-06-12.
//  Copyright (c) 2012 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

#import "EXTScope.h"
#import "M9Utilities.h"

@protocol M9ScrollViewDelegate <UITableViewDelegate>
@optional
// - (void)scrollViewWillBeginScrolling:(UIScrollView *)scrollView;
- (void)scrollViewDidEndScrolling:(UIScrollView *)scrollView;
@end

@interface M9ScrollViewController : UIViewController <UIScrollViewDelegate, M9ScrollViewDelegate> {
@protected
    UIScrollView *_scrollView;
}

@property(nonatomic, strong, readonly) UIScrollView *scrollView;

@end

#pragma mark - UIScrollView+M9Category

@interface UIScrollView (M9Category)

- (void)scrollToTopAnimated:(BOOL)animated;

@end

/**
 *  NOTE:
 *  // @see http://stackoverflow.com/a/31961867/456536
 *  - (BOOL)touchesShouldCancelInContentView:(UIView *)view {
 *      return YES;
 *  }
 */
