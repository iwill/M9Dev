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
        NSTextAttachment *linkAttachment = [NSTextAttachment new];
        linkAttachment.fileType = NSLinkAttributeName;
        linkAttachment.contents = [@"http://www.google.com" dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *string = @
        "Returns the index of the glyph falling under the given point, expressed in the given container's coordinate system."
        "UserA reply to UserB: hello"
        "If no glyph is under the point, the nearest glyph is returned, where nearest is defined according to the requirements of selection by touch or mouse."
        ;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
        [text addAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:[UIFont buttonFontSize]],
                               NSParagraphStyleAttributeName: ({
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.alignment = NSTextAlignmentCenter
            _RETURN paragraphStyle;
        }) }
                      range:NSMakeRange(0, text.length)];
        [text addAttributes:@{ // NSLinkAttributeName: @"http://www.google.com",
                               NSAttachmentAttributeName: linkAttachment,
                               NSForegroundColorAttributeName: [UIColor redColor] }
                      range:[string rangeOfString:@"UserA"]];
        [text addAttributes:@{ // NSLinkAttributeName: @"http://www.google.com",
                               NSAttachmentAttributeName: linkAttachment,
                               NSForegroundColorAttributeName: [UIColor redColor] }
                      range:[string rangeOfString:@"UserB"]];
        
        // A: UITextView
        UITextView *textView = [UITextView new];
        // textView.linkTextAttributes = @{ NSForegroundColorAttributeName: [UIColor redColor] };
        textView.editable = NO;
        textView.selectable = NO;
        [textView enableLinkWithCallback:^(UITextView *textView, NSString *urlString) {
            NSLog(@"urlString: %@", urlString);
        }];
        
        /* // B: UILabel
        UILabel *textView = [UILabel new];
        textView.numberOfLines = 0;
        textView.userInteractionEnabled = YES;
        [textView enableLinkWithCallback:^(UILabel *label, NSString *urlString) {
            NSLog(@"urlString: %@", urlString);
        }]; */
        
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
    
    [prevView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.scrollView).with.offset(margin);
    }];
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
