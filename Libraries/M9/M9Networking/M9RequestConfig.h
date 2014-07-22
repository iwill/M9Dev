//
//  M9RequestConfig.h
//  M9Dev
//
//  Created by iwill on 2014-07-06.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "M9Utilities.h"

/**
 * M9RequestParametersFormatter
 *
 *  All the parameters will be encoded
 *
 *  Key-Value:  a=1&b=2&a=1&b[]=1&b[]=2&c[x]=1&c[y]=2&c[z][]=1&c[z][]=2
 *  Key-JSON:   a=1&b=[1,2]&c={"x":1,"y":2,"z":[1,2]}
 *  JSON:       {"a":1,"b":[1,2],"c":{"x":1,"y":2,"z":[1,2]}}
 *  PList:      <?xml ....><!DOCTYPE ....><plist ....><dict>....</dict></plist>
 *
 *  JSON & PList do not support http method GET, HEAD and DELETE, KeyJSON will be used instead
 */
typedef NS_OPTIONS(NSUInteger, M9RequestParametersFormatter) {
    M9RequestParametersFormatter_KeyValue,
    M9RequestParametersFormatter_KeyJSON,
    M9RequestParametersFormatter_JSON,
    M9RequestParametersFormatter_PList
};

/**
 * MIME
 *
 *  Data:           nil
 *  JSON:           application/json, text/json, text/javascript - text/javascript for JSONP
 *  XML:            application/xml, text/xml
 *  XMLDocument:    application/xml, text/xml
 *  PList:          application/x-plist
 *  Image:          image/tiff, image/jpeg, image/gif, image/png, image/ico, image/x-icon, image/bmp, image/x-bmp, image/x-xbitmap, image/x-win-bitmap
 *  All:            *
 */
typedef NS_OPTIONS(NSUInteger, M9ResponseDataParser) {
    M9ResponseDataParser_Data   = 1 << 0,
    M9ResponseDataParser_JSON   = 1 << 1,
    M9ResponseDataParser_XML    = 1 << 2,
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
    M9ResponseDataParser_XMLDocument = 1 << 3,
#endif
    M9ResponseDataParser_PList  = 1 << 4,
    M9ResponseDataParser_Image  = 1 << 5,
    M9ResponseDataParser_All    = 0xFFFFFFFF
};

@interface M9RequestConfig : NSObject <M9MakeCopy>

@property(nonatomic) NSURL *baseURL; // default: nil
@property(nonatomic) M9RequestParametersFormatter parametersFormatter; // default: M9RequestParametersFormatter_KeyJSON

@property(nonatomic) NSTimeInterval timeoutInterval; // default: 10 per request / retry, AFNetworking: 60
@property(nonatomic) NSInteger maxRetryTimes; // default: 2, AFNetworking: 0

@property(nonatomic) BOOL cacheData; // default: YES
@property(nonatomic) BOOL useCachedData; // default: YES
@property(nonatomic) BOOL useCachedDataWithoutLoading; // default: NO, ignore useCachedData when useCachedDataWithoutLoading is YES
@property(nonatomic) BOOL useCachedDataWhenFailure; // default: NO

@property(nonatomic) M9ResponseDataParser dataParser; // default: M9ResponseDataParser_JSON

/* Authentication Challenges
 *  How to Respond to an Authentication Challenge. In order for the connection to continue, the block has three options:
 *      Provide authentication credentials
 *      Attempt to continue without credentials
 *      Cancel the authentication challenge
 *  Respond to an Authentication Challenge. The following are the three ways:
 *      Providing Credentials
 *      Continuing Without Credentials
 *      Canceling the Connection
 *  @see https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/Articles/AuthenticationChallenges.html#//apple_ref/doc/uid/TP40009507-SW1
 */
@property(nonatomic, copy) void (^willSendRequestForAuthenticationChallengeBlock)(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge);

@end
