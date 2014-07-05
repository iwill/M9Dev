//
//  M9Utilities.h
//  iM9
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

// NS instead of CF
// typedef CGFloat NSFloat;

// NSString
#define NSStringFromValue(value)                [@(value) description]
#define NSStringFromBOOL(value)                 (value ? @"YES" : @"NO")
#define NSStringFromVariableName(variableName)  @(#variableName)

// NSLocking SYNCHRONIZED
#define SYNCHRONIZED($lock, $statements) \
    @try { \
        [$lock lock]; \
        $statements \
    } \
    @finally { \
        [$lock unlock]; \
    }
// NSLocking LOCK & UNLOCK
#define LOCK($lock) \
    @try { \
        [$lock lock];
#define UNLOCK($lock) \
    } \
    @finally { \
        [$lock unlock]; \
    }
/*
#define LOCK($lock) \
    id<NSLocking> $$lock = $lock; \
    @try { \
        [$$lock lock];
#define UNLOCK \
    } \
    @finally { \
        [$$lock unlock]; \
    } */

// dispatch
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

/* suppress warning, @see
 *  http://stackoverflow.com/a/7933931/456536
 * @see also
 *  http://stackoverflow.com/a/20058585/456536
 */
#define SuppressPerformSelectorLeakWarning(statements) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
statements \
_Pragma("clang diagnostic pop")


typedef void (^CompletionType)();
typedef void (^CompletionTypeWithBOOL)(BOOL finished);

static inline NSString *NSDirectory(NSSearchPathDirectory directory) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    return [paths count] ? [paths objectAtIndex:0] : nil;
}

// @M9MakeCopyWithZone();
#define M9MakeCopyWithZone \
class NSObject; /* for @ */ \
- (instancetype)copyWithZone:(NSZone *)zone { \
    __typeof__(self) copy = [[self class] new]; \
    [self makeCopy:copy]; \
    return copy; \
}

@protocol M9MakeCopy <NSCopying>

- (void)makeCopy:(id)copy;

@end

