//
//  NSObject+M9BlockKVO.h
//  M9Dev
//
//  Created by MingLQ on 2016-10-08.
//  Copyright © 2016 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^M9KVOBlock)(NSString *keyPath, id object, NSDictionary<NSKeyValueChangeKey, id> *change);

@interface NSObject (M9BlockKVO)

/**
 *  @see - [NSNotificationCenter addObserverForName:object:queue:usingBlock:]
 */
- (id)addObserverForKeyPath:(NSString *)keyPath
                    options:(NSKeyValueObservingOptions)options
                 usingBlock:(M9KVOBlock)block;

@end
