//
//  UIScrollView+.m
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

@end
