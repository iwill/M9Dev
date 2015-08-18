//
//  UIView+M9.h
//  M9Dev
//
//  Created by MingLQ on 2011-10-11.
//  Copyright 2011 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

static inline UIEdgeInsets UIEdgeInsetsDiffRect(CGRect fromRect, CGRect toRect) {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top  = - CGRectGetMinY(fromRect) + CGRectGetMinY(toRect);
    insets.left = - CGRectGetMinX(fromRect) + CGRectGetMinX(toRect);
    insets.bottom = CGRectGetHeight(fromRect) - CGRectGetHeight(toRect) - insets.top;
    insets.right  = CGRectGetWidth(fromRect)  - CGRectGetWidth(toRect)  - insets.left;
    return insets;
}

#pragma mark -

@interface UIView (FirstResponder)

@property(nonatomic, readwrite, assign) UIView *firstResponder;

@end

#pragma mark -

@interface UIView (M9Category)

@property(nonatomic, readwrite, retain) UIImage *customBackgroundImage;
@property(nonatomic, readwrite, retain) UIView *customBackgroundView;
@property(nonatomic, readwrite, assign) UIEdgeInsets customBackgroundInsets;

- (UIView *)subviewWithTag:(NSInteger)tag;
- (void)removeAllSubviews;

/**
 * iOS6 alternative method for
 *  - (UIView *)resizableSnapshotViewFromRect:(CGRect)rect afterScreenUpdates:(BOOL)afterUpdates withCapInsets:(UIEdgeInsets)capInsets
 */
/* - (UIView *)snapshotViewFromRect:(CGRect)rect withCapInsets:(UIEdgeInsets)capInsets NS_DEPRECATED_IOS(6_0, 7_0); */

/**
 * returns 0.2
 *  @see +[UIView setAnimationDuration:]
 * BTW
 *  [CATransaction animationDuration] is 1/4s now
 *  [[UIApplication sharedApplication] statusBarOrientationAnimationDuration] is 0.3
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

