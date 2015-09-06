//
//  M9JSONAdapter.h
//  BBSFramework
//
//  Created by MingLQ on 2015-09-02.
//  Copyright (c) 2013 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "MTLJSONAdapter.h"

#import <Mantle/MTLValueTransformer.h>

@interface M9JSONAdapter : MTLJSONAdapter

/**
 *  primitive type
 *  @see NSString+NSStringExtensionMethods - xxxValue
 */
+ (NSValueTransformer *)transformerForModelPropertiesOfObjCType:(const char *)objCType;

/**
 *  class
 */
+ (NSValueTransformer *)NSStringJSONTransformer;
+ (NSValueTransformer *)NSNumberJSONTransformer;

@end
