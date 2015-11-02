//
//  UITableViewCell+M9.m
//  M9Dev
//
//  Created by MingLQ on 2015-09-08.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "UITableViewCell+M9.h"

@implementation UITableViewCell (M9AccessoryButton)

@dynamic accessoryButton;

- (UIButton *)accessoryButton {
    return [self.accessoryView as:[UIButton class]];
}

- (void)setAccessoryButton:(UIButton *)accessoryButton {
    [self.accessoryButton removeTarget:self action:@selector(m9_accessoryButtonTappedWithButton:) forControlEvents:UIControlEventTouchUpInside];
    [accessoryButton addTarget:self action:@selector(m9_accessoryButtonTappedWithButton:) forControlEvents:UIControlEventTouchUpInside];
    self.accessoryView = accessoryButton;
}

- (void)m9_accessoryButtonTappedWithButton:(UIButton *)button {
    if (button != self.accessoryView) {
        return;
    }
    UITableView *tableView = (UITableView *)[self closestViewOfClass:[UITableView class]];
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    if (indexPath && [tableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [tableView.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

@dynamic accessoryViewEnabled;
static void *M9AccessoryButtonTapGestureRecognizer = &M9AccessoryButtonTapGestureRecognizer;

- (BOOL)isAccessoryViewEnabled {
    UITapGestureRecognizer *tapGestureRecognizer = [self associatedValueForKey:M9AccessoryButtonTapGestureRecognizer];
    return self.accessoryView && tapGestureRecognizer.view == self.accessoryView;
}

- (void)setAccessoryViewEnabled:(BOOL)accessoryViewEnabled {
    UITapGestureRecognizer *tapGestureRecognizer = [self associatedValueForKey:M9AccessoryButtonTapGestureRecognizer];
    if (!accessoryViewEnabled || !self.accessoryView) {
        [tapGestureRecognizer.view removeGestureRecognizer:tapGestureRecognizer];
        // [self associateValue:nil withKey:M9AccessoryButtonTapGestureRecognizer];
        return;
    }
    if (!tapGestureRecognizer) {
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(m9_accessoryButtonTappedWithGestureRecognizer:)];
        [self associateValue:tapGestureRecognizer withKey:M9AccessoryButtonTapGestureRecognizer];
    }
    else if (tapGestureRecognizer.view && tapGestureRecognizer.view != self.accessoryView) {
        [tapGestureRecognizer.view removeGestureRecognizer:tapGestureRecognizer];
    }
    [self.accessoryView addGestureRecognizer:tapGestureRecognizer];
}

- (void)m9_accessoryButtonTappedWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.view != self.accessoryView) {
        return;
    }
    
    UITableView *tableView = (UITableView *)[self closestViewOfClass:[UITableView class]];
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    if (indexPath && [tableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [tableView.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

@end

#pragma mark -

@implementation UITableViewCell (M9AddSeparator)

@dynamic topSeparator, bottomSeparator;

static void *UITableViewCell_topSeparator = &UITableViewCell_topSeparator;
static void *UITableViewCell_bottomSeparator = &UITableViewCell_bottomSeparator;

- (UIView *)topSeparator {
    return [self associatedValueForKey:UITableViewCell_topSeparator];
}

- (void)setTopSeparator:(UIView *)topSeparator {
    [self associateValue:topSeparator withKey:UITableViewCell_topSeparator];
}

- (UIView *)bottomSeparator {
    return [self associatedValueForKey:UITableViewCell_bottomSeparator];
}

- (void)setBottomSeparator:(UIView *)bottomSeparator {
    [self associateValue:bottomSeparator withKey:UITableViewCell_bottomSeparator];
}

- (void)addTopSeparatorWithColor:(UIColor *)color inset:(UIEdgeInsets)inset {
    self.topSeparator = self.topSeparator OR [UIView new];
    self.topSeparator.backgroundColor = color OR [UIColor lightGrayColor];
    // !!!: self.contentView for iOS6
    [self.contentView addSubview:self.topSeparator];
    [self.topSeparator mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(1.0 / [UIScreen mainScreen].scale);
        make.left.equalTo(self).with.offset(inset.left);
        make.right.equalTo(self).with.offset(- inset.right);
    }];
}

- (void)addBottomSeparatorWithColor:(UIColor *)color inset:(UIEdgeInsets)inset {
    self.bottomSeparator = self.bottomSeparator OR [UIView new];
    self.bottomSeparator.backgroundColor = color OR [UIColor lightGrayColor];
    // !!!: self.contentView for iOS6
    [self.contentView addSubview:self.bottomSeparator];
    [self.bottomSeparator mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1.0 / [UIScreen mainScreen].scale);
        make.left.equalTo(self).with.offset(inset.left);
        make.right.equalTo(self).with.offset(- inset.right);
    }];
}

@end
