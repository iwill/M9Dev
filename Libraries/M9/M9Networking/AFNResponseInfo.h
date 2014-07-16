//
//  AFNResponseInfo.h
//  M9Dev
//
//  Created by iwill on 2014-07-09.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "M9ResponseInfo.h"

@class AFHTTPRequestOperation, M9RequestRef;

@interface AFNResponseInfo : NSObject <M9ResponseInfo>

+ (instancetype)responseInfoWithRequestOperation:(AFHTTPRequestOperation *)operation requestRef:(M9RequestRef *)requestRef;
- (instancetype)initWithRequestOperation:(AFHTTPRequestOperation *)operation requestRef:(M9RequestRef *)requestRef;

@end
