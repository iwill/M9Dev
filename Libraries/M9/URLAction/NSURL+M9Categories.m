//
//  NSURL+M9Categories.m
//  M9Dev
//
//  Created by MingLQ on 2015-06-23.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import "NSURL+M9Categories.h"

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

@end
