//
//  UIViewController+EventNotifications.m
//  M9Dev
//
//  Created by MingLQ on 2016-04-01.
//  Copyright © 2016年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <JRSwizzle/JRSwizzle.h>

#import "UIViewController+EventNotifications.h"

NSString * const UIViewControllerEventNotification = @"UIViewControllerEventNotification";

NSString * const UIViewControllerEventTypeKey = @"EventType";
NSString * const UIViewControllerEventIsAnimatedKey = @"IsAnimated";

@implementation UIViewController (EventNotifications)

static BOOL UIViewController_isEventNotificationsEnabled = NO;

+ (BOOL)isEventNotificationsEnabled {
    return UIViewController_isEventNotificationsEnabled;
}

+ (void)enableEventNotifications {
    [self jr_swizzleMethod:@selector(viewDidLoad)
                withMethod:@selector(swizzled_viewDidLoad)
                     error:nil];
    [self jr_swizzleMethod:@selector(viewWillAppear:)
                withMethod:@selector(swizzled_viewWillAppear:)
                     error:nil];
    [self jr_swizzleMethod:@selector(viewDidAppear:)
                withMethod:@selector(swizzled_viewDidAppear:)
                     error:nil];
    [self jr_swizzleMethod:@selector(viewWillDisappear:)
                withMethod:@selector(swizzled_viewWillDisappear:)
                     error:nil];
    [self jr_swizzleMethod:@selector(viewDidDisappear:)
                withMethod:@selector(swizzled_viewDidDisappear:)
                     error:nil];
    [self jr_swizzleMethod:@selector(viewWillLayoutSubviews)
                withMethod:@selector(swizzled_viewWillLayoutSubviews)
                     error:nil];
    [self jr_swizzleMethod:@selector(viewDidLayoutSubviews)
                withMethod:@selector(swizzled_viewDidLayoutSubviews)
                     error:nil];
    UIViewController_isEventNotificationsEnabled = YES;
}

- (void)swizzled_viewDidLoad {
    [self swizzled_viewDidLoad];
    [self postEventNotificationWithEventType:UIViewControllerEventType_viewDidLoad
                                    animated:NO];
}

- (void)swizzled_viewWillAppear:(BOOL)animated {
    [self swizzled_viewWillAppear:(BOOL)animated];
    [self postEventNotificationWithEventType:UIViewControllerEventType_viewWillAppear
                                    animated:animated];
}

- (void)swizzled_viewDidAppear:(BOOL)animated {
    [self swizzled_viewDidAppear:(BOOL)animated];
    [self postEventNotificationWithEventType:UIViewControllerEventType_viewDidAppear
                                    animated:animated];
}

- (void)swizzled_viewWillDisappear:(BOOL)animated {
    [self swizzled_viewWillDisappear:(BOOL)animated];
    [self postEventNotificationWithEventType:UIViewControllerEventType_viewWillDisappear
                                    animated:animated];
}

- (void)swizzled_viewDidDisappear:(BOOL)animated {
    [self swizzled_viewDidDisappear:(BOOL)animated];
    [self postEventNotificationWithEventType:UIViewControllerEventType_viewDidDisappear
                                    animated:animated];
}

- (void)swizzled_viewWillLayoutSubviews {
    [self swizzled_viewWillLayoutSubviews];
    [self postEventNotificationWithEventType:UIViewControllerEventType_viewWillLayoutSubviews
                                    animated:NO];
}

- (void)swizzled_viewDidLayoutSubviews {
    [self swizzled_viewDidLayoutSubviews];
    [self postEventNotificationWithEventType:UIViewControllerEventType_viewDidLayoutSubviews
                                    animated:NO];
}

- (void)postEventNotificationWithEventType:(UIViewControllerEventType)eventType animated:(BOOL)animated {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:UIViewControllerEventNotification
                                      object:self
                                    userInfo:@{ UIViewControllerEventTypeKey: @(eventType),
                                                UIViewControllerEventIsAnimatedKey: @(animated) }];
}

@end
