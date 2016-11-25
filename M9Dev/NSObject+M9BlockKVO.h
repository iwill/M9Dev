//
//  NSObject+M9BlockKVO.h
//  M9Dev
//
//  Created by MingLQ on 2016-10-08.
//  Copyright © 2016 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSObject+AssociatedObjects.h"
#import "M9Utilities.h"

typedef id M9BlockKVObserver;

typedef void (^M9KVOBlock)(id old, id new);

/**
 *  @see - [NSNotificationCenter addObserverForName:object:queue:usingBlock:]
 */
@interface NSObject (M9BlockKVO)

- (M9BlockKVObserver)addKVObserverForKeyPath:(NSString *)keyPath
                                  usingBlock:(M9KVOBlock)block; // options: old & new
- (M9BlockKVObserver)addKVObserverForKeyPath:(NSString *)keyPath
                                     options:(NSKeyValueObservingOptions)options
                                  usingBlock:(M9KVOBlock)block;

- (void)removeKVObserver:(NSObject *)observer;

@end
