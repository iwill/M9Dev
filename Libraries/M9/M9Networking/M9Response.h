//
//  M9Response.h
//  M9Dev
//
//  Created by iwill on 2014-07-06.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol M9Response <NSObject>

@property(nonatomic, strong) NSURLRequest *request;
@property(nonatomic, strong) NSHTTPURLResponse *response;

@property(nonatomic, strong) NSData *responseData;
@property(nonatomic, strong) NSString *responseString;
@property(nonatomic, strong) id responseObject;
@property(nonatomic, strong) NSError *error;

@end
