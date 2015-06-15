//
//  URLAction.m
//  M9Dev
//
//  Created by MingLQ on 2015-06-12.
//  Copyright (c) 2015年 iwill. All rights reserved.
//

#import "URLAction.h"

@interface URLAction ()

@property(nonatomic, strong) NSURLComponents *components;

@end

@implementation URLAction

+ (void)test {
    [URLAction setActionSettings:@{ @"action.test": @{ @"class":    [URLAction class],
                                                       @"target":   @"self",
                                                       @"action":   @"testWithAction:" }
                                    }];
}

+ (void)action {
}

static NSDictionary *ActionSettings = nil;

+ (NSDictionary *)actionSettings {@synchronized(self) {
    return ActionSettings;
}}

+ (void)setActionSettings:(NSDictionary *)actionSettings {@synchronized(self) {
    ActionSettings = [ActionSettings copy];
}}

+ (instancetype)actionWithURL:(NSString *)actionURL userInfo:(URLActionUserInfo *)userInfo {
    return [[self alloc] initWithURL:actionURL];
}

- (instancetype)initWithURL:(NSString *)actionURL {
    self = [super init];
    if (self) {
        self.components = [NSURLComponents componentsWithString:actionURL];
    }
    return self;
}

- (void)action {
}

@end
