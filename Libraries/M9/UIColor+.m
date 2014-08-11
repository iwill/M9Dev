//
//  UIColor+.m
//  iMSC
//
//  Created by Wills on 11-03-09.
//  Copyright 2011 Finalist. All rights reserved.
//

#import "UIColor+.h"

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

@implementation UIColor (M9Category)

- (UIColor *)inverseColor {
    
    CGColorRef oldCGColor = self.CGColor;
    
    NSUInteger numberOfComponents = CGColorGetNumberOfComponents(oldCGColor);
    
    // can not invert - the only component is the alpha
    // e.g. self == [UIColor groupTableViewBackgroundColor]
    if (numberOfComponents <= 1) {
        return [UIColor colorWithCGColor:oldCGColor];
    }
    
    const CGFloat *oldComponentColors = CGColorGetComponents(oldCGColor);
    CGFloat newComponentColors[numberOfComponents];
    int i = - 1;
    while (++i < numberOfComponents - 1) {
        newComponentColors[i] = 1 - oldComponentColors[i];
    }
    newComponentColors[i] = oldComponentColors[i]; // alpha
    
    CGColorRef newCGColor = CGColorCreate(CGColorGetColorSpace(oldCGColor), newComponentColors);
    UIColor *newColor = [UIColor colorWithCGColor:newCGColor];
    CGColorRelease(newCGColor);
    
    return newColor;
}

+ (UIColor *)colorWithName:(NSString *)name {
    static NSMutableDictionary *colors = nil;
    if (!colors) {
        colors = [[NSMutableDictionary alloc] init];
        
        // UIColor colors
        [colors setObject:[self blackColor]     forKey:@"_black"];
        [colors setObject:[self darkGrayColor]  forKey:@"_darkgray"];
        [colors setObject:[self lightGrayColor] forKey:@"_lightgray"];
        [colors setObject:[self whiteColor]     forKey:@"_white"];
        [colors setObject:[self grayColor]      forKey:@"_gray"];
        [colors setObject:[self redColor]       forKey:@"_red"];
        [colors setObject:[self greenColor]     forKey:@"_green"];
        [colors setObject:[self blueColor]      forKey:@"_blue"];
        [colors setObject:[self cyanColor]      forKey:@"_cyan"];
        [colors setObject:[self yellowColor]    forKey:@"_yellow"];
        [colors setObject:[self magentaColor]   forKey:@"_magenta"];
        [colors setObject:[self orangeColor]    forKey:@"_orange"];
        [colors setObject:[self purpleColor]    forKey:@"_purple"];
        [colors setObject:[self brownColor]     forKey:@"_brown"];
        [colors setObject:[self clearColor]     forKey:@"_clear"]; // clear color
        
        // web colors, see http://www.w3school.com.cn/html/html_colornames.asp
        NSString *colorsWithNamesPath = [[NSBundle mainBundle] pathForResource:@"colors-with-names"
                                                                        ofType:@"plist"
                                                                   inDirectory:@"Utility.bundle"];
        NSDictionary *colorsWithNames = [NSDictionary dictionaryWithContentsOfFile:colorsWithNamesPath];
        for (NSString *colorName in [colorsWithNames allKeys]) {
            NSString *color = [colorsWithNames objectForKey:colorName];
            [colors setObject:[self colorWithHexString:[color uppercaseString]] forKey:[colorName lowercaseString]];
        }
        [colors setObject:[self clearColor] forKey:@"transparent"]; // transparent
    }
    
    return [colors objectForKey:[name lowercaseString]];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    if ([[hexString lowercaseString] hasPrefix:@"0x"]) {
        hexString = [hexString substringFromIndex:2];
    }
    if ([hexString length] != 6) {
        return nil;
    }
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:hexString];
    unsigned hexValue = 0;
    if ([scanner scanHexInt:&hexValue] && [scanner isAtEnd]) {
        int r = ((hexValue & 0xFF0000) >> 16);
        int g = ((hexValue & 0x00FF00) >>  8);
        int b = ( hexValue & 0x0000FF)       ;
        return [self colorWithRed:((float)r / 255)
                            green:((float)g / 255)
                             blue:((float)b / 255)
                            alpha:1.0];
    }
    
    return nil;
}

+ (UIColor *)colorWithName:(NSString *)name alpha:(CGFloat)alpha {
    return [[self colorWithName:name] colorWithAlphaComponent:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    return [[self colorWithHexString:hexString] colorWithAlphaComponent:alpha];
}

@end

