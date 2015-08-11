//
//  UIButton+EventCallback.m
//  M9Dev
//
//  Created by MingLQ on 2015-08-11.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "UIButton+EventCallback.h"

@implementation UIButton (EventCallback)

@dynamic tapEventCallback;
static void *UIButton_EventCallback = &UIButton_EventCallback;

- (UIControlEventCallback)tapEventCallback {
    return [self associatedValueForKey:UIButton_EventCallback];
}

- (void)setTapEventCallback:(UIControlEventCallback)tapEventCallback {
    [self associateCopyOfValue:tapEventCallback withKey:UIButton_EventCallback];
    if (tapEventCallback) {
        [self addTarget:self action:@selector(callbackWithButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self removeTarget:self action:@selector(callbackWithButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)callbackWithButton:(UIButton *)button {
    if (self.tapEventCallback) self.tapEventCallback(button);
}

+ (instancetype)buttonWithTapEventCallback:(UIControlEventCallback)tapEventCallback {
    UIButton *button = [self new];
    button.tapEventCallback = tapEventCallback;
    return button;
}

@end
