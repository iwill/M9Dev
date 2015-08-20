//
//  M9RequestRef.h
//  M9Dev
//
//  Created by MingLQ on 2014-07-06.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M9RequestRef : NSObject

// @property(nonatomic, readonly, strong) M9RequestInfo *requestInfo;
// @property(nonatomic, readonly, strong) id<M9ResponseInfo> responseInfo;

@property(nonatomic, readonly) NSInteger requestID;
@property(nonatomic, readonly, weak) id owner;

// @property(nonatomic, readonly) NSTimeInterval loadingDuration;

- (BOOL)isCancelled;
- (void)cancel;

@end
