//
//  ARCWeakRef.m
//  M9Dev
//
//  Created by MingLQ on 2013-07-08.
//  Copyright (c) 2013 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "ARCWeakRef.h"

@implementation ARCWeakRef

- (instancetype)initWithObject:(id)object {
    self = [super init];
    if (self) {
        self.object = object;
    }
    return self;
}

+ (instancetype)weakRefWithObject:(id)object {
    return [[self alloc] initWithObject:object];
}

@end

