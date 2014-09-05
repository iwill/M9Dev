//
//  VideosJSCollectionViewController.m
//  M9Dev
//
//  Created by MingLQ on 2014-09-02.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "VideosJSCollectionViewController.h"

#import "EXTScope.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "M9Utilities.h"
#import "M9Networking.h"
#import "NSArray+.h"
#import "NSDictionary+.h"
#import "NSString+.h"
#import "UIColor+.h"
#import "UIImage+.h"
#import "UIScrollView+.h"

#import "JSCore.h"
#import "JSView.h"
#import "UICollectionViewFlowLayout+JS.h"
#import "JSCollectionViewCell.h"

@interface VideosJSCollectionViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation VideosJSCollectionViewController {
    M9Networking *networking;
    JSContext *context;
    
    NSMutableArray *allVideos;
    NSUInteger page;
    
    BOOL isLoading;
    
    UISegmentedControl *layoutSegmentedControl;
    NSArray *jsLayouts, *ocLayouts;
}

- (instancetype)init {
    self = [super initWithCollectionViewLayout:({
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(150, 124);
        layout.sectionInset = UIEdgeInsetsMake(7, 7, 7, 7);
        layout.minimumLineSpacing = 6;
        layout.minimumInteritemSpacing = 6;
        _RETURN layout;
    })];
    if (self) {
        self.navigationItem.title = @"display videos by js";
        
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = YES;
        
        self.clearsSelectionOnViewWillAppear = YES;
        
        M9RequestConfig *config = [M9RequestConfig new];
        config.baseURL = [NSURL URLWithString:@"http://api.tv.sohu.com/v4/"];
        networking = [M9Networking instanceWithRequestConfig:config];
        
        allVideos = [NSMutableArray array];
        
        context = [JSContext contextWithName:NSStringFromClass([self class])];
        [context setUpAll];
        context[@"JSCollectionViewCell"] = [JSCollectionViewCell class];
        
        NSString *file = [[NSBundle mainBundle] pathForResource:@"video-layout"
                                                         ofType:@"js"
                                                    inDirectory:@"jslayout"];
        NSString *script = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
        [context evaluateScript:script];
    }
    return self;
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor colorWithHexString:@"#E1E1E6"];
    self.collectionView.alwaysBounceVertical = YES;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.collectionView addSubview:refreshControl];
    
    [self.refreshControl beginRefreshing];
    [self refreshControlEventValueChanged:self.refreshControl];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -

- (NSString *)reuseIdentifierWithLayoutName:(NSString *)layoutName {
    return [NSString stringWithFormat:@"JSCollectionViewCell-%@", layoutName];
}

