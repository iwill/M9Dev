//
//  UIImage+M9.h
//  M9Dev
//
//  Created by MingLQ on 2011-06-20.
//  Copyright 2011 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (M9Category)

- (UIImage *)resizableImage;

- (UIImage *)imageByResizing:(CGSize)size;
- (UIImage *)imageByZooming:(CGFloat)zoom;
+ (UIImage *)imageWithImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *)imageWithImage:(UIImage *)image zoom:(CGFloat)zoom;

- (UIImage *)imageByRotateRadians:(CGFloat)radians;
- (UIImage *)imageByRotateRadians:(CGFloat)radians size:(CGSize)size;
- (UIImage *)imageByRotateDegrees:(CGFloat)degrees;
- (UIImage *)imageByRotateDegrees:(CGFloat)degrees size:(CGSize)size;
+ (UIImage *)imageWithImage:(UIImage *)image rotateRadians:(CGFloat)radians;
+ (UIImage *)imageWithImage:(UIImage *)image rotateRadians:(CGFloat)radians size:(CGSize)size;
+ (UIImage *)imageWithImage:(UIImage *)image rotateDegrees:(CGFloat)degrees;
+ (UIImage *)imageWithImage:(UIImage *)image rotateDegrees:(CGFloat)degrees size:(CGSize)size;

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)screenshot;

@end

#pragma mark - UIImage+Base64

@interface UIImage (Base64)

+ (instancetype)imageWithBase64String:(NSString *)base64String;

@end

#pragma mark - UIImageView+M9Category

@interface UIImageView (M9Category)

+ (instancetype)imageViewWithImageNamed:(NSString *)imageName;

@end
