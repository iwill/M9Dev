//
//  FreeTeestViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-09-18.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "FreeTeestViewController.h"

#import "UIControl+M9EventCallback.h"

static const CGFloat margin = 10, height = 44;

@implementation FreeTeestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"free test";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.alwaysBounceVertical = YES;
    
    UIButton *button = nil;
    
    {
        button = [self addButtonWithTitle:@"test ifNotStrong" nextTo:button];
        defineWeak(self, button);
        [button addEventCallback:^(id sender) {
            ifNotStrong(self, button) return;
            button.selected = !button.selected;
        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        button = [self addButtonWithTitle:@"test ifNotStrong nil" nextTo:button];
        id nill = nil;
        defineWeak(self, button, nill);
        [button addEventCallback:^(id sender) {
            ifNotStrong(self, button, nill) return;
            button.selected = !button.selected;
        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.scrollView).with.offset(margin);
    }];
}

- (UIButton *)addButtonWithTitle:(NSString *)title nextTo:(UIView *)prev {
    UIButton *button = [UIButton new];
    button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    button.backgroundColor = [UIColor lightGrayColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    
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
    
    return button;
}

@end
