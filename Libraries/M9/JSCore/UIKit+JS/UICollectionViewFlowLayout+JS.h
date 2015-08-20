//
//  UICollectionViewFlowLayout+JS.h
//  M9Dev
//
//  Created by MingLQ on 2014-09-04.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "UIView+JS.h"

@protocol UICollectionViewFlowLayoutExport <JSExport>

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGSize estimatedItemSize NS_AVAILABLE_IOS(8_0);
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic) CGSize headerReferenceSize;
@property (nonatomic) CGSize footerReferenceSize;
@property (nonatomic) UIEdgeInsets sectionInset;

@property (nonatomic, strong, setter=js_setSectionInset:) NSDictionary *js_sectionInset;

@end

@interface UICollectionViewFlowLayout (JS) <UICollectionViewFlowLayoutExport>

@end
