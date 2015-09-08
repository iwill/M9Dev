//
//  JSCollectionViewCell.m
//  M9Dev
//
//  Created by MingLQ on 2014-09-04.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "JSCollectionViewCell.h"

#import "M9Utilities.h"
#import "NSDictionary+M9.h"

@implementation JSCollectionViewCell {
    NSMutableDictionary *keyedSubviews;
}

@synthesize isSetUp;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        keyedSubviews = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if (self.prepareForReuseBlock) {
        self.prepareForReuseBlock();
    }
}

- (NSDictionary *)keyedSubviews {
    return [keyedSubviews copy];
}

- (UIView *)subviewForKey:(id)key {
    return [[keyedSubviews objectForKey:key] as:[UIView class]];
}

- (void)addSubview:(UIView *)subview forKey:(id)key {
    [keyedSubviews setObjectOrNil:subview forKey:key];
}

- (void)removeSubviewForKey:(id)key {
    [keyedSubviews removeObjectForKey:key];
}

@end
