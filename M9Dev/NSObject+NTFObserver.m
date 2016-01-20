//
//  NSObject+NTFObserver.m
//  M9Dev
//
//  Created by MingLQ on 2015-12-14.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "NSObject+NTFObserver.h"

#import "NSObject+AssociatedValues.h"

@interface NTFObserver : NSObject

@property (nonatomic, strong) id<NSObject> observer;
@property (nonatomic, weak) id object;

+ (instancetype)observer:(id<NSObject>)observer object:(id)object;

@end

@implementation NTFObserver

+ (instancetype)observer:(id<NSObject>)observer object:(id)object {
    NTFObserver *ntfObserver = [self new];
    ntfObserver.observer = observer;
    ntfObserver.object = object;
    return ntfObserver;
}

@end

@implementation NSObject (NTFObserver)

static void *NTFObserver_allNTFObservers = &NTFObserver_allNTFObservers;

- (NSMutableDictionary<id<NSCopying>, NSMutableArray<NTFObserver *> *> *)allNTFObservers {
    return [self associatedValueForKey:NTFObserver_allNTFObservers];
}

- (void)setAllNTFObservers:(NSMutableDictionary<id<NSCopying>, NSMutableArray<NTFObserver *> *> *)allNTFObservers {
    [self associateValue:allNTFObservers withKey:NTFObserver_allNTFObservers];
}

- (void)addNTFObserver:(id<NSObject>)observer name:(nullable id<NSCopying>)name object:(nullable id)object {
    if (!observer) {
        return;
    }
    
    name = name ?: [NSNull null];
    
    NTFObserver *ntfObserver = [NTFObserver observer:observer object:object];
    
    NSMutableDictionary<id<NSCopying>, NSMutableArray<NTFObserver *> *> *allNTFObservers = [self allNTFObservers];
    if (!allNTFObservers) {
        allNTFObservers = [NSMutableDictionary<id<NSCopying>, NSMutableArray<NTFObserver *> *> new];
        [self setAllNTFObservers:allNTFObservers];
    }
    
    NSMutableArray<NTFObserver *> *ntfObservers = [allNTFObservers objectForKey:name];
    if (!ntfObservers) {
        ntfObservers = [NSMutableArray<NTFObserver *> new];
        [allNTFObservers setObject:ntfObservers forKey:name];
    }
    
    [ntfObservers addObject:ntfObserver];
}

#pragma mark -

- (void)startNTFObserving:(id)object name:(NSString *)name callback:(NTFObserverCallback)callback { @synchronized(self) {
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
    [self addNTFObserver:observer name:name object:object];
}}

- (void)startNTFObservingForName:(NSString *)name callback:(NTFObserverCallback)callback { @synchronized(self) {
    [self startNTFObserving:nil name:name callback:callback];
}}

- (void)stopNTFObserving:(id)object forName:(NSString *)name { @synchronized(self) {
    NSMutableDictionary<id<NSCopying>, NSMutableArray<NTFObserver *> *> *allNTFObservers = [self allNTFObservers];
    NSArray<id<NSCopying>> *allKeys = name ? @[ name ] : [allNTFObservers allKeys];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    for (id<NSCopying> key in allKeys) {
        NSMutableArray<NTFObserver *> *ntfObservers = [allNTFObservers objectForKey:key];
        
        for (NTFObserver *ntfObserver in [ntfObservers copy]) {
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
            [allNTFObservers removeObjectForKey:key];
        }
    }
    
    if (!allNTFObservers.count) {
        [self setAllNTFObservers:nil];
    }
}}

- (void)stopAllNTFObserving { @synchronized(self) {
    [self stopNTFObserving:nil forName:nil];
}}

#pragma mark - NTFObservable

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
}

@end
