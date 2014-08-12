//
//  JSCore.m
//  M9Dev
//
//  Created by MingLQ on 2014-08-08.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "JSCore.h"

#import "M9Utilities.h"
#import "JSView.h"

@implementation JSValue (JSCore)

#define OCApplyMethod "OCApplyMethod"

- (JSValue *)callMethod:(NSString *)method withArguments:(NSArray *)arguments {
    JSContext *context = self.context;
    
    JSValue *applyMethod = context[@(OCApplyMethod)];
    if (applyMethod.isNull || applyMethod.isUndefined) {
        NSString *script = @(
        "this." OCApplyMethod " = function(object, method, args) {"
        "   return object[method].apply(object, args);"
        "};"
        );
        applyMethod = [context evaluateScript:script];
        context[@(OCApplyMethod)] = applyMethod;
    }
    
    return [applyMethod callWithArguments:@[ self, method, arguments ]];
}

@end

#pragma mark -

@implementation JSContext (JSCore)

#define JSContextName @"JSContextName"
@dynamic name;

+ (instancetype)contextWithName:(NSString *)name {
    JSContext *context = [self new];
    context.name = name;
    return context;
}

- (NSString *)name {
    JSValue *name = self[JSContextName];
    return [name isString] ? [name toString] : nil;
}

- (void)setName:(NSString *)name {
    self[JSContextName] = name;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@+%@", NSStringFromClass([JSContext class]), self.name];
}

- (void)setupAll {
    [self setupConsole];
    [self setupJSClass];
    [self setupUIKit];
}

- (void)setupConsole {
    self.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"[%@ | EXCEPTION] %@\n%@\n\n", context, exception, [exception valueForProperty:@"stack"]);
    };
    
    self[@"console"] = @{ @"log": ^(NSString *message) {
        NSLog(@"[%@ | LOG] %@", self, message);
    }, @"dir": ^(NSDictionary *dict) {
        NSLog(@"[%@ | DIR] <%@", self, dict);
        for (id key in dict) {
            NSLog(@"    %@: %@", key, dict[key]);
        }
        NSLog(@">");
    } };
}

- (void)setupJSClass {
    [self evaluateScript:@(
     "/*!"
     " * Javascript library - $class v0.2"
     " * http://github.com/iwill/"
     " */"
     " "
     "/**"
     " * $class v0.2"
     " */"
     "this.$class = function $class(source, SuperClass) {"
     "    SuperClass = SuperClass || Object;"
     "    if (source instanceof Function) {"
     "        source = source(SuperClass, SuperClass.prototype || {});"
     "    }"
     "    source = source || {};"
     "    source.constructor = source.hasOwnProperty(\"constructor\") ? source.constructor : function() {"
     "        SuperClass.apply(this, arguments);"
     "    };"
     "    "
     "    var Class = source.constructor;"
     "    Class.prototype = new SuperClass();"
     "    for (var each in source) {"
     "        Class.prototype[each] = source[each];"
     "    }"
     "    "
     "    return Class;"
     "};"
     )];
}

- (void)setupUIKit {
    self[@"UIColor"] = [UIColor class];
    self[@"UIFont"] = [UIFont class];
    self[@"UIView"] = [UIView class];
    self[@"UILabel"] = [UILabel class];
    
    self[@"JSView"] = [JSView class];
}

@end
