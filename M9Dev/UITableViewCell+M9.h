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

/**
 *  indexPath:          [self.closestTableView indexPathForCell:self]
 *  numberOfRows:       [self.closestTableView numberOfRowsInSection:indexPath.section]
 *  numberOfSections:   self.closestTableView.numberOfSections
 *
 *  @see UITableView
 */
@interface UITableViewCell (M9_UITableView)

/**
 *  @return nil if cell is not added to a tableView
 *
 *  @see UIView+M9.h
 *      - (UIView *)closestViewOfClass:(Class)clazz
 */
@property (nonatomic, readonly) UITableView *closestTableView;

/**
 *  @return NO if self.closestTableView is not available
 */
- (BOOL)isFirstRowOfSectionInTableView:(UITableView *)tableView;
- (BOOL)isLastRowOfSectionInTableView:(UITableView *)tableView;

@end

#pragma mark -

@interface UITableViewCell (M9_AccessoryButton)

// TODO: MingLQ - A or B

// A: set self.accessoryView with a UIButton
@property (nonatomic, strong) UIButton *accessoryButton;

// B: add UITapGestureRecognizer to self.accessoryView
@property (nonatomic, getter=isAccessoryViewEnabled) BOOL accessoryViewEnabled;

@end

#pragma mark -

@interface UITableViewCell (M9AddSeparator)

@property (nonatomic, strong) UIView *topSeparator, *bottomSeparator;

- (void)showTopSeparatorWithColor:(UIColor *)color insets:(UIEdgeInsets)insets;
- (void)showBottomSeparatorWithColor:(UIColor *)color insets:(UIEdgeInsets)insets;

- (void)hideTopSeparator;
- (void)hideBottomSeparator;

@end
