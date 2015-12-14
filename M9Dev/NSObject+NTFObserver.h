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

- (id)addNTFObserverForName:(NSString *)name callback:(NTFObserverCallback)callback;
// observer: the returning value of - addNTFObserverForName:callback:
- (void)removeNTFObserver:(id)observer forName:(NSString *)name;
- (void)removeNTFObserver:(id)observer;

- (void)notifyNTFObserverWithName:(NSString *)name;
- (void)notifyNTFObserverWithName:(NSString *)name info:(NSDictionary *)eventInfo;

@end
