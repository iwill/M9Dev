//
//  NSAttributedString+.m
//  M9Dev
//
//  Created by MingLQ on 2014-10-29.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSAttributedString+.h"

#import "M9Utilities.h"

@implementation NSAttributedString (M9Category)

+ (instancetype)attributedStringWithHTMLString:(NSString *)string {
    return [self attributedStringWithHTMLString:string encoding:NSUTF8StringEncoding error:nil];
}

+ (instancetype)attributedStringWithHTMLString:(NSString *)string encoding:(NSStringEncoding)encoding error:(NSError **)error {
    return [[self alloc] initWithData:[string dataUsingEncoding:encoding]
                              options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                         NSCharacterEncodingDocumentAttribute: @(encoding) }
                   documentAttributes:nil
                                error:error];
}

@end
