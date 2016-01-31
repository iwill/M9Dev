//
//  UIView+M9.m
//  M9Dev
//
//  Created by MingLQ on 2011-10-11.
//  Copyright (c) 2011 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import <JRSwizzle/JRSwizzle.h>

#import "UIView+M9.h"

#import "NSObject+AssociatedObjects.h"
#import "M9Utilities.h"

@implementation UIView (Hierarchy)

@dynamic firstResponder;

- (UIView *)firstResponder {
    if ([self isFirstResponder]) {
        return self;
    }
    for (UIView *subview in self.subviews) {
        UIView *firstResponder = subview.firstResponder;
        if (firstResponder) {
            return firstResponder;
        }
    }
    return nil;
}

// see - endEditing:
- (void)setFirstResponder:(UIView *)firstResponder {
    [self.firstResponder resignFirstResponder];
    [firstResponder becomeFirstResponder];
}

@end

#pragma mark -

@implementation UIView (updateConstraints_layoutSubviews)

+ (void)load {
    [self jr_swizzleMethod:@selector(updateConstraints)
                withMethod:@selector(m9_updateConstraints)
                     error:nil];
    [self jr_swizzleMethod:@selector(layoutSubviews)
                withMethod:@selector(m9_layoutSubviews)
                     error:nil];
}

- (void)m9_updateConstraints {
    if (self.updateConstraintsBlock) self.updateConstraintsBlock();
    [self m9_updateConstraints]; // at last
}

- (void)m9_layoutSubviews {
    [self m9_layoutSubviews]; // at first
    if (self.layoutSubviewsBlock) self.layoutSubviewsBlock();
    // iOS7: *** Assertion failure in -[XXView layoutSublayersOfLayer:], /SourceCache/UIKit/UIKit-2935.137/UIView.m:8794
    static BOOL iOS7AndLower = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *systemVersion = [UIDevice currentDevice].systemVersion;
        iOS7AndLower = [systemVersion hasPrefix:@"6."] || [systemVersion hasPrefix:@"7."];
    });
    if (iOS7AndLower) {
        [self layoutIfNeeded];
    }
}

@dynamic updateConstraintsBlock;
static void *UIView_updateConstraintsBlock = &UIView_updateConstraintsBlock;

- (UIViewUpdateConstraintsBlock)updateConstraintsBlock {
    return [self associatedValueForKey:UIView_updateConstraintsBlock];
}

- (void)setUpdateConstraintsBlock:(UIViewUpdateConstraintsBlock)updateConstraintsBlock {
    [self associateCopyOfValue:updateConstraintsBlock withKey:UIView_updateConstraintsBlock];
}

@dynamic layoutSubviewsBlock;
static void *UIView_layoutSubviewsBlock = &UIView_layoutSubviewsBlock;

- (UIViewLayoutSubviewsBlock)layoutSubviewsBlock {
    return [self associatedValueForKey:UIView_layoutSubviewsBlock];
}

- (void)setLayoutSubviewsBlock:(UIViewLayoutSubviewsBlock)layoutSubviewsBlock {
    [self associateCopyOfValue:layoutSubviewsBlock withKey:UIView_layoutSubviewsBlock];
}

@end

#pragma mark -

@implementation UIView (M9Category)

static NSInteger CustomBackgroundViewTag = NSIntegerMin;

+ (void)load {
    /* [self jr_swizzleMethod:@selector(initWithFrame:) withMethod:@selector(initWithFrame_swizzle_:) error:nil]; */
}

/* - (instancetype)initWithFrame_swizzle_:(CGRect)frame {
    self = [self initWithFrame_swizzle_:frame];
    if (self) {
        self.exclusiveTouch = YES;
    }
    return self;
} */

- (UIView *)customBackgroundView {
    return [self subviewWithTag:CustomBackgroundViewTag];
}
- (void)setCustomBackgroundView:(UIView *)customBackgroundView {
    customBackgroundView.tag = CustomBackgroundViewTag;
    customBackgroundView.frame = self.bounds;
    customBackgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                             | UIViewAutoresizingFlexibleHeight);
    [self insertSubview:customBackgroundView atIndex:0];
}

