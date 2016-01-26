//
//  M9Utilities.h
//  M9Dev
//
//  Created by MingLQ on 2013-06-26.
//  Copyright (c) 2013 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <Foundation/Foundation.h>


#if defined __cplusplus
extern "C" {
#endif


@interface M9Utilities : NSObject
@end


/* TODO: typedef void (^ResultCallback)(NSString *string, NSArray *array);
- (void)testStructWithResultCallback:(ResultCallback)result {
    return result(@"test", @[ @1, @2 ]);
}
[self testStructWithResultCallback:^(NSString *string, NSArray *array) {
    self.string = string;
    self.array = array;
}]; */


// @see SpectaUtility.h - https://github.com/specta/specta
#define IS_BLOCK(obj) [(obj) isKindOfClass:NSClassFromString([NSString stringWithFormat:@"%s%s%s", "N", "SB", "lock"])]


#define OR          ? :

// for compound statement
#define _RETURN     ; // RETURN is defined in tty.h

// for each with blocks
#define _BREAK      return NO
#define _CONTINUE   return YES


/**
 * @see __CLASS__ - Google: Objective-C macro __CLASS__
 *  !!!: _SELF_CLASS != [self class]
 */
#define _CLASS_NAME ({ \
    NSString *prettyFunction = [NSString stringWithUTF8String:__PRETTY_FUNCTION__]; \
    NSUInteger loc = [prettyFunction rangeOfString:@"["].location + 1; \
    NSUInteger len = [prettyFunction rangeOfString:@" "].location - loc; \
    NSRange range = NSMakeSafeRange(loc, len, prettyFunction.length); \
    [prettyFunction substringWithRange:range]; \
})
#define _SELF_CLASS     NSClassFromString(_CLASS_NAME)
#define _SUPER_CLASS    [_SELF_CLASS superclass]


/**
 *  @synthesize_singleton(sharedInstance);
 */
#define synthesize_singleton(METHOD) \
class NSObject; /* for @ */ \
\
static id _SINGLETON_INSTANCE = nil; \
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone { \
    if (self != _SELF_CLASS || _SINGLETON_INSTANCE) { \
        return nil; \
    } \
    @synchronized(self) { \
        if (!_SINGLETON_INSTANCE) { \
            _SINGLETON_INSTANCE = [super allocWithZone:zone]; \
            return _SINGLETON_INSTANCE; \
        } \
    } \
    return nil; \
} \
\
+ (instancetype)METHOD { \
    return (self == _SELF_CLASS) ? ([self new] ?: _SINGLETON_INSTANCE) : nil; \
}


/**
 * NSString
 */

#define NSObjectFromValue(value)                                @(value)
#define NSStringFromValue(value)                                [@(value) description]
#define NSStringFromBOOL(value)                                 (value ? @"YES" : @"NO")
#define NSStringFromVariableName(variableName)                  @(#variableName) // #variableName - variableName to CString

#define NSStringFromLiteral(literal)                            @(#literal)
// !!!: use defaultValue if preprocessor is undefined or its value is same to itself
#define NSStringFromPreprocessor(preprocessor, defaultValue)    ({ \
    NSString *string = NSStringFromLiteral(preprocessor); \
    [string isEqualToString:@#preprocessor] ? defaultValue : string; \
})
// !!!: use defaultValue if preprocessor is undefined or its value is same to itself
#define NSIntegerFromPreprocessor(preprocessor, defaultValue)   ({ \
    NSString *string = NSStringFromLiteral(preprocessor); \
    [string isEqualToString:@#preprocessor] ? defaultValue : [string integerValue]; \
})


/**
 * NSMerge
 */

#define NSMergeString(a, b)     [a OR @"" stringByAppendingString:b OR @""]
#define NSMergeArray(a, b)      [a OR @[] arrayByAddingObjectsFromArray:b OR @[]]
#define NSMergeDictionary(a, b) [a OR @{} dictionaryByAddingObjectsFromDictionary:b OR @{}]


/**
 * va - variable arguments
 */
