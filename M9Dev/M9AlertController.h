//
//  M9AlertController.h
//  M9Dev
//
//  Created by MingLQ on 2015-09-10.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "M9Utilities.h"
#import "NSArray+M9.h"
#import "NSObject+AssociatedValues.h"

@compatibility_alias M9AlertController UIResponder;

#pragma mark -

typedef NS_ENUM(NSInteger, M9AlertActionStyle) {
    M9AlertActionStyleDefault = 0,
    M9AlertActionStyleCancel,
    M9AlertActionStyleDestructive
};

@protocol M9AlertAction <NSObject>

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) M9AlertActionStyle style;
// @property (nonatomic, getter=isEnabled) BOOL enabled;

@end

#pragma mark -

typedef NS_ENUM(NSInteger, M9AlertControllerStyle) {
    M9AlertControllerStyleActionSheet = 0,
    M9AlertControllerStyleAlert
};

@protocol M9AlertController <NSObject>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, readonly) M9AlertControllerStyle preferredStyle;

@property (nonatomic, readonly) NSArray *actions;
@property (nonatomic, readonly) NSArray *textFields;

- (void)addActionWithTitle:(NSString *)title style:(M9AlertActionStyle)style handler:(void (^)(id<M9AlertAction> action))handler;
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;

- (void)presentFromViewController:(UIViewController *)presentingViewController animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)dismissAnimated:(BOOL)flag completion:(void (^)(void))completion;

- (UIAlertController *)asUIAlertController NS_AVAILABLE_IOS(8_0);
- (UIAlertView *)asUIAlertView NS_DEPRECATED_IOS(6_0, 8_0);
- (UIActionSheet *)asUIActionSheet NS_DEPRECATED_IOS(6_0, 8_0);

+ (M9AlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(M9AlertControllerStyle)preferredStyle;

@end

#pragma mark -

@interface M9AlertController (M9AlertController) <M9AlertController>

@end
