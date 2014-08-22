//
//  UIColor+.h
//  iMSC
//
//  Created by Wills on 11-03-09.
//  Copyright 2011 Finalist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (M9Category)

- (UIColor *)inverseColor;

+ (UIColor *)colorWithName:(NSString *)name;
+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)colorWithName:(NSString *)name alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end

