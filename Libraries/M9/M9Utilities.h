//
//  M9Utilities.h
//  M9Dev
//
//  Created by iwill on 2013-06-26.
//  Copyright (c) 2013年 M9. All rights reserved.
//

#import <Foundation/Foundation.h>


#define OR          ? :

// for compound statement
#define _RETURN     ; // RETURN is defined in tty.h

// for each with blocks
#define _BREAK      return NO
#define _CONTINUE   return YES


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
 * va - variable arguments
 */
#define va_each(type, first, block) { \
    type arg; \
    va_list arg_list; \
    if (first) { \
        block(first); \
        va_start(arg_list, first); \
        while((arg = va_arg(arg_list, type))) { \
            block(arg); \
        } \
        va_end(arg_list); \
    } \
}
#define va_each_if_yes(type, first, block) { \
    type arg; \
    va_list arg_list; \
    if (first) { \
        block(first); \
        va_start(arg_list, first); \
        while((arg = va_arg(arg_list, type)) && block(arg)) { \
        } \
        va_end(arg_list); \
    } \
}
#define va_to_array(type, first) ({ \
    NSMutableArray *array = [NSMutableArray array]; \
    va_each(type, first, ^(type arg) { \
        if (arg) [array addObject:arg]; \
    }); \
    _RETURN array; \
})
#define va_make(arg_list, first, statements) \
    va_list arg_list; \
    va_start(arg_list, first); \
    @try \
        statements \
    @finally { \
        va_end(arg_list); \
    }


/**
 * strongify var, or call $statements if $var is nil
 */
#define strongifyOr($var, $statements) \
    strongify($var); \
    if (!$var) { \
        $statements \
    }


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

#define dispatch_time_in_seconds(seconds) \
    dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC))

#define dispatch_after_seconds(seconds, block) \
    dispatch_after(dispatch_time_in_seconds(seconds), dispatch_get_main_queue(), block)

#define dispatch_sync_main_queue(block) \
    if ([NSThread isMainThread]) { \
        block(); \
    } \
    else { \
        dispatch_sync(dispatch_get_main_queue(), block); \
    }

#define dispatch_async_main_queue(block) \
    dispatch_async(dispatch_get_main_queue(), block)

#define dispatch_async_background_queue(block) \
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)


/**
 * if: return self if condition is YES
 * as: return self if self is kind of class
 */

@interface NSObject (ReturnSelf)

- (id)if:(BOOL)condition;

- (id)as:(Class)class;
- (id)asArray;
- (id)asDictionary;
- (id)asMemberOfClass:(Class)class;
- (id)asProtocol:(Protocol *)protocol;
- (id)ifRespondsToSelector:(SEL)selector;

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
 * NSDirectory
 */
static inline NSString *NSDirectory(NSSearchPathDirectory directory) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    return [paths count] ? [paths objectAtIndex:0] : nil;
}


/**
 * typedef
 */

// NS instead of CG
// typedef CGFloat NSFloat;

// UIAnimationCompletion
typedef void (^UIAnimationCompletion)();
typedef void (^UIAnimationCompletionWithBOOL)(BOOL finished);


/**
 * custom NSLog
 */

// #define AT __FILE__ ":" #__LINE__
#define M9HERE ({ \
    NSString *file = [[NSString stringWithUTF8String:__FILE__] lastPathComponent]; \
    NSString *class = NSStringFromClass([self class]); \
    NSString *method = [NSString stringWithUTF8String:__func__]; \
    method = [method stringByReplacingOccurrencesOfString:[file substringToIndex:file.length - 2] withString:class]; \
    [NSString stringWithFormat:@"%@@%@:%d", method, file, __LINE__]; \
})

// __OPTIMIZE__, @see GCC_OPTIMIZATION_LEVEL
#ifndef __OPTIMIZE__
    #define NSLogHere() { \
        NSLog(@"%@", M9HERE); \
    }
#else
    #define NSLogHere()
    #define NSLog(fmt, ...) { if (NO) [NSString stringWithFormat:fmt, ##__VA_ARGS__]; }
    #define NSLogv(fmt, ...) { if (NO) [NSString stringWithFormat:fmt, ##__VA_ARGS__]; }
#endif


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

