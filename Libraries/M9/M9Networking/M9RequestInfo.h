//
//  M9RequestInfo.h
//  M9Dev
//
//  Created by MingLQ on 2014-07-16.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9RequestConfig.h"

@interface M9RequestInfo : M9RequestConfig

@property(nonatomic, strong) NSString *URLString;
@property(nonatomic, strong) NSDictionary *parameters;
@property(nonatomic, copy) void (^success)(id<M9ResponseRef> responseRef, id responseObject);
@property(nonatomic, copy) void (^failure)(id<M9ResponseRef> responseRef, NSError *error);

@property(nonatomic, weak) id sender; // for cancel all requests by sender
@property(nonatomic, strong) id userInfo;

@end
