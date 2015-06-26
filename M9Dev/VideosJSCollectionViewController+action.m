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

- (id)openWithAction:(URLAction *)action completion:(URLActionCompletionBlock)completion {
    UIViewController *sourceViewController = [action sourceViewControllerForTargetViewController:self];
    if (sourceViewController.navigationController) {
        [sourceViewController.navigationController pushViewController:self animated:YES completion:^{
            if (completion) completion(YES, nil);
        }];
    }
    else {
        if (completion) completion(YES, nil);
    }
    return self;
}

- (id)gotoWithAction:(URLAction *)action completion:(URLActionCompletionBlock)completion {
    __block UIViewController *rootViewController = [UIViewController gotoRootViewControllerAnimated:YES completion:^{
        UINavigationController *navigationController = [rootViewController as:[UINavigationController class]];
        if (navigationController) {
            [navigationController pushViewController:self animated:YES completion:^{
                if (completion) completion(YES, nil);
            }];
        }
        else {
            if (completion) completion(YES, nil);
        }
    }];
    return self;
}

@end
