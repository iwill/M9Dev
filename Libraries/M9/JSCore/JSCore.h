//
//  JSCore.h
//  M9Dev
//
//  Created by MingLQ on 2014-08-08.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface JSValue (JSCore)

- (JSValue *)callMethod:(NSString *)method withArguments:(NSArray *)arguments;

@end
