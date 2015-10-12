//
//  M9Link.h
//  M9Dev
//
//  Created by MingLQ on 2015-10-10.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

/* TODO: MingLQ
 *  √ !!!: both UILabel and UITextView
 *  √ UILabel+Link
 *      - enableLinkWithCallback: - _add UITapGestureRecognizer OR UILongPressGestureRecognizer.minimumPressDuration
 *  √ UIGestureRecognizer action
 *      location to index
 *  √ NSTextAttachment
 *      @property linkURL
 *  static _UIGestureRecognizerDelegate
 *      start - remember and remove origin bg, add new
 *      end - remove new bg, add origin bg
 */

/**
 *  @see https://www.cocoanetics.com/2015/03/customizing-uilabel-hyperlinks/
 */

typedef void (^M9LabelLinkCalback)(UILabel * _Nullable label, NSString * _Nullable urlString, NSRange range);

@interface UILabel (M9Link)
- (void)enableLinkWithCallback:(nullable M9LabelLinkCalback)callback;
@end

#pragma mark -

typedef void (^M9TextViewLinkCalback)(UITextView * _Nullable label, NSString * _Nullable urlString, NSRange range);

@interface UITextView (M9Link)
- (void)enableLinkWithCallback:(nullable M9TextViewLinkCalback)callback;
@end

#pragma mark -

@interface NSTextAttachment (M9Link)

// @see image of NSTextAttachment
// Link representing the text attachment contents. Modifying this property invalidates -contents, -fileType, and -FileWrapper properties.
@property(nullable, strong, NS_NONATOMIC_IOSONLY) NSString *linkURL NS_AVAILABLE(10_11, 7_0);

@end
