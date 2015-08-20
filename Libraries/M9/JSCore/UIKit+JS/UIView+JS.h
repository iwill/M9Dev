//
//  UIView+JS.h
//  M9Dev
//
//  Created by MingLQ on 2014-08-07.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol UIViewExport <JSExport>

#pragma mark UIView

- (id)initWithFrame:(CGRect)frame;

@property(nonatomic,getter=isUserInteractionEnabled) BOOL userInteractionEnabled;
@property(nonatomic)                                 NSInteger tag;
@property(nonatomic,readonly,retain)                 CALayer  *layer;

#pragma mark UIViewGeometry

@property(nonatomic) CGRect            frame;

@property(nonatomic) CGRect            bounds;
@property(nonatomic) CGPoint           center;
@property(nonatomic) CGAffineTransform transform;
@property(nonatomic) CGFloat           contentScaleFactor NS_AVAILABLE_IOS(4_0);

@property(nonatomic,getter=isMultipleTouchEnabled) BOOL multipleTouchEnabled;
@property(nonatomic,getter=isExclusiveTouch) BOOL       exclusiveTouch;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

- (CGPoint)convertPoint:(CGPoint)point toView:(UIView *)view;
- (CGPoint)convertPoint:(CGPoint)point fromView:(UIView *)view;
- (CGRect)convertRect:(CGRect)rect toView:(UIView *)view;
- (CGRect)convertRect:(CGRect)rect fromView:(UIView *)view;

@property(nonatomic) BOOL               autoresizesSubviews;
@property(nonatomic) UIViewAutoresizing autoresizingMask;

- (CGSize)sizeThatFits:(CGSize)size;
- (void)sizeToFit;

#pragma mark UIViewHierarchy

@property(nonatomic,readonly) UIView       *superview;
@property(nonatomic,readonly,copy) NSArray *subviews;
@property(nonatomic,readonly) UIWindow     *window;

- (void)removeFromSuperview;
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index;
- (void)exchangeSubviewAtIndex:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2;

- (void)addSubview:(UIView *)view;
- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview;
- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview;

- (void)bringSubviewToFront:(UIView *)view;
- (void)sendSubviewToBack:(UIView *)view;

- (BOOL)isDescendantOfView:(UIView *)view;
- (UIView *)viewWithTag:(NSInteger)tag;

- (void)setNeedsLayout;
- (void)layoutIfNeeded;

- (void)layoutSubviews;

#pragma mark UIViewRendering

- (void)setNeedsDisplay;
- (void)setNeedsDisplayInRect:(CGRect)rect;

@property(nonatomic)                 BOOL              clipsToBounds;
@property(nonatomic,copy)            UIColor          *backgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic)                 CGFloat           alpha;
@property(nonatomic,getter=isOpaque) BOOL              opaque;
@property(nonatomic)                 BOOL              clearsContextBeforeDrawing;
@property(nonatomic,getter=isHidden) BOOL              hidden;
@property(nonatomic)                 UIViewContentMode contentMode;
@property(nonatomic)                 CGRect            contentStretch NS_DEPRECATED_IOS(3_0,6_0);

@property(nonatomic,retain) UIColor *tintColor NS_AVAILABLE_IOS(7_0);

@property(nonatomic) UIViewTintAdjustmentMode tintAdjustmentMode NS_AVAILABLE_IOS(7_0);

#pragma mark UIViewAnimation

+ (void)beginAnimations:(NSString *)animationID context:(void *)context;
+ (void)commitAnimations;

+ (void)setAnimationDelegate:(id)delegate;
+ (void)setAnimationWillStartSelector:(SEL)selector;
+ (void)setAnimationDidStopSelector:(SEL)selector;
+ (void)setAnimationDuration:(NSTimeInterval)duration;
+ (void)setAnimationDelay:(NSTimeInterval)delay;
+ (void)setAnimationStartDate:(NSDate *)startDate;
+ (void)setAnimationCurve:(UIViewAnimationCurve)curve;
+ (void)setAnimationRepeatCount:(float)repeatCount;
+ (void)setAnimationRepeatAutoreverses:(BOOL)repeatAutoreverses;
+ (void)setAnimationBeginsFromCurrentState:(BOOL)fromCurrentState;

+ (void)setAnimationTransition:(UIViewAnimationTransition)transition forView:(UIView *)view cache:(BOOL)cache;

+ (void)setAnimationsEnabled:(BOOL)enabled;
+ (BOOL)areAnimationsEnabled;
+ (void)performWithoutAnimation:(void (^)(void))actionsWithoutAnimation NS_AVAILABLE_IOS(7_0);

#pragma mark UIViewAnimationWithBlocks

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion NS_AVAILABLE_IOS(4_0);

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion NS_AVAILABLE_IOS(4_0);

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations NS_AVAILABLE_IOS(4_0);

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion NS_AVAILABLE_IOS(7_0);

+ (void)transitionWithView:(UIView *)view duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion NS_AVAILABLE_IOS(4_0);

+ (void)transitionFromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion NS_AVAILABLE_IOS(4_0);

+ (void)performSystemAnimation:(UISystemAnimation)animation onViews:(NSArray *)views options:(UIViewAnimationOptions)options animations:(void (^)(void))parallelAnimations completion:(void (^)(BOOL finished))completion NS_AVAILABLE_IOS(7_0);

