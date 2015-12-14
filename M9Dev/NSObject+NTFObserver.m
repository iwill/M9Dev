//
//  NSObject+NTFObserver.m
//  M9Dev
//
//  Created by MingLQ on 2015-12-14.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "NSObject+NTFObserver.h"

#define NTFObserverMakeName(name) [NSString stringWithFormat:@"NTFObserver-%@-%@", NSStringFromClass([self class]), name]

@implementation NSObject (NTFObserver)

- (id)addNTFObserverForName:(NSString *)name callback:(NTFObserverCallback)callback {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    return [notificationCenter addObserverForName:NTFObserverMakeName(name)
                                           object:self
                                            queue:[NSOperationQueue mainQueue]
                                       usingBlock:^(NSNotification *notification) {
                                           if (callback) callback(notification.object,
                                                                  name/* notification.name */,
                                                                  notification.userInfo);
                                       }];
}

- (void)removeNTFObserver:(id)observer forName:(NSString *)name {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:observer name:NTFObserverMakeName(name) object:self];
}

- (void)removeNTFObserver:(id)observer {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:observer];
}

- (void)notifyNTFObserverWithName:(NSString *)name {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:NTFObserverMakeName(name) object:self];
}

- (void)notifyNTFObserverWithName:(NSString *)name info:(NSDictionary *)info {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:NTFObserverMakeName(name) object:self userInfo:info];
}

@end
