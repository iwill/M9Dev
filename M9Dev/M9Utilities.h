//
//  M9Utilities.h
//  M9Dev
//
//  Created by MingLQ on 2013-06-26.
//  Copyright (c) 2013 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#if defined __cplusplus
    #define __EXTERN_C__ \
        extern "C" {
    __EXTERN_C__
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
#define IS_BLOCK(OBJECT) [(OBJECT) isKindOfClass:NSClassFromString([NSString stringWithFormat:@"%s%s%s", "N", "SB", "lock"])]


#define OR          ? :

// for compound statement
#define _RETURN     ; // RETURN is defined in tty.h

// for each with blocks
#define _BREAK      return NO   // ???: _STOP
#define _CONTINUE   return YES  // ???: _GOON


/**
 *  @see __CLASS__ - Google: Objective-C macro __CLASS__
 *      !!!: _THIS_CLASS != [self class]
 */
#define _THIS_CLASS_NAME ({ \
    static NSString *ClassName = nil; \
    if (!ClassName) {\
        NSString *prettyFunction = [NSString stringWithUTF8String:__PRETTY_FUNCTION__]; \
        NSUInteger loc = [prettyFunction rangeOfString:@"["].location + 1; \
        NSUInteger len = [prettyFunction rangeOfString:@" "].location - loc; \
        NSRange range = NSMakeSafeRange(loc, len, prettyFunction.length); \
        ClassName = [prettyFunction substringWithRange:range]; \
    } \
    _RETURN ClassName; \
})
#define _THIS_CLASS     NSClassFromString(_THIS_CLASS_NAME)


/**
 *  @singleton_synthesize(sharedInstance);
 */
#define singleton_synthesize(SHARED_METHOD) \
class NSObject; /* '@' for @singleton_synthesize */ \
\
static id _SINGLETON_INSTANCE = nil; \
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone { \
    if (self != _THIS_CLASS || _SINGLETON_INSTANCE) { \
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
+ (instancetype)SHARED_METHOD { \
    return (self == _THIS_CLASS) ? (_SINGLETON_INSTANCE ?: [self new] ?: _SINGLETON_INSTANCE) : nil; \
}
#define synthesize_singleton singleton_synthesize // DEPRECATED_ATTRIBUTE


/**
 *  NSString
 */

#define NSObjectFromValue(VALUE, DEFAULT_VALUE) ({ VALUE ? @(VALUE) : DEFAULT_VALUE; })
#define NSStringFromValue(VALUE, DEFAULT_VALUE) ({ VALUE ? [@(VALUE) description] : DEFAULT_VALUE; })
#define NSStringFromBOOL(VALUE)                 ({ VALUE ? @"YES" : @"NO"; })

#define NSSelectorString(SELECTOR)              NSStringFromSelector(@selector(SELECTOR))

#define NSStringFromLiteral(LITERAL)            @#LITERAL // #LITERAL - LITERAL to CString

// !!!: use DEFAULT_VALUE if PREPROCESSOR is undefined or its value is same to itself
#define NSStringFromPreprocessor(PREPROCESSOR, DEFAULT_VALUE)    ({ \
    NSString *string = NSStringFromLiteral(PREPROCESSOR); \
    _RETURN [string isEqualToString:@#PREPROCESSOR] ? DEFAULT_VALUE : string; \
})
// !!!: use DEFAULT_VALUE if PREPROCESSOR is undefined or its value is same to itself
#define NSIntegerFromPreprocessor(PREPROCESSOR, DEFAULT_VALUE)   ({ \
    NSString *string = NSStringFromLiteral(PREPROCESSOR); \
    _RETURN [string isEqualToString:@#PREPROCESSOR] ? DEFAULT_VALUE : [string integerValue]; \
})