#define va_each(type, first, block) { \
    va_list args; \
    va_start(args, first); \
    for (type arg = first; !!arg; arg = va_arg(args, type)) { \
        block(arg); \
    } \
    va_end(args); \
}
#define va_each_if_yes(type, first, block) { \
    va_list args; \
    va_start(args, first); \
    for (type arg = first; arg && block(arg); arg = va_arg(args, type)) { \
    } \
    va_end(args); \
}
#define va_to_array(type, first) ({ \
    NSMutableArray *array = [NSMutableArray array]; \
    va_each(type, first, ^(type arg) { \
        if (arg) [array addObject:arg]; \
    }); \
    _RETURN array; \
})
/*
#define va_make(args, first, statements) \
    va_list args; \
    va_start(args, first); \
    @try \
        statements \
    @finally { \
        va_end(args); \
    } */


/**
 * weakdef, strongdef & strongdef_ifNOT
 */
#define weakdef(...) @weakify(__VA_ARGS__)
#define strongdef(...) @strongify(__VA_ARGS__)
// strongdef(a, b); if (!a || !b) ...
#define strongdef_ifNOT(...) \
    @strongify(__VA_ARGS__) \
    if (!({ \
        NSArray *array = nil; \
        @try { array = @[ __VA_ARGS__ ]; } @catch (NSException *exception) {} \
        _RETURN array;\
    }))


/**
 * NSLocking
 * Allows return everywhere between LOCK and UNLOCK, no need extra unlock
 */

/* LOCKED(id<NSLocking> lock, statements-block) - syntax like @synchronized with NSLocking
 * e.g.
 *  LOCKED(lock, {
 *      // statements
 *  });
 */
#define LOCKED($lock, $statements) \
    [$lock lock]; \
    @try \
        $statements \
    @finally { \
        [$lock unlock]; \
    }

/*  LOCK(id<NSLocking> lock);
 *  // statements
 *  UNLOCK();
 */
#define LOCK($lock) \
    @try { \
        [$lock lock];
        // statements
#define UNLOCK($lock) \
    } \
    @finally { \
        [$lock unlock]; \
    }

/* NOTE: @synchronized without indent
 *  SYNCHRONIZED(object)
 *  // statements
 *  SYNCHRONIZED_END
#define SYNCHRONIZED(object) { \
    @synchronized(object) {
        // statements
#define END \
    }
 */


/**
 * dispatch
 */

static inline dispatch_time_t dispatch_time_in_seconds(NSTimeInterval seconds) {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
}

/* typedef void (^dispatch_semaphore_signal_callback)(void);

static inline long dispatch_semaphore_wait_for(NSTimeInterval timeout, void (^block)(dispatch_semaphore_signal_callback signal)) {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    if (block) block(^{
        dispatch_semaphore_signal(semaphore);
    });
    return dispatch_semaphore_wait(semaphore, timeout > 0.0 ? dispatch_time_in_seconds(timeout) : DISPATCH_TIME_FOREVER);
}

static inline long dispatch_semaphore_wait_for_block(void (^block)(dispatch_semaphore_signal_callback signal)) {
    return dispatch_semaphore_wait_for(- 1.0, block);
}

static inline long dispatch_semaphore_wait_for_seconds(NSTimeInterval seconds) {
    return dispatch_semaphore_wait_for(seconds, nil);
} */

static inline void dispatch_after_seconds(NSTimeInterval seconds,
                                          dispatch_queue_t queue,
                                          dispatch_block_t block) {
    dispatch_after(dispatch_time_in_seconds(seconds),
                   queue OR dispatch_get_main_queue(),
                   block);
}

static inline void dispatch_sync_main_queue(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

static inline void dispatch_async_main_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}

static inline void dispatch_async_background_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
}    


/**
 * if: return self if condition is YES
 * as: return self if self is kind of class
 */

// TODO: asString, asNumber, asInteger ...
@interface NSObject (ReturnSelfIf)

- (id)if:(BOOL)condition;

- (id)as:(Class)clazz;
- (id)asMemberOfClass:(Class)clazz;
- (id)asProtocol:(Protocol *)protocol;
- (id)ifRespondsToSelector:(SEL)selector;

