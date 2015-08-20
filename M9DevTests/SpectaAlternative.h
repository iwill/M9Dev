//
//  SpectaAlternative.h
//  M9Dev
//
//  Created by MingLQ on 2014-12-11.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DoneCallback)(void);
void _waitForSeconds(NSTimeInterval seconds);
void _waitFor(void (^block)(DoneCallback done), NSTimeInterval timeout);
void _waitUntil(void (^block)(DoneCallback done));

void _describe(NSString *name, void (^block)());
void _it(NSString *name, void (^block)());

typedef void (^StateCallback)(NSInteger state);
typedef void (^ValidateCallback)(NSInteger got);
void _itWill(NSString *name, void (^block)(StateCallback doneWithState), ValidateCallback validate);
