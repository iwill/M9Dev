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
#import "M9Networking+.h"

#import "CallbackRequestInfo.h"
#import "DelegateRequestInfo.h"

@interface M9NetworkingViewController ()

@end

@implementation M9NetworkingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(- 1, 0, 320 + 2, 44);
    
    frame.origin.y += CGRectGetMaxY(frame) + 20;
    [self.view addSubview:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = frame;
        [button setTitle:@"request" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonDidTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.layer.borderWidth = 0.5;
        button;
    })];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)buttonDidTapped:(UIButton *)button {
    if (button.selected) {
        button.selected = NO; // confirm result
        return;
    }
    else {
        button.enabled = NO; // start loading
    }
    
    // NSString *URLString = @"http://10.2.10.187:3000/static/index.html";
    NSString *URLString = @"http://10.2.10.187:3000/route/path/file.json?a=1&b=2";
    NSDictionary *parameters = @{ @"x": @1, @"y": @2 };
    
    BOOL useBlock = NO;
    BOOL useCustomBlock = YES;
    if (useBlock) {
        M9RequestInfo *requestInfo = [M9RequestInfo new];
        requestInfo.URLString = URLString;
        requestInfo.parameters = parameters;
        
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
    else if (useCustomBlock) {
        CallbackRequestInfo *requestInfo = [CallbackRequestInfo new];
        requestInfo.URLString = URLString;
        requestInfo.parameters = parameters;
        
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
    else {
        DelegateRequestInfo *requestInfo = [DelegateRequestInfo new];
        requestInfo.URLString = URLString;
        requestInfo.parameters = parameters;
        [requestInfo setDelegate:self
                   successSelector:@selector(successWithRequestInfo:responseInfo:responseObject:)
                   failureSelector:@selector(failureWithRequestInfo:responseInfo:error:)];
        requestInfo.userInfo = button;
        
        [M9NETWORKING GET:requestInfo];
    }
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
