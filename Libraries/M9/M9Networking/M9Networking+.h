//
//  M9Networking+.h
//  M9Dev
//
//  Created by MingLQ on 2014-07-15.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import "M9Networking.h"

#pragma mark -

@interface M9Networking (finish)

- (M9RequestRef *)GET:(NSString *)URLString
               finish:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject, NSError *error))finish;
- (M9RequestRef *)GET:(NSString *)URLString
           parameters:(NSDictionary *)parameters
               finish:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject, NSError *error))finish;
- (M9RequestRef *)POST:(NSString *)URLString
            parameters:(NSDictionary *)parameters
                finish:(void (^)(id<M9ResponseInfo> responseInfo, id responseObject, NSError *error))finish;

@end
