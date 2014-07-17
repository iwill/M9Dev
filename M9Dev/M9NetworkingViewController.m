//
//  M9NetworkingViewController.m
//  M9Dev
//
//  Created by iwill on 2014-07-05.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9NetworkingViewController.h"

#import "EXTScope.h"
#import "M9Utilities.h"
#import "NSInvocation+.h"
#import "M9Networking.h"

#import "CallbackRequestInfo.h"
#import "DelegateRequestInfo.h"

@interface M9NetworkingViewController ()

@end

@implementation M9NetworkingViewController {
    NSURL *baseURL;
    NSString *testURLString;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupRequestConfig];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(- 1, 0, 320 + 2, 44);
    
    frame.origin.y = CGRectGetMaxY(frame) + 20;
    [self.view addSubview:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = frame;
        [button setTitle:@"request with callback" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonDidTapped1:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.layer.borderWidth = 0.5;
        button;
    })];
    
    frame.origin.y = CGRectGetMaxY(frame) + 20;
    [self.view addSubview:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = frame;
        [button setTitle:@"request with custom callback" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonDidTapped2:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.layer.borderWidth = 0.5;
        button;
    })];
    
    frame.origin.y = CGRectGetMaxY(frame) + 20;
    [self.view addSubview:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = frame;
        [button setTitle:@"request with delegate" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonDidTapped3:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.layer.borderWidth = 0.5;
        button;
    })];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupRequestConfig {
    baseURL = [NSURL URLWithString:@"http://localhost:3000"];
    // baseURL = [NSURL URLWithString:@"http://10.2.10.187:3000"];
    
    // testURLString = @"/static/index.html";
    testURLString = @"/route/path/file.json?a=1&b=2";
}

- (void)buttonDidTapped1:(UIButton *)button {
    if (button.selected) {
        button.selected = NO; // confirm result
        return;
    }
    else {
        button.enabled = NO; // start loading
    }
    
    M9RequestInfo *requestInfo = [M9RequestInfo new];
    requestInfo.baseURL = baseURL;
    requestInfo.URLString = testURLString;
    requestInfo.parameters = @{ @"x": @1, @"y": @2 };
    
    weakify(button);
    requestInfo.success = ^(id<M9ResponseInfo> responseInfo, id responseObject) {
        NSLog(@"success: %@", responseObject);
        strongify(button);
        button.enabled = YES; // stop loading
        button.selected = YES; // alert result
        [button setTitle:@"success" forState:UIControlStateSelected];
    };
    requestInfo.failure = ^(id<M9ResponseInfo> responseInfo, NSError *error) {
        NSLog(@"failure: %@", error);
        strongify(button);
        button.enabled = YES; // stop loading
        button.selected = YES; // alert result
        [button setTitle:@"failure" forState:UIControlStateSelected];
    };
    
    [M9NETWORKING GET:requestInfo];
}

- (void)buttonDidTapped2:(UIButton *)button {
    if (button.selected) {
        button.selected = NO; // confirm result
        return;
    }
    else {
        button.enabled = NO; // start loading
    }
    
    CallbackRequestInfo *requestInfo = [CallbackRequestInfo new];
    requestInfo.baseURL = baseURL;
    requestInfo.URLString = testURLString;
    requestInfo.parameters = @{ @"x": @1, @"y": @2 };
    
    weakify(button);
    [requestInfo setSuccessWithCustomCallback:^(id<M9ResponseInfo> responseInfo, NSDictionary *data) {
        NSLog(@"CallbackRequestInfo: %@", data);
        strongify(button);
        button.enabled = YES; // stop loading
        button.selected = YES; // alert result
        [button setTitle:@"success" forState:UIControlStateSelected];
    }];
    [requestInfo setFailureWithCustomCallback:^(id<M9ResponseInfo> responseInfo, NSString *errorMessage) {
        NSLog(@"CallbackRequestInfo: %@", errorMessage);
        strongify(button);
        button.enabled = YES; // stop loading
        button.selected = YES; // alert result
        [button setTitle:@"failure" forState:UIControlStateSelected];
    }];
    
    [M9NETWORKING GET:requestInfo];
}

- (void)buttonDidTapped3:(UIButton *)button {
    if (button.selected) {
        button.selected = NO; // confirm result
        return;
    }
    else {
        button.enabled = NO; // start loading
    }
    
    DelegateRequestInfo *requestInfo = [DelegateRequestInfo new];
    requestInfo.baseURL = baseURL;
    requestInfo.URLString = testURLString;
    requestInfo.parameters = @{ @"x": @1, @"y": @2 };
    [requestInfo setDelegate:self
             successSelector:@selector(successWithRequestInfo:responseInfo:responseObject:)
             failureSelector:@selector(failureWithRequestInfo:responseInfo:error:)];
    requestInfo.userInfo = button;
    
    [M9NETWORKING GET:requestInfo];
}

- (void)successWithRequestInfo:(DelegateRequestInfo *)requestInfo responseInfo:(id<M9ResponseInfo>)responseInfo responseObject:(id)responseObject {
    NSLog(@"DelegateRequestInfo: %@", responseObject);
    UIButton *button = requestInfo.userInfo;
    button.enabled = YES; // stop loading
    button.selected = YES; // alert result
    [button setTitle:@"success" forState:UIControlStateSelected];
}

- (void)failureWithRequestInfo:(DelegateRequestInfo *)requestInfo responseInfo:(id<M9ResponseInfo>)responseInfo error:(NSError *)error {
    NSLog(@"DelegateRequestInfo: %@", error);
    UIButton *button = requestInfo.userInfo;
    button.enabled = YES; // stop loading
    button.selected = YES; // alert result
    [button setTitle:@"failure" forState:UIControlStateSelected];
}

@end
