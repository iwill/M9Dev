//
//  SpectaAlternative.h
//  M9Dev
//
//  Created by MingLQ on 2014-12-11.
//  Copyright (c) 2014年 iwill. All rights reserved.
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
#define validateState(expected) \
    ^(NSInteger got) { \
        expect(got).equal(expected); \
    }
void _itWill(NSString *name, void (^block)(StateCallback doneWithState), ValidateCallback validate);