#pragma mark UIViewKeyframeAnimations

+ (void)animateKeyframesWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewKeyframeAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion NS_AVAILABLE_IOS(7_0);
+ (void)addKeyframeWithRelativeStartTime:(double)frameStartTime relativeDuration:(double)frameDuration animations:(void (^)(void))animations NS_AVAILABLE_IOS(7_0);

#pragma mark UIViewGestureRecognizers

@property(nonatomic,copy) NSArray *gestureRecognizers NS_AVAILABLE_IOS(3_2);

- (void)addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer NS_AVAILABLE_IOS(3_2);
- (void)removeGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer NS_AVAILABLE_IOS(3_2);

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer NS_AVAILABLE_IOS(6_0);

#pragma mark UIViewMotionEffects

- (void)addMotionEffect:(UIMotionEffect *)effect NS_AVAILABLE_IOS(7_0);

- (void)removeMotionEffect:(UIMotionEffect *)effect NS_AVAILABLE_IOS(7_0);

@property (copy, nonatomic) NSArray *motionEffects NS_AVAILABLE_IOS(7_0);

#pragma mark UIConstraintBasedLayoutInstallingConstraints

- (NSArray *)constraints NS_AVAILABLE_IOS(6_0);

- (void)addConstraint:(NSLayoutConstraint *)constraint NS_AVAILABLE_IOS(6_0);
- (void)addConstraints:(NSArray *)constraints NS_AVAILABLE_IOS(6_0);
- (void)removeConstraint:(NSLayoutConstraint *)constraint NS_AVAILABLE_IOS(6_0);
- (void)removeConstraints:(NSArray *)constraints NS_AVAILABLE_IOS(6_0);

#pragma mark UIConstraintBasedLayoutCoreMethods

- (void)updateConstraintsIfNeeded NS_AVAILABLE_IOS(6_0);
- (void)updateConstraints NS_AVAILABLE_IOS(6_0);
- (BOOL)needsUpdateConstraints NS_AVAILABLE_IOS(6_0);
- (void)setNeedsUpdateConstraints NS_AVAILABLE_IOS(6_0);

#pragma mark UIConstraintBasedCompatibility

- (BOOL)translatesAutoresizingMaskIntoConstraints NS_AVAILABLE_IOS(6_0);
- (void)setTranslatesAutoresizingMaskIntoConstraints:(BOOL)flag NS_AVAILABLE_IOS(6_0);

+ (BOOL)requiresConstraintBasedLayout NS_AVAILABLE_IOS(6_0);

#pragma mark UIConstraintBasedLayoutLayering

- (CGRect)alignmentRectForFrame:(CGRect)frame NS_AVAILABLE_IOS(6_0);
- (CGRect)frameForAlignmentRect:(CGRect)alignmentRect NS_AVAILABLE_IOS(6_0);

- (UIEdgeInsets)alignmentRectInsets NS_AVAILABLE_IOS(6_0);

- (UIView *)viewForBaselineLayout NS_AVAILABLE_IOS(6_0);

- (CGSize)intrinsicContentSize NS_AVAILABLE_IOS(6_0);
- (void)invalidateIntrinsicContentSize NS_AVAILABLE_IOS(6_0);

- (UILayoutPriority)contentHuggingPriorityForAxis:(UILayoutConstraintAxis)axis NS_AVAILABLE_IOS(6_0);
- (void)setContentHuggingPriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis NS_AVAILABLE_IOS(6_0);

- (UILayoutPriority)contentCompressionResistancePriorityForAxis:(UILayoutConstraintAxis)axis NS_AVAILABLE_IOS(6_0);
- (void)setContentCompressionResistancePriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis NS_AVAILABLE_IOS(6_0);

#pragma mark UIConstraintBasedLayoutFittingSize

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize NS_AVAILABLE_IOS(6_0);

#pragma mark UIConstraintBasedLayoutDebugging

- (NSArray *)constraintsAffectingLayoutForAxis:(UILayoutConstraintAxis)axis NS_AVAILABLE_IOS(6_0);

- (BOOL)hasAmbiguousLayout NS_AVAILABLE_IOS(6_0);
- (void)exerciseAmbiguityInLayout NS_AVAILABLE_IOS(6_0);

#pragma mark UIStateRestoration

@property (nonatomic, copy) NSString *restorationIdentifier NS_AVAILABLE_IOS(6_0);
- (void) encodeRestorableStateWithCoder:(NSCoder *)coder NS_AVAILABLE_IOS(6_0);
- (void) decodeRestorableStateWithCoder:(NSCoder *)coder NS_AVAILABLE_IOS(6_0);

#pragma mark UISnapshotting

- (UIView *)snapshotViewAfterScreenUpdates:(BOOL)afterUpdates NS_AVAILABLE_IOS(7_0);
- (UIView *)resizableSnapshotViewFromRect:(CGRect)rect afterScreenUpdates:(BOOL)afterUpdates withCapInsets:(UIEdgeInsets)capInsets NS_AVAILABLE_IOS(7_0);
- (BOOL)drawViewHierarchyInRect:(CGRect)rect afterScreenUpdates:(BOOL)afterUpdates NS_AVAILABLE_IOS(7_0);

#pragma mark NSObject

- (NSString *)description;

@end

@interface UIView (JS) <UIViewExport>

@end
