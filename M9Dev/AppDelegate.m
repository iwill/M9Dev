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
#import "NSURL+M9Categories.h"

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
    
    [URLAction setActionSettings:@{ @"action.hello":
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
                                                                   actionSelector:@selector(testWithAction:completion:)]
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
    if ([url.host isEqualToString:@"action"]) {
        NSString *actionString = [url.queryDictionary stringForKey:@"url"];
        
        // !!!: do this in action 1.0 manager
        
        NSURL *actionURL = [NSURL URLWithString:actionString];
        if ([actionURL.scheme isEqualToString:@"act"]) {
            NSString *actionVersion = [actionURL.queryDictionary stringForKey:@"-av-"];
            // TODO: version compare
            if (!actionVersion.length) {
                actionURL = nil; // TODO: translate to action 2.0 if action 1.0
            }
            
            // filter action 2.0
            if ([URLAction performActionWithURLString:actionString source:self]) {
                NSLog(@"action 2.0: %@", actionString);
            }
            // forward action 1.0
            else {
                NSLog(@"action 1.0: %@", actionString);
            }
            return YES;
        }
    }
    return NO;
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
