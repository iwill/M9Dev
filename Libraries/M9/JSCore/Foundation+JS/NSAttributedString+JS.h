//
//  NSAttributedString+JS.h
//  M9Dev
//
//  Created by MingLQ on 2014-09-09.
//  Copyright (c) 2014年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "NSAttributedString+M9.h"

@protocol NSAttributedStringExport <JSExport>

#pragma mark NSAttributedString

@property (readonly, copy) NSString *string;
- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range;

#pragma mark NSAttributedString+NSExtendedAttributedString

@property (readonly) NSUInteger length;
- (id)attribute:(NSString *)attrName atIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range;
- (NSAttributedString *)attributedSubstringFromRange:(NSRange)range;

- (NSDictionary *)attributesAtIndex:(NSUInteger)location longestEffectiveRange:(NSRangePointer)range inRange:(NSRange)rangeLimit;
- (id)attribute:(NSString *)attrName atIndex:(NSUInteger)location longestEffectiveRange:(NSRangePointer)range inRange:(NSRange)rangeLimit;

- (BOOL)isEqualToAttributedString:(NSAttributedString *)other;

- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary *)attrs;

- (void)enumerateAttributesInRange:(NSRange)enumerationRange options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(NSDictionary *attrs, NSRange range, BOOL *stop))block NS_AVAILABLE(10_6, 4_0);
- (void)enumerateAttribute:(NSString *)attrName inRange:(NSRange)enumerationRange options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id value, NSRange range, BOOL *stop))block NS_AVAILABLE(10_6, 4_0);

#pragma mark NSAttributedString+

+ (instancetype)attributedStringWithHTMLString:(NSString *)string NS_AVAILABLE_IOS(7_0); // use NSUTF8StringEncoding
+ (instancetype)attributedStringWithHTMLString:(NSString *)string encoding:(NSStringEncoding)encoding error:(NSError **)error NS_AVAILABLE_IOS(7_0);

@end

@interface NSAttributedString (JS) <NSAttributedStringExport>

@end

#pragma mark -

@protocol NSMutableAttributedStringExport <JSExport>

#pragma mark NSAttributedString

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str;
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range;

#pragma mark NSAttributedString+NSExtendedMutableAttributedString

@property (readonly, retain) NSMutableString *mutableString;

- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)range;
- (void)addAttributes:(NSDictionary *)attrs range:(NSRange)range;
- (void)removeAttribute:(NSString *)name range:(NSRange)range;

- (void)replaceCharactersInRange:(NSRange)range withAttributedString:(NSAttributedString *)attrString;
- (void)insertAttributedString:(NSAttributedString *)attrString atIndex:(NSUInteger)loc;
- (void)appendAttributedString:(NSAttributedString *)attrString;
- (void)deleteCharactersInRange:(NSRange)range;
- (void)setAttributedString:(NSAttributedString *)attrString;

- (void)beginEditing;
- (void)endEditing;

@end

@interface NSMutableAttributedString (JS) <NSMutableAttributedStringExport>

@end
