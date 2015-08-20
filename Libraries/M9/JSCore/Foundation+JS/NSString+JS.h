//
//  NSString+JS.h
//  M9Dev
//
//  Created by MingLQ on 2014-09-04.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "NSString+M9.h"

@protocol NSStringExport <JSExport>

#pragma mark NSString+NSData

+ (instancetype)stringWithData:(NSData *)data;
+ (instancetype)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;

#pragma mark NSString+Base64

+ (NSString *)stringWithBase64Data:(NSData *)base64Data;
+ (NSString *)stringWithBase64Data:(NSData *)base64Data lineLength:(int)lineLength;
+ (NSString *)stringWithBase64Data:(NSData *)base64Data lineLength:(int)lineLength lineFeed:(NSString *)lineFeed;

@end

@interface NSString (JS) <NSStringExport>

@end