- (void)layoutSegmentedControlValueDidChange:(UISegmentedControl *)segmentedControl {
    UICollectionViewLayout *nextLayout = [ocLayouts objectOrNilAtIndex:segmentedControl.selectedSegmentIndex];
    if (!nextLayout) {
        return;
    }
    
    [nextLayout invalidateLayout];
    
    weakify(self);
    [self.collectionView performBatchUpdates:^{
        strongify(self);
        [self.collectionView setCollectionViewLayout:nextLayout animated:YES];
        [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    } completion:^(BOOL finished) {
        strongify(self);
        NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
        if ([indexPaths count]) {
            [self.collectionView reloadItemsAtIndexPaths:indexPaths];
        }
    }];
}

- (void)refreshControlEventValueChanged:(UIRefreshControl *)refreshControl {
    if (refreshControl.isRefreshing) {
        [self reloadData];
    }
}

- (void)loadLayouts {
    NSMutableArray *jsLayoutsArray = [NSMutableArray array];
    NSMutableArray *ocLayoutsArray = [NSMutableArray array];
    NSMutableArray *layoutNames = [NSMutableArray array];
    jsLayouts = ({
        JSValue *jsLayoutsValue = context[@"JSLayout"][@"jsLayouts"];
        NSInteger jsLayoutsCount = [jsLayoutsValue[@"length"] toInt32];
        for (NSInteger i = 0; i < jsLayoutsCount; i++) {
            JSValue *jsLayout = jsLayoutsValue[@(i)];
            UICollectionViewFlowLayout *ocLayout = [UICollectionViewFlowLayout new];
            [jsLayout callMethod:@"layout_setUp" withArguments:@[ ocLayout ]];
            NSString *layoutName = [jsLayout[@"name"] toString];
            [jsLayoutsArray addObjectOrNil:jsLayout];
            [ocLayoutsArray addObjectOrNil:ocLayout];
            [layoutNames addObjectOrNil:layoutName];
            
            [self.collectionView registerClass:[JSCollectionViewCell class] forCellWithReuseIdentifier:[self reuseIdentifierWithLayoutName:layoutName]];
        }
        _RETURN [jsLayoutsArray copy];
    });
    ocLayouts = [ocLayoutsArray copy];
    
    layoutSegmentedControl = [[UISegmentedControl alloc] initWithItems:layoutNames];
    layoutSegmentedControl.selectedSegmentIndex = 0;
    [layoutSegmentedControl addTarget:self action:@selector(layoutSegmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = layoutSegmentedControl;
    [self layoutSegmentedControlValueDidChange:layoutSegmentedControl];
}

- (void)loadData {
    if (![jsLayouts count]) {
        [self loadLayouts];
    }
    
    if (isLoading) {
        return;
    }
    isLoading = YES;
    
    M9RequestInfo *requestInfo = [M9RequestInfo requestInfoWithRequestConfig:networking.requestConfig];
    requestInfo.URLString = @"search/channel.json";
    requestInfo.parameters = @{ @"api_key":     @"695fe827ffeb7d74260a813025970bd5",
                                @"plat":        @3,
                                @"sver":        @"4.5",
                                @"partner":     @1,
                                @"cid":         @1,
                                @"page":        @(page + 1),
                                @"page_size":   @30 };
    requestInfo.owner = self;
    
    weakify(requestInfo);
    [requestInfo setSuccess:^(id<M9ResponseInfo> responseInfo, id responseObject) {
        strongify(requestInfo);
        
        NSDictionary *data = [[responseObject as:[NSDictionary class]] dictionaryForKey:@"data"];
        NSArray *videos = [data arrayForKey:@"videos"];
        if (![videos count]) {
            if (requestInfo.failure) requestInfo.failure(responseInfo, nil);
            return;
        }
        
        page++;
        
        NSLog(@"page %ld: %ld", (unsigned long)page, (unsigned long)[videos count]);
        
        [allVideos addObjectsFromArray:videos];
        [self.collectionView reloadData];
        
        [self stopLoading];
    } failure:^(id<M9ResponseInfo> responseInfo, NSError *error) {
        // strongify(requestInfo);
        
        NSLog(@"page %ld: %@", (unsigned long)page, error);
        
        [self stopLoading];
    }];
    
    [networking send:requestInfo];
}

- (void)stopLoading {
    [self.refreshControl endRefreshing];
    isLoading = NO;
}

- (void)cancelLoading {
    [networking cancelAllWithOwner:self];
}

- (void)clearData {
    page = 0;
    [allVideos removeAllObjects];
    [self.collectionView reloadData];
}

- (void)reloadData {
    [self cancelLoading];
    [self clearData];
    [self loadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [allVideos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSValue *jsLayout = [jsLayouts objectOrNilAtIndex:layoutSegmentedControl.selectedSegmentIndex];
    NSString *layoutName = [jsLayout[@"name"] toString];
    
    NSDictionary *video = [allVideos objectOrNilAtIndex:indexPath.item];
    JSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self reuseIdentifierWithLayoutName:layoutName]
                                                                           forIndexPath:indexPath];
    
    if (!cell.isSetUp) {
        cell.isSetUp = YES;
        [jsLayout callMethod:@"cell_setUp" withArguments:@[ cell ]];
        
        weakify(cell);
        cell.prepareForReuseBlock = ^ {
            strongify(cell);
            [jsLayout callMethod:@"cell_prepareForReuse" withArguments:@[ cell ]];
        };
    }
    
    [jsLayout callMethod:@"cell_updateWithData" withArguments:@[ cell, video ]];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        return;
    }
    
    if ([scrollView scrolledToTheBottomEdge]) {
        [self loadData];
    }
}

@end
