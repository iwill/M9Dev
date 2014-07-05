//
//  NSObject+AssociatedValues.m
//  ProgressedAnimation
//
//  Created by MingLQ on 2014-02-21.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "NSObject+AssociatedValues.h"

@implementation NSObject (AssociatedValues)

- (float)associatedFloatForKey:(const void *)key {
    id value = [self associatedValueForKey:key];
    if ([value respondsToSelector:@selector(floatValue)]) {
        return [value floatValue];
    }
    return 0;
}

- (void)associateFloat:(float)value withKey:(const void *)key {
    [self associateValue:value == 0.0 ? nil : @(value) withKey:key];
}

- (double)associatedDoubleForKey:(const void *)key {
    id value = [self associatedValueForKey:key];
    if ([value respondsToSelector:@selector(doubleValue)]) {
        return [value doubleValue];
    }
    return 0;
}

- (void)associateDouble:(double)value withKey:(const void *)key {
    [self associateValue:value == 0.0 ? nil : @(value) withKey:key];
}

- (long long)associatedLongLongForKey:(const void *)key {
    id value = [self associatedValueForKey:key];
    if ([value respondsToSelector:@selector(longLongValue)]) {
        return [value longLongValue];
    }
    return !!value;
}

- (void)associateLongLong:(long long)value withKey:(const void *)key {
    [self associateValue:value ? @(value) : nil withKey:key];
}

- (unsigned long long)associatedUnsignedLongLongForKey:(const void *)key {
    id value = [self associatedValueForKey:key];
    if ([value respondsToSelector:@selector(unsignedLongLongValue)]) {
        return [value unsignedLongLongValue];
    }
    return !!value;
}

- (void)associateUnsignedLongLong:(unsigned long long)value withKey:(const void *)key {
    [self associateValue:value ? @(value) : nil withKey:key];
}

- (BOOL)associatedBOOLForKey:(const void *)key {
    id value = [self associatedValueForKey:key];
    if ([value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return !!value;
}

- (void)associateBOOL:(BOOL)value withKey:(const void *)key {
    [self associateValue:value ? @(value) : nil withKey:key];
}

- (NSInteger)associatedIntegerForKey:(const void *)key {
    id value = [self associatedValueForKey:key];
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}

- (void)associateInteger:(NSInteger)value withKey:(const void *)key {
    [self associateValue:value ? nil : @(value) withKey:key];
}

- (NSUInteger)associatedUnsignedIntegerForKey:(const void *)key {
    id value = [self associatedValueForKey:key];
    if ([value respondsToSelector:@selector(unsignedIntegerValue)]) {
        return [value unsignedIntegerValue];
    }
    return 0;
}

- (void)associateUnsignedInteger:(NSUInteger)value withKey:(const void *)key {
    [self associateValue:value ? nil : @(value) withKey:key];
}

- (id)associatedValueForKey:(const void *)key class:(Class)class {
    id value = [self associatedValueForKey:key];
    if (!class || [value isKindOfClass:class]) {
        return value;
    }
    return nil;
}

@end

