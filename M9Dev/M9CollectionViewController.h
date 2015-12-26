//
//  M9CollectionViewController.h
//  M9Dev
//
//  Created by MingLQ on 2015-12-26.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "M9ScrollViewController.h"

@interface M9CollectionViewController : M9ScrollViewController {
@protected
    UICollectionView *_collectionView;
}

@property (nonatomic, readonly) UICollectionViewLayout *collectionViewLayout;
// !!!: dataSource & delegate are nil by default
@property(nonatomic, strong, readonly) UICollectionView *collectionView;
@property(nonatomic) BOOL clearsSelectionOnViewWillAppear;

- (instancetype)init;
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end
