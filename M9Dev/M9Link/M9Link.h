//
//  M9Link.h
//  M9Dev
//
//  Created by MingLQ on 2015-10-10.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

/* TODO: MingLQ
 *  !!!: both UILabel and UITextView
 *  NSTextAttachment
 *      @property linkURL
 *  UILabel+Link
 *      - enableLinkWithCallback: - _add UITapGestureRecognizer OR UILongPressGestureRecognizer.minimumPressDuration
 *  static _UIGestureRecognizerDelegate
 *      start - remember and remove origin bg, add new
 *      end - remove new bg, add origin bg
 *  UIGestureRecognizer action
 *      location to index
 */

typedef void (^M9LabelLinkCalback)(UILabel *label, NSString *urlString);

@interface UILabel (M9Link)
- (void)enableLinkWithCallback:(M9LabelLinkCalback)callback;
@end

#pragma mark -

typedef void (^M9TextViewLinkCalback)(UITextView *label, NSString *urlString);

@interface UITextView (M9Link)
- (void)enableLinkWithCallback:(M9TextViewLinkCalback)callback;
@end
