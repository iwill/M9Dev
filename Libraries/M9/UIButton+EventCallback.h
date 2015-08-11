//
//  UIButton+EventCallback.h
//  M9Dev
//
//  Created by MingLQ on 2015-08-11.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSObject+AssociatedObjects.h"

typedef void (^UIControlEventCallback)(UIButton *button);

@interface UIButton (EventCallback)

@property(nonatomic, copy) UIControlEventCallback tapEventCallback;

+ (instancetype)buttonWithTapEventCallback:(UIControlEventCallback)tapEventCallback;

@end
