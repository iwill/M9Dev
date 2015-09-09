//
//  UITableViewCell+M9AccessoryButton.m
//  M9Dev
//
//  Created by MingLQ on 2015-09-08.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "UITableViewCell+M9AccessoryButton.h"

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
