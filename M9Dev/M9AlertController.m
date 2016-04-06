//
//  M9AlertController.m
//  M9Dev
//
//  Created by MingLQ on 2015-09-10.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "M9AlertController.h"

static void *M9AlertController_allActions = &M9AlertController_allActions;

#pragma mark - UIAlertAction

@interface UIAlertAction (M9AlertAction) <M9AlertAction>

@end

@implementation UIAlertAction (M9AlertAction)

@end

#pragma mark - UIAlertController

@interface UIAlertController (M9AlertController) <M9AlertController>

@end

@implementation UIAlertController (M9AlertController)

- (void)addActionWithTitle:(NSString *)title style:(M9AlertActionStyle)style handler:(void (^)(id<M9AlertAction> action))handler {
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:(UIAlertActionStyle)style handler:^(UIAlertAction *action) {
        if (handler) {
            handler(action);
        }
    }];
    [self addAction:alertAction];
}

- (void)presentFromViewController:(UIViewController *)presentingViewController animated:(BOOL)flag completion:(void (^)(void))completion {
    [presentingViewController presentViewController:self animated:flag completion:completion];
}

- (void)dismissAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self dismissViewControllerAnimated:flag completion:completion];
}

- (UIAlertController *)asUIAlertController {
    return [self as:[UIAlertController class]];
}

- (UIAlertView *)asUIAlertView {
    return [self as:[UIAlertView class]];
}

- (UIActionSheet *)asUIActionSheet {
    return [self as:[UIActionSheet class]];
}

@end

#pragma mark - M9AlertAction

@interface M9AlertAction : NSObject <M9AlertAction>

+ (instancetype)actionWithTitle:(NSString *)title style:(M9AlertActionStyle)style handler:(void (^)(id<M9AlertAction> action))handler;

@end

@interface M9AlertAction ()

@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) M9AlertActionStyle style;

@property (nonatomic, copy) void (^handler)(id<M9AlertAction> action);

@end

@implementation M9AlertAction

// @synthesize enabled;

+ (instancetype)actionWithTitle:(NSString *)title style:(M9AlertActionStyle)style handler:(void (^)(id<M9AlertAction> action))handler {
    M9AlertAction *alertAction = [self new];
    alertAction.title = title;
    alertAction.style = style;
    alertAction.handler = handler;
    return alertAction;
}

@end

#pragma mark - _M9AlertControllerDelegate

@interface _M9AlertControllerDelegate : NSObject <UIAlertViewDelegate, UIActionSheetDelegate>

@end

@implementation _M9AlertControllerDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    id<M9AlertController> alertController = (id<M9AlertController>)alertView;
    M9AlertAction *alertAction = [alertController.actions objectOrNilAtIndex:buttonIndex];
    if (alertAction.handler) {
        alertAction.handler(alertAction);
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    id<M9AlertController> alertController = (id<M9AlertController>)actionSheet;
    M9AlertAction *alertAction = [alertController.actions objectOrNilAtIndex:buttonIndex];
    if (alertAction.handler) {
        alertAction.handler(alertAction);
    }
}

@end

static _M9AlertControllerDelegate *AlertControllerDelegate = nil;

#pragma mark - UIAlertView

@interface UIAlertView (M9AlertController) <M9AlertController>

@property (nonatomic, strong) NSMutableArray *allActions;

@property (nonatomic, readonly) NSArray *actions;
@property (nonatomic, readonly) NSArray *textFields;

@end

@implementation UIAlertView (M9AlertController)

@dynamic allActions;

- (NSMutableArray *)allActions {
    return [self associatedValueForKey:M9AlertController_allActions];
}

- (void)setAllActions:(NSMutableArray *)allActions {
    [self associateValue:allActions withKey:M9AlertController_allActions];
}


- (M9AlertControllerStyle)preferredStyle {
    return M9AlertControllerStyleAlert;
}

- (NSArray *)actions {
    return [self.allActions copy];
}

- (NSArray *)textFields {
    switch (self.alertViewStyle) {
        case UIAlertViewStylePlainTextInput:
            return @[ [self textFieldAtIndex:0] ];
        case UIAlertViewStyleSecureTextInput:
            return @[ [self textFieldAtIndex:0] ];
        case UIAlertViewStyleLoginAndPasswordInput:
            return @[ [self textFieldAtIndex:0], [self textFieldAtIndex:1] ];
        default:
            return nil;
    }
}

+ (M9AlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(M9AlertControllerStyle)preferredStyle {
    AlertControllerDelegate = AlertControllerDelegate OR [_M9AlertControllerDelegate new];
    return [[UIAlertView alloc] initWithTitle:title message:message delegate:AlertControllerDelegate cancelButtonTitle:nil otherButtonTitles:nil];
}

- (void)addActionWithTitle:(NSString *)title style:(M9AlertActionStyle)style handler:(void (^)(id<M9AlertAction> action))handler {
    id<M9AlertAction> alertAction = [M9AlertAction actionWithTitle:title style:style handler:handler];
    if (!self.allActions) {
        self.allActions = [NSMutableArray new];
    }
    [self.allActions addObject:alertAction];
    
    if (style == M9AlertActionStyleCancel) {
        self.cancelButtonIndex = self.numberOfButtons;
    }
    [self addButtonWithTitle:title];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler {
    NSLog(@"You can add a text fields by setting the <#alertViewStyle#> property of <#UIAlertView#>.");
}

- (void)presentFromViewController:(UIViewController *)presentingViewController animated:(BOOL)flag completion:(void (^)(void))completion {
    [self show];
    if (completion) {
        completion();
    }
}

- (void)dismissAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self dismissWithClickedButtonIndex:self.cancelButtonIndex animated:flag];
    if (completion) {
        completion();
    }
}

