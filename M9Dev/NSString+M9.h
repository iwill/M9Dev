//
//  NSString+M9.h
//  M9Dev
//
//  Created by MingLQ on 2011-06-04.
//  Copyright (c) 2011 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <Foundation/Foundation.h>

#pragma mark - NSString+Length

/**
 *  NSUTF8StringEncoding
 */
@interface NSString (Length)

- (NSUInteger)bytesLength;
- (NSString *)visualSubstringOfBytesLength:(NSUInteger)bytesLength;

- (NSUInteger)visualLength;
- (NSString *)visualSubstringOfVisualLength:(NSUInteger)visualLength;

@end

#pragma mark - NSString+NSData

@interface NSString (NSData)

+ (instancetype)stringWithData:(NSData *)data; // encoding: NSUTF8StringEncoding by default
+ (instancetype)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;

@end

#pragma mark - NSString+Base64

@interface NSString (Base64)

+ (instancetype)stringWithBase64Data:(NSData *)base64Data; // lineLength: 0, lineFeed: @"\n"
+ (instancetype)stringWithBase64Data:(NSData *)base64Data lineLength:(int)lineLength; // lineFeed: @"\n"
+ (instancetype)stringWithBase64Data:(NSData *)base64Data lineLength:(int)lineLength lineFeed:(NSString *)lineFeed;

@end
