//
//  M9Networking+.m
//  M9Dev
//
//  Created by MingLQ on 2014-07-15.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9Networking+.h"

@implementation M9Networking (finish)

- (M9RequestRef *)GET:(NSString *)URLString
               finish:(void (^)(id<M9ResponseRef> responseRef, id responseObject, NSError *error))finish {
    return [self GET:URLString parameters:nil finish:finish];
}

- (M9RequestRef *)GET:(NSString *)URLString
           parameters:(NSDictionary *)parameters
               finish:(void (^)(id<M9ResponseRef> responseRef, id responseObject, NSError *error))finish {
    return [self GET:URLString parameters:parameters success:^(id<M9ResponseRef> responseRef, id responseObject) {
        if (finish) {
            finish(responseRef, responseObject, nil);
        }
    } failure:^(id<M9ResponseRef> responseRef, NSError *error) {
        if (finish) {
            finish(responseRef, nil, error);
        }
    }];
}

- (M9RequestRef *)POST:(NSString *)URLString
            parameters:(NSDictionary *)parameters
                finish:(void (^)(id<M9ResponseRef> responseRef, id responseObject, NSError *error))finish {
    return [self POST:URLString parameters:parameters success:^(id<M9ResponseRef> responseRef, id responseObject) {
        if (finish) {
            finish(responseRef, responseObject, nil);
        }
    } failure:^(id<M9ResponseRef> responseRef, NSError *error) {
        finish(responseRef, nil, error);
    }];
}

@end