- (NSArray *)asArray;
- (NSDictionary *)asDictionary;

- (id)performIfRespondsToSelector:(SEL)selector;
- (id)performIfRespondsToSelector:(SEL)selector withObject:(id)object;
- (id)performIfRespondsToSelector:(SEL)selector withObject:(id)object1 withObject:(id)object2;

@end


/**
 * M9MakeCopy & @M9MakeCopyWithZone
 */

@protocol M9MakeCopy <NSCopying>

- (void)makeCopy:(id)copy;

@end

#define M9MakeCopyWithZone \
class NSObject; /* for @ */ \
- (instancetype)copyWithZone:(NSZone *)zone { \
    __typeof__(self) copy = [[self class] new]; \
    [self makeCopy:copy]; \
    return copy; \
}


/**
 *  UISizeScaleWithMargin base on designing screen width
 */
CGFloat UISizeScaleWithMargin(CGFloat margin, CGFloat baseWidth);
CGFloat UISizeScaleWithMargin_320(CGFloat margin);
CGFloat UISizeScaleWithMargin_375(CGFloat margin);
CGFloat UISizeScaleWithMargin_414(CGFloat margin);


/**
 * bundle & directory
 */
// [UIImage imageNamed:M9Dev_bundle_"QING.png"]

#define M9Dev_bundle_ @"M9Dev.bundle/"

@interface UIImage (M9DevBundle)

+ (UIImage *)imageNamedInM9DevBundle:(NSString *)name;

@end

// NSDirectory
static inline NSString *NSDirectory(NSSearchPathDirectory directory) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    return [paths count] ? [paths objectAtIndex:0] : nil;
}


/**
 * UIKit
 */

// NS instead of CG
// typedef CGFloat NSFloat;

// animationDuration
static const CGFloat UIViewAnimationDuration = 0.2; // @see UIView + setAnimationDuration:

// UIAnimationCompletion
typedef void (^UIAnimationCompletion)();
typedef void (^UIAnimationCompletionWithBOOL)(BOOL finished);


/**
 * NSRange
 */
static inline NSRange NSMakeSafeRange(NSUInteger loc, NSUInteger len, NSUInteger length) {
    loc = MIN(loc, length);
    len = MIN(len, length - loc);
    return NSMakeRange(loc, len);
}
static inline NSRange NSSafeRangeOfLength(NSRange range, NSUInteger length) {
    return NSMakeSafeRange(range.location, range.length, length);
}


/**
 * SetStruct
 */
#define SetStruct(_struct, statements) ({ \
    __typeof__(_struct) set = _struct; \
    statements \
    _RETURN set; \
})


/**
 * CGRectSet
 */
#define CGRectSetX(_rect, _x) ({ \
    CGRect rect = _rect; \
    rect.origin.x = _x; \
    _RETURN rect; \
})
#define CGRectSetY(_rect, _y) ({ \
    CGRect rect = _rect; \
    rect.origin.y = _y; \
    _RETURN rect; \
})
#define CGRectSetXY(_rect, _x, _y) ({ \
    CGRect rect = _rect; \
    rect.origin.x = _x; \
    rect.origin.y = _y; \
    _RETURN rect; \
})
#define CGRectSetWidth(_rect, _width) ({ \
    CGRect rect = _rect; \
    rect.size.width = _width; \
    _RETURN rect; \
})
#define CGRectSetHeight(_rect, _height) ({ \
    CGRect rect = _rect; \
    rect.size.height = _height; \
    _RETURN rect; \
})
#define CGRectSetWidthHeight(_rect, _width, _height) ({ \
    CGRect rect = _rect; \
    rect.size.width = _width; \
    rect.size.height = _height; \
    _RETURN rect; \
})
#define CGRectSetOrigin(_rect, _origin) ({ \
    CGRect rect = _rect; \
    rect.origin = _origin; \
    _RETURN rect; \
})
#define CGRectSetSize(_rect, _size) ({ \
    CGRect rect = _rect; \
    rect.size = _size; \
    _RETURN rect; \
})
#define CGRectSet(_rect, statements) ({ \
    CGFloat x = _rect.origin.x, y = _rect.origin.y; \
    CGFloat width = _rect.size.width, height = _rect.size.height; \
    statements \
    _RETURN CGRectMake(x, y, width, height); \
})


