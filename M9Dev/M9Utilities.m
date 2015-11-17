//
//  M9Utilities.m
//  M9Dev
//
//  Created by MingLQ on 2013-06-26.
//  Copyright (c) 2013 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "M9Utilities.h"

@implementation NSObject (ReturnSelfIf)

- (id)if:(BOOL)condition {
    return condition ? self : nil;
}

- (instancetype)as:(Class)clazz {
    return [self if:[self isKindOfClass:clazz]];
}

- (id)asMemberOfClass:(Class)clazz {
    return [self if:[self isMemberOfClass:clazz]];
}

- (id)asProtocol:(Protocol *)protocol {
    return [self if:[self conformsToProtocol:protocol]];
}

- (id)ifRespondsToSelector:(SEL)selector {
    return [self if:[self respondsToSelector:selector]];
}

- (NSArray *)asArray {
    return [self as:[NSArray class]];
}

- (NSDictionary *)asDictionary {
    return [self as:[NSDictionary class]];
}

- (id)performIfRespondsToSelector:(SEL)selector {
    SuppressPerformSelectorLeakWarning({
        return [[self ifRespondsToSelector:selector] performSelector:selector];
    });
}

- (id)performIfRespondsToSelector:(SEL)selector withObject:(id)object {
    SuppressPerformSelectorLeakWarning({
        return [[self ifRespondsToSelector:selector] performSelector:selector withObject:object];
    });
}

- (id)performIfRespondsToSelector:(SEL)selector withObject:(id)object1 withObject:(id)object2 {
    SuppressPerformSelectorLeakWarning({
        return [[self ifRespondsToSelector:selector] performSelector:selector withObject:object1 withObject:object2];
    });
}

@end

#pragma mark -

CGFloat UISizeScaleWithMargin(CGFloat margin, CGFloat baseWidth) {
    static CGFloat screenWidth;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        screenWidth = MIN(screenSize.width, screenSize.height);
    });
    NSCAssert(margin >= 0.0, @"<#margin#> must great than <#0.0#>");
    NSCAssert(margin < baseWidth && margin < screenWidth, @"<#margin#> must less than <#baseWidth#> & <#screenWidth#>");
    if (margin < 0.0 || margin >= baseWidth || margin >= screenWidth) {
        margin = 0;
    }
    return (screenWidth - margin) / (baseWidth - margin);
};

CGFloat UISizeScaleWithMargin_320(CGFloat margin) {
    static CGFloat const iPhone5Width = 320;
    return UISizeScaleWithMargin(margin, iPhone5Width);
}

CGFloat UISizeScaleWithMargin_375(CGFloat margin) {
    static CGFloat const iPhone6Width = 375;
    return UISizeScaleWithMargin(margin, iPhone6Width);
}

CGFloat UISizeScaleWithMargin_414(CGFloat margin) {
    static CGFloat const iPhone6PlusWidth = 414;
    return UISizeScaleWithMargin(margin, iPhone6PlusWidth);
}

#pragma mark -

@implementation UIImage (M9DevBundle)

+ (UIImage *)imageNamedInM9DevBundle:(NSString *)name {
    /* !!!: iOS8 ONLY
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"M9Dev" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    UITraitCollection *traitCollection = [UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale];
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:traitCollection]; */
    
    return [self imageNamed:[NSString stringWithFormat:M9Dev_bundle_"%@", name]];
}

@end

#pragma mark -

/**
 * custom NSLog
 */

void __NO_NSLog__(NSString *format, ...) {}
