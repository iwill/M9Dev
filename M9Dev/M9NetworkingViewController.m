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

#import "M9RequestInfoExt.h"

@interface M9NetworkingViewController ()

@end

@implementation M9NetworkingViewController {
    NSString *testURLString;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:NSIntegerMax - 2014 - 7 - 5];
        
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
        [button setTitle:@"request" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonDidTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.layer.borderWidth = 0.5;
        button;
    })];
    
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
    // M9NETWORKING.requestConfig.baseURL = [NSURL URLWithString:@"http://localhost:3000"];
    M9NETWORKING.requestConfig.baseURL = [NSURL URLWithString:@"http://10.2.10.187:3000"];
    
    // testURLString = @"/hello.txt";
    // testURLString = @"/static/index.html";
    testURLString = @"/route/path/file.json?a=1&b=2";
}

- (void)buttonDidTapped:(UIButton *)button {
    if (button.selected) {
        button.selected = NO; // confirm result
        return;
    }
    else {
        button.enabled = NO; // start loading
    }
    
    weakify(button);
    [M9NETWORKING GET:testURLString
           parameters:@{ @"a": @1, @"b": @[ @1, @2 ], @"c": @{ @"x": @1, @"y": @2, @"z": @[ @1, @2 ] } }
              success:^(id<M9ResponseInfo> responseInfo, id responseObject) {
                  NSLog(@"success: %@", responseObject);
                  strongify(button);
                  button.enabled = YES; // stop loading
                  button.selected = YES; // alert result
                  [button setTitle:@"success" forState:UIControlStateSelected];
              } failure:^(id<M9ResponseInfo> responseInfo, NSError *error) {
                  NSLog(@"failure: %@", error);
                  strongify(button);
                  button.enabled = YES; // stop loading
                  button.selected = YES; // alert result
                  [button setTitle:@"failure" forState:UIControlStateSelected];
              }];
}

- (void)buttonDidTapped1:(UIButton *)button {
    if (button.selected) {
        button.selected = NO; // confirm result
        return;
    }
    else {
        button.enabled = NO; // start loading
    }
    
    M9RequestInfo *requestInfo = [M9RequestInfo requestInfoWithRequestConfig:M9NETWORKING.requestConfig];
    /* can be removed */ requestInfo.HTTPMethod = HTTPGET;
    /* can be removed */ requestInfo.baseURL = M9NETWORKING.requestConfig.baseURL;
    /* can be removed */ requestInfo.parametersFormatter = M9RequestParametersFormatter_KeyJSON;
    /* can be removed */ requestInfo.dataParser = M9ResponseDataParser_JSON;
    requestInfo.URLString = testURLString;
    requestInfo.parameters = @{ @"x": @1, @"y": @2 };
    
    weakify(requestInfo, button);
    requestInfo.parsing = ^id(id<M9ResponseInfo> responseInfo, id responseObject, NSError **error) {
        NSLog(@"parsing: %@", responseObject);
        *error = nil;
        NSDictionary *responseDictionary = [responseObject as:[NSDictionary class]];
        if (!responseDictionary) {
            *error = [NSError errorWithDomain:@"M9TestErrorDomain" code:0 userInfo:nil];
        }
        return responseDictionary;
    };
    requestInfo.success = ^(id<M9ResponseInfo> responseInfo, id responseObject) {
        strongify(requestInfo, button);
        if (![responseObject count]) {
            requestInfo.failure((id<M9ResponseInfo>)requestInfo, nil);
            return;
        }
        NSLog(@"success: %@", responseObject);
        button.enabled = YES; // stop loading
        button.selected = YES; // alert result
        [button setTitle:@"success" forState:UIControlStateSelected];
    };
    requestInfo.failure = ^(id<M9ResponseInfo> responseInfo, NSError *error) {
        strongify(button);
        NSLog(@"failure: %@", error);
        button.enabled = YES; // stop loading
        button.selected = YES; // alert result
        [button setTitle:@"failure" forState:UIControlStateSelected];
    };
    
    [M9NETWORKING send:requestInfo];
}

- (void)buttonDidTapped2:(UIButton *)button {
    if (button.selected) {
        button.selected = NO; // confirm result
        return;
    }
    else {
        button.enabled = NO; // start loading
    }
    
    M9RequestInfoCallbackExt *requestInfo = [M9RequestInfoCallbackExt requestInfoWithRequestConfig:M9NETWORKING.requestConfig];
    requestInfo.URLString = testURLString;
    requestInfo.parameters = @{ @"x": @1, @"y": @2 };
    
    weakify(button);
    [requestInfo setSuccessWithCustomCallback:^(id<M9ResponseInfo> responseInfo, NSArray *dataList) {
        NSLog(@"M9RequestInfoCallbackExt: %@", dataList);
        strongify(button);
        button.enabled = YES; // stop loading
        button.selected = YES; // alert result
        [button setTitle:@"success" forState:UIControlStateSelected];
    }];
    [requestInfo setFailureWithCustomCallback:^(id<M9ResponseInfo> responseInfo, NSString *errorMessage) {
        NSLog(@"M9RequestInfoCallbackExt: %@", errorMessage);
        strongify(button);
        button.enabled = YES; // stop loading
        button.selected = YES; // alert result
        [button setTitle:@"failure" forState:UIControlStateSelected];
    }];
    
    [M9NETWORKING send:requestInfo];
}

- (void)buttonDidTapped3:(UIButton *)button {
    if (button.selected) {
        button.selected = NO; // confirm result
        return;
    }
    else {
        button.enabled = NO; // start loading
    }
    
    M9RequestInfoDelegateExt *requestInfo = [M9RequestInfoDelegateExt requestInfoWithRequestConfig:M9NETWORKING.requestConfig];
    requestInfo.URLString = testURLString;
    requestInfo.parameters = @{ @"x": @1, @"y": @2 };
    [requestInfo setDelegate:self
             successSelector:@selector(successWithRequestInfo:responseInfo:responseObject:)
             failureSelector:@selector(failureWithRequestInfo:responseInfo:error:)];
    requestInfo.userInfo = button;
    
    [M9NETWORKING send:requestInfo];
}

- (void)successWithRequestInfo:(M9RequestInfoDelegateExt *)requestInfo responseInfo:(id<M9ResponseInfo>)responseInfo responseObject:(id)responseObject {
    NSLog(@"M9RequestInfoDelegateExt: %@", responseObject);
    UIButton *button = requestInfo.userInfo;
    button.enabled = YES; // stop loading
    button.selected = YES; // alert result
    [button setTitle:@"success" forState:UIControlStateSelected];
}

- (void)failureWithRequestInfo:(M9RequestInfoDelegateExt *)requestInfo responseInfo:(id<M9ResponseInfo>)responseInfo error:(NSError *)error {
    NSLog(@"M9RequestInfoDelegateExt: %@", error);
    UIButton *button = requestInfo.userInfo;
    button.enabled = YES; // stop loading
    button.selected = YES; // alert result
    [button setTitle:@"failure" forState:UIControlStateSelected];
}

@end
