//
//  UIImageView+JS.h
//  M9Dev
//
//  Created by MingLQ on 2014-09-04.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "UIView+JS.h"
#import "UIImageView+WebCache.h"

@protocol UIImageViewExport <JSExport>

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)sd_cancelCurrentImageLoad;

@end

@interface UIImageView (JS) <UIViewExport, UIImageViewExport>

@end
