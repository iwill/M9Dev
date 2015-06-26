//
//  URLAction+1.0.m
//  M9Dev
//
//  Created by MingLQ on 2015-06-24.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import "URLAction+1.0.h"

@implementation URLAction (_1_0)

+ (NSURL *)actionURLFrom_1_0:(NSString *)actionURLString {
    NSURL *actionURL = [self actionURLFromString:actionURLString];
    NSDictionary *queryDictionary = [actionURL queryDictionary];
    NSDictionary *moreDictionary = [[queryDictionary stringForKey:@"more"] JSONDictionary];
    NSDictionary *sourceDataDictionary = [moreDictionary dictionaryForKey:@"sourcedata"];
    
    NSString *host = nil;
    NSDictionary *parameters = nil;
    
    NSString *action = [queryDictionary stringForKey:@"action"];
    if ([action isEqualToString:@"1.18"]) {
        host = @"webview.open";
        parameters = @{ @"url":     [queryDictionary stringForKey:@"urls"] OR @"",
                        @"params":  [sourceDataDictionary stringForKey:@"params"] OR @"" };
    }
    else if ([action isEqualToString:@"2.4"]) {
        host = @"channel.goto";
        parameters = @{ @"cid":             [queryDictionary stringForKey:@"cid"] OR @"",
                        @"cateCode":        [queryDictionary stringForKey:@"cateCode"] OR @"",
                        @"columnID":        [queryDictionary stringForKey:@"ex2"] OR @"",
                        @"subChannelID":    [queryDictionary stringForKey:@"ex3"] OR @"",
                        @"channelListType": [queryDictionary stringForKey:@"channel_list_type"] OR @"",
                        @"channelID":       [queryDictionary stringForKey:@"channel_id"] OR @"" };
    }
    
    NSString *scheme = @"sva";
    NSString *query = [NSURL queryStringFromParameters:parameters];
    NSString *fragment = nil;
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@?%@#%@",
                                 scheme,
                                 host OR @"",
                                 query OR @"",
                                 fragment OR @""]];
    
}

+ (NSURL *)actionURLFromString:(NSString *)actionURLString {
    NSString *scheme = @"sva", *host = nil, *query = nil, *fragment = nil;
    
    // !!!: 查找 // 而不是 :// - 因为 sohuvideo://sva://xxxx 转成 NSURL 之后会变成 sohuvideo://sva//xxxx
    NSRange range = [actionURLString rangeOfString:@"//" options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        // 兼容 sva:xxxx
        range = [actionURLString rangeOfString:@":"];
    }
    if (range.location != NSNotFound) {
        actionURLString = [actionURLString substringFromIndex:range.location + range.length];
    }
    
    range = NSSafeRangeOfLength([actionURLString rangeOfString:@"?"], actionURLString.length);
    host = [actionURLString substringToIndex:range.location];
    actionURLString = [actionURLString substringFromIndex:range.location + range.length];
    
    range = NSSafeRangeOfLength([actionURLString rangeOfString:@"#"], actionURLString.length);
    query = [actionURLString substringToIndex:range.location];
    actionURLString = [actionURLString substringFromIndex:range.location + range.length];
    
    fragment = actionURLString;
    actionURLString = nil;
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@?%@#%@",
                                 scheme,
                                 host OR @"",
                                 query OR @"",
                                 fragment OR @""]];
}

@end
