//
//  UIResponder+M9.h
//  M9Dev
//
//  Created by MingLQ on 2015-09-08.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL (^M9ResponderFindingBlock)(UIResponder *responder, BOOL *stop);

@interface UIResponder (M9)

- (UIResponder *)closestResponderOfClass:(Class)clazz; // NOT include self
- (UIResponder *)closestResponderOfClass:(Class)clazz includeSelf:(BOOL)includeSelf;
- (UIResponder *)findResponderWithBlock:(M9ResponderFindingBlock)enumerateBlock;

@end
