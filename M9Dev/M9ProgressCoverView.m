//
//  M9ProgressCoverView.m
//  M9Dev
//
//  Created by MingLQ on 2015-10-20.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "M9ProgressCoverView.h"

@interface M9ProgressCoverView ()

@property (nonatomic, readwrite) UILabel *progressLabel;
@property (nonatomic, readwrite) UIView *progressView;

@end

@implementation M9ProgressCoverView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.15];
        
        self.floatEdge = UIRectEdgeTop;
        self.removeFromSuperViewOnCompleted = YES;
        
        self.progressLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            _RETURN label;
        });
        [self addSubview:self.progressLabel];
        [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.progressView = ({
            UIView *view = [[UIView alloc] initWithFrame:self.bounds];
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
            _RETURN view;
        });
        [self addSubview:self.progressView];
        
        self.hidden = YES;
    }
    return self;
}

- (void)updateConstraints {
    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        switch (self.floatEdge) {
            case UIRectEdgeLeft:
                make.width.equalTo(self).multipliedBy(self.progress);
                make.right.and.bottom.equalTo(self);
                break;
            case UIRectEdgeRight:
                make.width.equalTo(self).multipliedBy(self.progress);
                make.left.top.and.bottom.equalTo(self);
                break;
            case UIRectEdgeBottom:
                make.height.equalTo(self).multipliedBy(self.progress);
                make.left.right.and.top.equalTo(self);
                break;
            default:
                make.height.equalTo(self).multipliedBy(self.progress);
                make.left.right.and.bottom.equalTo(self);
                break;
        }
    }];
    [super updateConstraints];
}

- (void)setProgress:(CGFloat)progress {
    self.completed = NO;
    
    progress = MIN(MAX(progress, 0.0), 1.0);
    _progress = progress;
    self.progressLabel.text = [NSString stringWithFormat:@" %ld%%", (long)floor(progress * 100)];
    
    [self setNeedsUpdateConstraints];
}

@dynamic completed;

- (BOOL)isCompleted {
    return self.hidden;
}

- (void)setCompleted:(BOOL)completed {
    if (completed) {
        self.progress = 0.0;
    }
    
    BOOL removeFromSuperView = (self.removeFromSuperViewOnCompleted
                                && (!self.completed && completed));
    
    self.hidden = completed;
    
    if (removeFromSuperView) {
        [self removeFromSuperview];
    }
}

@end
