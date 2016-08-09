//
//  UIControl+M9EventCallback.h
//  M9Dev
//
//  Created by MingLQ on 2015-08-11.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <UIKit/UIKit.h>

#import "NSObject+AssociatedObjects.h"
#import "M9Utilities.h"

typedef void (^M9EventCallback)(id sender);

@interface UIControl (M9EventCallback)

- (void)addEventCallback:(M9EventCallback)eventCallback
        forControlEvents:(UIControlEvents)controlEvents;
- (void)removeEventCallbackForControlEvents:(UIControlEvents)controlEvents;

@end
