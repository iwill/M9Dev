//
//  M9Utilities.m
//  M9Dev
//
//  Created by MingLQ on 2013-06-26.
//  Copyright (c) 2013 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import "M9Utilities.h"

@implementation M9Utilities
@end

#pragma mark -

@interface M9Tuple ()

@property (nonatomic, copy) M9TuplePackBlock pack;

@end

@implementation M9Tuple

+ (instancetype)tupleWithPack:(M9TuplePackBlock)pack {
    M9Tuple *tuple = [self new];
    tuple.pack = pack;
    return tuple;
}

@dynamic unpack; // writeonly
- (void)unpack:(id/* M9TupleUnpackBlock */)unpack {
    (self.pack ?: ^(M9TupleUnpackBlock unpack) {
        if (unpack) unpack(0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0, 0, 0); // 0/nil
    })(unpack);
}

@end

#pragma mark -

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

#if defined(__OPTIMIZE__)
    void __NO_NSLog__(NSString *format, ...) {}
#endif

#pragma mark -

@implementation M9Utilities (DDLOG)

+ (void)setupDDLOG {
#if defined(M9_DDLOG_ENABLED)
    NSArray *allLoggers = [DDLog allLoggers];
    for (id<DDLogger> logger in @[ [DDASLLogger sharedInstance], [DDTTYLogger sharedInstance] ]) {
        if (![allLoggers containsObject:logger]) {
            [DDLog addLogger:logger];
        }
    }
    
    UIColor *errColor = [UIColor colorWithRed:255.0 / 255 green: 44.0 / 255 blue: 56.0 / 255 alpha:1.0];
    UIColor *warColor = [UIColor colorWithRed:255.0 / 255 green:124.0 / 255 blue: 72.0 / 255 alpha:1.0];
    // UIColor *infColor = [UIColor colorWithRed:  0.0 / 255 green:160.0 / 255 blue:255.0 / 255 alpha:1.0];
    UIColor *infColor = [UIColor colorWithRed:  0.0 / 255 green:204.0 / 255 blue:255.0 / 255 alpha:1.0];
    // UIColor *infColor = [UIColor colorWithRed: 65.0 / 255 green:255.0 / 255 blue:255.0 / 255 alpha:1.0];
    // UIColor *debColor = [UIColor colorWithRed: 65.0 / 255 green:204.0 / 255 blue: 69.0 / 255 alpha:1.0];
    UIColor *debColor = [UIColor colorWithRed: 35.0 / 255 green:255.0 / 255 blue:131.0 / 255 alpha:1.0];
    UIColor *verColor = [UIColor colorWithRed:204.0 / 255 green:204.0 / 255 blue:204.0 / 255 alpha:1.0];
    UIColor *bgColor = [UIColor blackColor];
    
    DDTTYLogger *ttyLogger = [DDTTYLogger sharedInstance];
    [ttyLogger setColorsEnabled:YES];
    [ttyLogger setForegroundColor:errColor backgroundColor:bgColor forFlag:DDLogFlagError context:M9_DDLOG_CXT];
    [ttyLogger setForegroundColor:warColor backgroundColor:bgColor forFlag:DDLogFlagWarning context:M9_DDLOG_CXT];
    [ttyLogger setForegroundColor:infColor backgroundColor:bgColor forFlag:DDLogFlagInfo context:M9_DDLOG_CXT];
    [ttyLogger setForegroundColor:debColor backgroundColor:bgColor forFlag:DDLogFlagDebug context:M9_DDLOG_CXT];
    [ttyLogger setForegroundColor:verColor backgroundColor:bgColor forFlag:DDLogFlagVerbose context:M9_DDLOG_CXT];
    
    DDLOG(@"DDLOG ColorLegend:");
    DDERR(@"ERR");
    DDWAR(@"WAR");
    DDINF(@"INF");
    DDDEB(@"DEB");
    DDVER(@"VER");
#endif
}

@end
