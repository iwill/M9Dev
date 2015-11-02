//
//  NSURL+M9.h
//  M9Dev
//
//  Created by MingLQ on 2015-06-23.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <Foundation/Foundation.h>
#import <NSString-URLEncode/NSString+URLEncode.h>

#import "M9Utilities.h"
#import "NSDictionary+M9.h"

@interface NSURL (M9Categories)

@property(copy, readonly) NSDictionary *queryDictionary;

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters;

@end

/**
 *  Use NSString+URLEncode
 *
 *  @see
 *      http://madebymany.com/blog/url-encoding-an-nsstring-on-ios
 *      http://johan.svbtle.com/encodeuricomponent-in-objectivec
 *      http://stackoverflow.com/a/8086845/456536
 */

/**
 *  Copied from AFNetworking
 *  @see AFNetworking/AFURLRequestSerialization.m
 *      static inline NSString * AFPercentEscapedStringFromString(NSString *string)
 *      static NSString * AFBase64EncodedStringFromString(NSString *string)
 *  ???: decode
 */
