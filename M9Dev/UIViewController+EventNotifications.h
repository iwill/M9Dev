//
//  UIViewController+EventNotifications.h
//  M9Dev
//
//  Created by MingLQ on 2016-04-01.
//  Copyright © 2016年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const UIViewControllerEventNotification;

extern NSString * const UIViewControllerEventTypeKey;
extern NSString * const UIViewControllerEventAnimationKey;

typedef NS_ENUM(NSInteger, UIViewControllerEventType) {
    UIViewControllerEventType_viewDidLoad = 1,
    UIViewControllerEventType_viewWillAppear,
    UIViewControllerEventType_viewDidAppear,
    UIViewControllerEventType_viewWillDisappear,
    UIViewControllerEventType_viewDidDisappear,
    UIViewControllerEventType_viewWillLayoutSubviews,
    UIViewControllerEventType_viewDidLayoutSubviews
};

@interface UIViewController (EventNotifications)

+ (BOOL)isEventNotificationsEnabled;
+ (void)enableEventNotifications;

@end
