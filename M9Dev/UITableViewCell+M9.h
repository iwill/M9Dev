//
//  UITableViewCell+M9.h
//  M9Dev
//
//  Created by MingLQ on 2015-09-08.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

#import "NSObject+AssociatedValues.h"
#import "M9Utilities.h"
#import "UIView+M9.h"

@interface UITableViewCell (M9AccessoryButton)

// TODO: MingLQ - A or B

// A: set self.accessoryView with a UIButton
@property (nonatomic, strong) UIButton *accessoryButton;

// B: add UITapGestureRecognizer to self.accessoryView
@property (nonatomic, getter=isAccessoryViewEnabled) BOOL accessoryViewEnabled;

@end

#pragma mark -

@interface UITableViewCell (M9AddSeparator)

@property (nonatomic, strong) UIView *topSeparator, *bottomSeparator;

- (void)addTopSeparatorWithColor:(UIColor *)color inset:(UIEdgeInsets)inset;
- (void)addBottomSeparatorWithColor:(UIColor *)color inset:(UIEdgeInsets)inset;

@end
