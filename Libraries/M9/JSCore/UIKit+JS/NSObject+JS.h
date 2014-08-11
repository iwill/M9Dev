//
//  NSObject+JS.h
//  M9Dev
//
//  Created by MingLQ on 2014-08-07.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

typedef id (^JSConstructor)();
static inline JSConstructor JSConstructorWithClass(NSString *className) {
    return ^() {
        return [NSClassFromString(className) new];
    };
}

@protocol NSObjectExport <JSExport>

@end
