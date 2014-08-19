//
//  UIImage+.h
//  iM9
//
//  Created by iwill on 2011-06-20.
//  Copyright 2011 M9. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (M9Category)

- (id)initWithName:(NSString *)name DEPRECATED_ATTRIBUTE;
+ (UIImage *)imageWithName:(NSString *)name DEPRECATED_ATTRIBUTE;

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

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)resizableImageWithColor:(UIColor *)color;

+ (UIImage *)screenshot;

@end

@interface UIImageView (M9Category)

+ (instancetype)imageViewWithImageNamed:(NSString *)imageName;

@end

