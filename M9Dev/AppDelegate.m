//
//  AppDelegate.m
//  M9Dev
//
//  Created by iwill on 2014-07-05.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "AppDelegate.h"

#import "M9Networking.h"

#import "M9NetworkingViewController.h"
#import "JSLayoutViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // M9NETWORKING.requestConfig.baseURL = [NSURL URLWithString:@"http://localhost:3000"];
    M9NETWORKING.requestConfig.baseURL = [NSURL URLWithString:@"http://10.2.10.187:3000"];
    M9NETWORKING.requestConfig.dataParser = M9ResponseDataParser_All;
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[ ({ [JSLayoutViewController new]; }),
                                          ({ [M9NetworkingViewController new]; }) ];
    tabBarController.tabBarController.tabBar.barStyle = UIBarStyleBlack;
    tabBarController.tabBarController.tabBar.translucent = NO;
    self.window.rootViewController = tabBarController;
    
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
