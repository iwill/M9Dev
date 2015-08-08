//
//  NSAttributedString+M9.h
//  M9Dev
//
//  Created by MingLQ on 2014-10-29.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (M9Category)

+ (instancetype)attributedStringWithHTMLString:(NSString *)string NS_AVAILABLE_IOS(7_0); // use NSUTF8StringEncoding
+ (instancetype)attributedStringWithHTMLString:(NSString *)string encoding:(NSStringEncoding)encoding error:(NSError **)error NS_AVAILABLE_IOS(7_0);

@end
