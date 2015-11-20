//
//  DDLog+M9.m
//  M9Dev
//
//  Created by MingLQ on 2015-11-20.
//  Copyright © 2015年 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "DDLog+M9.h"

#if defined(COCOA_LUMBERJACK_AVAILABLE) && !defined(__OPTIMIZE__)
@implementation DDLog (M9)

+ (void)m9_setupDDLog {
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
    [ttyLogger setForegroundColor:errColor backgroundColor:bgColor forFlag:DDLogFlagError];
    [ttyLogger setForegroundColor:warColor backgroundColor:bgColor forFlag:DDLogFlagWarning];
    [ttyLogger setForegroundColor:infColor backgroundColor:bgColor forFlag:DDLogFlagInfo];
    [ttyLogger setForegroundColor:debColor backgroundColor:bgColor forFlag:DDLogFlagDebug];
    [ttyLogger setForegroundColor:verColor backgroundColor:bgColor forFlag:DDLogFlagVerbose];
    
    DDLogInfo(@"DDLog+M9-ColorLegend:");
    DDLogError(@"Error");
    DDLogWarn(@"Warn");
    DDLogInfo(@"Info");
    DDLogDebug(@"Debug");
    DDLogVerbose(@"Verbose");
}

@end
#endif
