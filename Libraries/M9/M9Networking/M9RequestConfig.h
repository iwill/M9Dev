//
//  M9RequestConfig.h
//  M9Dev
//
//  Created by iwill on 2014-07-06.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "M9Utilities.h"

#import "M9RequestRef.h"
#import "M9ResponseRef.h"

typedef NS_OPTIONS(NSUInteger, M9ResponseParseOptions) {
    M9ResponseParseOption_Data  = 1 << 0,
    M9ResponseParseOption_JSON  = 1 << 1,
    M9ResponseParseOption_XML   = 1 << 2,
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
    M9ResponseParseOption_XMLDocument = 1 << 3,
#endif
    M9ResponseParseOption_PList = 1 << 4,
    M9ResponseParseOption_Image = 1 << 5,
    M9ResponseParseOption_All   = 0xFFFFFFFF
};

@interface M9RequestConfig : NSObject <M9MakeCopy>

@property(nonatomic) M9ResponseParseOptions responseParseOptions;

@property(nonatomic) NSTimeInterval timeoutInterval; // default: 10 per request / retry, AFNetworking: 60
@property(nonatomic) NSInteger maxRetryTimes; // default: 2, AFNetworking: 0

@property(nonatomic) BOOL cacheData; // default: YES
@property(nonatomic) BOOL useCachedData; // default: YES
@property(nonatomic) BOOL useCachedDataWhenFailure; // default: NO
// TODO: @property(nonatomic) BOOL useCachedDataWithoutLoading; // default: NO

@end

#pragma mark -

@interface M9RequestInfo : M9RequestConfig

@property(nonatomic, strong) NSString *URLString;
@property(nonatomic, strong) NSDictionary *parameters;
@property(nonatomic, copy) void (^success)(id<M9ResponseRef> responseRef, id responseObject);
@property(nonatomic, copy) void (^failure)(id<M9ResponseRef> responseRef, NSError *error);

@property(nonatomic, weak) id sender; // for cancel all requests by sender

+ (instancetype)requestInfoWithConfig:(M9RequestConfig *)requestConfig;

@end
