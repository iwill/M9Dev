//
//  ARCWeakRef.m
//  M9Dev
//
//  Created by MingLQ on 2013-07-08.
//  Copyright (c) 2013 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

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

