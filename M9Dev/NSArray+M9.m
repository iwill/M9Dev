//
//  NSArray+M9.m
//  M9Dev
//
//  Created by MingLQ on 2011-08-04.
//  Copyright (c) 2011 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
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

- (BOOL)addObjectOrNil:(id)anObject {
    if (!anObject) {
        return NO;
    }
    [self addObject:anObject];
    return YES;
}

- (BOOL)insertObjectOrNil:(id)anObject atIndex:(NSUInteger)index {
    if (!anObject || index > [self count]) {
        return NO;
    }
    [self insertObject:anObject atIndex:index];
    return YES;
}

- (BOOL)removeObjectOrNilAtIndex:(NSUInteger)index {
    if (index >= [self count]) {
        return NO;
    }
    [self removeObjectAtIndex:index];
    return YES;
}

- (BOOL)replaceObjectAtIndex:(NSUInteger)index withObjectOrNil:(id)anObject {
    if (!anObject || index >= [self count]) {
        return NO;
    }
    [self replaceObjectAtIndex:index withObject:anObject];
    return YES;
}

@end

