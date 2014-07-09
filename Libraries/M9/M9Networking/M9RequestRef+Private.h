//
//  M9RequestRef+Private.h
//  M9Dev
//
//  Created by iwill on 2014-07-06.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "M9RequestRef.h"

@interface M9RequestRef ()

// public readonly?
@property(nonatomic, readwrite) NSInteger requestID;
@property(nonatomic, readonly, weak) id sender;

@property(nonatomic, readwrite) NSInteger retriedTimes;
@property(nonatomic, readwrite) BOOL usedCachedData;
@property(nonatomic, readwrite) NSOperation *currentRequestOperation;

@property(nonatomic, readwrite, setter = setCancelled:) BOOL isCancelled;

- (instancetype)initWithSender:(id)sender;
+ (instancetype)requestRefWithSender:(id)sender;

- (void)cancel;

@end

#pragma mark -

@interface NSObject (M9RequestSender) /* <M9RequestSender> */

- (void)addRequestRef:(M9RequestRef *)requestRef;
- (void)removeRequestRef:(M9RequestRef *)requestRef;
- (NSMutableArray *)allRequestRef;

@end
