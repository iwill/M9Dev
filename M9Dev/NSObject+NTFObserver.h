//
//  NSObject+NTFObserver.h
//  M9Dev
//
//  Created by MingLQ on 2015-12-14.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

// NOTE: MingLQ - typedef NSString *NSNotificationName

typedef void (^NTFObserverBlock)(/* id object, NSString *name, */NSDictionary *info);

/**
 *  NTFObserver: observer implementation via NSNotificationCenter&NSNotification
 */
@interface NSObject (NTFObserver)

- (void)ntf_startObserving:(id)object name:(NSString *)name usingBlock:(NTFObserverBlock)block;
- (void)ntf_startObservingForName:(NSString *)name usingBlock:(NTFObserverBlock)block;
- (void)ntf_stopObserving:(id)object name:(NSString *)name;
- (void)ntf_stopAllObserving;

/* #pragma mark - DEPRECATED_ATTRIBUTE

- (id)addNTFObserverForName:(NSString *)name usingBlock:(NTFObserverBlock)block;
// observer: the returning value of - addNTFObserverForName:usingBlock:
- (void)removeNTFObserver:(id)observer name:(NSString *)name;
- (void)removeNTFObserver:(id)observer;

- (void)notifyNTFObserverWithName:(NSString *)name;
- (void)notifyNTFObserverWithName:(NSString *)name info:(NSDictionary *)info; */

@end

#pragma mark -

@interface NSObject (NTFObservable)

- (void)ntf_notifyObserverWithName:(NSString *)name;
- (void)ntf_notifyObserverWithName:(NSString *)name info:(NSDictionary *)info;

@end

#pragma mark -

typedef void (^NTFObserveBlock)(id value);

@interface NSObject (NTFBlockObservable)

- (id)ntf_addObserverForKey:(NSString *)key usingBlock:(NTFObserveBlock)block;
- (void)ntf_notifyObserversForKey:(NSString *)key value:(id)value;
- (void)ntf_removeObserver:(id)observer;

@end
