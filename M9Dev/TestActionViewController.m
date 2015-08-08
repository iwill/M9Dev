//
//  TestActionViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-06-24.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import "TestActionViewController.h"

#import <Masonry/Masonry.h>

#import "M9URLAction.h"
#import "M9URLAction+1.0.h"

@implementation TestActionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"test action";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.alwaysBounceVertical = YES;
    
    CGFloat margin = 10, height = 44;
    UIView *prev = nil;
    for (NSString *actionString in @[ @"sva://action.cmd?action=2.4&cid=7002&cateCode=7002&ex2=-1&ex3=70020002&channel_list_type=2&channel_id=700600",
                                      @"sohuvideo://action.cmd?action=1.18&urls=http%3A%2F%2Fh5.tv.sohu.com%2Fupload%2Ftouch%2Factivity%2Frunning_man%2Findex.shtml",
                                      @"sohuvideo://sva://action.cmd?action=1.25&cateCode=8888&channel_id=88880001&cid=8888&ex2=%e6%90%9c%e7%8b%90%e5%bd%b1%e9%99%a2",
                                      @"sohuvideo://sva://action.cmd?action=1.18&urls=http%3A%2F%2Ftv.sohu.com%2Fupload%2Ftouch%2Ffeedback.html&more=%7B%22sourcedata%22%3A%7B%22params%22%3A%22plat%22%7D%7D",
                                      @"sva://videos.open",
                                      @"sva://videos.goto",
                                      @"sva://root.goto#sva%3A%2F%2Fvideos.open" ]) {
        UIButton *button = [UIButton new];
        button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        button.backgroundColor = [UIColor lightGrayColor];
        [button setTitle:actionString forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(actionWithButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).with.offset(margin);
            make.right.equalTo(self.view).with.offset(- margin);
            if (!prev) {
                make.top.equalTo(self.scrollView).with.offset(margin);
            }
            else {
                make.top.equalTo(prev.mas_bottom).with.offset(margin);
            }
            make.height.mas_equalTo(height);
        }];
        prev = button;
    }
    [prev mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.scrollView).with.offset(margin);
    }];
}

- (void)actionWithButton:(UIButton *)button {
    NSString *actionString = [button titleForState:UIControlStateNormal];
    NSLog(@"got action: %@", actionString);
    
    NSURL *actionURL = [NSURL URLWithString:actionString];
    if ([[actionURL.host lowercaseString] isEqualToString:@"action.cmd"]) {
        actionURL = [M9URLAction actionURLFrom_1_0:actionString];
        NSLog(@"translate action from 1.0 to 2.0: %@", actionURL);
    }
    
    // filter action 2.0
    __block M9URLAction *action = [M9URLAction performActionWithURL:actionURL completion:^() {
        NSLog(@"completion: <#%@#>", action);
    }];
    if (action) {
        NSLog(@"action 2.0");
    }
    // forward action 1.0
    else {
        NSLog(@"action 1.0");
    }
}

@end
