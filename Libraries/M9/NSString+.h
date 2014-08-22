//
//  NSString+.h
//  iM9
//
//  Created by iwill on 2011-06-04.
//  Copyright 2011 M9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSData)

+ (instancetype)stringWithData:(NSData *)data; // encoding: NSUTF8StringEncoding by default
+ (instancetype)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;

@end

@interface NSString (Base64)

- (NSData *)base64Data;

+ (NSString *)stringWithBase64Data:(NSData *)base64Data;
+ (NSString *)stringWithBase64Data:(NSData *)base64Data lineLength:(int)lineLength;
+ (NSString *)stringWithBase64Data:(NSData *)base64Data lineLength:(int)lineLength lineFeed:(NSString *)lineFeed;

@end

