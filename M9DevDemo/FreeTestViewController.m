//
//  FreeTestViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-09-18.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "FreeTestViewController.h"

#import "UIControl+M9EventCallback.h"

static const CGFloat margin = 10, height = 44;

@implementation FreeTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"free test";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.alwaysBounceVertical = YES;
    
    UIView *prevView = nil;
    
    {
        UIButton *button = [self addButtonWithTitle:@"test ifNotStrong" nextTo:prevView];
        weakdef(self, button);
        [button addEventCallback:^(id sender) {
            strongdef_ifNOT(self, button) return;
            button.selected = !button.selected;
        } forControlEvents:UIControlEventTouchUpInside];
        prevView = button;
    }
    
    {
        UIButton *button = [self addButtonWithTitle:@"test ifNotStrong(nil)" nextTo:prevView];
        id nill = nil;
        weakdef(self, button, nill);
        [button addEventCallback:^(id sender) {
            strongdef_ifNOT(self, button, nill) return;
            button.selected = !button.selected;
        } forControlEvents:UIControlEventTouchUpInside];
        prevView = button;
    }
    
    {
        NSString *string = @"UserA reply to UserB: hello";
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
        [text addAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:[UIFont buttonFontSize]] } range:NSMakeRange(0, text.length)];
        [text addAttributes:@{ NSLinkAttributeName: @"http://www.google.com" } range:[string rangeOfString:@"UserA"]];
        [text addAttributes:@{ NSLinkAttributeName: @"http://www.google.com" } range:[string rangeOfString:@"UserB"]];
        /* NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [text addAttributes:@{ NSParagraphStyleAttributeName: paragraphStyle } range:NSMakeRange(0, text.length)]; */
        
        UITextView *textView = [UITextView new];
        textView.attributedText = text;
        textView.backgroundColor = [UIColor lightGrayColor];
        textView.linkTextAttributes = @{ NSForegroundColorAttributeName: [UIColor redColor] };
        textView.textAlignment = NSTextAlignmentCenter;
        textView.editable = NO;
        textView.selectable = NO;
        
        [self.scrollView addSubview:textView];
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).with.offset(margin);
            make.right.equalTo(self.view).with.offset(- margin);
            if (!prevView) {
                make.top.equalTo(self.scrollView).with.offset(margin);
            }
            else {
                make.top.equalTo(prevView.mas_bottom).with.offset(margin);
            }
            make.height.mas_equalTo(height);
        }];
        prevView = textView;
    }
    
    [prevView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.scrollView).with.offset(margin);
    }];
}

- (UIButton *)addButtonWithTitle:(NSString *)title nextTo:(UIView *)prevView {
    UIButton *button = [UIButton new];
    button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    button.backgroundColor = [UIColor lightGrayColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    
    [self.scrollView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(margin);
        make.right.equalTo(self.view).with.offset(- margin);
        if (!prevView) {
            make.top.equalTo(self.scrollView).with.offset(margin);
        }
        else {
            make.top.equalTo(prevView.mas_bottom).with.offset(margin);
        }
        make.height.mas_equalTo(height);
    }];
    
    return button;
}

@end
