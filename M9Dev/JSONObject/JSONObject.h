//
//  JSONObject.h
//  M9Dev
//
//  Created by MingLQ on 2011-08-25.
//  Copyright (c) 2011 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <Foundation/Foundation.h>

#import "NSArray+M9.h"
#import "NSDictionary+M9.h"


#pragma mark - JSONObject protocol

@protocol JSONObject <NSObject>

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary;
- (void)updateWithJSONDictionary:(NSDictionary *)jsonDictionary;
- (NSMutableDictionary *)toJSONDictionary;

+ (instancetype)instanceWithJSONDictionary:(NSDictionary *)jsonDictionary;
+ (NSMutableArray *)instancesWithJSONArray:(NSArray *)jsonArray;

@end

#pragma mark - JSONObject class

/**
 * JSONObject - Manage properties by NSMutableDictionary, and conforms to JSONObject protocol
 *
 *  1. Declare readwrite JSONDictionary in the anonymous Category:
 *      @property(nonatomic, readwrite, retain) NSMutableDictionary *JSONDictionary;
 *
 *  2. Create observers in the in the init method:
 *      if (!jsonDictionary) {
 *          self.JSONDictionary = [NSMutableDictionary dictionary];
 *      }
 *      else {
 *          self.JSONDictionary = [[jsonDictionary mutableCopy] autorelease];
 *      }
 *  and destroy it in the dealloc method:
 *      self.JSONDictionary = nil;
 *
 *  3. Declare @property-s in @interface:
 *      @property(nonatomic, readwrite, retain) NSString *property;
 *
 *  4. @dynamic them in @implementation:
 *      @dynamic property;
 *
 *  5. Write getter/setter methods yourself:
 *      - (NSString *)property {
 *          return [self.JSONDictionary stringForKey:@"property"];
 *      }
 *      - (void)setProperty:(NSString *)property {
 *          [self.JSONDictionary setObjectOrNil:property];
 *      }
 */
@interface JSONObject : NSObject <JSONObject>

@property(nonatomic, readonly, retain) NSMutableDictionary *JSONDictionary;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary NS_DESIGNATED_INITIALIZER;

@end

#pragma mark - NON JSONObject

// TODO: @see NSJSONSerialization + isValidJSONObject:

@interface NSObject (NonJSONObject)

// !!!: return YES for NSNull
- (BOOL)isNonJSONObject;

@end

@interface NSArray (NonJSONObject)

- (BOOL)hasNonJSONObject;
- (NSArray *)nonJSONObjects;
- (NSArray *)arrayByRemovingNonJSONObjects;

@end

@interface NSMutableArray (NonJSONObject)

- (void)removeNonJSONObjects;

@end

@interface NSDictionary (NonJSONObject)

- (BOOL)hasNonJSONObject;
- (NSDictionary *)nonJSONObjects;
- (NSDictionary *)dictionaryByRemovingNonJSONObjects;

@end

@interface NSMutableDictionary (NonJSONObject)

- (void)removeNonJSONObjects;

@end

