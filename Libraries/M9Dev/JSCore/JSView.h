//
//  JSView.h
//  M9Dev
//
//  Created by MingLQ on 2014-08-11.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <UIKit/UIKit.h>

#import "UIView+JS.h"

@interface JSView : UIView

@property(nonatomic, readonly, copy) NSDictionary *keyedSubviews;

- (UIView *)subviewForKey:(id)key;
- (void)addSubview:(UIView *)subview forKey:(id)key;
- (void)removeSubviewForKey:(id)key;

@end

#pragma mark -

@protocol JSViewExport <JSExport>

@property(nonatomic, readonly, copy) NSDictionary *keyedSubviews;

- (UIView *)subviewForKey:(id)key;
- (void)addSubview:(UIView *)subview forKey:(id)key;
- (void)removeSubviewForKey:(id)key;

@end

@interface JSView (JS) <UIViewExport, JSViewExport>

@end
