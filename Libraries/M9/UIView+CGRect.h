//
//  UIView+CGRect.h
//  M9Dev
//
//  Created by iwill on 2014-08-06.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (CGRect)

- (void)setFrameWithX:(CGFloat)x;
- (void)setFrameWithY:(CGFloat)y;
- (void)setFrameWithX:(CGFloat)x y:(CGFloat)y;

- (void)setFrameWithWidth:(CGFloat)width;
- (void)setFrameWithHeight:(CGFloat)height;
- (void)setFrameWithWidth:(CGFloat)width height:(CGFloat)height;

- (void)setFrameWithOrigin:(CGPoint)origin;
- (void)setFrameWithSize:(CGSize)size;

- (void)setBoundsWithX:(CGFloat)x;
- (void)setBoundsWithY:(CGFloat)y;
- (void)setBoundsWithX:(CGFloat)x y:(CGFloat)y;

@end
