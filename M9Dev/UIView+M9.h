//
//  UIView+M9.h
//  M9Dev
//
//  Created by MingLQ on 2011-10-11.
//  Copyright (c) 2011 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <UIKit/UIKit.h>

#import "UIResponder+M9.h"
#import "UIView+alignmentRectInsets.h"

static inline UIEdgeInsets CGRectDiff(CGRect fromRect, CGRect toRect) {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top  = - CGRectGetMinY(fromRect) + CGRectGetMinY(toRect);
    insets.left = - CGRectGetMinX(fromRect) + CGRectGetMinX(toRect);
    insets.bottom = CGRectGetHeight(fromRect) - CGRectGetHeight(toRect) - insets.top;
    insets.right  = CGRectGetWidth(fromRect)  - CGRectGetWidth(toRect)  - insets.left;
    return insets;
}

#pragma mark -

@interface UIView (Hierarchy)

@property (nonatomic, readwrite, assign) UIView *firstResponder;

@end

#pragma mark -

typedef void (^UIViewUpdateConstraintsBlock)();
typedef void (^UIViewLayoutSubviewsBlock)();

/**
 *  Only used for views which you donot want to subclass.
 *
 *  e.g.:
 *      UIButton *button = [UIButton new];
 *      // config
 *      button.updateConstraintsBlock = ^{
 *          // update constraints
 *      };
 *
 *  override:
 *      UIViewUpdateConstraintsBlock originalBlock = aView.updateConstraintsBlock;
 *      aView.updateConstraintsBlock = ^{
 *          if (originalBlock) {
 *              originalBlock();
 *          }
 *          // update constraints
 *      };
 */
@interface UIView (updateConstraints_layoutSubviews)

@property (nonatomic, copy) UIViewUpdateConstraintsBlock updateConstraintsBlock;
// re-declare for code completions
- (UIViewUpdateConstraintsBlock)updateConstraintsBlock;
- (void)setUpdateConstraintsBlock:(UIViewUpdateConstraintsBlock)updateConstraintsBlock;

@property (nonatomic, copy) UIViewLayoutSubviewsBlock layoutSubviewsBlock;
// re-declare for code completions
- (UIViewLayoutSubviewsBlock)layoutSubviewsBlock;
- (void)setLayoutSubviewsBlock:(UIViewLayoutSubviewsBlock)layoutSubviewsBlock;

@end

#pragma mark -

@interface UIView (M9Category)

@property (nonatomic, readwrite, retain) UIImage *customBackgroundImage;
@property (nonatomic, readwrite, retain) UIView *customBackgroundView;
@property (nonatomic, readwrite, assign) UIEdgeInsets customBackgroundInsets;

- (UIView *)subviewWithTag:(NSInteger)tag;

// return nil if not found in the current view controller
- (UIView *)closestViewOfClass:(Class)clazz; // NOT include self
- (UIView *)closestViewOfClass:(Class)clazz includeSelf:(BOOL)includeSelf;
// return nil if not found in the current window
- (UIViewController *)closestViewController;

/**
 * iOS6 alternative method for
 *  - (UIView *)resizableSnapshotViewFromRect:(CGRect)rect afterScreenUpdates:(BOOL)afterUpdates withCapInsets:(UIEdgeInsets)capInsets
 */
- (UIView *)snapshotViewFromRect:(CGRect)rect withCapInsets:(UIEdgeInsets)capInsets NS_DEPRECATED_IOS(6_0, 7_0);

/**
 * returns 0.2
 *  @see +[UIView setAnimationDuration:]
 * BTW
 *  [CATransaction animationDuration] defaults to 1/4s
 *  [[UIApplication sharedApplication] statusBarOrientationAnimationDuration] defaults to 0.3
 */
+ (NSTimeInterval)animationDuration;
/**
 *  returns [CATransaction animationDuration] if animated, or 0.0
 */
+ (NSTimeInterval)animationDuration:(BOOL)animated;

+ (void)animate:(BOOL)animated delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void)animate:(BOOL)animated animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void)animate:(BOOL)animated animations:(void (^)(void))animations;

#pragma mark DEBUG

// continue if callback returns YES, and break if returns NO
- (void)eachSubview:(BOOL (^)(UIView *subview, NSInteger depth))callback;

- (NSString *)allSubviewsDescription;

@end

#pragma mark -

@interface UIView (SwipeView)

/**
 *  Add UISwipeGestureRecognizer-s and return them, you can set delegate or add more target-action-s to them
 *  @return two UISwipeGestureRecognizer-s with separately left and right direction
 */
- (NSArray *)addSwipeGestureRecognizerWithTarget:(id)target action:(SEL)action;

- (void)swipeWithGestureRecognizer:(UISwipeGestureRecognizer *)gesture;
- (void)swipeWithGestureRecognizer:(UISwipeGestureRecognizer *)gesture
                        animations:(void (^)(void))animations
                        completion:(void (^)(BOOL finished))completion;

- (void)swipeToLeft:(BOOL)swipeToLeft animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

@end

