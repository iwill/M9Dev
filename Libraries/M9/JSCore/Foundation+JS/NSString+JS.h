//
//  NSString+JS.h
//  M9Dev
//
//  Created by MingLQ on 2014-09-04.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "NSString+.h"

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

#pragma mark -

@protocol NSDataExport_Base64 <JSExport>

+ (instancetype)dataWithBase64String:(NSString *)base64String;

@end

@interface NSData (JS_Base64) <NSDataExport_Base64>

@end