#define NSVersionEQ(A, B) ({ [A compare:B options:NSNumericSearch] == NSOrderedSame; })
#define NSVersionLT(A, B) ({ [A compare:B options:NSNumericSearch] <  NSOrderedSame; })
#define NSVersionGT(A, B) ({ [A compare:B options:NSNumericSearch] >  NSOrderedSame; })
#define NSVersionLE(A, B) ({ [A compare:B options:NSNumericSearch] <= NSOrderedSame; })
#define NSVersionGE(A, B) ({ [A compare:B options:NSNumericSearch] >= NSOrderedSame; })


/**
 *  NSMerge - DEPRECATED_ATTRIBUTE
 */

#define NSMergeString(A, B)     [A OR @"" stringByAppendingString:B OR @""]
#define NSMergeArray(A, B)      [A OR @[] arrayByAddingObjectsFromArray:B OR @[]]
#define NSMergeDictionary(A, B) [A OR @{} dictionaryByAddingObjectsFromDictionary:B OR @{}]


/**
 *  if_let (int i = 0,
 *          i > 0) {
 *      // ...
 *  }
 *  else if_let (int i = 1; BOOL b = YES,
 *               (i > 0 && b)) {
 *      // ...
 *  }
 *  else {
 *      // ...
 *  }
 */
#define if_let(DEF, IF) if (({ DEF; IF; }))


/**
 *  va - variable arguments
 */
#define va_each(TYPE, FIRST, BLOCK) { \
    va_list args; \
    va_start(args, FIRST); \
    for (TYPE arg = FIRST; !!arg; arg = va_arg(args, TYPE)) { \
        BLOCK(arg); \
    } \
    va_end(args); \
}
#define va_each_if_yes(TYPE, FIRST, BLOCK) { \
    va_list args; \
    va_start(args, FIRST); \
    for (TYPE arg = FIRST; arg && BLOCK(arg); arg = va_arg(args, TYPE)) { \
    } \
    va_end(args); \
}
#define va_to_array(TYPE, FIRST) ({ \
    NSMutableArray *array = [NSMutableArray array]; \
    va_each(TYPE, FIRST, ^(TYPE arg) { \
        if (arg) [array addObject:arg]; \
    }); \
    _RETURN array; \
})
/*
#define va_make(ARGS, FIRST, STATEMENTS) { \
    va_list ARGS; \
    va_start(ARGS, FIRST); \
    @try \
        STATEMENTS \
    @finally { \
        va_end(ARGS); \
    }
} */


/**
 *  weakdef, strongdef & strongdef_ifNOT
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
 *  RACTupleUnpackNoWarn without unused-variable warnings - DEPRECATED_ATTRIBUTE
 */
#define RACTupleUnpackNoWarn(...) \
    _Pragma("GCC diagnostic push") \
    _Pragma("GCC diagnostic ignored \"-Wunused-variable\"") \
    RACTupleUnpack(__VA_ARGS__) \
    _Pragma("GCC diagnostic pop")


/**
 *  M9TuplePack & M9TupleUnpack
 *  define:
 *      - (M9Tuple<void (^)(BOOL state1, BOOL state2> *)states;
 *  pack:
 *      BOOL state1 = self.state1, state2 = self.state2;
 *      return M9TuplePack(state1, state2);
 *  unpack:
 *      M9TupleUnpack(tuple) = ^(BOOL state1, BOOL state2) {
 *          // ...
 *      };
 */

/**
 *  !!!:
 *  1. The following `self` is retained, until `tuple` released;
 *  2. The properties are read when `M9TupleUnpack` but NOT `M9TuplePack`, the result may be unexpected;
 *      M9Tuple *tuple = M9TuplePack(self.state1, self.state2);
 *  So, strongly recommend using local variables.
 *      BOOL state1 = self.state1, state2 = self.state2;
 *      M9Tuple *tuple = M9TuplePack(state1, state2);
 */
#define M9TuplePack(TYPE, ...) _M9TuplePack(void (^)TYPE, __VA_ARGS__)
#define _M9TuplePack(TYPE, ...) \
({[M9Tuple tupleWithPack:^(M9TupleUnpackBlock unpack) { \
    if (unpack) ((TYPE)unpack)(__VA_ARGS__); \
}];})
/**
 *  need NOT weakify&strongify in unpack - unpack block is called immediately
 */
