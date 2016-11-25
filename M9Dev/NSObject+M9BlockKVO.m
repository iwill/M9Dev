//
//  NSObject+M9BlockKVO.m
//  M9Dev
//
//  Created by MingLQ on 2016-10-08.
//  Copyright © 2016 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "NSObject+M9BlockKVO.h"

@interface M9BlockKVOObserver : NSObject

@property (nonatomic, copy) M9KVOBlock block;

@end

@implementation M9BlockKVOObserver

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    if (self.block) self.block(change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);
}

@end

#pragma mark -

@implementation NSObject (M9BlockKVO)

static void *M9BlockKVOObservers = &M9BlockKVOObservers;

- (M9BlockKVObserver)addKVObserverForKeyPath:(NSString *)keyPath
                                  usingBlock:(M9KVOBlock)block {
    return [self addKVObserverForKeyPath:keyPath
                                 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                              usingBlock:block];
}

- (M9BlockKVObserver)addKVObserverForKeyPath:(NSString *)keyPath
                                     options:(NSKeyValueObservingOptions)options
                                  usingBlock:(M9KVOBlock)block {
    M9BlockKVOObserver *observer = [M9BlockKVOObserver new];
    observer.block = block;
    
    NSMutableArray *observers = [self associatedValueForKey:M9BlockKVOObservers];
    if (!observers) {
        observers = [NSMutableArray new];
        [self associateValue:observers withKey:M9BlockKVOObservers];
    }
    [observers addObject:observer];
    
    [self addObserver:observer
           forKeyPath:keyPath
              options:options
              context:NULL];
    return observer;
}

- (void)removeKVObserver:(NSObject *)observer {
    NSMutableArray *observers = [self associatedValueForKey:M9BlockKVOObservers];
    [observers removeObject:observer];
}

@end