/**
 * custom NSLog
 */

// #define AT __FILE__ ":" #__LINE__
#define _HERE ({ \
    NSString *file = [[NSString stringWithUTF8String:__FILE__] lastPathComponent]; \
    [NSString stringWithFormat:@"%s (%@:%d)", __PRETTY_FUNCTION__, file, __LINE__]; \
})

// __OPTIMIZE__, @see GCC_OPTIMIZATION_LEVEL
#if !defined(__OPTIMIZE__)
    #define NSLogHere() { \
        NSLog(@"%@", _HERE); \
    }
#else
    void __NO_NSLog__(NSString *format, ...);
    #define NSLogHere()
    #define NSLog(fmt, ...) { __NO_NSLog__(fmt, ##__VA_ARGS__); }
    #define NSLogv(fmt, ...) { __NO_NSLog__(fmt, ##__VA_ARGS__); }
#endif


/**
 *  custom DDLog
 *
 *  Install XcodeColors:
 *      https://github.com/robbiehanson/XcodeColors
 *  Enable XcodeColors:
 *      [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
 *      [command+option+r] > Run XXXX.app > Environment Variable > + > XcodeColors: YES
 *      https://github.com/robbiehanson/CocoaLumberjack/wiki/XcodeColors
 */
#if defined(M9_DDLOG_ENABLED)
    #import <CocoaLumberjack/CocoaLumberjack.h>
    #if defined(__OPTIMIZE__)
        #define ddLogLevelGlobal DDLogLevelOff
    #else
        #define ddLogLevelGlobal DDLogLevelAll
    #endif
    #undef  LOG_LEVEL_DEF
    #define LOG_LEVEL_DEF M9_ddLogLevel
    #define M9_DDLOG_CXT (NSIntegerMax-2015-11-21)
    #define DDERR(frmt, ...) LOG_MAYBE(NO,                LOG_LEVEL_DEF, DDLogFlagError,   M9_DDLOG_CXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
    #define DDWAR(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagWarning, M9_DDLOG_CXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
    #define DDINF(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagInfo,    M9_DDLOG_CXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
    #define DDDEB(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagDebug,   M9_DDLOG_CXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
    #define DDVER(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, M9_DDLOG_CXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
    #define DDLOG(frmt, ...) DDINF(frmt, ##__VA_ARGS__)
    static const NSUInteger M9_ddLogLevel = ddLogLevelGlobal;
#else
    #import <Foundation/Foundation.h>
    #define DDERR(frmt, ...) NSLog(@"<#ERR#> " frmt, ##__VA_ARGS__)
    #define DDWAR(frmt, ...) NSLog(@"<#WAR#> " frmt, ##__VA_ARGS__)
    #define DDINF(frmt, ...) NSLog(@"<#INF#> " frmt, ##__VA_ARGS__)
    #define DDDEB(frmt, ...) NSLog(@"<#DEB#> " frmt, ##__VA_ARGS__)
    #define DDVER(frmt, ...) NSLog(@"<#VER#> " frmt, ##__VA_ARGS__)
    #define DDLOG(frmt, ...) DDINF(frmt, ##__VA_ARGS__)
#endif
@interface M9Utilities (DDLOG)
+ (void)setupDDLOG;
@end


/**
 * suppress warning
 *
 * e.g.
 *  SuppressPerformSelectorLeakWarning({
 *      // statements
 *  });
 * suppress warning, @see
 *  http://stackoverflow.com/a/7933931/456536
 * @see also
 *  http://stackoverflow.com/a/20058585/456536
 */

#define SuppressPerformSelectorLeakWarning(statements) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
statements \
_Pragma("clang diagnostic pop")

#define SuppressDeprecatedDeclarationsWarning(statements) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"") \
statements \
_Pragma("clang diagnostic pop")


#if defined __cplusplus
};
#endif

