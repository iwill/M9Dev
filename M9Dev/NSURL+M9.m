//
//  NSURL+M9Categories.m
//  M9Dev
//
//  Created by MingLQ on 2015-06-23.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "NSURL+M9.h"

@implementation NSURL (M9Categories)

- (NSDictionary *)queryDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSString *keyValue in [self.query componentsSeparatedByString:@"&"]) {
        NSRange range = NSSafeRangeOfLength([keyValue rangeOfString:@"="], keyValue.length);
        NSString *key = [[keyValue substringToIndex:range.location] stringByRemovingPercentEncoding];
        NSString *value = [[keyValue substringFromIndex:MIN(range.location + 1, keyValue.length)] stringByRemovingPercentEncoding];
        [dictionary setObjectOrNil:value OR @"" forKey:key];
    }
    return [dictionary copy];
}

+ (NSString *)queryStringFromDictionary:(NSDictionary *)dictionary {
    NSMutableString *queryString = nil;
    for (__strong id key in [dictionary allKeys]) {
        key = [[key description] URLEncode];
        id value = [[dictionary stringForKey:key] URLEncode];
        NSString *keyValue = [NSString stringWithFormat:@"%@=%@", key, value OR @""];
        if (!queryString) {
            queryString = [keyValue mutableCopy];
        }
        else {
            [queryString appendFormat:@"&%@", keyValue];
        }
    }
    return queryString;
}

@end
