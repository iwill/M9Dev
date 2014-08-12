//
//  JSLayoutViewController.m
//  M9Dev
//
//  Created by MingLQ on 2014-08-11.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "JSLayoutViewController.h"

#import "M9Networking.h"
#import "NSString+.h"

#import <JavaScriptCore/JavaScriptCore.h>
#import "JSCore.h"
#import "UIColor+JS.h"
#import "UIView+JS.h"
#import "JSView.h"

@interface JSLayoutViewController ()

@property(nonatomic) NSInteger top;

@end

@implementation JSLayoutViewController {
    JSContext *context;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:NSIntegerMax - 2014 - 8 - 11];
        
        context = [JSContext new];
        
        context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            NSLog(@"exception: %@", exception);
        };
        
        context[@"console"] = @{ @"log": ^(NSString *message) {
            NSLog(@"%@", message);
        }, @"dir": ^(NSDictionary *dict) {
            NSLog(@"js dir: %@", dict);
            for (id key in dict) {
                NSLog(@"    %@: %@", key, dict[key]);
            }
        } };
        
        // context[@"NSObject"] = [NSObject class];
        context[@"UIColor"] = [UIColor class];
        context[@"UIFont"] = [UIFont class];
        context[@"UIView"] = [UIView class];
        context[@"UILabel"] = [UILabel class];
        
        context[@"JSView"] = [JSView class];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(- 1, 20 * 2, 320 + 2, 44);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = frame;
    [button setTitle:@"load" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonDidTapped:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    button.layer.borderWidth = 0.5;
    [self.view addSubview:button];
    
    context[@"canvas"] = self.view;
    self.top = CGRectGetMaxY(frame) + 20;
    
    [self loadScriptWithButton:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)buttonDidTapped:(UIButton *)button {
    [self clearUsersWithButton:button];
    [self loadScriptWithButton:button];
}

- (void)loadScriptWithButton:(UIButton *)button {
    if (button.selected) {
        button.selected = NO; // confirm result
        return;
    }
    else {
        button.enabled = NO; // start loading
    }
    
    [M9NETWORKING GET:@"/static/jslayout/layout.js" success:^(id<M9ResponseInfo> responseInfo, id responseObject) {
        NSString *script = [NSString stringWithData:[responseObject as:[NSData class]]];
        NSLog(@"script: %@", script);
        [context evaluateScript:script];
        [self loadDataWithButton:button];
    } failure:^(id<M9ResponseInfo> responseInfo, NSError *error) {
        NSLog(@"load script error: %@", error);
        button.enabled = YES; // stop loading
        button.selected = YES; // alert result
        [button setTitle:@"failure" forState:UIControlStateSelected];
    }];
}

- (void)loadDataWithButton:(UIButton *)button {
    [M9NETWORKING GET:@"/static/jslayout/data.json" success:^(id<M9ResponseInfo> responseInfo, id responseObject) {
        NSArray *users = [responseObject as:[NSArray class]];
        NSLog(@"data: %@", users);
        [self displayUsers:users];
        
        button.enabled = YES; // stop loading
        button.selected = YES; // alert result
        [button setTitle:@"success" forState:UIControlStateSelected];
    } failure:^(id<M9ResponseInfo> responseInfo, NSError *error) {
        NSLog(@"load data error: %@", error);
        button.enabled = YES; // stop loading
        button.selected = YES; // alert result
        [button setTitle:@"failure" forState:UIControlStateSelected];
    }];
}

- (void)displayUsers:(NSArray *)users {
    for (id object in users) {
        NSDictionary *user = [object as:[NSDictionary class]];
        
        JSValue *jsLayout = [context[@"JSLayout"] callMethod:@"layoutWithData" withArguments:@[ user ]];
        JSValue *jsView = [jsLayout callMethod:@"createView" withArguments:@[ @(self.top) ]];
        
        JSView *userView = [[jsView toObject] as:[JSView class]];
        if (userView) {
            [jsLayout callMethod:@"updateWithData" withArguments:@[ userView, user ]];
        }
        
        if (userView) {
            [self.view addSubview:userView];
            self.top = CGRectGetMaxY(userView.frame) + 20;
        }
    }
}

- (void)clearUsersWithButton:(UIButton *)button {
    self.top = 0;
    for (UIView *view in self.view.subviews) {
        if (view == button) {
            self.top = MAX(self.top, CGRectGetMaxY(button.frame) + 20);
        }
        else {
            [view removeFromSuperview];
        }
    }
}

@end
