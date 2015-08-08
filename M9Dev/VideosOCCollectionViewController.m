//
//  VideosOCCollectionViewController.m
//  M9Dev
//
//  Created by MingLQ on 2014-09-02.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "VideosOCCollectionViewController.h"

#import "EXTScope+M9.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "M9Utilities.h"
#import "M9Networking.h"
#import "NSArray+.h"
#import "NSDictionary+.h"
#import "UIColor+.h"
#import "UIImage+.h"
#import "UIScrollView+.h"

@interface UIImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UIImageView *imageView;

@end

@interface UIImageCollectionViewCell ()

@property (nonatomic, strong, readwrite) UILabel *textLabel;
@property (nonatomic, strong, readwrite) UIImageView *imageView;

@end

@implementation UIImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            self.imageView = imageView;
            _RETURN imageView;
        })];
        
        [self.contentView addSubview:({
            CGFloat fontSize = 14, textMargin = 5;
            
            UIView *backgroundView = [[UIVisualEffectView alloc] initWithEffect:[[UIBlurEffect alloc] init]];
            if (!backgroundView) {
                backgroundView = [UIView new];
                backgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.93];
            }
            backgroundView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(CGRectGetHeight(self.bounds) - (fontSize + textMargin * 2), 0, 0, 0));
            backgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
            
            UILabel *textLabel = [[UILabel alloc] initWithFrame:backgroundView.bounds];
            textLabel.backgroundColor = [UIColor clearColor];
            textLabel.textAlignment = NSTextAlignmentCenter;
            textLabel.font = [UIFont systemFontOfSize:fontSize];
            textLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            
            self.textLabel = textLabel;
            [backgroundView addSubview:textLabel];
            
            _RETURN backgroundView;
        })];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.textLabel.text = nil;
    self.imageView.image = nil;
    [self.imageView sd_cancelCurrentImageLoad];
}

@end

#pragma mark -

@interface VideosOCCollectionViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation VideosOCCollectionViewController {
    M9Networking *networking;
    
    NSMutableArray *allVideos;
    NSUInteger page;
    
    BOOL isLoading;
    
    UICollectionViewFlowLayout *horLayout, *verLayout;
}

static NSString *const UIImageCollectionViewCellIdentifier = @"UIImageCollectionViewCellIdentifier";

- (instancetype)init {
    horLayout = ({
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(150, 124);
        layout.sectionInset = UIEdgeInsetsMake(7, 7, 7, 7);
        layout.minimumLineSpacing = 6;
        layout.minimumInteritemSpacing = 6;
        _RETURN layout;
    });
    
    verLayout = ({
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(98, 135);
        layout.sectionInset = UIEdgeInsetsMake(7, 7, 7, 7);
        layout.minimumLineSpacing = 6;
        layout.minimumInteritemSpacing = 6;
        _RETURN layout;
    });
    
    self = [super initWithCollectionViewLayout:horLayout];
    if (self) {
        self.navigationItem.title = @"display videos by oc";
        
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = YES;
        
        self.clearsSelectionOnViewWillAppear = YES;
        
        M9RequestConfig *config = [M9RequestConfig new];
        config.baseURL = [NSURL URLWithString:@"http://api.tv.sohu.com/v4/"];
        networking = [M9Networking instanceWithRequestConfig:config];
        
        allVideos = [NSMutableArray array];
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
    
    UISegmentedControl *layoutSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Hor", @"Ver"]];
    layoutSegmentedControl.selectedSegmentIndex = 0;
    [layoutSegmentedControl addTarget:self action:@selector(layoutSegmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = layoutSegmentedControl;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.collectionView addSubview:refreshControl];
    [self.collectionView registerClass:[UIImageCollectionViewCell class] forCellWithReuseIdentifier:UIImageCollectionViewCellIdentifier];
    
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

- (void)layoutSegmentedControlValueDidChange:(UISegmentedControl *)layoutSegmentedControl {
    UICollectionViewLayout *nextLayout = nil;
    if (layoutSegmentedControl.selectedSegmentIndex == 0) {
        nextLayout = horLayout;
    }
    else {
        nextLayout = verLayout;
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

- (void)loadData {
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
    static UIImage *defaultImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultImage = [UIImage imageWithColor:[UIColor lightGrayColor]];
    });
    
    BOOL isHor = self.collectionView.collectionViewLayout == horLayout;
    
    NSDictionary *video = [allVideos objectOrNilAtIndex:indexPath.item];
    NSString *title = video[@"album_name"];
    NSURL *imageURL = [NSURL URLWithString:video[isHor ? @"hor_high_pic" : @"ver_high_pic"]];
    
    UIImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:UIImageCollectionViewCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = title;
    [cell.imageView sd_setImageWithURL:imageURL
                      placeholderImage:defaultImage
                               options:SDWebImageRetryFailed
                             completed:nil];
    
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
