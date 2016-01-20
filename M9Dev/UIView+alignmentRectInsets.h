//
//  UIView+alignmentRectInsets.h
//  M9Dev
//
//  Created by MingLQ on 2016-01-20.
//  Copyright © 2016年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIView_alignmentRectInsets <NSObject>

@property (nonatomic) UIEdgeInsets alignmentRectInsets;

@end

#pragma mark -

@interface UILabel (alignmentRectInsets) <UIView_alignmentRectInsets>
@end

@interface UIButton (alignmentRectInsets) <UIView_alignmentRectInsets>
@end
