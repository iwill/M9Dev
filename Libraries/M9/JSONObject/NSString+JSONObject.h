//
//  NSString+JSONObject.h
//  M9Dev
//
//  Created by MingLQ on 2011-08-25.
//  Copyright 2011 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONObject;

@interface NSObject (JSONObject)

- (id)JSONObject;

@end

@interface NSString (JSONObject)

- (id)JSONObject;
- (id)JSONObjectWithMutableContainers;
- (NSArray *)JSONArray;
- (NSMutableArray *)JSONArrayWithMutableContainers;
- (NSDictionary *)JSONDictionary;
- (NSMutableDictionary *)JSONDictionaryWithMutableContainers;

// modelClass MUST conforms to protocol JSONObject
- (NSArray *)arrayOfJSONObjectsWithClass:(Class)modelClass;
// modelClass MUST conforms to protocol JSONObject
- (id<JSONObject>)JSONObjectWithClass:(Class)modelClass;

// stringify
+ (NSData *)dataWithJSONObject:(id)object;
+ (NSString *)stringWithJSONObject:(id)object;

@end

