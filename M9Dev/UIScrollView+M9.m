//
//  UIScrollView+M9.m
//  M9Dev
//
//  Created by MingLQ on 2014-09-04.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "UIScrollView+M9.h"

@implementation UIScrollView (UIScrollViewScrolledToTheBottomEdge)

@dynamic minOffsetX, minOffsetY, maxOffsetX, maxOffsetY;

- (CGFloat)minOffsetX {
    return - self.contentInset.left;
}

- (CGFloat)minOffsetY {
    return - self.contentInset.top;
}

- (CGFloat)maxOffsetX {
    CGFloat viewWidth = CGRectGetWidth(self.frame) - self.contentInset.right;
    return MAX(self.minOffsetX, (self.contentSize.width - viewWidth));
}

- (CGFloat)maxOffsetY {
    CGFloat viewHeight = CGRectGetHeight(self.frame) - self.contentInset.bottom;
    return MAX(self.minOffsetY, (self.contentSize.height - viewHeight));
}

// @see http://stackoverflow.com/a/17856354/456536
// @see http://stackoverflow.com/a/9418625/456536
- (void)setContentOffsetWithoutNotifingDelegate:(CGPoint)contentOffset {
    id<UIScrollViewDelegate> delegate = self.delegate;
    self.contentOffset = contentOffset;
    self.delegate = delegate;
}

- (CGFloat)bouncingOffsetY {
    CGFloat top = self.contentInset.top;
    CGFloat bottom = self.contentInset.bottom;
    CGFloat viewHeight = CGRectGetHeight(self.frame);
    CGFloat contentOffsetY = self.contentOffset.y;
    CGFloat contentHeight = self.contentSize.height;
    
    CGFloat topOffset = contentOffsetY + top;
    
    if (topOffset < 0.0) {
        // NSLog(@"topOffset: %f", topOffset);
        return topOffset;
    }
    
    CGFloat bottomOffset = contentOffsetY + viewHeight - bottom - contentHeight;
    
    if (topOffset > 0 && bottomOffset >= 0) {
        CGFloat minContentHeight = top + viewHeight + bottom;
        if (contentHeight < minContentHeight) {
            // NSLog(@"bottomOffset: %f", topOffset);
            return topOffset;
        }
        else {
            // NSLog(@"bottomOffset: %f", bottomOffset);
            return bottomOffset;
        }
    }
    
    return 0.0;
}

- (BOOL)scrolledToTheBottomEdge {
    if (!self.dragging && !self.decelerating) {
        return NO;
    }
    if (self.contentOffset.y <= - self.contentInset.top) {
        return NO;
    }
    
    CGFloat bottomOffset = self.contentOffset.y + self.frame.size.height - self.contentSize.height;
    CGFloat bottomViewHeight = 0;
    return bottomOffset - bottomViewHeight >= 0;
}

@end
