//
//  VideosTableViewController.m
//  M9Dev
//
//  Created by MingLQ on 2014-08-14.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

#import "VideosTableViewController.h"

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

#define UIImageTableViewMargin          7
#define UIImageTableViewMidMargin       6

#define UIImageTableViewImageHeight     85
#define UIImageTableViewImageWidth      150

#define UIImageTableViewTextHeight      12
#define UIImageTableViewTextWidth       UIImageTableViewImageWidth
#define UIImageTableViewTextFontSize    UIImageTableViewTextHeight
#define UIImageTableViewTextColor       @"#3F3F43"

#define UIImageTableViewBackgroundColor @"#F3F3F5"
#define UIImageTableViewBorderWidth     0.5
#define UIImageTableViewBorderColor     @"#D5D5D7"

#define UIImageTableViewCellHeight      (UIImageTableViewImageHeight + UIImageTableViewTextHeight)

@interface UIImageTableViewCell : UITableViewCell

@end

@implementation UIImageTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(UIImageTableViewImageWidth + UIImageTableViewMargin * 2,
                                      UIImageTableViewMargin,
                                      CGRectGetWidth(self.contentView.bounds) - UIImageTableViewImageWidth + UIImageTableViewMargin * 3,
                                      UIImageTableViewImageHeight);
    self.imageView.frame = CGRectMake(UIImageTableViewMargin, UIImageTableViewMargin, UIImageTableViewImageWidth, UIImageTableViewImageHeight);
}

@end

#pragma mark -

@interface VideosTableViewController ()

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property(nonatomic) BOOL clearsSelectionOnViewWillAppear;

@end

@implementation VideosTableViewController {
    UITableViewStyle tableViewStyle;
    
    M9Networking *networking;
    JSContext *context;
    
    NSMutableArray *allVideos;
    NSUInteger page;
    
    BOOL isLoading;
}

- (id)init {
    return [self initWithStyle:UITableViewStylePlain];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super init];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:NSIntegerMax - 2014 - 8 - 15];
        
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = YES;
        
        tableViewStyle = style;
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
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:tableViewStyle];
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    tableView.scrollsToTop = YES;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.tableView addSubview:refreshControl];
    
    [self.tableView registerClass:[UIImageTableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    self.tableView.rowHeight = UIImageTableViewCellHeight;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, UIImageTableViewMargin, 0, 0);
    
    [self.refreshControl beginRefreshing];
    [self refreshControlEventValueChanged:self.refreshControl];
}

- (void)viewDidLayoutSubviews {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.clearsSelectionOnViewWillAppear) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    }
}

- (void)refreshControlEventValueChanged:(UIRefreshControl *)refreshControl {
    if (refreshControl.isRefreshing) {
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
                                @"sver":        @"4.3.1",
                                @"partner":     @1,
                                @"cid":         @2,
                                @"page":        @(page + 1),
                                @"page_size":   @30 };
    
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
        [self.tableView reloadData];
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
    [self.tableView reloadData];
}

#pragma mark - UIScrollViewDelegate

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

/* - (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
} */
/* - (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
} */
/* - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
} */

/* - (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
} */
/* - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
} */

/* - (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
} */

/* - (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return YES;
} */
/* - (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
} */

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [allVideos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static UIImage *defaultImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultImage = [UIImage imageWithColor:[UIColor lightGrayColor] size:CGSizeMake(120, 90)];
    });
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    NSDictionary *video = [allVideos objectOrNilAtIndex:indexPath.row];
    
    NSString *title = [video stringForKey:@"album_name"];;
    NSURL *imageURL = [NSURL URLWithString:[video stringForKey:@"hor_high_pic"]];
    
    cell.textLabel.text = title;
    [cell.imageView sd_setImageWithURL:imageURL placeholderImage:defaultImage options:SDWebImageRetryFailed completed:nil];
    
    return cell;
}

@end
