//
//  UIView+alignmentRectInsets.m
//  M9Dev
//
//  Created by MingLQ on 2016-01-20.
//  Copyright © 2016年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <JRSwizzle/JRSwizzle.h>

#import "UIView+alignmentRectInsets.h"

#import "NSObject+AssociatedObjects.h"

static void *UIView_alignmentRectInsets = &UIView_alignmentRectInsets;

@interface UIView (alignmentRectInsets)

@end

@implementation UIView (alignmentRectInsets)

+ (void)load {
    for (Class clazz in @[ [UILabel class], [UIButton class] ]) {
        [clazz jr_swizzleMethod:@selector(alignmentRectInsets)
                     withMethod:@selector(m9_alignmentRectInsets)
                          error:nil];
    }
}

- (UIEdgeInsets)m9_alignmentRectInsets {
    NSValue *value = [self associatedValueForKey:UIView_alignmentRectInsets];
    return value ? [value UIEdgeInsetsValue] : [self m9_alignmentRectInsets];
}

- (void)setAlignmentRectInsets:(UIEdgeInsets)alignmentRectInsets {
    NSValue *value = [NSValue valueWithUIEdgeInsets:alignmentRectInsets];
    [self associateValue:value withKey:UIView_alignmentRectInsets];
}

@end

#pragma mark -

@implementation UILabel (alignmentRectInsets)
@dynamic alignmentRectInsets;
@end

@implementation UIButton (alignmentRectInsets)
@dynamic alignmentRectInsets;
@end
