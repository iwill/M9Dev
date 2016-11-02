//
//  M9ProgressCoverView.h
//  M9Dev
//
//  Created by MingLQ on 2015-10-20.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

#import "M9Utilities.h"

@interface M9ProgressCoverView : UIView

@property (nonatomic, readonly) UILabel *progressLabel;
@property (nonatomic, readonly) UIView *progressView;

@property (nonatomic) UIRectEdge floatEdge; // default: UIRectEdgeTop
@property (nonatomic) BOOL removeFromSuperViewOnCompleted; // default: YES

@property (nonatomic) CGFloat progress;
@property (nonatomic, getter=isCompleted) BOOL completed;

@end
