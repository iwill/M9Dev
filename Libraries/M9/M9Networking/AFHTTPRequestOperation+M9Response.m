//
//  AFHTTPRequestOperation+M9Response.m
//  M9Dev
//
//  Created by iwill on 2014-07-06.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "AFHTTPRequestOperation+M9Response.h"

@implementation AFHTTPRequestOperation (M9Response)

+ (void)load {
    NSAssert([self instancesRespondToSelector:@selector(request)],
             @"AFHTTPRequestOperation doesNotRecognizeSelector:request");
    NSAssert([self instancesRespondToSelector:@selector(response)],
             @"AFHTTPRequestOperation doesNotRecognizeSelector:response");
    NSAssert([self instancesRespondToSelector:@selector(responseData)],
             @"AFHTTPRequestOperation doesNotRecognizeSelector:responseData");
    NSAssert([self instancesRespondToSelector:@selector(responseString)],
             @"AFHTTPRequestOperation doesNotRecognizeSelector:responseString");
    NSAssert([self instancesRespondToSelector:@selector(responseObject)],
             @"AFHTTPRequestOperation doesNotRecognizeSelector:responseObject");
    NSAssert([self instancesRespondToSelector:@selector(error)],
             @"AFHTTPRequestOperation doesNotRecognizeSelector:error");
}

@end
