//
//  DDLog+M9.h
//  M9Dev
//
//  Created by MingLQ on 2015-11-21.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#if defined(M9_DDLOG_ENABLED)
    #import <CocoaLumberjack/CocoaLumberjack.h>
    #if defined(__OPTIMIZE__)
        #define ddLogLevelGlobal DDLogLevelOff
    #else
        #define ddLogLevelGlobal DDLogLevelAll
    #endif
    #undef  LOG_LEVEL_DEF
    #define LOG_LEVEL_DEF M9_ddLogLevel
    #define M9_LOG_CXT (2015-11-21)
    #define DDLogErr(frmt, ...) LOG_MAYBE(NO,                LOG_LEVEL_DEF, DDLogFlagError,   M9_LOG_CXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
    #define DDLogWar(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagWarning, M9_LOG_CXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
    #define DDLogInf(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagInfo,    M9_LOG_CXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
    #define DDLogDeb(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagDebug,   M9_LOG_CXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
    #define DDLogVer(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, M9_LOG_CXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
    static const NSUInteger M9_ddLogLevel = ddLogLevelGlobal;
    @interface DDLog (M9)
    + (void)m9_setupDDLog;
    @end
#else
    #define DDLogErr(frmt, ...) NSLog(@"<#ERR#> " frmt, ##__VA_ARGS__)
    #define DDLogWar(frmt, ...) NSLog(@"<#WAR#> " frmt, ##__VA_ARGS__)
    #define DDLogInf(frmt, ...) NSLog(@"<#INF#> " frmt, ##__VA_ARGS__)
    #define DDLogDeb(frmt, ...) NSLog(@"<#DEB#> " frmt, ##__VA_ARGS__)
    #define DDLogVer(frmt, ...) NSLog(@"<#VER#> " frmt, ##__VA_ARGS__)
    #import <Foundation/Foundation.h>
    @interface DDLog : NSObject
    + (void)m9_setupDDLog;
    @end
#endif