- (UIImage *)customBackgroundImage {
    UIView *backgroundView = self.customBackgroundView;
    if (![backgroundView isKindOfClass:[UIImageView class]]) {
        return nil;
    }
    
    return ((UIImageView *)backgroundView).image;
}
- (void)setCustomBackgroundImage:(UIImage *)customBackgroundImage {
    UIView *backgroundView = self.customBackgroundView;
    if (![backgroundView isKindOfClass:[UIImageView class]]) {
        [backgroundView removeFromSuperview];
        backgroundView = nil;
    }
    
    if (!backgroundView) {
        backgroundView = [[UIImageView alloc] init];
        self.customBackgroundView = backgroundView;
    }
    
    ((UIImageView *)backgroundView).image = customBackgroundImage;
}

- (UIEdgeInsets)customBackgroundInsets {
    UIView *backgroundView = self.customBackgroundView;
    return CGRectDiff(self.bounds, backgroundView.frame);
}

- (void)setCustomBackgroundInsets:(UIEdgeInsets)backgroundInsets {
    UIView *backgroundView = self.customBackgroundView;
    if (!backgroundView) {
        backgroundView = [[UIImageView alloc] init];
        self.customBackgroundView = backgroundView;
    }
    backgroundView.frame = UIEdgeInsetsInsetRect(self.bounds, backgroundInsets);
}

- (UIView *)subviewWithTag:(NSInteger)tag {
    for (UIView *subview in self.subviews) {
        if (subview.tag == tag) {
            return subview;
        }
    }
    return nil;
}

- (UIView *)closestViewOfClass:(Class)clazz {
    return [self closestViewOfClass:clazz includeSelf:NO];
}

- (UIView *)closestViewOfClass:(Class)clazz includeSelf:(BOOL)includeSelf {
    if (clazz == [UIView class]) {
        return includeSelf ? self : self.superview;
    }
    if (![clazz isSubclassOfClass:[UIView class]]) {
        return nil;
    }
    return (UIView *)[self findResponderWithBlock:^BOOL(UIResponder *responder, BOOL *stop) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            *stop = YES;
            return NO;
        }
        return ((includeSelf || responder != self)
                && [responder isKindOfClass:clazz]);
    }];
}

- (UIViewController *)closestViewController {
    return (UIViewController *)[self closestResponderOfClass:[UIViewController class]];
}

- (NSString *)viewDescriptionWithIndent:(NSString *)indent {
    return [NSString stringWithFormat:@"%@%@ bounds: %@ superclass: %@\n",
            indent,
            self,
            NSStringFromCGRect(self.bounds),
            NSStringFromClass([self superclass])];
}

- (NSString *)allSubviewsDescriptionWithIndent:(NSString *)indent {
    indent = indent OR @"";
    NSMutableString *subviewsDescription = [[self viewDescriptionWithIndent:indent] mutableCopy];
    for (UIView *subview in self.subviews) {
        [subviewsDescription appendString:[subview allSubviewsDescriptionWithIndent:[indent stringByAppendingString:@"    "]]];
    }
    return subviewsDescription;
}

- (NSString *)allSubviewsDescription {
    return [self allSubviewsDescriptionWithIndent:nil];
}

- (void)eachView:(UIView *)view
           depth:(NSInteger)depth
        callback:(BOOL (^)(UIView *subview, NSInteger depth))callback {
    BOOL goon = callback(view, depth);
    if (!goon) {
        return;
    }
    for (UIView *subview in view.subviews) {
        [self eachView:subview depth:depth + 1 callback:callback];
    }
}

/**
 *  [self eachSubview:^BOOL(UIView *subview, NSInteger depth) {
 *      NSLog(@"%d: %@", depth, subview);
 *      return ![subview isKindOfClass:[UIPageControl class]];
 *  }];
 */
- (void)eachSubview:(BOOL (^)(UIView *subview, NSInteger depth))callback {
    if (!callback) {
        return;
    }
    [self eachView:self depth:0 callback:callback];
}

- (UIView *)snapshotViewFromRect:(CGRect)rect withCapInsets:(UIEdgeInsets)capInsets {
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(currentContext, - CGRectGetMinX(rect), - CGRectGetMinY(rect));
    [self.layer renderInContext:currentContext];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *snapshotView = [[UIImageView alloc] initWithFrame:rect];
    snapshotView.image = [snapshotImage resizableImageWithCapInsets:capInsets];
    return snapshotView;
}

+ (NSTimeInterval)animationDuration {
    return 0.2;
}

