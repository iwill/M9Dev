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

- (id)openWithAction:(URLAction *)action completion:(URLActionCompletionBlock)completion;
- (id)gotoWithAction:(URLAction *)action completion:(URLActionCompletionBlock)completion;

@end
