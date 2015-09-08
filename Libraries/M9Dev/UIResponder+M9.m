//
//  UIResponder+M9.m
//  M9Dev
//
//  Created by MingLQ on 2015-09-08.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "UIResponder+M9.h"

@implementation UIResponder (M9)

- (UIResponder *)closestResponderOfClass:(Class)clazz {
    return [self closestResponderOfClass:clazz includeSelf:NO];
}

- (UIResponder *)closestResponderOfClass:(Class)clazz includeSelf:(BOOL)includeSelf {
    if (![clazz isSubclassOfClass:[UIResponder class]]) {
        return nil;
    }
    return [self findResponderWithBlock:^BOOL(UIResponder *responder, BOOL *stop) {
        return ((includeSelf || responder != self)
                && [responder isKindOfClass:clazz]);
    }];
}

- (UIResponder *)findResponderWithBlock:(M9ResponderFindingBlock)findingBlock {
    BOOL stop = NO;
    UIResponder *responder = self;
    do {
        if (findingBlock(responder, &stop)) {
            return responder;
        }
    } while (!stop && (responder = responder.nextResponder));
    return nil;
}

@end