+ (NSTimeInterval)animationDuration:(BOOL)animated {
    return animated ? [self animationDuration] : 0.0;
}

+ (void)animate:(BOOL)animated
          delay:(NSTimeInterval)delay
        options:(UIViewAnimationOptions)options
     animations:(void (^)(void))animations
     completion:(void (^)(BOOL finished))completion {
    [self animateWithDuration:[self animationDuration:animated]
                        delay:delay
                      options:options
                   animations:animations
                   completion:completion];
}

+ (void)animate:(BOOL)animated
     animations:(void (^)(void))animations
     completion:(void (^)(BOOL finished))completion {
    [self animateWithDuration:[self animationDuration:animated]
                   animations:animations
                   completion:completion];
}

+ (void)animate:(BOOL)animated animations:(void (^)(void))animations {
    [self animateWithDuration:[self animationDuration:animated] animations:animations];
}

@end

#pragma mark -

@implementation UIView (SwipeView)

- (NSArray *)addSwipeGestureRecognizerWithTarget:(id)target action:(SEL)action {
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc]
                                                  initWithTarget:target action:action];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeLeftGesture];
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc]
                                                   initWithTarget:target action:action];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeRightGesture];
    
    return @[ swipeLeftGesture, swipeRightGesture ];
}

- (void)swipeWithGestureRecognizer:(UISwipeGestureRecognizer *)gesture {
    [self swipeWithGestureRecognizer:gesture animations:nil completion:nil];
}

- (void)swipeWithGestureRecognizer:(UISwipeGestureRecognizer *)gesture
                        animations:(void (^)(void))animations
                        completion:(void (^)(BOOL finished))completion {
    if (gesture.direction != UISwipeGestureRecognizerDirectionLeft
        && gesture.direction != UISwipeGestureRecognizerDirectionRight) {
        return;
    }
    
    [self swipeToLeft:gesture.direction == UISwipeGestureRecognizerDirectionLeft
           animations:animations
           completion:completion];
}

- (void)swipeToLeft:(BOOL)swipeToLeft
         animations:(void (^)(void))animations
         completion:(void (^)(BOOL finished))completion {
    UIView *superview = self.superview;
    
    // snapshot
    UIView *snapshotView = nil;
    CGRect snapshotFrame = self.frame;
    UIEdgeInsets snapshotEdgeInsets = UIEdgeInsetsZero;
    if ([superview respondsToSelector:@selector(resizableSnapshotViewFromRect:afterScreenUpdates:withCapInsets:)]) {
        snapshotView = [superview resizableSnapshotViewFromRect:snapshotFrame
                                             afterScreenUpdates:NO
                                                  withCapInsets:snapshotEdgeInsets];
    }
    else {
        snapshotView = [superview snapshotViewFromRect:snapshotFrame withCapInsets:snapshotEdgeInsets];
    }
    snapshotView.frame = snapshotFrame;
    
    // prepare
    void (^actionsWithoutAnimation)() = ^{
        [superview insertSubview:snapshotView aboveSubview:self];
        self.frame = ({
            CGRect frame = self.frame;
            frame.origin.x = (swipeToLeft
                              ? (frame.origin.x + frame.size.width)
                              : (frame.origin.x - frame.size.width));
            _RETURN frame;
        });
    };
    if ([[UIView class] respondsToSelector:@selector(performWithoutAnimation:)]) {
        [UIView performWithoutAnimation:actionsWithoutAnimation];
    }
    else {
        actionsWithoutAnimation();
    }
    
    // animation
    CGFloat animationDuration = [UIView animationDuration] * 2;
    [UIView animateWithDuration:animationDuration animations:^{
        if (animations) {
            animations();
        }
        
        snapshotView.frame = ({
            CGRect frame = snapshotView.frame;
            frame.origin.x = (swipeToLeft
                              ? (frame.origin.x - frame.size.width)
                              : (frame.origin.x + frame.size.width));
            _RETURN frame;
        });
        self.frame = ({
            CGRect frame = self.frame;
            frame.origin.x = (swipeToLeft
                              ? (frame.origin.x - frame.size.width)
                              : (frame.origin.x + frame.size.width));
            _RETURN frame;
        });
    } completion:^(BOOL finished) {
        [snapshotView removeFromSuperview];
        
        if (completion) {
            completion(finished);
        }
    }];
}

@end