#define M9TupleUnpack(TUPLE)    (TUPLE ?: [M9Tuple new]).unpack

typedef void (^M9TupleUnpackBlock)(/* ... */);
typedef void (^M9TuplePackBlock)(M9TupleUnpackBlock unpack);

/*  M9Tuple with Lightweight Generics:
 *  - (M9Tuple<void (^)(NSString *string, NSInteger integer, ...)> *)aTuple;
 *  ???: M9TupleGeneric or M9TupleType()
 */
// - (M9Tuple<M9TupleGeneric(NSString *string, NSInteger integer, ...)> *)aTuple;
#define M9TupleGeneric      void (^)
// - (M9TupleType(NSString *string, NSInteger integer))aTuple;
#define M9TupleType(...)    M9Tuple<void (^)(__VA_ARGS__)> *

@interface M9Tuple<M9TupleUnpackTypeGeneric> : NSObject
@property (nonatomic, /* writeonly, */ assign, setter=unpack:) id/* <M9TupleUnpackTypeGeneric> */ unpack;
+ (instancetype)tupleWithPack:(M9TuplePackBlock)pack;
@end


/**
 *  NSLocking
 *  Allows return everywhere between LOCK and UNLOCK, no need extra unlock
 */

/*  LOCKED(id<NSLocking> lock, statements-block) - syntax like @synchronized with NSLocking
 *  e.g.
 *      LOCKED(lock, {
 *          // statements
 *      });
 */
#define LOCKED(_LOCK, _STATEMENTS) \
    [_LOCK lock]; \
    @try \
        _STATEMENTS \
    @finally { \
        [_LOCK unlock]; \
    }

/*  LOCK(id<NSLocking> lock);
 *  // statements
 *  UNLOCK();
 */
#define LOCK(_LOCK) \
    @try { \
        [_LOCK lock];
        // statements
#define UNLOCK(_LOCK) \
    } \
    @finally { \
        [_LOCK unlock]; \
    }

/*  SYNCHRONIZED(OBJECT)
 *  // statements
 *  SYNCHRONIZED_END
#define SYNCHRONIZED(OBJECT) { \
    @synchronized(OBJECT) {
        // statements
#define SYNCHRONIZED_END \
    }
 */


/**
 *  dispatch
 */

// DEPRECATED_ATTRIBUTE
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

// DEPRECATED_ATTRIBUTE
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
 *  if: return self if condition is YES
 *  as: return self if self is kind of class
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
 *  M9Copying & @M9MakeCopyWithZone
 */

@protocol M9Copying <NSCopying>

- (void)makeCopy:(id)copy;

@end

#define M9MakeCopyWithZone \
class NSObject;  /* '@' for @M9MakeCopyWithZone */ \
- (instancetype)copyWithZone:(NSZone *)zone { \
    __typeof__(self) copy = [[self class] new]; \
    [self makeCopy:copy]; \
    return copy; \
}


/**
 *  UIOnePixel
 */
#define UIOnePixel ({ 1.0 / [UIScreen mainScreen].scale; })


/**
 *  UISizeScaleWithMargin base on designing screen width
 */
CGFloat UISizeScaleWithMargin(CGFloat margin, CGFloat baseWidth);
CGFloat UISizeScaleWithMargin_320(CGFloat margin);
CGFloat UISizeScaleWithMargin_375(CGFloat margin);
CGFloat UISizeScaleWithMargin_414(CGFloat margin);


/**
 *  bundle & directory
 */
// [UIImage imageNamed:M9Dev_bundle_"QING.png"]

#define M9Dev_bundle_ @"M9Dev.bundle/"

@interface UIImage (M9DevBundle)

+ (UIImage *)imageNamedInM9DevBundle:(NSString *)name;

@end

// NSDirectory
static inline NSString *NSDirectory(NSSearchPathDirectory directory) {
    return NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES).firstObject;
}


/**
 *  UIKit
 */

