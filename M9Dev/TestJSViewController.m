//
//  TestJSViewController.m
//  M9Dev
//
//  Created by MingLQ on 2014-08-07.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9Utilities.h"

#import "TestJSViewController.h"

#import <JavaScriptCore/JavaScriptCore.h>
#import "JSCore.h"
#import "UIColor+JS.h"
#import "UIView+JS.h"

@protocol TestJSViewControllerExport <JSExport>

@property(nonatomic) NSInteger top;

@end

@interface TestJSViewController (JS) <TestJSViewControllerExport>

@end

@implementation TestJSViewController (JS)

@dynamic top;

@end

#pragma mark -

@interface TestJSViewController ()

@property(nonatomic) NSInteger top;

@end

@implementation TestJSViewController {
    JSContext *global;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:NSIntegerMax - 2014 - 8 - 7];
        
        global = [JSContext new];
        
        global.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            NSLog(@"exception: %@", exception);
        };
        
        global[@"console"] = @{ @"log": ^(NSString *message) {
            NSLog(@"js log: %@", message);
        }, @"dir": ^(NSDictionary *dict) {
            NSLog(@"js dir: %@", dict);
            for (id key in dict) {
                NSLog(@"    %@: %@", key, dict[key]);
            }
        } };
        
        global[@"NSObject"] = [NSObject class];
        global[@"UIColor"] = [UIColor class];
        global[@"UIView"] = [UIView class];
        
        global[@"self"] = self;
        
        [global evaluateScript:@"console.log(NSObject);"];
        [global evaluateScript:@"console.log(UIColor);"];
        [global evaluateScript:@"console.log(UIView);"];
        [global evaluateScript:@"console.log(self);"];
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
        [button setTitle:@"add" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonDidTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.layer.borderWidth = 0.5;
        button;
    })];
    
    global[@"canvas"] = self.view;
    self.top = CGRectGetMaxY(frame) + 20;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#define JS_RETURN ""

/* TODO:
 *  js swizzle method
 *  js create view from template, prepare for reuse, update with model
 *  js load data, data source
 *  js create view controller?
 */

- (void)buttonDidTapped:(UIButton *)button {
    NSString *js = @(
    /*
    "console.log(NSObject);"
    "var object = new NSObject();"
    "console.log(object);" */
    
    "var view = new UIView({ x: 20, y: self.top, width: 280, height: 44 });"
    "view.backgroundColor = UIColor.blueColor();"
    "view.alpha = 0.5;"
    "console.log(view.description());"
    
    "canvas.addSubview(view);"
    "/* view.removeFromSuperview(); */"
    
    "self.top += view.frame.height + 20;"
    
    JS_RETURN "view"
    );
    
    // JSValue *value =
    [global evaluateScript:js];
    // NSLog(@"%@", value);
    
    
    UIView *(^oc)() =  ^ {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, self.top, 280, 44)];
        view.backgroundColor = [UIColor blueColor];
        view.alpha = 0.5;
        NSLog(@"oc log: %@", view);
        
        [self.view addSubview:view];
        // [view removeFromSuperview];
        
        self.top += view.frame.size.height + 20;
        
        return view;
    };
    
    if (NO) oc();
}

@end
