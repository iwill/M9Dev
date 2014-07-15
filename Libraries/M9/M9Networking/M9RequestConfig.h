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

/**
 * MIME
 *  M9ResponseParseOption_Data:         nil
 *  M9ResponseParseOption_JSON:         application/json, text/json, text/javascript - text/javascript for JSONP
 *  M9ResponseParseOption_XML:          application/xml, text/xml
 *  M9ResponseParseOption_XMLDocument:  application/xml, text/xml
 *  M9ResponseParseOption_PList:        application/x-plist
 *  M9ResponseParseOption_Image:        image/tiff, image/jpeg, image/gif, image/png, image/ico, image/x-icon, image/bmp, image/x-bmp, image/x-xbitmap, image/x-win-bitmap
 *  M9ResponseParseOption_All
 */
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

@property(nonatomic) NSTimeInterval timeoutInterval; // default: 10 per request / retry, AFNetworking: 60
@property(nonatomic) NSInteger maxRetryTimes; // default: 2, AFNetworking: 0

@property(nonatomic) BOOL cacheData; // default: YES
@property(nonatomic) BOOL useCachedData; // default: YES
@property(nonatomic) BOOL useCachedDataWhenFailure; // default: NO
// TODO: @property(nonatomic) BOOL useCachedDataWithoutLoading; // default: NO

@property(nonatomic) M9ResponseParseOptions responseParseOptions; // default: M9ResponseParseOption_JSON

@end

#pragma mark -

@interface M9RequestInfo : M9RequestConfig

@property(nonatomic, strong) NSString *URLString;
@property(nonatomic, strong) NSDictionary *parameters;
@property(nonatomic, copy) void (^success)(id<M9ResponseRef> responseRef, id responseObject);
@property(nonatomic, copy) void (^failure)(id<M9ResponseRef> responseRef, NSError *error);

@property(nonatomic, weak) id sender; // for cancel all requests by sender

@end
