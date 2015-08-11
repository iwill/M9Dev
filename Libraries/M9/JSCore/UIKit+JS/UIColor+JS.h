//
//  UIColor+JS.h
//  M9Dev
//
//  Created by MingLQ on 2014-08-07.
//  Copyright (c) 2014年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "UIColor+.h"

@protocol UIColorExport <JSExport>

#pragma mark UIColor

- (UIColor *)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

+ (UIColor *)colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithCGColor:(CGColorRef)cgColor;
+ (UIColor *)colorWithPatternImage:(UIImage *)image;
+ (UIColor *)colorWithCIColor:(CIColor *)ciColor NS_AVAILABLE_IOS(5_0);

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

- (UIColor *)colorWithAlphaComponent:(CGFloat)alpha;

@property(nonatomic,readonly) CGColorRef CGColor;
- (CGColorRef)CGColor NS_RETURNS_INNER_POINTER;

@property(nonatomic,readonly) CIColor   *CIColor NS_AVAILABLE_IOS(5_0);

#pragma mark UIColor+

+ (UIColor *)colorWithHexString:(NSString *)hexString;
- (UIColor *)inverseColor;

@end

@interface UIColor (JS) <UIColorExport>

@end
