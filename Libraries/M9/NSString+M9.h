//
//  NSString+M9.h
//  M9Dev
//
//  Created by MingLQ on 2011-06-04.
//  Copyright 2011 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSData)

+ (instancetype)stringWithData:(NSData *)data; // encoding: NSUTF8StringEncoding by default
+ (instancetype)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;

@end

#pragma mark - NSString+Base64

@interface NSString (Base64)

+ (instancetype)stringWithBase64Data:(NSData *)base64Data;
+ (instancetype)stringWithBase64Data:(NSData *)base64Data lineLength:(int)lineLength;
+ (instancetype)stringWithBase64Data:(NSData *)base64Data lineLength:(int)lineLength lineFeed:(NSString *)lineFeed;

@end
