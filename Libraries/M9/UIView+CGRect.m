//
//  UIView+CGRect.m
//  M9Dev
//
//  Created by iwill on 2014-08-06.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "UIView+CGRect.h"

@implementation UIView (CGRect)

- (void)setFrameWithX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setFrameWithY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setFrameWithX:(CGFloat)x y:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.x = x;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setFrameWithWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setFrameWithHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setFrameWithWidth:(CGFloat)width height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.width = width;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setFrameWithOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setFrameWithSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setBoundsWithX:(CGFloat)x {
    CGRect bounds = self.bounds;
    bounds.origin.x = x;
    self.bounds = bounds;
}

- (void)setBoundsWithY:(CGFloat)y {
    CGRect bounds = self.bounds;
    bounds.origin.y = y;
    self.bounds = bounds;
}

- (void)setBoundsWithX:(CGFloat)x y:(CGFloat)y {
    CGRect bounds = self.bounds;
    bounds.origin.x = x;
    bounds.origin.y = y;
    self.bounds = bounds;
}

@end
