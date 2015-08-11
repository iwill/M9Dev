//
//  UIImage+.m
//  M9Dev
//
//  Created by MingLQ on 2011-06-20.
//  Copyright 2011 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import <QuartzCore/QuartzCore.h>

#import "UIImage+M9.h"
#import "NSData+M9.h"

static inline CGFloat DegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

static inline CGFloat RadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
}

@implementation UIImage (M9Category)

#pragma mark resizable image

- (UIImage *)resizableImage {
    CGFloat x = MAX(self.size.width / 2 - 1, 0), y = MAX(self.size.height / 2 - 1, 0);
    
    if (![self respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        return [self stretchableImageWithLeftCapWidth:x topCapHeight:y];
    }
    
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(y, x, y, x)];
}

#pragma mark resize and zoom image

- (UIImage *)imageByResizing:(CGSize)size {
    return [UIImage imageWithImage:self size:size];
}

- (UIImage *)imageByZooming:(CGFloat)zoom {
    return [UIImage imageWithImage:self zoom:zoom];
}

+ (UIImage *)imageWithImage:(UIImage *)image size:(CGSize)size {
    if (!image) {
        return nil;
    }
    if (CGSizeEqualToSize(size, image.size)) {
        return [image copy];
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image zoom:(CGFloat)zoom {
    return [self imageWithImage:image size:CGSizeMake(image.size.width * zoom, image.size.height * zoom)];
}

#pragma mark rotate image

- (UIImage *)imageByRotateRadians:(CGFloat)radians {
    return [self imageByRotateDegrees:RadiansToDegrees(radians)];
}

- (UIImage *)imageByRotateRadians:(CGFloat)radians size:(CGSize)size {
    return [self imageByRotateDegrees:RadiansToDegrees(radians) size:size];
}

- (UIImage *)imageByRotateDegrees:(CGFloat)degrees {
    return [self imageByRotateDegrees:degrees size:CGSizeZero];
}

// @see http://stackoverflow.com/questions/11667565/how-to-rotate-an-image-90-degrees-on-ios
- (UIImage *)imageByRotateDegrees:(CGFloat)degrees size:(CGSize)size {
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        UIView *rotatedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
        CGAffineTransform transform = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
        rotatedView.transform = transform;
        size = rotatedView.frame.size;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1, - 1);
    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
    CGContextRotateCTM(context, - DegreesToRadians(degrees));
    CGContextDrawImage(context,
                       CGRectMake(- size.width / 2,
                                  - size.height / 2,
                                  size.width,
                                  size.height),
                       self.CGImage);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image rotateRadians:(CGFloat)radians {
    return [image imageByRotateRadians:radians];
}

+ (UIImage *)imageWithImage:(UIImage *)image rotateRadians:(CGFloat)radians size:(CGSize)size {
    return [image imageByRotateRadians:radians size:size];
}

+ (UIImage *)imageWithImage:(UIImage *)image rotateDegrees:(CGFloat)degrees {
    return [image imageByRotateDegrees:degrees];
}

+ (UIImage *)imageWithImage:(UIImage *)image rotateDegrees:(CGFloat)degrees size:(CGSize)size {
    return [image imageByRotateDegrees:degrees size:size];
}

#pragma mark image with color

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [[self imageWithColor:color size:CGSizeMake(1, 1)] resizableImage];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    color = color ? color : [UIColor clearColor];
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark screenshot image

+ (UIImage *)screenshot {
    // Create a graphics context with the target size
    CGSize imageSize = [UIScreen mainScreen].bounds.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (![window respondsToSelector:@selector(screen)] || window.screen == [UIScreen mainScreen]) {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, window.center.x, window.center.y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  - window.bounds.size.width * [window.layer anchorPoint].x,
                                  - window.bounds.size.height * [window.layer anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [window.layer renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end

#pragma mark - UIImage+Base64

@implementation UIImage (Base64)

+ (instancetype)imageWithBase64String:(NSString *)base64String {
    return [self imageWithData:[NSData dataWithBase64String:base64String]];
}

@end

#pragma mark - UIImageView+M9Category

@implementation UIImageView (M9Category)

+ (instancetype)imageViewWithImageNamed:(NSString *)imageName {
    return [[self alloc] initWithImage:[UIImage imageNamed:imageName]];
}

@end