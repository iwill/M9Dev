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
    NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionary];
    for (NSString *keyValue in [self.query componentsSeparatedByString:@"&"]) {
        NSRange range = NSSafeRangeOfLength([keyValue rangeOfString:@"="], keyValue.length);
        NSString *key = [[keyValue substringToIndex:range.location] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *value = [[keyValue substringFromIndex:MIN(range.location + 1, keyValue.length)] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [queryDictionary setObjectOrNil:value OR @"" forKey:key];
    }
    return queryDictionary;
}

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters {
    NSMutableString *queryString = nil;
    for (__strong id key in [parameters allKeys]) {
        key = [[key description] URLEncode];
        id value = [[parameters stringForKey:key] URLEncode];
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
