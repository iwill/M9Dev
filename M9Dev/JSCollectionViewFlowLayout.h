//
//  JSCollectionViewFlowLayout.h
//  M9Dev
//
//  Created by MingLQ on 2014-09-05.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "JSCollectionViewCell.h"

@interface JSCollectionViewFlowLayout : UICollectionViewFlowLayout

@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, strong) JSValue *jsLayout;

- (void)cell_setUp:(JSCollectionViewCell *)cell;
- (void)cell_prepareForReuse:(JSCollectionViewCell *)cell;
- (void)cell_update:(JSCollectionViewCell *)cell withData:(id)data;

@end
