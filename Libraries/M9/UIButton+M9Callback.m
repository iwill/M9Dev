//
//  UIButton+M9Callback.m
//  M9Dev
//
//  Created by MingLQ on 2015-08-11.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "UIButton+M9Callback.h"

@implementation UIButton (M9Callback)

@dynamic callback;
static void *UIButton_M9Callback = &UIButton_M9Callback;

- (M9ButtonCallback)callback {
    return [self associatedValueForKey:UIButton_M9Callback];
}

- (void)setCallback:(M9ButtonCallback)callback {
    [self associateCopyOfValue:callback withKey:UIButton_M9Callback];
    if (callback) {
        [self addTarget:self action:@selector(callbackWithButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self removeTarget:self action:@selector(callbackWithButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)callbackWithButton:(UIButton *)button {
    if (self.callback) self.callback(button);
}

@end
