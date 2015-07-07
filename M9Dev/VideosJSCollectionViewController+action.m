//
//  VideosJSCollectionViewController+action.m
//  M9Dev
//
//  Created by MingLQ on 2015-06-26.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import "VideosJSCollectionViewController+action.h"

#import "UIViewController+.h"
#import "UINavigationController+.h"

@implementation VideosJSCollectionViewController (action)

- (void)openWithAction:(URLAction *)action next:(URLActionNextBlock)next {
    UIViewController *topViewController = [UIViewController topViewController];
    UINavigationController *navigationController = ([topViewController as:[UINavigationController class]]
                                                    OR topViewController.navigationController);
    if (navigationController) {
        [navigationController pushViewController:self animated:YES completion:^{
            if (next) next(nil);
        }];
    }
}

- (void)gotoWithAction:(URLAction *)action next:(URLActionNextBlock)next {
    __block UIViewController *rootViewController = [UIViewController gotoRootViewControllerAnimated:YES completion:^{
        UINavigationController *navigationController = [rootViewController as:[UINavigationController class]];
        if (navigationController) {
            [navigationController pushViewController:self animated:YES completion:^{
                if (next) next(nil);
            }];
        }
    }];
}

@end
