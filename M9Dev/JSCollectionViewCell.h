//
//  JSCollectionViewCell.h
//  M9Dev
//
//  Created by MingLQ on 2014-09-04.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "JSView.h"
#import "UICollectionViewCell+JS.h"

typedef void (^JSCollectionViewCellPrepareForReuseBlock)();

@interface JSCollectionViewCell : UICollectionViewCell <JSViewExport, UICollectionViewCellExport>

@property(nonatomic, setter=setSetUp:) BOOL isSetUp;

@property(nonatomic, copy) JSCollectionViewCellPrepareForReuseBlock prepareForReuseBlock;

- (void)prepareForReuse;

@end
