//
//  VideosJSCollectionViewController+action.h
//  M9Dev
//
//  Created by MingLQ on 2015-06-26.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import "VideosJSCollectionViewController.h"

#import "URLAction.h"

@interface VideosJSCollectionViewController (action)

- (void)openWithAction:(URLAction *)action finish:(URLActionFinishBlock)finish;
- (void)gotoWithAction:(URLAction *)action finish:(URLActionFinishBlock)finish;

@end
