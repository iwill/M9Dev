//
//  AFNResponseInfo.m
//  M9Dev
//
//  Created by MingLQ on 2014-07-09.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "AFNResponseInfo.h"

#import "AFHTTPRequestOperation.h"
#import "M9RequestRef+Private.h"

@interface AFNResponseInfo ()

@end

@implementation AFNResponseInfo {
    AFHTTPRequestOperation *_operation;
    M9RequestRef *_requestRef;
}

+ (instancetype)responseInfoWithRequestOperation:(AFHTTPRequestOperation *)operation requestRef:(M9RequestRef *)requestRef {
    return [[self alloc] initWithRequestOperation:operation requestRef:requestRef];
}

- (instancetype)initWithRequestOperation:(AFHTTPRequestOperation *)operation requestRef:(M9RequestRef *)requestRef {
    self = [self init];
    if (self) {
        _operation = operation;
        _requestRef = requestRef;
    }
    return self;
}

- (NSURLRequest *)request {
    return [_operation request];
}

- (NSHTTPURLResponse *)response {
    return [_operation response];
}

- (NSData *)responseData {
    return [_operation responseData];
}

- (NSString *)responseString {
    return [_operation responseString];
}

- (id)responseObject {
    return [_operation responseObject];
}

- (NSError *)error {
    return [_operation error];
}

- (NSInteger)retriedTimes {
    return _requestRef.retriedTimes;
}

- (BOOL)usedCachedData {
    return _requestRef.usedCachedData;
}

@end
