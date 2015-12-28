//
//  Reachability+.h
//  iPhoneVideo
//
//  Created by MingLQ on 2012-04-06.
//  Copyright 2012 SOHU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

// base on Reachability from Apple
#import <Reachability/Reachability.h>

#pragma mark - Reachability

@interface Reachability (sharedReachability)

+ (Reachability *)sharedReachability;
+ (NetworkStatus)currentReachabilityStatus;

/**
 * @param selector
 *      The selector must have one and only one argument (an instance of NSNotification)
 */
+ (void)addReachabilityChangedNotificationObserver:(id)observer selector:(SEL)selector;
+ (void)removeReachabilityChangedNotificationObserver:(id)observer;

@end

#pragma mark - CTTelephonyNetworkInfo

@interface Reachability (CTTelephonyNetworkInfo)

+ (CTTelephonyNetworkInfo *)sharedTelephonyNetworkInfo;
+ (NSString *)currentRadioAccessTechnology;

@end

#pragma mark - NetworkType

typedef NS_ENUM(NSInteger, NetworkType) {
    NetworkTypeNone = 0,
    NetworkTypeWiFi = 1,
    NetworkType2G   = 2,
    NetworkType3G   = 3,
    NetworkType4G   = 4,
    NetworkTypeUnknownWWAN = NSIntegerMax
};

@interface Reachability (NetworkType)

+ (NetworkType)currentNetworkType;

+ (BOOL)reachable;
+ (BOOL)notReachable;

+ (BOOL)reachableViaWiFi;
+ (BOOL)reachableViaWWAN;

+ (BOOL)reachableViaWWAN2G;
+ (BOOL)reachableViaWWAN3G;
+ (BOOL)reachableViaWWAN4G;

/**
 * Notify observers both when WWAN and WiFi changed via CTRadioAccessTechnologyDidChangeNotification.
 *
 * WWAN types are available from iOS7, call add/remove ReachabilityChangedNotificationObserver for iOS6 and lower.
 *
 * !!!: WARNING
 *      To actually get iOS to emit those notifications, you need to carry an instance of CTTelephonyNetworkInfo around.
 *      Don’t try to create a new instance of CTTelephonyNetworkInfo inside the notification, or it’ll crash.
 *      -- Because creating a new instance will post CTRadioAccessTechnologyDidChangeNotification - circular recursion.
 *      @see http://www.objc.io/issue-5/iOS7-hidden-gems-and-workarounds.html
 *
 * @param selector
 *      The selector must have one and only one argument (an instance of NSNotification)
 */
+ (void)addNetworkTypeChangedNotificationObserver:(id)observer selector:(SEL)selector DEPRECATED_ATTRIBUTE;
+ (void)removeNetworkTypeChangedNotificationObserver:(id)observer DEPRECATED_ATTRIBUTE;

@end
