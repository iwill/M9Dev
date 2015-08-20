//
//  JSCore.h
//  M9Dev
//
//  Created by MingLQ on 2014-08-08.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

/**
 *  Error: "TypeError: self type check failed for Objective-C instance method"
 *  Reason: Duplicated property or method in JSExport protocol
 */

@interface JSValue (JSCore)

- (JSValue *)callMethod:(NSString *)method withArguments:(NSArray *)arguments;

@end

@interface JSContext (JSCore)

+ (instancetype)contextWithName:(NSString *)name;

@property(nonatomic, copy) NSString *name;

- (void)setUpAll;
- (void)setUpConsole;
- (void)setUpJSClass;
- (void)setUpFoundation;
- (void)setUpUIKit;

@end
