//
//  AFNResponseInfo.h
//  M9Dev
//
//  Created by MingLQ on 2014-07-09.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "M9ResponseInfo.h"

@class AFHTTPRequestOperation, M9RequestRef;

@interface AFNResponseInfo : NSObject <M9ResponseInfo>

+ (instancetype)responseInfoWithRequestOperation:(AFHTTPRequestOperation *)operation requestRef:(M9RequestRef *)requestRef;
- (instancetype)initWithRequestOperation:(AFHTTPRequestOperation *)operation requestRef:(M9RequestRef *)requestRef;

@end
