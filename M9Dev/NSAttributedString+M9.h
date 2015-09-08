//
//  NSAttributedString+M9.h
//  M9Dev
//
//  Created by MingLQ on 2014-10-29.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (M9Category)

+ (instancetype)attributedStringWithHTMLString:(NSString *)string NS_AVAILABLE_IOS(7_0); // use NSUTF8StringEncoding
+ (instancetype)attributedStringWithHTMLString:(NSString *)string encoding:(NSStringEncoding)encoding error:(NSError **)error NS_AVAILABLE_IOS(7_0);

/* TODO: replace <#text#> with images
 * TODO: add link to <#text#>
NSRange lbsRang = [detailText rangeOfString:@"<#lbs#>"];
if (lbsRang.location != NSNotFound) {
    if (NSClassFromString(@"NSTextAttachment")) {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"ic_lbs_place_n.png"];
        if ([attachment respondsToSelector:@selector(setBounds:)]) {
            attachment.bounds = CGRectMake(- 1, - 1, attachment.image.size.width, attachment.image.size.height);
        }
        NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:attachment];
        NSMutableAttributedString *textString = [[NSMutableAttributedString alloc] initWithString:detailText];
        [textString replaceCharactersInRange:lbsRang withAttributedString:imageString];
        label.attributedText = textString;
    }
    else {
        label.text = [detailText stringByReplacingCharactersInRange:lbsRang withString:@"📍"];
    }
} */

@end
