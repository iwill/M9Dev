//
//  UIImage+M9.m
//  M9Dev
//
//  Created by MingLQ on 2011-06-20.
//  Copyright (c) 2011 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

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
    if (CGSizeEqualToSize(size, self.size)) {
        return self;
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageByZooming:(CGFloat)zoom {
    return [self imageByResizing:CGSizeMake(self.size.width * zoom, self.size.height * zoom)];
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

#pragma mark blur image

- (UIImage *)blurImageWithRadius:(CGFloat)blurRadius {
    // boxSize must be odd and gt 1
    int boxSize = MAX(1, floor(blurRadius * 50) * 2 + 1);
    
    CGImageRef rawImage = self.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(rawImage);
    inBuffer.height = CGImageGetHeight(rawImage);
    inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    inBuffer.data = (void *)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(rawImage);
    outBuffer.height = CGImageGetHeight(rawImage);
    outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    
    // !!!: kvImageHighQualityResampling: Use a higher quality, slower resampling filter for Geometry operations
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend/* | kvImageHighQualityResampling */);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(self.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
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
