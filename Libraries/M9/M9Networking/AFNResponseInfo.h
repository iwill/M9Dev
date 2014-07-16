//
//  AFNResponseRef.h
//  M9Dev
//
//  Created by iwill on 2014-07-09.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "M9ResponseRef.h"

@class AFHTTPRequestOperation, M9RequestRef;

@interface AFNResponseRef : NSObject <M9ResponseRef>

+ (instancetype)responseRefWithRequestOperation:(AFHTTPRequestOperation *)operation requestRef:(M9RequestRef *)requestRef;
- (instancetype)initWithRequestOperation:(AFHTTPRequestOperation *)operation requestRef:(M9RequestRef *)requestRef;

@end
