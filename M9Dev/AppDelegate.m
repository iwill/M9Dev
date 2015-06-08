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

@end
