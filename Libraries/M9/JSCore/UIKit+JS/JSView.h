//
//  JSView.h
//  M9Dev
//
//  Created by MingLQ on 2014-08-11.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+JS.h"

@interface JSView : UIView

@end

@protocol JSViewExport <JSExport>

@property(nonatomic, strong) NSMutableDictionary *keyedSubviews;

@end

@interface JSValue (JS) <UIViewExport, JSViewExport>

@property(nonatomic, strong) NSMutableDictionary *keyedSubviews;

@end