// NS instead of CG
// typedef CGFloat NSFloat;

// animationDuration
static CGFloat const UIViewAnimationDuration = 0.2; // @see UIView + setAnimationDuration:

// UIAnimationCompletion
typedef void (^UIAnimationCompletion)();
typedef void (^UIAnimationCompletionWithBOOL)(BOOL finished);


/**
 *  NSRange
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
 *  SetStruct
 */
#define SetStruct(STRUCT, STATEMENTS) ({ \
    __typeof__(STRUCT) set = STRUCT; \
    STATEMENTS \
    _RETURN set; \
})


/**
 *  CGRectSet
 */
#define CGRectSetX(RECT, X) ({ \
    CGRect rect = RECT; \
    rect.origin.x = X; \
    _RETURN rect; \
})
#define CGRectSetY(RECT, Y) ({ \
    CGRect rect = RECT; \
    rect.origin.y = Y; \
    _RETURN rect; \
})
#define CGRectSetXY(RECT, X, Y) ({ \
    CGRect rect = RECT; \
    rect.origin.x = X; \
    rect.origin.y = Y; \
    _RETURN rect; \
})
#define CGRectSetWidth(RECT, WIDTH) ({ \
    CGRect rect = RECT; \
    rect.size.width = WIDTH; \
    _RETURN rect; \
})
#define CGRectSetHeight(RECT, HEIGHT) ({ \
    CGRect rect = RECT; \
    rect.size.height = HEIGHT; \
    _RETURN rect; \
})
#define CGRectSetWidthHeight(RECT, WIDTH, HEIGHT) ({ \
    CGRect rect = RECT; \
    rect.size.width = WIDTH; \
    rect.size.height = HEIGHT; \
    _RETURN rect; \
})
#define CGRectSetOrigin(RECT, ORIGIN) ({ \
    CGRect rect = RECT; \
    rect.origin = ORIGIN; \
    _RETURN rect; \
})
#define CGRectSetSize(RECT, SIZE) ({ \
    CGRect rect = RECT; \
    rect.size = SIZE; \
    _RETURN rect; \
})
#define CGRectSet(RECT, STATEMENTS) ({ \
    CGFloat x = RECT.origin.x, y = RECT.origin.y; \
    CGFloat width = RECT.size.width, height = RECT.size.height; \
    STATEMENTS \
    _RETURN CGRectMake(x, y, width, height); \
})


/**
 *  custom NSLog - ???
 */

// #define AT __FILE__ ":" #__LINE__
#define _HERE ({ \
    NSString *file = [[NSString stringWithUTF8String:__FILE__] lastPathComponent]; \
    [NSString stringWithFormat:@"%s (%@:%d)", __PRETTY_FUNCTION__, file, __LINE__]; \
})

// __OPTIMIZE__, @see GCC_OPTIMIZATION_LEVEL
#if defined(__OPTIMIZE__)
    // inhibit unused warnings
    void __NO_NSLog__(NSString *format, ...);
    #define NSLogHere()
    #define NSLog   __NO_NSLog__
    #define NSLogv  __NO_NSLog__
#else
    #define NSLogHere() { \
        NSLog(@"%@", _HERE); \
    }
#endif


/**
 *  custom DDLog - DEPRECATED_ATTRIBUTE
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
    static NSUInteger const M9_ddLogLevel = ddLogLevelGlobal;
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
 *  suppress warning
 *
 *  e.g.
 *      SuppressPerformSelectorLeakWarning({
 *          // statements
 *      });
 *  suppress warning, @see
 *      http://stackoverflow.com/a/7933931/456536
 *  @see also
 *      http://stackoverflow.com/a/20058585/456536
 */

#define SuppressUnusedVariableWarning(statements) \
_Pragma("GCC diagnostic push") \
_Pragma("GCC diagnostic ignored \"-Wunused-variable\"") \
statements \
_Pragma("GCC diagnostic pop")
    
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
    #define __EXTERN_C_END__ \
        };
    __EXTERN_C_END__
#endif

