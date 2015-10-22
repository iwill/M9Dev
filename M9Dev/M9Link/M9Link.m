//
//  M9Link.m
//  M9Dev
//
//  Created by MingLQ on 2015-10-10.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <objc/runtime.h>

#import "M9Link.h"

typedef void (^M9LinkCalback)(UIView *view, NSString *urlString, NSRange range);
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

- (void)_M9Link_didTapWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    M9LabelLinkCalback callback = objc_getAssociatedObject(self, M9Link_callback);
    if (!callback) {
        return;
    }
    
    CGPoint point = [tapGestureRecognizer locationInView:self];
    
    NSTextContainer *textContainer = [self _M9Link_textContainer];
    NSLayoutManager *layoutManager = [self _M9Link_layoutManager];
    
    NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
    CGRect textBounds = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
    textBounds.origin = self.bounds.origin;
    textBounds.size.width = ceil(CGRectGetWidth(textBounds));
    textBounds.size.height = ceil(CGRectGetHeight(textBounds));
    // textBounds = UIEdgeInsetsInsetRect(textBounds, UIEdgeInsetsMake(- 2, - 2, - 2, - 2));
    
    point.y -= (CGRectGetHeight(self.bounds) - CGRectGetHeight(textBounds)) / 2;
    if (!CGRectContainsPoint(textBounds, point)) {
        return;
    }
    
    NSUInteger glyphIndex = [layoutManager glyphIndexForPoint:point inTextContainer:textContainer];
    NSUInteger charIndex = [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    
    NSRange range = NSMakeRange(NSNotFound, 0);
    NSDictionary *attributes = [self.attributedText attributesAtIndex:MIN(charIndex, self.attributedText.length - 1)
                                                       effectiveRange:&range];
    
    NSTextAttachment *linkAttachment = attributes[NSAttachmentAttributeName];
    NSString *linkURL = linkAttachment.contents ? [[NSString alloc] initWithData:linkAttachment.contents encoding:NSUTF8StringEncoding] : nil;
    if (linkURL.length && callback) callback(self, linkURL, range);
}

@end

#pragma mark -

@implementation UITextView (M9Link)

- (void)enableLinkWithCallback:(M9TextViewLinkCalback)callback {
    [M9Link enableLinkForView:self callback:(M9LinkCalback)callback];
}

- (void)_M9Link_didTapWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    M9LinkCalback callback = objc_getAssociatedObject(self, M9Link_callback);
    if (!callback) {
        return;
    }
    
    CGPoint point = [tapGestureRecognizer locationInView:self];
    
    UITextPosition *position = [self closestPositionToPoint:point];
    // NSDictionary *attributes = [textView textStylingAtPosition:tapPosition inDirection:UITextStorageDirectionForward];
    
    // to get range
    UITextPosition *beginningPosition = self.beginningOfDocument;
    NSInteger index = [self offsetFromPosition:beginningPosition toPosition:position];
    NSRange range = NSMakeRange(NSNotFound, 0);
    NSDictionary *attributes = [self.attributedText attributesAtIndex:MIN(index, self.attributedText.length - 1)
                                                       effectiveRange:&range];
    
    id urlObject = attributes[NSLinkAttributeName];
    NSString *linkURL = [urlObject isKindOfClass:[NSURL class]] ? [(NSURL *)urlObject absoluteString] : (NSString *)urlObject;
    if (linkURL.length && callback) callback(self, linkURL, range);
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
                                                    ? : [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(_M9Link_didTapWithGestureRecognizer:)]);
    tapGestureRecognizer.delegate = TapGestureRecognizerDelegate;
    [view addGestureRecognizer:tapGestureRecognizer];
    
    view.userInteractionEnabled = YES;
    
    objc_setAssociatedObject(view, M9Link_callback, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

#pragma mark -

@implementation NSTextAttachment (M9Link)

- (NSString *)linkURL {
    return ([self.fileType isEqualToString:NSLinkAttributeName] && self.contents
            ? [[NSString alloc] initWithData:self.contents encoding:NSUTF8StringEncoding]
            : nil);
}

- (void)setLinkURL:(NSString *)linkURL {
    self.fileType = NSLinkAttributeName;
    self.contents = [linkURL dataUsingEncoding:NSUTF8StringEncoding];
    self.fileWrapper = nil;
}

@end
