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
#import "M9Networking.h"
#import "M9Networking+.h"

#import "NSInvocation+.h"

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

- (void)test {
    NSLog(@"<#NSString *format#>: %@", NSStringFromSelector(_cmd));
}

- (BOOL)testBOOL:(BOOL)boolean {
    NSLog(@"<#NSString *format#>: %@", NSStringFromSelector(_cmd));
    return !boolean;
}

- (NSInteger)testInteger:(NSInteger)integer {
    NSLog(@"<#NSString *format#>: %@", NSStringFromSelector(_cmd));
    return integer + 123;
}

- (NSUInteger)testUInteger:(NSUInteger)uInteger {
    NSLog(@"<#NSString *format#>: %@", NSStringFromSelector(_cmd));
    return uInteger + 123456;
}

- (id)testObject:(id)object {
    NSLog(@"<#NSString *format#>: %@", NSStringFromSelector(_cmd));
    return object;
}

- (id)testBOOL:(BOOL)boolean Integer:(NSInteger)integer UInteger:(NSUInteger)uInteger {
    NSLog(@"<#NSString *format#>: %@ %d, %d, %u", NSStringFromSelector(_cmd), boolean, integer, uInteger);
    return self;
}

- (void)buttonDidTapped:(UIButton *)button {
    [self invokeWithSelector:@selector(test) returnValue:nil arguments:nil];
    
    BOOL boolean = NO;
    [self invokeWithSelector:@selector(testBOOL:) returnValue:&boolean argument:&boolean];
    NSLog(@"boolean: %d", boolean);
    
    NSInteger integer = 10000000;
    [self invokeWithSelector:@selector(testInteger:) returnValue:&integer argument:&integer];
    NSLog(@"integer: %d", integer);
    
    NSUInteger uInteger = 10000000;
    [self invokeWithSelector:@selector(testUInteger:) returnValue:&uInteger argument:&uInteger];
    NSLog(@"uInteger: %u", uInteger);
    
    id object = self;
    [self invokeWithSelector:@selector(testObject:) returnValue:&object argument:&object];
    NSLog(@"object: %@", object);
    
    id final = nil;
    [self invokeWithSelector:@selector(testBOOL:Integer:UInteger:) returnValue:&final arguments:&boolean, &integer, &uInteger];
    NSLog(@"object: %@", object);
    
    if (button.selected) {
        button.selected = NO; // confirm result
        return;
    }
    else {
        button.enabled = NO; // start loading
    }
    
    M9RequestInfo *requestInfo = [M9RequestInfo new];
    // requestInfo.URLString = @"http://10.2.10.187:3000/static/index.html";
    requestInfo.URLString = @"http://10.2.10.187:3000/route/path/file.json?a=1&b=2";
    requestInfo.parameters = @{ @"x": @1, @"y": @2 };
    requestInfo.sender = self;
    
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

@end
