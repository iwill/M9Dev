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

#pragma mark - Base64

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

@implementation NSData (Base64)

+ (instancetype)dataWithBase64String:(NSString *)base64String {
    unsigned long ixtext, lentext;
    unsigned char ch, input[4] = {}, output[3] = {};
    short i, ixinput;
    Boolean flignore, flendtext = false;
    const char *temporary;
    NSMutableData *result;
    
    if (!base64String) {
        return [NSData data];
    }
    
    ixtext = 0;
    temporary = [base64String UTF8String];
    lentext = [base64String length];
    result = [NSMutableData dataWithCapacity:lentext];
    ixinput = 0;
    
    while (true) {
        if (ixtext >= lentext) {
            break;
        }
        
        ch = temporary[ixtext++];
        
        flignore = false;
        
        if ((ch >= 'A') && (ch <= 'Z')) {
            ch = ch - 'A';
        }
        else if ((ch >= 'a') && (ch <= 'z')) {
            ch = ch - 'a' + 26;
        }
        else if ((ch >= '0') && (ch <= '9')) {
            ch = ch - '0' + 52;
        }
        else if (ch == '+') {
            ch = 62;
        }
        else if (ch == '=') {
            flendtext = true;
        }
        else if (ch == '/') {
            ch = 63;
        }
        else {
            flignore = true;
        }
        
        if (!flignore) {
            short ctcharsinput = 3;
            Boolean flbreak = false;
            
            if (flendtext) {
                if (ixinput == 0) {
                    break;
                }
                
                if ((ixinput == 1) || (ixinput == 2)) {
                    ctcharsinput = 1;
                }
                else {
                    ctcharsinput = 2;
                }
                
                ixinput = 3;
                
                flbreak = true;
            }
            
            input[ixinput++] = ch;
            
            if (ixinput == 4) {
                ixinput = 0;
                
                output[0] = (input[0] << 2) | ((input[1] & 0x30) >> 4);
                output[1] = ((input[1] & 0x0F) << 4) | ((input[2] & 0x3C) >> 2);
                output[2] = ((input[2] & 0x03) << 6) | (input[3] & 0x3F);
                
                for (i = 0; i < ctcharsinput; i++) {
                    [result appendBytes:&output[i] length:1];
                }
            }
            
            if (flbreak) {
                break;
            }
        }
    }
    
    return [self dataWithData:result];
}

@end
