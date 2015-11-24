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

// NO offsetX, offsetY
@property (nonatomic, readonly) CGFloat minOffsetX, minOffsetY, maxOffsetX, maxOffsetY;

- (void)setContentOffsetWithoutNotifingDelegate:(CGPoint)contentOffset;

/**
 *  if (dragging && bouncingOffsetY < 0) {
 *      // pulling down to reload
 *  }
 *  else if (bouncingOffsetY > 0) {
 *      // scrolling up to load more
 *  }
 *  else {
 *      // not bouncing
 *  }
 */
- (CGFloat)bouncingOffsetY;
- (BOOL)scrolledToTheBottomEdge /* DEPRECATED_ATTRIBUTE */;

@end
