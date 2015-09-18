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

- (CGFloat)bouncingOffsetY {
    CGFloat top = self.contentInset.top;
    CGFloat bottom = self.contentInset.bottom;
    CGFloat viewHeight = CGRectGetHeight(self.frame);
    CGFloat contentOffsetY = self.contentOffset.y;
    CGFloat contentHeight = self.contentSize.height;
    
    CGFloat topOffset = contentOffsetY + top;
    CGFloat bottomOffset = contentOffsetY + viewHeight - bottom - contentHeight;
    
    if (topOffset < 0.0) {
        // NSLog(@"topOffset: %f", topOffset);
        return topOffset;
    }
    else if (topOffset > 0 && bottomOffset >= 0) {
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
    else {
        return 0.0;
    }
}

@end
