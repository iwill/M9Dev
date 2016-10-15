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
    if (self.block) self.block(keyPath, object, change);
}

@end

#pragma mark -

@implementation NSObject (M9BlockKVO)

- (id)addObserverForKeyPath:(NSString *)keyPath
                    options:(NSKeyValueObservingOptions)options
                 usingBlock:(M9KVOBlock)block {
    M9BlockKVOObserver *observer = [M9BlockKVOObserver new];
    observer.block = block;
    [self addObserver:observer forKeyPath:keyPath options:options context:NULL];
    return observer;
}

@end
