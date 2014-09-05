//
//  NSData+.m
//  Utility
//
//  Created by iwill on 2014-06-19.
//
//

#import "NSData+.h"

@implementation NSData (NSString)

+ (instancetype)dataWithString:(NSString *)string encoding:(NSStringEncoding)encoding {
    return [string dataUsingEncoding:encoding];
}

+ (instancetype)dataWithString:(NSString *)string encoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy {
    return [string dataUsingEncoding:encoding allowLossyConversion:lossy];
}

@end

#pragma mark - NSData+Base64

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

#pragma mark - NSData+UIImage

@implementation NSData (UIImage)

+ (instancetype)dataWithPNGImage:(UIImage *)image {
    return UIImagePNGRepresentation(image);
}

+ (instancetype)dataWithJPGImage:(UIImage *)image quality:(CGFloat)quality {
    return UIImageJPEGRepresentation(image, quality);
}

@end
