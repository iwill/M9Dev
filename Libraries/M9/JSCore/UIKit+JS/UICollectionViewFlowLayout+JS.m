//
//  UICollectionViewFlowLayout+JS.m
//  M9Dev
//
//  Created by MingLQ on 2014-09-04.
//  Copyright (c) 2014年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "UICollectionViewFlowLayout+JS.h"

#import "NSDictionary+.h"

#define UIEdgeInsets

#define UIEdgeInsets_top    @"top"
#define UIEdgeInsets_left   @"left"
#define UIEdgeInsets_bottom @"bottom"
#define UIEdgeInsets_right  @"right"

@implementation UICollectionViewFlowLayout (JS)

- (NSDictionary *)js_sectionInset {
    return @{ UIEdgeInsets_top: @(self.sectionInset.top),
              UIEdgeInsets_left: @(self.sectionInset.left),
              UIEdgeInsets_bottom: @(self.sectionInset.bottom),
              UIEdgeInsets_right: @(self.sectionInset.right) };
}

- (void)js_setSectionInset:(NSDictionary *)js_sectionInset {
    self.sectionInset = UIEdgeInsetsMake([js_sectionInset integerForKey:UIEdgeInsets_top],
                                         [js_sectionInset integerForKey:UIEdgeInsets_left],
                                         [js_sectionInset integerForKey:UIEdgeInsets_bottom],
                                         [js_sectionInset integerForKey:UIEdgeInsets_right]);
}

@end
