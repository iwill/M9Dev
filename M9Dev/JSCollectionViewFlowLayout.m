//
//  JSCollectionViewFlowLayout.m
//  M9Dev
//
//  Created by MingLQ on 2014-09-05.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "JSCollectionViewFlowLayout.h"

#import "JSCore.h"

@implementation JSCollectionViewFlowLayout

- (void)setJsLayout:(JSValue *)jsLayout {
    _name = [jsLayout[@"name"] toString];
    _jsLayout = jsLayout;
    
    [_jsLayout callMethod:@"layout_setUp" withArguments:@[ self ]];
}

- (void)cell_setUp:(JSCollectionViewCell *)cell {
    [_jsLayout callMethod:@"cell_setUp" withArguments:@[ cell ]];
}

- (void)cell_prepareForReuse:(JSCollectionViewCell *)cell {
    [_jsLayout callMethod:@"cell_prepareForReuse" withArguments:@[ cell ]];
}

- (void)cell_update:(JSCollectionViewCell *)cell withData:(NSData *)data {
    [_jsLayout callMethod:@"cell_updateWithData" withArguments:@[ cell, data ]];
}

@end
