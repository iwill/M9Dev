//
//  JSCollectionViewFlowLayout.m
//  M9Dev
//
//  Created by MingLQ on 2014-09-05.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "JSCollectionViewFlowLayout.h"

#import "JSCore.h"

@interface JSCollectionViewFlowLayout ()

@end

@implementation JSCollectionViewFlowLayout {
    JSManagedValue *_jsLayout;
}

@dynamic jsLayout;

- (JSValue *)jsLayout {
    return _jsLayout.value;
}

- (void)setJsLayout:(JSValue *)jsLayout {
    _name = [jsLayout[@"name"] toString];
    // !!!: JSManagedValue & Managed References - https://developer.apple.com/videos/wwdc/2013/?id=615
    _jsLayout = [JSManagedValue managedValueWithValue:jsLayout];
    [jsLayout.context.virtualMachine addManagedReference:_jsLayout withOwner:self];
    
    [_jsLayout.value callMethod:@"layout_setUp" withArguments:@[ self ]];
}

- (void)cell_setUp:(JSCollectionViewCell *)cell {
    [_jsLayout.value callMethod:@"cell_setUp" withArguments:@[ cell ]];
}

- (void)cell_prepareForReuse:(JSCollectionViewCell *)cell {
    [_jsLayout.value callMethod:@"cell_prepareForReuse" withArguments:@[ cell ]];
}

- (void)cell_update:(JSCollectionViewCell *)cell withData:(NSData *)data {
    [_jsLayout.value callMethod:@"cell_updateWithData" withArguments:@[ cell, data ]];
}

@end
