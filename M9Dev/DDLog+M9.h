//
//  DDLog+M9.h
//  M9Dev
//
//  Created by MingLQ on 2015-11-20.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#if defined(COCOA_LUMBERJACK_AVAILABLE)
    #if defined(__OPTIMIZE__)
        #define ddLogLevelGlobal DDLogLevelOff
    #else
        #import <CocoaLumberjack/CocoaLumberjack.h>
        #define ddLogLevelGlobal DDLogLevelAll
        #undef  LOG_LEVEL_DEF
        #define LOG_LEVEL_DEF M9_ddLogLevel
static const NSUInteger M9_ddLogLevel = ddLogLevelGlobal;
@interface DDLog (M9)
+ (void)m9_setupDDLog;
@end
    #endif
#else
    #undef  DDLogError
    #undef  DDLogWarn
    #undef  DDLogInfo
    #undef  DDLogDebug
    #undef  DDLogVerbose
    #define DDLogError(frmt, ...)   NSLog(@"<#ERR#> " frmt, ##__VA_ARGS__)
    #define DDLogWarn(frmt, ...)    NSLog(@"<#WAR#> " frmt, ##__VA_ARGS__);
    #define DDLogInfo(frmt, ...)    NSLog(@"<#INF#> " frmt, ##__VA_ARGS__);
    #define DDLogDebug(frmt, ...)   NSLog(@"<#DEB#> " frmt, ##__VA_ARGS__);
    #define DDLogVerbose(frmt, ...) NSLog(@"<#VER#> " frmt, ##__VA_ARGS__);
#endif
