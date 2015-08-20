//
//  NSURL+JS.h
//  M9Dev
//
//  Created by MingLQ on 2014-09-04.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol NSURLExport <JSExport>

+ (instancetype)URLWithString:(NSString *)URLString;
+ (instancetype)URLWithString:(NSString *)URLString relativeToURL:(NSURL *)baseURL;

@property (readonly, copy) NSString *absoluteString;
@property (readonly, copy) NSString *relativeString;
@property (readonly, copy) NSURL *baseURL;
@property (readonly, copy) NSURL *absoluteURL;

@end

@interface NSURL (JS) <NSURLExport>

@end
