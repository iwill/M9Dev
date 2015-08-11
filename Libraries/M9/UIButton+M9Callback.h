//
//  UIButton+M9Callback.h
//  M9Dev
//
//  Created by MingLQ on 2015-08-11.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSObject+AssociatedObjects.h"

typedef void (^M9ButtonCallback)(UIButton *button);

@interface UIButton (M9Callback)

@property(nonatomic, copy) M9ButtonCallback callback;

@end
