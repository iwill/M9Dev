//
//  UIScrollViewController.h
//  M9Dev
//
//  Created by MingLQ on 2014-08-22.
//  Copyright (c) 2014 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <UIKit/UIKit.h>

/**
 *  default values:
 *      autoresizingMask:       W + H
 *      autoResizeWidth:        NO
 *      autoResizeHeight:       NO
 *      marginRight:            0
 *      marginBottom:           0
 */
@interface UIAutoResizeScrollView : UIScrollView

@property(nonatomic) BOOL autoResizeWidth, autoResizeHeight;
@property(nonatomic) CGFloat marginRight, marginBottom;

@end

#pragma mark -

@interface UIScrollViewController : UIViewController

@property(nonatomic, strong) UIAutoResizeScrollView *scrollView;

@end
