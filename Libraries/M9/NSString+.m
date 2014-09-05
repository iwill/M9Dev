//
//  NSString+.m
//  iM9
//
//  Created by iwill on 2011-06-04.
//  Copyright 2011 M9. All rights reserved.
//

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import "NSString+.h"

@implementation NSString (NSData)

+ (instancetype)stringWithData:(NSData *)data {
    return [self stringWithData:data encoding:NSUTF8StringEncoding];
}

+ (instancetype)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding {
    return data ? [[self alloc] initWithData:data encoding:encoding] : nil;
}

@end

#pragma mark - NSString+Base64

static char base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSString (Base64)

+ (instancetype)stringWithBase64Data:(NSData *)base64Data {
    return [self stringWithBase64Data:base64Data lineLength:0];
}

+ (instancetype)stringWithBase64Data:(NSData *)base64Data lineLength:(int)lineLength {
    return [self stringWithBase64Data:base64Data lineLength:lineLength lineFeed:@"\n"];
}

+ (instancetype)stringWithBase64Data:(NSData *)base64Data lineLength:(int)lineLength lineFeed:(NSString *)lineFeed {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [base64Data length];
    
    if (lentext < 1) {
        return @"";
    }
    
    result = [NSMutableString stringWithCapacity:lentext];
    
    raw = [base64Data bytes];
    
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        
        if (ctremaining <= 0) {
            break;
        }
        
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            
            if (ix < lentext) {
                input[i] = raw[ix];
            }
            else {
                input[i] = 0;
            }
        }
        
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        
        ctcopy = 4;
        
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++) {
            [result appendString:[NSString stringWithFormat:@"%c", base64EncodingTable[output[i]]]];
        }
        
        for (i = ctcopy; i < 4; i++) {
            [result appendString:@"="];
        }
        
        ixtext += 3;
        charsonline += 4;
        
        if (lineLength > 0 && charsonline >= lineLength && lineFeed.length) {
            charsonline = 0;
            [result appendString:lineFeed];
        }
    }
    
    return [self stringWithString:result];
}

@end
