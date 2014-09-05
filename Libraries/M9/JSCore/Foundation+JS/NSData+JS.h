//
//  NSData+JS.h
//  M9Dev
//
//  Created by MingLQ on 2014-09-05.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "NSData+.h"

@protocol NSDataExport <JSExport>

+ (instancetype)dataWithBase64String:(NSString *)base64String;

@end

@interface NSData (JS) <NSDataExport>

@end
