//
//  NSString+JSONObject.m
//  iPhoneVideo
//
//  Created by MingLQ on 2011-08-25.
//  Copyright 2011 SOHU. All rights reserved.
//

#if ! __has_feature(objc_arc)
// Add -fobjc-arc or remove -fno-objc-arc: Target > Build Phases > Compile Sources > implementation.m
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import "NSString+JSONObject.h"

#import "JSONObject.h"

@implementation NSObject (JSONObject)

- (id)JSONObject {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        return self;
    }
    return nil;
}

@end

@implementation NSString (JSONObject)

/* implemented by NSJSONSerialization */
- (id)JSONObject {
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}

- (id)JSONObjectWithMutableContainers {
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
}

- (NSArray *)JSONArray {
    /* NSString *jsonString = [self trimmedString];
    if (![jsonString hasPrefix:@"["] && ![jsonString hasSuffix:@"]"]) {
        return nil;
    }
    id json = [jsonString JSONObject]; */
    
    id json = [self JSONObject];
    return [json isKindOfClass:[NSArray class]] ? (NSArray *)json : nil;
}

- (NSMutableArray *)JSONArrayWithMutableContainers {
    id json = [self JSONObjectWithMutableContainers];
    return [json isKindOfClass:[NSArray class]] ? (NSMutableArray *)json : nil;
}

- (NSDictionary *)JSONDictionary {
    /* NSString *jsonString = [self trimmedString];
    if (![jsonString hasPrefix:@"{"] && ![jsonString hasSuffix:@"}"]) {
        return nil;
    }
    id json = [jsonString JSONObject]; */
    
    id json = [self JSONObject];
    return [json isKindOfClass:[NSDictionary class]] ? (NSDictionary *)json : nil;
}

- (NSMutableDictionary *)JSONDictionaryWithMutableContainers {
    id json = [self JSONObjectWithMutableContainers];
    return [json isKindOfClass:[NSMutableDictionary class]] ? (NSMutableDictionary *)json : nil;
}

#pragma mark private

// no assertion
- (id<JSONObject>)_JSONObjectWithClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)jsonDictionary {
    return [[modelClass alloc] initWithJSONDictionary:jsonDictionary];
}

#pragma mark public

- (id<JSONObject>)JSONObjectWithClass:(Class)modelClass {
    NSAssert([modelClass conformsToProtocol:@protocol(JSONObject)], @"Invalid model class: does not conforms to protocol <JSONObject>!");
    
    NSDictionary *jsonDictionary = [self JSONDictionary];
    return jsonDictionary ? [self _JSONObjectWithClass:modelClass fromJSONDictionary:jsonDictionary] : nil;
}

- (NSArray *)arrayOfJSONObjectsWithClass:(Class)modelClass {
    NSAssert([modelClass conformsToProtocol:@protocol(JSONObject)], @"Invalid model class: does not conforms to protocol <JSONObject>!");
    
    NSArray *jsonArray = [self JSONArray];
    if (!jsonArray) {
        return nil;
    }
    NSMutableArray *objects = [NSMutableArray array];
    for (id json in jsonArray) {
        if (![json isKindOfClass:NSDictionary.class]) {
            continue;
        }
        [objects addObject:[self _JSONObjectWithClass:modelClass fromJSONDictionary:(NSDictionary *)json]];
    }
    return objects;
}

#pragma mark - stringify

+ (NSString *)stringWithJSONObject:(id)object {
    NSData *data = [self dataWithJSONObject:object];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

+ (NSData *)dataWithJSONObject:(id)object {
    return object ? [NSJSONSerialization dataWithJSONObject:object options:0 error:nil] : nil;
}

@end

