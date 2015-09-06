//
//  NSData+M9.h
//  M9Dev
//
//  Created by MingLQ on 2014-06-19.
//  Released under the MIT license.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSData (NSString)

+ (instancetype)dataWithString:(NSString *)string encoding:(NSStringEncoding)encoding;
+ (instancetype)dataWithString:(NSString *)string encoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy;

@end

#pragma mark - NSData+Base64

@interface NSData (Base64)

+ (instancetype)dataWithBase64String:(NSString *)base64String;

@end

#pragma mark - NSData+UIImage

@interface NSData (UIImage)

+ (instancetype)dataWithPNGImage:(UIImage *)image;
+ (instancetype)dataWithJPGImage:(UIImage *)image quality:(CGFloat)quality;

@end
