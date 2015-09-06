//
//  M9JSONAdapter.m
//  BBSFramework
//
//  Created by MingLQ on 2015-09-02.
//  Copyright (c) 2013 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "M9JSONAdapter.h"

@implementation M9JSONAdapter

#pragma mark - primitive type

+ (NSValueTransformer *)transformerForModelPropertiesOfObjCType:(const char *)objCType {
    if (strcmp(objCType, @encode(float)) == 0) {
        return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) *success = YES;
            if ([value isKindOfClass:[NSNumber class]]) {
                return value;
            }
            if ([value respondsToSelector:@selector(floatValue)]) {
                return @([value floatValue]);
            }
            if (success) *success = NO;
            return nil;
        }];
    }
    
    if (strcmp(objCType, @encode(double)) == 0) {
        return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) *success = YES;
            if ([value isKindOfClass:[NSNumber class]]) {
                return value;
            }
            if ([value respondsToSelector:@selector(doubleValue)]) {
                return @([value doubleValue]);
            }
            if (success) *success = NO;
            return nil;
        }];
    }
    
    if (strcmp(objCType, @encode(long long)) == 0) {
        return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) *success = YES;
            if ([value isKindOfClass:[NSNumber class]]) {
                return value;
            }
            if ([value respondsToSelector:@selector(longLongValue)]) {
                return @([value longLongValue]);
            }
            if (success) *success = NO;
            return nil;
        }];
    }
    
    if (strcmp(objCType, @encode(BOOL)) == 0) {
        return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) *success = YES;
            if ([value isKindOfClass:[NSNumber class]]) {
                return value;
            }
            if ([value respondsToSelector:@selector(boolValue)]) {
                return @([value boolValue]);
            }
            if (success) *success = NO;
            return nil;
        }];
    }
    
    if (strcmp(objCType, @encode(NSInteger)) == 0) {
        return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) *success = YES;
            if ([value isKindOfClass:[NSNumber class]]) {
                return value;
            }
            if ([value respondsToSelector:@selector(integerValue)]) {
                return @([value integerValue]);
            }
            if (success) *success = NO;
            return nil;
        }];
    }
    
    return nil;
}

#pragma mark - class

+ (NSValueTransformer *)NSStringJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if (success) *success = YES;
        if (!value || [value isKindOfClass:[NSString class]]) {
            return value;
        }
        if ([value isEqual:[NSNull null]]) {
            return nil;
        }
        if ([value isKindOfClass:[NSNumber class]]) {
            return [value description];
        }
        return nil;
    }];
}

+ (NSValueTransformer *)NSNumberJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if (success) *success = YES;
        if (!value || [value isKindOfClass:[NSNumber class]]) {
            return value;
        }
        if ([value isKindOfClass:[NSString class]]) {
            NSString *string = (NSString *)value;
            if ([string rangeOfString:@"."].length) {
                return @([string doubleValue]);
            }
            else {
                return @([string integerValue]);
            }
        }
        return nil;
    }];
}

@end
