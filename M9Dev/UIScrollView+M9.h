//
//  UIScrollView+M9.h
//  M9Dev
//
//  Created by MingLQ on 2014-09-04.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (UIScrollViewScrolledToTheBottomEdge)

- (BOOL)scrolledToTheBottomEdge;

/**
 *  pulling down to reload: bouncingOffsetY < 0
 *  scrolling up to load more: bouncingOffsetY > 0
 *  otherwise: bouncingOffsetY == 0
 */
- (CGFloat)bouncingOffsetY;
- (BOOL)isPullingDownToReload;
- (BOOL)isScrollingUpToLoadMore;

@end
