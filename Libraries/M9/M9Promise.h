//
//  M9Promise.h
//  M9Dev
//
//  Created by MingLQ on 2014-11-10.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

@class M9Promise;

typedef void (^Fulfill)(id value);
typedef void (^Reject)(id reason);
typedef void (^Task)(Fulfill fulfill, Reject reject);

typedef M9Promise *(^Then)(Fulfill onFulfilled, Reject onRejected);
typedef M9Promise *(^Done)(Fulfill onFulfilled);
typedef M9Promise *(^Catch)(Reject onRejected);

@interface M9Promise : NSObject

+ (instancetype)promise:(Task)task;
+ (instancetype)all:(Task)task, ...;
+ (instancetype)any:(Task)task, ...;

@property(nonatomic, copy, readonly) Then then/* (Fulfill onFulfilled, Reject onRejected) */;
@property(nonatomic, copy, readonly) Done done/* (Fulfill onFulfilled) */;
@property(nonatomic, copy, readonly) Catch catch/* (Reject onRejected) */;

@property(nonatomic, copy, readonly) Fulfill fulfill;
@property(nonatomic, copy, readonly) Reject reject;

@end

#pragma mark -

#define _then(done, catch)   done:done catch:catch

@interface M9Promise (ObjC)

- (instancetype)done:(Fulfill)done catch:(Reject)catch;

@end

