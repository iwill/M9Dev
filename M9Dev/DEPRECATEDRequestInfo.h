//
//  DEPRECATEDRequestInfo.h
//  M9Dev
//
//  Created by MingLQ on 2014-07-16.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9RequestInfo.h"

#import "EXTScope.h"

@interface DEPRECATEDRequestInfo : M9RequestInfo

@property(nonatomic, weak) id delegate; // the sender
@property(nonatomic) SEL successSelector, failureSelector;

@end
