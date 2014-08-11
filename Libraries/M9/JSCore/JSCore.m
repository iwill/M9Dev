//
//  JSCore.m
//  M9Dev
//
//  Created by MingLQ on 2014-08-08.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "JSCore.h"

#import "M9Utilities.h"

@implementation JSValue (JSCore)

#define OCApplyMethod "OCApplyMethod"

- (JSValue *)callMethod:(NSString *)method withArguments:(NSArray *)arguments {
    JSContext *context = self.context;
    
    JSValue *applyMethod = context[@(OCApplyMethod)];
    if (applyMethod.isNull || applyMethod.isUndefined) {
        NSString *script = @(
        "this." OCApplyMethod " = function(object, method, args) {"
        "   object[method].apply(object, args);"
        "};"
        );
        applyMethod = [context evaluateScript:script];
        context[@(OCApplyMethod)] = applyMethod;
    }
    
    return [applyMethod callWithArguments:@[ self, method, arguments ]];
}

@end
