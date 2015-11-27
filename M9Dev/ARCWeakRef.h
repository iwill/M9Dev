//
//  ARCWeakRef.h
//  M9Dev
//
//  Created by MingLQ on 2013-07-08.
//  Copyright (c) 2013 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <Foundation/Foundation.h>

#import "EXTScope.h"

/**
 *  Bring ARC weak ref to MRC code.
 *  !!!: Use weakify and strongify from extobjc instead in ARC.
 *
 *  Usage:
 *      NSMutableArray *observers = ...;
 *      [observers addObject:[ARCWeakRef weakRefWithObject:observer]];
 *  OR
 *      __typeof__(self) selfType;
 *      ARCWeakRef *weakRef = [ARCWeakRef weakRefWithObject:self];
 *      [object setCallback:^{
 *          __typeof__(selfType) self = weakRef.object
 *          NSLog(@"self: %@", self);
 *      }];
 */

@interface ARCWeakRef : NSObject

@property(nonatomic, weak) id object;

+ (instancetype)weakRefWithObject:(id)object;

@end

