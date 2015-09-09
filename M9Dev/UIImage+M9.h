//
//  UIImage+M9.h
//  M9Dev
//
//  Created by MingLQ on 2011-06-20.
//  Copyright (c) 2011 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <UIKit/UIKit.h>

@interface UIImage (M9Category)

- (UIImage *)resizableImage;

- (UIImage *)imageByResizing:(CGSize)size;
- (UIImage *)imageByZooming:(CGFloat)zoom;

- (UIImage *)imageByRotateRadians:(CGFloat)radians;
- (UIImage *)imageByRotateRadians:(CGFloat)radians size:(CGSize)size;
- (UIImage *)imageByRotateDegrees:(CGFloat)degrees;
- (UIImage *)imageByRotateDegrees:(CGFloat)degrees size:(CGSize)size;

/**
 *  better than CoreImage(too slow) and GPUImage(too large)
 *  @see http://blog.bubbly.net/2013/09/11/slick-tricks-for-ios-blur-effect/
 *  @see https://github.com/kronik/DKLiveBlur
 *
 *  dispatch_queue_t queue = dispatch_queue_create("Blur queue", NULL);
 *  dispatch_async(queue, ^{
 *      UIImage *blurImage = [image blurWithRadius:1.0];
 *      dispatch_async(dispatch_get_main_queue(), ^{
 *          imageView.image = blurImage;
 *      });
 *  });
 */
- (UIImage *)blurImageWithRadius:(CGFloat)blurRadius;

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
