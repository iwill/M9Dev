//
//  NSObject+NTFObserver.h
//  M9Dev
//
//  Created by MingLQ on 2015-12-14.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NTFObserverCallback)(id object, NSString *name, NSDictionary *info);

/**
 *  NTFObserver: observer implementation via NSNotificationCenter&NSNotification
 */
@interface NSObject (NTFObserver)

- (void)ntf_startObserving:(id)object name:(NSString *)name callback:(NTFObserverCallback)callback;
- (void)ntf_startObservingForName:(NSString *)name callback:(NTFObserverCallback)callback;
- (void)ntf_stopObserving:(id)object forName:(NSString *)name;
- (void)ntf_stopAllObserving;

/* #pragma mark - DEPRECATED_ATTRIBUTE

- (id)addNTFObserverForName:(NSString *)name callback:(NTFObserverCallback)callback;
// observer: the returning value of - addNTFObserverForName:callback:
- (void)removeNTFObserver:(id)observer forName:(NSString *)name;
- (void)removeNTFObserver:(id)observer;

- (void)notifyNTFObserverWithName:(NSString *)name;
- (void)notifyNTFObserverWithName:(NSString *)name info:(NSDictionary *)info; */

@end

#pragma mark -

@interface NSObject (NTFObservable)

- (void)ntf_notifyObserverWithName:(NSString *)name;
- (void)ntf_notifyObserverWithName:(NSString *)name info:(NSDictionary *)info;

@end
