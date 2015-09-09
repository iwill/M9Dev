//
//  TestCornerRadiusViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-09-09.
//  Copyright (c) 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "TestCornerRadiusViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface TestCornerRadiusTableViewCell : UITableViewCell

@end

@implementation TestCornerRadiusTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        for (NSInteger i = 0; i < 3; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100 * i + 10, 10, 80, 80)];
            // imageView.image = [UIImage imageNamed:M9Dev_bundle_@"QING.png"];
            [imageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.yimg.com/uy/build/images/sohp/backgrounds/bottom5.jpg"]];
            
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.cornerRadius = 40;
            imageView.layer.masksToBounds = YES;
            
            // ???:
            // @see http://zsisme.gitbooks.io/ios-/content/chapter15/offscreen-rendering.html
            imageView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.imageView.bounds
                                                                    cornerRadius:imageView.layer.cornerRadius].CGPath;
            
            /*
            // @see http://stackoverflow.com/a/11049343/456536
            // @see http://zsisme.gitbooks.io/ios-/content/chapter15/offscreen-rendering.html
            imageView.layer.shouldRasterize = YES;
            imageView.layer.rasterizationScale = [UIScreen mainScreen].scale; */
            
            [self.contentView addSubview:imageView];
        }
    }
    return self;
}

@end

@implementation TestCornerRadiusViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.title = @"TestCornerRadius";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerClass:[TestCornerRadiusTableViewCell class] forCellReuseIdentifier:@"TestCornerRadiusTableViewCell"];
    self.tableView.rowHeight = 100;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TestCornerRadiusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestCornerRadiusTableViewCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - <UITableViewDelegate>

@end
