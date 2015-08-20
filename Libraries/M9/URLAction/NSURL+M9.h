//
//  NSURL+M9.h
//  M9Dev
//
//  Created by MingLQ on 2015-06-23.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
// #import <CoreFoundation/CoreFoundation.h>

#import "M9Utilities.h"
#import "NSDictionary+M9.h"

@interface NSURL (M9Categories)

@property(copy, readonly) NSDictionary *queryDictionary;

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters;

@end

#pragma mark -

/**
 *  Copied from AFNetworking
 *  @see AFNetworking/AFURLRequestSerialization.m
 */

static NSString * const _kAFCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";
static NSString * const _kAFCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";

static inline NSString * _AFPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                  (__bridge CFStringRef)string,
                                                                                  (__bridge CFStringRef)_kAFCharactersToLeaveUnescapedInQueryStringPairKey,
                                                                                  (__bridge CFStringRef)_kAFCharactersToBeEscapedInQueryString,
                                                                                  CFStringConvertNSStringEncodingToEncoding(encoding));
}

static inline NSString * _AFPercentEscapedQueryStringValueFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                  (__bridge CFStringRef)string,
                                                                                  NULL,
                                                                                  (__bridge CFStringRef)_kAFCharactersToBeEscapedInQueryString,
                                                                                  CFStringConvertNSStringEncodingToEncoding(encoding));
}

static inline NSString * URLEncodedFieldWithEncoding(id field, NSStringEncoding stringEncoding) {
    return _AFPercentEscapedQueryStringKeyFromStringWithEncoding([field description], stringEncoding);
}

static inline NSString * URLEncodedValueWithEncoding(id value, NSStringEncoding stringEncoding) {
    if (!value || [value isEqual:[NSNull null]]) return @"";
    return _AFPercentEscapedQueryStringValueFromStringWithEncoding([value description], stringEncoding);
}

// ???: decode
static inline NSString * AFBase64EncodedStringFromString(NSString *string) {
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6) & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0) & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}
