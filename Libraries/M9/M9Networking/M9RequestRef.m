//
//  M9RequestRef.m
//  M9Dev
//
//  Created by iwill on 2014-07-06.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#if ! __has_feature(objc_arc)
// Add -fobjc-arc or remove -fno-objc-arc: Target > Build Phases > Compile Sources > implementation.m
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import "M9RequestRef.h"
#import "M9RequestRef+Private.h"

#import "NSObject+AssociatedValues.h"

@implementation M9RequestRef {
    NSInteger _requestID;
    __weak id _sender;
    id _userInfo;
}

@dynamic sender, userInfo;

+ (instancetype)requestRefWithSender:(id)sender userInfo:(id)userInfo {
    return [[self alloc] initWithSender:sender userInfo:userInfo];
}

- (instancetype)initWithSender:(id)sender userInfo:(id)userInfo {
    self = [super init];
    if (self) {
        @synchronized([self class]) {
            static NSInteger M9RequestID = 1;
            _requestID = M9RequestID++;
            _sender = sender;
            _userInfo = userInfo;
        }
    }
    return self;
}

- (NSUInteger)hash {
    return self.requestID;
}

- (BOOL)isEqual:(id)object {
    return ([object isMemberOfClass:[self class]]
            && ((M9RequestRef *)object).requestID == self.requestID);
}

- (id)sender {
    return _sender;
}

- (id)userInfo {
    return _userInfo;
}

- (BOOL)isCancelled { @synchronized(self) { // lock: requestRef.isCancelled && requestRef.currentRequestOperation
    return _isCancelled;
}}

- (void)cancel { @synchronized(self) { // lock: requestRef.isCancelled && requestRef.currentRequestOperation
    self.isCancelled = YES;
    [self.currentRequestOperation cancel];
}}

@end

#pragma mark -

@implementation NSObject (M9RequestSender)

static void *const M9RequestSender_allRequestRef = (void *)&M9RequestSender_allRequestRef;

- (void)addRequestRef:(M9RequestRef *)requestRef { @synchronized(self) { // lock: sender.allRequestRefOfSender
    if (!requestRef) {
        return;
    }
    NSMutableArray *allRequestRef = [self allRequestRef];
    if (!allRequestRef) {
        allRequestRef = [NSMutableArray array];
        [self associateValue:allRequestRef withKey:M9RequestSender_allRequestRef];
    }
    [allRequestRef addObject:requestRef];
}}

- (void)removeRequestRef:(M9RequestRef *)requestRef { @synchronized(requestRef) { // lock: sender.allRequestRefOfSender
    if (!requestRef) {
        return;
    }
    NSMutableArray *allRequestRef = [self allRequestRef];
    [allRequestRef removeObject:requestRef];
    if (![allRequestRef count]) {
        [self associateValue:nil withKey:M9RequestSender_allRequestRef];
    }
}}

- (NSMutableArray *)allRequestRef { @synchronized(self) { // lock: sender.allRequestRefOfSender
    return [self associatedValueForKey:M9RequestSender_allRequestRef class:[NSMutableArray class]];
}}

@end
