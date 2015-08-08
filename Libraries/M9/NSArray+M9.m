//
//  NSArray+.m
//  iM9
//
//  Created by MingLQ on 2011-08-04.
//  Copyright 2011 SOHU. All rights reserved.
//

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import "NSArray+M9.h"

@implementation NSArray (Shortcuts)

- (id)objectOrNilAtIndex:(NSUInteger)index {
    return [self containsIndex:index] ? [self objectAtIndex:index] : nil;
}

- (BOOL)containsIndex:(NSUInteger)index {
    return index < [self count];
}

@end

#pragma mark -

@implementation NSMutableArray (Shortcuts)

- (void)addObjectOrNil:(id)anObject {
    if (anObject) {
        [self addObject:anObject];
    }
}

- (BOOL)insertObjectOrNil:(id)anObject atIndex:(NSUInteger)index {
    if (anObject && index <= [self count]) {
        [self insertObject:anObject atIndex:index];
        return YES;
    }
    return NO;
}

- (BOOL)replaceObjectAtIndex:(NSUInteger)index withObjectOrNil:(id)anObject {
    if (anObject && index < [self count]) {
        [self replaceObjectAtIndex:index withObject:anObject];
        return YES;
    }
    return NO;
}

@end

