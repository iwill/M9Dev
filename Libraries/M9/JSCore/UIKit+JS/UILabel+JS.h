//
//  UILabel+JS.h
//  M9Dev
//
//  Created by MingLQ on 2014-08-12.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "UIView+JS.h"

@protocol UILabelExport <JSExport>

@property(nonatomic,copy)   NSString           *text;
@property(nonatomic,retain) UIFont             *font;
@property(nonatomic,retain) UIColor            *textColor;
@property(nonatomic,retain) UIColor            *shadowColor;
@property(nonatomic)        CGSize             shadowOffset;
@property(nonatomic)        NSTextAlignment    textAlignment;
@property(nonatomic)        NSLineBreakMode    lineBreakMode;

@property(nonatomic,copy)   NSAttributedString *attributedText NS_AVAILABLE_IOS(6_0);

@property(nonatomic,retain)               UIColor *highlightedTextColor;
@property(nonatomic,getter=isHighlighted) BOOL     highlighted;

// @property(nonatomic,getter=isUserInteractionEnabled) BOOL userInteractionEnabled;
@property(nonatomic,getter=isEnabled)                BOOL enabled;

@property(nonatomic) NSInteger numberOfLines;

@property(nonatomic) BOOL adjustsFontSizeToFitWidth;
@property(nonatomic) BOOL adjustsLetterSpacingToFitWidth NS_DEPRECATED_IOS(6_0,7_0);
@property(nonatomic) CGFloat minimumFontSize NS_DEPRECATED_IOS(2_0, 6_0);
@property(nonatomic) UIBaselineAdjustment baselineAdjustment;
@property(nonatomic) CGFloat minimumScaleFactor NS_AVAILABLE_IOS(6_0);

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines;
- (void)drawTextInRect:(CGRect)rect;

@property(nonatomic) CGFloat preferredMaxLayoutWidth NS_AVAILABLE_IOS(6_0);

@end

@interface UILabel (JS) <UIViewExport, UILabelExport>

@end
