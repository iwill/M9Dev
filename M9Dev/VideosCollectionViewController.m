//
//  VideosCollectionViewController.m
//  M9Dev
//
//  Created by MingLQ on 2014-09-02.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "VideosCollectionViewController.h"

#import "EXTScope.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "M9Utilities.h"
#import "M9Networking.h"
#import "NSArray+.h"
#import "NSDictionary+.h"
#import "UIColor+.h"
#import "UIImage+.h"

#import "JSCore.h"
#import "JSView.h"

@interface VideoView : UIView

@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UIImageView *imageView;

@end

@interface VideoView ()

@property (nonatomic, strong, readwrite) UILabel *textLabel;
@property (nonatomic, strong, readwrite) UIImageView *imageView;

@end

@implementation VideoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
            imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            self.imageView = imageView;
            _RETURN imageView;
        })];
        
        [self addSubview:({
            CGFloat inset = CGRectGetHeight(frame) - [UIFont labelFontSize];
            
            UIVisualEffectView *backgroundView = [[UIVisualEffectView alloc] initWithEffect:[[UIBlurEffect alloc] init]];
            backgroundView.frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(inset, 0, 0, 0));
            
            UILabel *textLabel = [[UILabel alloc] initWithFrame:backgroundView.bounds];
            textLabel.backgroundColor = [UIColor clearColor];
            textLabel.textAlignment = NSTextAlignmentCenter;
            textLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
            
            self.textLabel = textLabel;
            [backgroundView addSubview:textLabel];
            
            _RETURN backgroundView;
        })];
    }
    return self;
}

@end

#pragma mark -

@interface VideosCollectionViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation VideosCollectionViewController {
    M9Networking *networking;
    JSContext *context;
    
    NSMutableArray *allVideos;
    NSUInteger page;
    
    BOOL isLoading;
}

- (instancetype)init {
    return [self initWithCollectionViewLayout:({
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = CGSizeMake(150, 124);
        _RETURN layout;
    })];
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.navigationItem.title = @"display videos by oc or js";
        
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = YES;
        
        self.clearsSelectionOnViewWillAppear = YES;
        
        M9RequestConfig *config = [M9RequestConfig new];
        config.baseURL = [NSURL URLWithString:@"http://api.tv.sohu.com/v4/"];
        networking = [M9Networking instanceWithRequestConfig:config];
        
        allVideos = [NSMutableArray array];
        
        context = [JSContext contextWithName:NSStringFromClass([self class])];
        [context setupAll];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#E1E1E6"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.collectionView addSubview:refreshControl];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    
    [self.refreshControl beginRefreshing];
    [self refreshControlEventValueChanged:self.refreshControl];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)refreshControlEventValueChanged:(UIRefreshControl *)refreshControl {
    if (refreshControl.isRefreshing) {
        [networking cancelAllWithOwner:self];
        [self clearData];
        [self loadData];
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
        
        NSLog(@"page %ld: %ld", page, [videos count]);
        
        [allVideos addObjectsFromArray:videos];
        [self.collectionView reloadData];
        [self.refreshControl endRefreshing];
        isLoading = NO;
    } failure:^(id<M9ResponseInfo> responseInfo, NSError *error) {
        // strongify(requestInfo);
        
        NSLog(@"page %ld: %@", page, error);
        
        [self.refreshControl endRefreshing];
        isLoading = NO;
    }];
    
    [networking send:requestInfo];
}

- (void)clearData {
    page = 0;
    [allVideos removeAllObjects];
    [self.collectionView reloadData];
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
        defaultImage = [UIImage imageWithColor:[UIColor lightGrayColor] size:CGSizeMake(120, 90)];
    });
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    
    VideoView *videoView = nil;
    NSDictionary *video = [allVideos objectOrNilAtIndex:indexPath.row];
    
    NSString *title = [video stringForKey:@"album_name"];;
    NSURL *imageURL = [NSURL URLWithString:[video stringForKey:@"hor_high_pic"]];
    
    videoView.textLabel.text = title;
    [videoView.imageView sd_setImageWithURL:imageURL placeholderImage:defaultImage options:SDWebImageRetryFailed completed:nil];
    
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
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - CGRectGetHeight(scrollView.frame);
    if (maximumOffset > 0 && currentOffset - maximumOffset >= 0) {
        [self loadData];
    }
}

@end
