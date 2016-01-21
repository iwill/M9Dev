//
//  NSObject+NTFObserver.m
//  M9Dev
//
//  Created by MingLQ on 2015-12-14.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "NSObject+NTFObserver.h"

#import "NSObject+AssociatedValues.h"

@interface _NTFObserver : NSObject

@property (nonatomic, strong) id<NSObject> observer;
@property (nonatomic, weak) id object;

+ (instancetype)observer:(id<NSObject>)observer object:(id)object;

@end

@implementation _NTFObserver

+ (instancetype)observer:(id<NSObject>)observer object:(id)object {
    _NTFObserver *ntfObserver = [self new];
    ntfObserver.observer = observer;
    ntfObserver.object = object;
    return ntfObserver;
}

@end

#pragma mark -

@implementation NSObject (NTFObserver)

static void *NTFObserver_allNTFObservers = &NTFObserver_allNTFObservers;

- (NSMutableDictionary<id<NSCopying>, NSMutableArray<_NTFObserver *> *> *)ntf_allObservers {
    return [self associatedValueForKey:NTFObserver_allNTFObservers];
}

- (void)ntf_setAllObservers:(NSMutableDictionary<id<NSCopying>, NSMutableArray<_NTFObserver *> *> *)allObservers {
    [self associateValue:allObservers withKey:NTFObserver_allNTFObservers];
}

- (void)ntf_addObserver:(id<NSObject>)observer name:(nullable id<NSCopying>)name object:(nullable id)object {
    if (!observer) {
        return;
    }
    
    name = name ?: [NSNull null];
    
    _NTFObserver *ntfObserver = [_NTFObserver observer:observer object:object];
    
    NSMutableDictionary<id<NSCopying>, NSMutableArray<_NTFObserver *> *> *allObservers = [self ntf_allObservers];
    if (!allObservers) {
        allObservers = [NSMutableDictionary<id<NSCopying>, NSMutableArray<_NTFObserver *> *> new];
        [self ntf_setAllObservers:allObservers];
    }
    
    NSMutableArray<_NTFObserver *> *ntfObservers = [allObservers objectForKey:name];
    if (!ntfObservers) {
        ntfObservers = [NSMutableArray<_NTFObserver *> new];
        [allObservers setObject:ntfObservers forKey:name];
    }
    
    [ntfObservers addObject:ntfObserver];
}

#pragma mark - public

- (void)ntf_startObserving:(id)object name:(NSString *)name callback:(NTFObserverCallback)callback { @synchronized(self) {
    if (!callback) {
        return;
    }
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    id<NSObject> observer = [notificationCenter addObserverForName:name
                                                            object:object
                                                             queue:[NSOperationQueue mainQueue]
                                                        usingBlock:^(NSNotification * _Nonnull notification) {
                                                            callback(notification.object,
                                                                     notification.name,
                                                                     notification.userInfo);
                                                        }];
    [self ntf_addObserver:observer name:name object:object];
}}

- (void)ntf_startObservingForName:(NSString *)name callback:(NTFObserverCallback)callback { @synchronized(self) {
    [self ntf_startObserving:nil name:name callback:callback];
}}

- (void)ntf_stopObserving:(id)object forName:(NSString *)name { @synchronized(self) {
    NSMutableDictionary<id<NSCopying>, NSMutableArray<_NTFObserver *> *> *allObservers = [self ntf_allObservers];
    NSArray<id<NSCopying>> *allKeys = name ? @[ name ] : [allObservers allKeys];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    for (id<NSCopying> key in allKeys) {
        NSMutableArray<_NTFObserver *> *ntfObservers = [allObservers objectForKey:key];
        
        for (_NTFObserver *ntfObserver in [ntfObservers copy]) {
            if (!object || object == ntfObserver.object) {
                if (name || object) {
                    [notificationCenter removeObserver:ntfObserver.observer name:name object:object];
                }
                else {
                    [notificationCenter removeObserver:ntfObserver.observer];
                }
                [ntfObservers removeObject:ntfObserver];
            }
        }
        
        if (!ntfObservers.count) {
            [allObservers removeObjectForKey:key];
        }
    }
    
    if (!allObservers.count) {
        [self ntf_setAllObservers:nil];
    }
}}

- (void)ntf_stopAllObserving { @synchronized(self) {
    [self ntf_stopObserving:nil forName:nil];
}}

/* #pragma mark - DEPRECATED_ATTRIBUTE

#define NTFObserverMakeName(name) [NSString stringWithFormat:@"NTFObserver-%@-%@", NSStringFromClass([self class]), name]

- (id)addNTFObserverForName:(NSString *)name callback:(NTFObserverCallback)callback {
    if (!callback) {
        return nil;
    }
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    return [notificationCenter addObserverForName:NTFObserverMakeName(name)
                                           object:self
                                            queue:[NSOperationQueue mainQueue]
                                       usingBlock:^(NSNotification *notification) {
                                           // NOT: notification.name - notification.name == NTFObserverMakeName(name)
                                           callback(notification.object,
                                                    name,
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
} */

@end

#pragma mark - NTFObservable

@implementation NSObject (NTFObservable)

- (void)ntf_notifyObserverWithName:(NSString *)name {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:name object:self];
}

- (void)ntf_notifyObserverWithName:(NSString *)name info:(NSDictionary *)info {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:name object:self userInfo:info];
}

@end
