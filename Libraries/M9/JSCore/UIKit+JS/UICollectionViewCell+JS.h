//
//  UICollectionViewCell+JS.h
//  M9Dev
//
//  Created by MingLQ on 2014-09-04.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "UIView+JS.h"

@protocol UICollectionViewCellExport <JSExport>

@property(nonatomic, readonly) UIView *contentView;

@property(nonatomic, retain) UIView *backgroundView;
@property(nonatomic, retain) UIView *selectedBackgroundView;

@end

@interface UICollectionViewCell (JS) <UIViewExport, UICollectionViewCellExport>

@end
