//
//  M9ScrollViewController.h
//  iPhoneVideo
//
//  Created by Ming LQ on 2012-06-12.
//  Copyright (c) 2012年 M9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

#import "M9Utilities.h"

/*
@protocol M9ScrollViewDelegate <UITableViewDelegate>
@optional
- (void)scrollViewDidEndScrolling:(UIScrollView *)scrollView;
@end */

@interface M9ScrollViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, readonly, retain) UIScrollView *scrollView;

@end