- (UIAlertController *)asUIAlertController {
    return [self as:NSClassFromString(@"UIAlertController")];
}

- (UIAlertView *)asUIAlertView {
    return [self as:[UIAlertView class]];
}

- (UIActionSheet *)asUIActionSheet {
    return [self as:[UIActionSheet class]];
}

@end

#pragma mark - UIActionSheet

@interface UIActionSheet (M9AlertController) <M9AlertController>

@property (nonatomic, strong) NSMutableArray *allActions;

@property (nonatomic, readonly) NSArray *actions;
@property (nonatomic, readonly) NSArray *textFields;

@end

@implementation UIActionSheet (M9AlertController)

@dynamic allActions;

- (NSMutableArray *)allActions {
    return [self associatedValueForKey:M9AlertController_allActions];
}

- (void)setAllActions:(NSMutableArray *)allActions {
    [self associateValue:allActions withKey:M9AlertController_allActions];
}

- (NSString *)message {
    return nil;
}

- (void)setMessage:(NSString *)message {
}

- (M9AlertControllerStyle)preferredStyle {
    return M9AlertControllerStyleActionSheet;
}

- (NSArray *)actions {
    return [self.allActions copy];
}

- (NSArray *)textFields {
    return nil;
}

+ (M9AlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(M9AlertControllerStyle)preferredStyle {
    // title = [NSString stringWithFormat:@"%@: %@", title, message];
    AlertControllerDelegate = AlertControllerDelegate OR [_M9AlertControllerDelegate new];
    return [[UIActionSheet alloc] initWithTitle:title delegate:AlertControllerDelegate cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
}

- (void)addActionWithTitle:(NSString *)title style:(M9AlertActionStyle)style handler:(void (^)(id<M9AlertAction> action))handler {
    id<M9AlertAction> alertAction = [M9AlertAction actionWithTitle:title style:style handler:handler];
    if (!self.allActions) {
        self.allActions = [NSMutableArray new];
    }
    [self.allActions addObject:alertAction];
    
    if (style == M9AlertActionStyleCancel) {
        self.cancelButtonIndex = self.numberOfButtons;
    }
    else if (style == M9AlertActionStyleDestructive) {
        self.destructiveButtonIndex = self.numberOfButtons;
    }
    [self addButtonWithTitle:title];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler {
    NSLog(@"You can add a text field only if the <#preferredStyle#> property is set to <#M9AlertControllerStyleAlert#>.");
}

- (void)presentFromViewController:(UIViewController *)presentingViewController animated:(BOOL)flag completion:(void (^)(void))completion {
    [self showInView:presentingViewController.view];
    if (completion) {
        completion();
    }
}

- (void)dismissAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self dismissWithClickedButtonIndex:self.cancelButtonIndex animated:flag];
    if (completion) {
        completion();
    }
}

- (UIAlertController *)asUIAlertController {
    return [self as:NSClassFromString(@"UIAlertController")];
}

- (UIAlertView *)asUIAlertView {
    return [self as:[UIAlertView class]];
}

- (UIActionSheet *)asUIActionSheet {
    return [self as:[UIActionSheet class]];
}

@end


#pragma mark - M9AlertController

@implementation M9AlertController (M9AlertController)

@dynamic actions, textFields, title, message, preferredStyle;

+ (M9AlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(M9AlertControllerStyle)preferredStyle {
    if (NSClassFromString(@"UIAlertController")) {
        return [UIAlertController alertControllerWithTitle:title
                                                   message:message
                                            preferredStyle:(UIAlertControllerStyle)preferredStyle];
    }
    
    if (preferredStyle == M9AlertControllerStyleActionSheet) {
        return [UIActionSheet alertControllerWithTitle:title
                                               message:message
                                        preferredStyle:preferredStyle];
    }
    
    return [UIAlertView  alertControllerWithTitle:title
                                          message:message
                                   preferredStyle:preferredStyle];
}

- (void)addActionWithTitle:(NSString *)title style:(M9AlertActionStyle)style handler:(void (^)(id<M9AlertAction> action))handler {
#if !defined(__OPTIMIZE__)
    [self doesNotRecognizeSelector:_cmd];
#endif
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler {
#if !defined(__OPTIMIZE__)
    [self doesNotRecognizeSelector:_cmd];
#endif
}

- (void)presentFromViewController:(UIViewController *)presentingViewController animated:(BOOL)flag completion:(void (^)(void))completion {
#if !defined(__OPTIMIZE__)
    [self doesNotRecognizeSelector:_cmd];
#endif
}

- (void)dismissAnimated:(BOOL)flag completion:(void (^)(void))completion {
#if !defined(__OPTIMIZE__)
    [self doesNotRecognizeSelector:_cmd];
#endif
}

- (UIAlertController *)asUIAlertController {
#if !defined(__OPTIMIZE__)
    [self doesNotRecognizeSelector:_cmd];
#endif
    return nil;
}

- (UIAlertView *)asUIAlertView {
#if !defined(__OPTIMIZE__)
    [self doesNotRecognizeSelector:_cmd];
#endif
    return nil;
}

- (UIActionSheet *)asUIActionSheet {
#if !defined(__OPTIMIZE__)
    [self doesNotRecognizeSelector:_cmd];
#endif
    return nil;
}

@end
