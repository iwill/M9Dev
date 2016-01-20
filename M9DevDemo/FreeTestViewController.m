//
//  FreeTestViewController.m
//  M9Dev
//
//  Created by MingLQ on 2015-09-18.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "FreeTestViewController.h"

#import "UIControl+M9EventCallback.h"
#import "M9Link.h"
#import "UIView+M9.h"

#import "NSThread+M9.h"

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
        NSString *string = @
        "Returns the index of the glyph falling under the given point, expressed in the given container's coordinate system. "
        "UserA reply to UserB: hello"
        " If no glyph is under the point, the nearest glyph is returned, where nearest is defined according to the requirements of selection by touch or mouse."
        ;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
        [text addAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:[UIFont buttonFontSize]],
                               NSParagraphStyleAttributeName: ({
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.alignment = NSTextAlignmentCenter
            _RETURN paragraphStyle;
        }) }
                      range:NSMakeRange(0, text.length)];
        
        /* // UITextView
        [text addAttributes:@{ NSLinkAttributeName: @"http://www.google.com" }
                      range:[string rangeOfString:@"UserA"]];
        [text addAttributes:@{ NSLinkAttributeName: @"http://www.google.com" }
                      range:[string rangeOfString:@"UserB"]];
        UITextView *textView = [UITextView new];
        textView.linkTextAttributes = @{ NSForegroundColorAttributeName: [UIColor redColor] };
        textView.editable = NO;
        textView.selectable = NO;
        [textView enableLinkWithCallback:^(UITextView *textView, NSString *urlString, NSRange range) {
            NSLog(@"%@: %@", [textView.attributedText.string substringWithRange:range], urlString);
        }]; // */
        
        // /* // UILabel
        NSTextAttachment *linkAttachment = [NSTextAttachment new];
        linkAttachment.linkURL = @"http://www.google.com";
        [text addAttributes:@{ NSAttachmentAttributeName: linkAttachment,
                               NSForegroundColorAttributeName: [UIColor redColor] }
                      range:[string rangeOfString:@"UserA"]];
        [text addAttributes:@{ NSAttachmentAttributeName: linkAttachment,
                               NSForegroundColorAttributeName: [UIColor redColor] }
                      range:[string rangeOfString:@"UserB"]];
        UILabel *textView = [UILabel new];
        textView.numberOfLines = 0;
        textView.userInteractionEnabled = YES;
        [textView enableLinkWithCallback:^(UILabel *label, NSString *urlString, NSRange range) {
            NSLog(@"%@: %@", [label.attributedText.string substringWithRange:range], urlString);
        }]; // */
        
        textView.backgroundColor = [UIColor lightGrayColor];
        textView.attributedText = text;
        // [textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapWithGestureRecognizer:)]];
        
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
            make.height.mas_equalTo(120);
        }];
        prevView = textView;
    }
    
    {
        UIButton *button = [self addButtonWithTitle:@"test thread" nextTo:prevView];
        weakdef(self);
        [button addEventCallback:^(id sender) {
            strongdef_ifNOT(self) return;
            // [self performSelectorInBackground:@selector(suspend) withObject:nil];
            dispatch_async_background_queue(^{
                NSThread *thread = [NSThread currentThread];
                [self performSelector:@selector(resume) withObject:nil afterDelay:5];
                /* dispatch_after_seconds(2, dispatch_get_main_queue(), ^{
                    NSLog(@"<#NSThread+M9#>: 2 before resume");
                    [thread resume];
                    NSLog(@"<#NSThread+M9#>: 3 after resume");
                }); */
                NSLog(@"<#NSThread+M9#>: 1 before suspend");
                BOOL suspend = [thread suspend];
                NSLog(@"<#NSThread+M9#>: 4 after suspend - %@", NSStringFromBOOL(suspend));
            });
        } forControlEvents:UIControlEventTouchUpInside];
        prevView = button;
    }
    
    {
        UIButton *button = [UIButton new];
        button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        button.backgroundColor = [UIColor lightGrayColor];
        [button setTitle:@"test alignmentRectInsets" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        
        button.alignmentRectInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        
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
        
        /* weakdef(self);
        [button addEventCallback:^(id sender) {
            strongdef_ifNOT(self) return;
            
        } forControlEvents:UIControlEventTouchUpInside]; */
        prevView = button;
    }
    
    [prevView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.scrollView).with.offset(margin);
    }];
}

- (void)resume {
    NSLog(@"<#NSThread+M9#>: 2 before resume");
    [[NSThread currentThread] resume];
    NSLog(@"<#NSThread+M9#>: 3 after resume");
}

- (void)didTapWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    /* [label.attributedText enumerateAttributesInRange:NSMakeRange(0, label.attributedText.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
    }]; */
    
    /* UITextPosition *tapPosition = [label closestPositionToPoint:tapLocation];
    NSDictionary *tapAttributes = [label textStylingAtPosition:tapPosition inDirection:UITextStorageDirectionForward];
    id urlObject = tapAttributes[NSLinkAttributeName];
    NSURL *tapURL = [urlObject as:[NSURL class]] OR [NSURL URLWithString:urlObject];
    if (tapURL) {
        [self textView:label shouldInteractWithURL:tapURL inRange:NSMakeRange(0, 0)];
        return;
    } */
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
