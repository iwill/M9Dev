//
//  M9CollectionViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-12-26.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "M9CollectionViewController.h"

@interface M9CollectionViewController ()

@property (nonatomic, readwrite) UICollectionViewLayout *collectionViewLayout;
@property(nonatomic, strong, readwrite) UICollectionView *collectionView;

@end

@implementation M9CollectionViewController

- (instancetype)init {
    return [self initWithCollectionViewLayout:nil];
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.collectionViewLayout = layout;
    }
    return self;
}

@dynamic scrollView;
- (UIScrollView *)scrollView {
    return self.collectionView;
}

@synthesize collectionView = _collectionView;
- (UICollectionView *)collectionView {
    if (![self isViewLoaded]) {
        [self view];
    }
    if (_collectionView) {
        return _collectionView;
    }
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                          collectionViewLayout:self.collectionViewLayout];
    // collectionView.delegate = self;
    // collectionView.dataSource = self;
    self.collectionView = collectionView;
    [self.view addSubview:collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.height.equalTo(self.view);
    }];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self collectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.clearsSelectionOnViewWillAppear) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        for (NSIndexPath *indexPath in indexPaths) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:animated];
        }
    }
}

- (void)dealloc {
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

@end
