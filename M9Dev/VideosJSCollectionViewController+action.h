//
//  VideosJSCollectionViewController+action.h
//  M9Dev
//
//  Created by MingLQ on 2015-06-26.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import "VideosJSCollectionViewController.h"

#import "M9URLAction.h"

@interface VideosJSCollectionViewController (action)

- (void)openWithAction:(M9URLAction *)action finish:(M9URLActionFinishBlock)finish;
- (void)gotoWithAction:(M9URLAction *)action finish:(M9URLActionFinishBlock)finish;

@end
