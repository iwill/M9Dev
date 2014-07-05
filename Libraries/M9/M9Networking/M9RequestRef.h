//
//  M9RequestRef.h
//  M9Dev
//
//  Created by iwill on 2014-07-06.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M9RequestRef : NSObject

@property(nonatomic, readonly) NSInteger retryTimes;
@property(nonatomic, readonly) BOOL usedCache;

- (BOOL)isCancelled;
- (void)cancel;

@end
