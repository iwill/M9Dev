//
//  M9RequestRef.h
//  M9Dev
//
//  Created by iwill on 2014-07-06.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M9RequestRef : NSObject

@property(nonatomic, readonly) NSInteger requestID;
@property(nonatomic, readonly, weak) id sender;

@property(nonatomic, readonly) NSInteger retriedTimes;
@property(nonatomic, readonly) BOOL usedCachedData;
// @property(nonatomic, readonly) NSTimeInterval loadingDuration;

- (BOOL)isCancelled;
- (void)cancel;

@end
