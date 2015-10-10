//
//  M9Link.m
//  M9Dev
//
//  Created by MingLQ on 2015-10-10.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <objc/runtime.h>

#import "M9Link.h"

typedef void (^M9LinkCalback)(UIView *view, NSString *urlString);
static void *M9Link_callback = &M9Link_callback;

@interface M9Link : NSObject

+ (void)enableLinkForView:(UIView *)view callback:(M9LinkCalback)callback;

@end

#pragma mark -

@implementation UILabel (M9Link)

- (void)enableLinkWithCallback:(M9LabelLinkCalback)callback {
    [M9Link enableLinkForView:self callback:(M9LinkCalback)callback];
}

- (NSTextContainer *)_M9Link_textContainer {
    static void *M9Link_textContainer = &M9Link_textContainer;
    
    // CGSizeMake(CGRectGetWidth(label.bounds), CGFLOAT_MAX)
    NSTextContainer *textContainer = objc_getAssociatedObject(self, M9Link_textContainer);
    if (!textContainer) {
        textContainer = [NSTextContainer new];
        objc_setAssociatedObject(self, M9Link_textContainer, textContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    textContainer.size = self.bounds.size;
    textContainer.lineBreakMode = self.lineBreakMode;
    textContainer.lineFragmentPadding = 0;
    textContainer.maximumNumberOfLines = (NSUInteger)self.numberOfLines;
    
    return textContainer;
}

- (NSLayoutManager *)_M9Link_layoutManager {
    static void *M9Link_layoutManager = &M9Link_layoutManager;
    
    NSLayoutManager *layoutManager = objc_getAssociatedObject(self, M9Link_layoutManager);
    if (!layoutManager) {
        layoutManager = [NSLayoutManager new];
        [layoutManager addTextContainer:[self _M9Link_textContainer]];
        objc_setAssociatedObject(self, M9Link_layoutManager, layoutManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self.attributedText];
    [textStorage addLayoutManager:layoutManager];
    layoutManager.textStorage = textStorage;
    
    return layoutManager;
}

@end

@implementation UITextView (M9Link)

- (void)enableLinkWithCallback:(M9TextViewLinkCalback)callback {
    [M9Link enableLinkForView:self callback:(M9LinkCalback)callback];
}

@end

#pragma mark -

@interface M9LinkTapGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@end

@implementation M9LinkTapGestureRecognizerDelegate

@end

static M9LinkTapGestureRecognizerDelegate *TapGestureRecognizerDelegate = nil;

@implementation M9Link

+ (UITapGestureRecognizer *)_M9Link_linkTapGestureRecognizerOfView:(UIView *)view {
    for (UIGestureRecognizer *gestureRecognizer in view.gestureRecognizers) {
        if (gestureRecognizer.delegate == TapGestureRecognizerDelegate) {
            return [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] ? (UITapGestureRecognizer *)gestureRecognizer : nil;
        }
    }
    return nil;
}

+ (void)enableLinkForView:(UIView *)view callback:(M9LinkCalback)callback {
    if ([view isKindOfClass:[UILabel class]]
        || [view isKindOfClass:[UITextView class]]) {
    }
    else {
        return;
    }
    
    TapGestureRecognizerDelegate = TapGestureRecognizerDelegate ? : [M9LinkTapGestureRecognizerDelegate new];
    
    UITapGestureRecognizer *tapGestureRecognizer = ([self _M9Link_linkTapGestureRecognizerOfView:view]
                                                    ? : [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_M9Link_didTapWithGestureRecognizer:)]);
    tapGestureRecognizer.delegate = TapGestureRecognizerDelegate;
    [view addGestureRecognizer:tapGestureRecognizer];
    
    view.userInteractionEnabled = YES;
    
    objc_setAssociatedObject(view, M9Link_callback, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)_M9Link_didTapWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    UIView *view = tapGestureRecognizer.view;
    
    UILabel *label = [view isKindOfClass:[UILabel class]] ? (UILabel *)view : nil;
    UITextView *textView = [view isKindOfClass:[UITextView class]] ? (UITextView *)view : nil;
    if (!label && !textView) {
        return;
    }
    
    M9LinkCalback callback = objc_getAssociatedObject(view, M9Link_callback);
    if (!callback) {
        return;
    }
    
    NSTextContainer *textContainer = label ? [label _M9Link_textContainer] : textView.textContainer;
    NSLayoutManager *layoutManager = label ? [label _M9Link_layoutManager] : textView.layoutManager;
    
    NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
    CGRect textBounds = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
    textBounds.origin = view.bounds.origin;
    textBounds.size.width = ceil(CGRectGetWidth(textBounds));
    textBounds.size.height = ceil(CGRectGetHeight(textBounds));
    // textBounds = UIEdgeInsetsInsetRect(textBounds, UIEdgeInsetsMake(- 2, - 2, - 2, - 2));
    
    CGPoint point = [tapGestureRecognizer locationInView:view];
    point.y -= (CGRectGetHeight(view.bounds) - CGRectGetHeight(textBounds)) / 2;
    if (!CGRectContainsPoint(textBounds, point)) {
        return;
    }
    
    NSUInteger glyphIndex = [layoutManager glyphIndexForPoint:point inTextContainer:textContainer];
    NSUInteger charIndex = [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    
    NSDictionary *attributes = [label.attributedText ? : textView.attributedText attributesAtIndex:charIndex effectiveRange:nil];
    NSTextAttachment *linkAttachment = attributes[NSAttachmentAttributeName];
    NSString *linkURL = linkAttachment.contents ? [[NSString alloc] initWithData:linkAttachment.contents encoding:NSUTF8StringEncoding] : nil;
    
    if (linkURL.length) {
        if (callback) callback(view, linkURL);
    }
}

@end
