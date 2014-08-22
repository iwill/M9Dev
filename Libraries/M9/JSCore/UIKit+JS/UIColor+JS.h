//
//  UIColor+JS.h
//  M9Dev
//
//  Created by MingLQ on 2014-08-07.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "UIColor+.h"

@protocol UIColorExport <JSExport>

#pragma mark - UIColor+

+ (UIColor *)colorWithHexString:(NSString *)hexString;
- (UIColor *)inverseColor;

#pragma mark - UIColor

+ (UIColor *)colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithCGColor:(CGColorRef)cgColor;
+ (UIColor *)colorWithPatternImage:(UIImage *)image;
+ (UIColor *)colorWithCIColor:(CIColor *)ciColor NS_AVAILABLE_IOS(5_0);

// - (UIColor *)initWithWhite:(CGFloat)white alpha:(CGFloat)alpha;
// - (UIColor *)initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
- (UIColor *)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
// - (UIColor *)initWithCGColor:(CGColorRef)cgColor;
// - (UIColor *)initWithPatternImage:(UIImage*)image;
// - (UIColor *)initWithCIColor:(CIColor *)ciColor NS_AVAILABLE_IOS(5_0);

+ (UIColor *)blackColor;
+ (UIColor *)darkGrayColor;
+ (UIColor *)lightGrayColor;
+ (UIColor *)whiteColor;
+ (UIColor *)grayColor;
+ (UIColor *)redColor;
+ (UIColor *)greenColor;
+ (UIColor *)blueColor;
+ (UIColor *)cyanColor;
+ (UIColor *)yellowColor;
+ (UIColor *)magentaColor;
+ (UIColor *)orangeColor;
+ (UIColor *)purpleColor;
+ (UIColor *)brownColor;
+ (UIColor *)clearColor;

- (void)set;

- (void)setFill;
- (void)setStroke;

- (BOOL)getWhite:(CGFloat *)white alpha:(CGFloat *)alpha NS_AVAILABLE_IOS(5_0);
- (BOOL)getHue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha NS_AVAILABLE_IOS(5_0);
- (BOOL)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha NS_AVAILABLE_IOS(5_0);

- (UIColor *)colorWithAlphaComponent:(CGFloat)alpha;

@property(nonatomic,readonly) CGColorRef CGColor;
- (CGColorRef)CGColor NS_RETURNS_INNER_POINTER;

@property(nonatomic,readonly) CIColor   *CIColor NS_AVAILABLE_IOS(5_0);

#pragma mark - UIKitAdditions

// - (id)initWithColor:(UIColor *)color NS_AVAILABLE_IOS(5_0);

@end

@interface UIColor (JS) <UIColorExport>

@end
