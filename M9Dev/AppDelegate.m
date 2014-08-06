//
//  AppDelegate.m
//  M9Dev
//
//  Created by iwill on 2014-07-05.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "AppDelegate.h"

#import "M9NetworkingViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[ ({ [M9NetworkingViewController new]; }),
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
