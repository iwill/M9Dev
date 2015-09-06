//
//  M9URLAction+1.0.m
//  M9Dev
//
//  Created by MingLQ on 2015-06-24.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "M9URLAction+1.0.h"

@implementation M9URLAction (_1_0)

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
                        @"share":   [queryDictionary stringForKey:@"share"] OR @"",
                        @"params":  [sourceDataDictionary stringForKey:@"params"] OR @"" };
    }
    else if ([action isEqualToString:@"1.25"]) {
        host = @"columns.open";
        parameters = @{ @"cate_code":   [queryDictionary stringForKey:@"cateCode"] OR @"",
                        @"channel_id":  [queryDictionary stringForKey:@"channel_id"] OR [queryDictionary stringForKey:@"ex3"] OR @"",
                        @"tag_id":      [queryDictionary stringForKey:@"tag_id"] OR @"",
                        @"channeled":   [queryDictionary stringForKey:@"channeled"] OR @"",
                        @"title":       [queryDictionary stringForKey:@"ex2"] OR @"",
                        @"can_add":     [queryDictionary stringForKey:@"can_add"] OR @"" };
    }
    else if ([action isEqualToString:@"2.4"]) {
        host = @"channel.goto";
        parameters = @{ @"channel_list_type":   [queryDictionary stringForKey:@"channel_list_type"] OR @"",
                        @"cid":                 [queryDictionary stringForKey:@"cid"] OR @"",
                        @"cate_code":           [queryDictionary stringForKey:@"cateCode"] OR @"",
                        @"channel_id":          [queryDictionary stringForKey:@"channel_id"] OR @"",
                        @"subchannel_id":       [queryDictionary stringForKey:@"ex3"] OR @"",
                        @"column_id":           [queryDictionary stringForKey:@"ex2"] OR @"" };
    }
    
    if (!host.length) {
        return nil;
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
