//
//  UITableViewCell+M9AccessoryButton.m
//  M9Dev
//
//  Created by MingLQ on 2015-09-08.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "UITableViewCell+M9AccessoryButton.h"

@implementation UITableViewCell (M9AccessoryButton)

/* @dynamic accessoryButton;

- (UIButton *)accessoryButton {
    return [self.accessoryView as:[UIButton class]];
}

- (void)setAccessoryButton:(UIButton *)accessoryButton {
    self.accessoryView = accessoryButton;
    [accessoryButton addTarget:self action:@selector(m9_accessoryButtonTappedWithButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)m9_accessoryButtonTappedWithButton:(UIButton *)button {
    UITableViewCell *cell = (UITableViewCell *)[button closestViewOfClass:[UITableViewCell class]];
    UITableView *tableView = (UITableView *)[cell closestViewOfClass:[UITableView class]];
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    if (indexPath && [tableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [tableView.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
} */

// TODO: self.accessoryTapGestureRecognizer
- (void)enableAccessoryView {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(m9_accessoryButtonTappedWithGestureRecognizer:)];
    [self.accessoryView addGestureRecognizer:tapGestureRecognizer];
}

- (void)disableAccessoryView {
    // [self.accessoryView removeGestureRecognizer:self.accessoryTapGestureRecognizer];
}

- (void)m9_accessoryButtonTappedWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    UITableViewCell *cell = (UITableViewCell *)[tapGestureRecognizer.view closestViewOfClass:[UITableViewCell class]];
    UITableView *tableView = (UITableView *)[cell closestViewOfClass:[UITableView class]];
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    if (indexPath && [tableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [tableView.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

@end
