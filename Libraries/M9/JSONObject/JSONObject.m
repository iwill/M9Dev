//
//  JSONObject.m
//  M9Dev
//
//  Created by MingLQ on 2011-08-25.
//  Copyright 2011 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#if ! __has_feature(objc_arc)
// Add -fobjc-arc or remove -fno-objc-arc: Target > Build Phases > Compile Sources > implementation.m
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import "JSONObject.h"


#pragma mark -

@interface JSONObject ()

@property(nonatomic, readwrite, retain) NSMutableDictionary *JSONDictionary;

@end

@implementation JSONObject

- (id)init {
    return [self initWithJSONDictionary:nil];
}

- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary {
    self = [super init];
    if (self) {
        /* !!!: both [jsonDictionary isKindOfClass:[NSMutableDictionary class]]
         *  & [jsonDictionary respondsToSelector:@selector(setObject:forKey:)] does not work
         */
        if (!jsonDictionary) {
            self.JSONDictionary = [NSMutableDictionary dictionary];
        }
        else {
            self.JSONDictionary = [jsonDictionary mutableCopy];
        }
    }
    return self;
}

- (void)updateWithJSONDictionary:(NSDictionary *)jsonDictionary {
    [self.JSONDictionary addEntriesFromDictionary:jsonDictionary];
}

- (NSMutableDictionary *)toJSONDictionary {
    return self.JSONDictionary;
}

- (void)dealloc {
    self.JSONDictionary = nil;
}

+ (instancetype)instanceWithJSONDictionary:(NSDictionary *)jsonDictionary {
    return [[self alloc] initWithJSONDictionary:jsonDictionary];
}

+ (NSMutableArray *)instancesWithJSONArray:(NSArray *)jsonArray {
    NSMutableArray *resultArray = [NSMutableArray array];
    for (id jsonObject in jsonArray) {
        if (![jsonObject isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        id object = [self instanceWithJSONDictionary:(NSDictionary *)jsonObject];
        [resultArray addObjectOrNil:object];
    }
    return resultArray;
}

@end

#pragma mark -

@implementation NSObject (NonJSONObject)

- (BOOL)isNonJSONObject {
    if (self == [NSNull null]) {
        return YES;
    }
    
    if ([self isKindOfClass:NSData.class]
        || [self isKindOfClass:NSDate.class]
        || [self isKindOfClass:NSNumber.class]
        || [self isKindOfClass:NSString.class]) {
        return NO;
    }
    
    if ([self isKindOfClass:NSArray.class]) {
        return [(NSArray *)self hasNonJSONObject];
    }
    
    if ([self isKindOfClass:NSDictionary.class]) {
        return [(NSDictionary *)self hasNonJSONObject];
    }
    
    return YES;
}

@end

@implementation NSArray (NonJSONObject)

- (BOOL)hasNonJSONObject {
    for (id object in self) {
        if ([object isNonJSONObject]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)nonJSONObjects {
    NSMutableArray *nonJSONObjects = [NSMutableArray array];
    for (id object in self) {
        if ([object isNonJSONObject]) {
            [nonJSONObjects addObject:object];
        }
    }
    return [nonJSONObjects count] ? nonJSONObjects : nil;
}

- (NSArray *)arrayByRemovingNonJSONObjects {
    NSMutableArray *arrayWithJSONObjects = [self mutableCopy];
    [arrayWithJSONObjects removeNonJSONObjects];
    return arrayWithJSONObjects;
}

@end

@implementation NSMutableArray (NonJSONObject)

- (void)removeNonJSONObjects {
    for (id object in [self nonJSONObjects]) {
        [self removeObject:object];
    }
}

@end

@implementation NSDictionary (NonJSONObject)

- (BOOL)hasNonJSONObject {
    for (id key in [self allKeys]) {
        if ([key isNonJSONObject]
            || [[self objectForKey:key] isNonJSONObject]) {
            return YES;
        }
    }
    return NO;
}

- (NSDictionary *)nonJSONObjects {
    NSMutableArray *nonJSONObjectKeys = [NSMutableArray array];
    for (id key in [self allKeys]) {
        if ([key isNonJSONObject]
            || [[self objectForKey:key] isNonJSONObject]) {
            [nonJSONObjectKeys addObject:key];
        }
    }
    return [self dictionaryWithValuesForKeys:nonJSONObjectKeys];
}

- (NSDictionary *)dictionaryByRemovingNonJSONObjects {
    NSMutableDictionary *dictionaryWithJSONObjects = [self mutableCopy];
    [dictionaryWithJSONObjects removeNonJSONObjects];
    return dictionaryWithJSONObjects;
}

@end

@implementation NSMutableDictionary (NonJSONObject)

- (void)removeNonJSONObjects {
    [self removeObjectsForKeys:[[self nonJSONObjects] allKeys]];
}

@end

