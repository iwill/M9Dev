//
//  UIFont+JS.h
//  M9Dev
//
//  Created by MingLQ on 2014-08-12.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol UIFontExport <JSExport>

+ (UIFont *)preferredFontForTextStyle:(NSString *)style NS_AVAILABLE_IOS(7_0);

+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize;

+ (NSArray *)familyNames;

+ (NSArray *)fontNamesForFamilyName:(NSString *)familyName;

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize;
+ (UIFont *)italicSystemFontOfSize:(CGFloat)fontSize;

@property(nonatomic,readonly,retain) NSString *familyName;
@property(nonatomic,readonly,retain) NSString *fontName;
@property(nonatomic,readonly)        CGFloat   pointSize;
@property(nonatomic,readonly)        CGFloat   ascender;
@property(nonatomic,readonly)        CGFloat   descender;
@property(nonatomic,readonly)        CGFloat   capHeight;
@property(nonatomic,readonly)        CGFloat   xHeight;
@property(nonatomic,readonly)        CGFloat   lineHeight NS_AVAILABLE_IOS(4_0);
@property(nonatomic,readonly)        CGFloat   leading;

- (UIFont *)fontWithSize:(CGFloat)fontSize;

+ (UIFont *)fontWithDescriptor:(UIFontDescriptor *)descriptor size:(CGFloat)pointSize NS_AVAILABLE_IOS(7_0);

- (UIFontDescriptor *)fontDescriptor NS_AVAILABLE_IOS(7_0);

#pragma mark UIFontSystemFonts

+ (CGFloat)labelFontSize;
+ (CGFloat)buttonFontSize;
+ (CGFloat)smallSystemFontSize;
+ (CGFloat)systemFontSize;

@end

@interface UIFont (JS) <UIFontExport>

@end
