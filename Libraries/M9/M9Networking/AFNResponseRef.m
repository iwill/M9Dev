//
//  AFNResponseRef.m
//  M9Dev
//
//  Created by iwill on 2014-07-09.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "AFNResponseRef.h"

#import "AFHTTPRequestOperation.h"
#import "M9RequestRef+Private.h"

@interface AFNResponseRef ()

@end

@implementation AFNResponseRef {
    AFHTTPRequestOperation *_operation;
    M9RequestRef *_requestRef;
}

+ (instancetype)responseRefWithRequestOperation:(AFHTTPRequestOperation *)operation requestRef:(M9RequestRef *)requestRef {
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

- (id)requestRef {
    return _requestRef;
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

@end
