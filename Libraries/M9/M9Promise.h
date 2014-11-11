//
//  M9Promise.h
//  M9Dev
//
//  Created by MingLQ on 2014-11-10.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

/* TODO: Thenable?
@protocol M9Thenable <NSObject>

@property(nonatomic, copy, readonly) id<M9Thenable> (^then)(id (^fulfillCallback)(id value), id (^rejectCallback)(id value));

@end */

/**
 * M9Promise
 *  a simple implementation Promises/A+ with Objective-C
 *
 * @see
 *  Promises/A+
 *  https://promisesaplus.com/
 *  http://www.ituring.com.cn/article/66566
 *  PromiseJS Implementing
 *  https://www.promisejs.org/
 *  https://www.promisejs.org/implementing/
 *  https://github.com/then/promise/
 */
@class M9Promise;

typedef void (^M9PromiseCall)(id value);
typedef void (^M9PromiseTask)(M9PromiseCall fulfill, M9PromiseCall reject);

/**
 * M9PromiseCallback
 *  callback type for fulfill/reject
 *
 * @param id value
 *  value/reason to fulfill/reject the current-promise
 *
 * @return
 *  nil if nothing to do,
 *  a value/reason to fulfill/reject the next promise from then,
 *  or a new promise before the next-promise in the chain
 */
typedef id (^M9PromiseCallback)(id value);
typedef M9Promise *(^M9PromiseThen)(M9PromiseCallback fulfillCallback, M9PromiseCallback rejectCallback);
typedef M9Promise *(^M9PromiseDone)(M9PromiseCallback fulfillCallback);
typedef M9Promise *(^M9PromiseCatch)(M9PromiseCallback rejectCallback);

typedef NS_ENUM(NSInteger, M9PromiseState) {
    M9PromiseStatePending = 0,
    M9PromiseStateFulfilled,
    M9PromiseStateRejected
};

#define M9PromiseError @"M9PromiseError"
typedef NS_ENUM(NSInteger, M9PromiseErrorCode) {
    M9PromiseErrorCode_TypeError
};

#pragma mark -

@interface M9Promise : NSObject

@property(nonatomic) M9PromiseState state;

+ (instancetype)promise:(M9PromiseTask)task;

@property(nonatomic, copy, readonly) M9PromiseThen then/* (M9PromiseCallback fulfillCallback, M9PromiseCallback rejectCallback) */;
@property(nonatomic, copy, readonly) M9PromiseDone done/* (M9PromiseCallback fulfillCallback) */;
@property(nonatomic, copy, readonly) M9PromiseCatch catch/* (M9PromiseCallback rejectCallback) */;

// ???: M9Promise or M9PromiseTask
+ (instancetype)all:(id)task, ...;
+ (instancetype)any:(id)task, ...;

@end

#pragma mark -

#define _then(done, catch)   done:done catch:catch

@interface M9Promise (ObjC)

- (instancetype)done:(M9PromiseCallback)done catch:(M9PromiseCallback)catch;

@end

