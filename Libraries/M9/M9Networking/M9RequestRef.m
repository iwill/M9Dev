//
//  M9RequestRef.m
//  M9Dev
//
//  Created by MingLQ on 2014-07-06.
//  Copyright (c) 2014年 MingLQ <minglq.9@gmail.com>. All rights reserved.
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
    __weak id _owner;
}

@dynamic owner;

+ (instancetype)requestRefWithOwner:(id)owner {
    return [[self alloc] initWithOwner:owner];
}

- (instancetype)initWithOwner:(id)owner {
    self = [super init];
    if (self) {
        @synchronized([self class]) {
            static NSInteger M9RequestID = 1;
            _requestID = M9RequestID++;
            _owner = owner;
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

- (id)owner {
    return _owner;
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

@implementation NSObject (M9RequestOwner)

static void *const M9RequestOwner_allRequestRef = (void *)&M9RequestOwner_allRequestRef;

- (void)addRequestRef:(M9RequestRef *)requestRef { @synchronized(self) { // lock: owner.allRequestRefOfOwner
    if (!requestRef) {
        return;
    }
    NSMutableArray *allRequestRef = [self allRequestRef];
    if (!allRequestRef) {
        allRequestRef = [NSMutableArray array];
        [self associateValue:allRequestRef withKey:M9RequestOwner_allRequestRef];
    }
    [allRequestRef addObject:requestRef];
}}

- (void)removeRequestRef:(M9RequestRef *)requestRef { @synchronized(requestRef) { // lock: owner.allRequestRefOfOwner
    if (!requestRef) {
        return;
    }
    NSMutableArray *allRequestRef = [self allRequestRef];
    [allRequestRef removeObject:requestRef];
    if (![allRequestRef count]) {
        [self associateValue:nil withKey:M9RequestOwner_allRequestRef];
    }
}}

- (NSMutableArray *)allRequestRef { @synchronized(self) { // lock: owner.allRequestRefOfOwner
    return [self associatedValueForKey:M9RequestOwner_allRequestRef class:[NSMutableArray class]];
}}

@end
