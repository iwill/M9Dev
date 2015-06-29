//
//  AppDelegate.m
//  M9Dev
//
//  Created by iwill on 2014-07-05.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "AppDelegate.h"

#import "M9Utilities.h"
#import "M9Networking.h"

#import "M9DevTestTableViewController.h"
#import "URLAction.h"
#import "URLAction+1.0.h"
#import "VideosJSCollectionViewController+action.h"

#define APP_VERSION_KEY @"CFBundleShortVersionString"
#define APP_VERSION [[[NSBundle mainBundle] objectForInfoDictionaryKey:APP_VERSION_KEY] description]

#define APP_BUILD_VERSION_KEY @"CFBundleVersion"
#define APP_BUILD_VERSION [[[NSBundle mainBundle] objectForInfoDictionaryKey:APP_BUILD_VERSION_KEY] description]

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"<#format#>: %@ - %@", APP_VERSION, APP_BUILD_VERSION);
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // M9NETWORKING.requestConfig.baseURL = [NSURL URLWithString:@"http://localhost:3000"];
    M9NETWORKING.requestConfig.baseURL = [NSURL URLWithString:@"http://10.2.10.187:3000"];
    M9NETWORKING.requestConfig.dataParser = M9ResponseDataParser_All;
    
    UIViewController *rootViewController = [[M9DevTestTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    [URLAction setActionSettings:
     @{ @"action.hello":
            [URLActionSetting actionSettingWithBlock:^id(URLAction *action, URLActionCompletionBlock completion)
             {
                 NSLog(@"%@ : %@ ? %@ # %@",
                       action.actionKey,
                       action.actionURL,
                       action.parameters,
                       action.nextActionURL);
                 if (completion) completion(YES, @{ @"x": @1, @"y": @2 });
                 return nil;
             }],
        @"action.test":
            [URLActionSetting actionSettingWithTarget:self
                                       actionSelector:@selector(testWithAction:completion:)],
        @"webview.open":
            [URLActionSetting actionSettingWithBlock:^id(URLAction *action, URLActionCompletionBlock completion)
             {
                 NSLog(@"%@ : %@ ? %@ # %@",
                       action.actionKey,
                       action.actionURL,
                       action.parameters,
                       action.nextActionURL);
                 if (completion) completion(YES, @{ @"x": @1, @"y": @2 });
                 return nil;
             }],
        @"channel.goto":
            [URLActionSetting actionSettingWithBlock:^id(URLAction *action, URLActionCompletionBlock completion)
             {
                 NSLog(@"%@ : %@ ? %@ # %@",
                       action.actionKey,
                       action.actionURL,
                       action.parameters,
                       action.nextActionURL);
                 if (completion) completion(YES, @{ @"x": @1, @"y": @2 });
                 return nil;
             }],
        @"videos.open":
            [URLActionSetting actionSettingWithTarget:[VideosJSCollectionViewController class]
                                     instanceSelector:@selector(new)
                                       actionSelector:@selector(openWithAction:completion:)],
        @"videos.goto":
            [URLActionSetting actionSettingWithTarget:[VideosJSCollectionViewController class]
                                     instanceSelector:@selector(new)
                                       actionSelector:@selector(gotoWithAction:completion:)],
        @"root.goto":
            [URLActionSetting actionSettingWithBlock:^id(URLAction *action, URLActionCompletionBlock completion)
             {
                 __block UIViewController *rootViewController = [UIViewController gotoRootViewControllerAnimated:YES completion:^{
                     if (completion) completion(YES, @{ @"key": @"value" });
                 }];
                 return [rootViewController as:[UINavigationController class]];
             }]
        }];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"got url: %@", url);
    
    NSURL *actionURL = nil;
    if ([url.host isEqualToString:@"action"]) {
        NSString *actionString = [url.queryDictionary stringForKey:@"url"];
        actionURL = [NSURL URLWithString:actionString];
        NSLog(@"action 2.0: %@", actionURL);
    }
    else if ([[url.host lowercaseString] isEqualToString:@"action.cmd"]
             || [[url.path lowercaseString] isEqualToString:@"//action.cmd"]) {
        actionURL = [URLAction actionURLFrom_1_0:[url absoluteString]];
        NSLog(@"translate to action 2.0: %@", actionURL);
    }
    
    // !!!: do this in action 1.0 manager
    
    // filter action 2.0
    if ([actionURL.scheme isEqualToString:@"sva"]
        && [URLAction performActionWithURL:actionURL source:self]) {
        NSLog(@"action 2.0");
    }
    // forward action 1.0, a new method without translating
    else {
        NSLog(@"action 1.0");
    }
    
    return YES;
}

- (id)testWithAction:(URLAction *)action completion:(URLActionCompletionBlock)completion {
    NSLog(@"%@ : %@ ? %@ # %@ - %@",
          action.actionKey,
          action.actionURL,
          action.parameters,
          action.nextActionURL,
          action.prevActionResult);
    if (completion) completion(YES, nil);
    return nil;
}

@end
