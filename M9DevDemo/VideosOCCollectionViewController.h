//
//  VideosOCCollectionViewController.h
//  M9Dev
//
//  Created by MingLQ on 2014-09-02.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "M9CollectionViewController.h"

@interface VideosOCCollectionViewController : M9CollectionViewController <
UICollectionViewDataSource,
UICollectionViewDelegate
>

- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithCollectionViewLayout:(nullable UICollectionViewLayout *)layout NS_UNAVAILABLE;
- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(nullable NSCoder *)aDecoder NS_UNAVAILABLE;

@end
