//
//  Reachability+.m
//  iPhoneVideo
//
//  Created by MingLQ on 2012-04-06.
//  Copyright 2012 SOHU. All rights reserved.
//

#import "Reachability+.h"

typedef NS_ENUM(NSInteger, WWANType) {
    WWANTypeNone            = 0, // has not
    WWANType2G              = 2,
    WWANType3G              = 3,
    WWANType4G              = 4,
    WWANTypeUnknown         = NetworkTypeUnknown // has, but unknown
};

@interface Reachability (WWANType)

+ (WWANType)currentWWANType;

@end

#pragma mark - Reachability

@implementation Reachability (sharedReachability)

+ (Reachability *)sharedReachability {
    static Reachability *SharedReachability = nil;
    if (SharedReachability) {
        return SharedReachability;
    }
    @synchronized(self) {
        if (!SharedReachability) {
            SharedReachability = [Reachability reachabilityForInternetConnection];
        }
    }
    return SharedReachability;
}

+ (NetworkStatus)currentReachabilityStatus {
    return [[self sharedReachability] currentReachabilityStatus];
}

@end

#pragma mark - CTTelephonyNetworkInfo

@implementation Reachability (CTTelephonyNetworkInfo)

+ (CTTelephonyNetworkInfo *)sharedTelephonyNetworkInfo {
    static CTTelephonyNetworkInfo *SharedTelephonyNetworkInfo = nil;
    if (SharedTelephonyNetworkInfo) {
        return SharedTelephonyNetworkInfo;
    }
    @synchronized(self) {
        if (!SharedTelephonyNetworkInfo) {
            SharedTelephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
        }
    }
    return SharedTelephonyNetworkInfo;
}

+ (NSString *)currentRadioAccessTechnology {
    return [self sharedTelephonyNetworkInfo].currentRadioAccessTechnology;
}

@end

#pragma mark - WWANType

@implementation Reachability (WWANType)

+ (WWANType)currentWWANType {
    NSString *currentRadioAccessTechnology = [self sharedTelephonyNetworkInfo].currentRadioAccessTechnology;
    if (!currentRadioAccessTechnology) {
        return WWANTypeNone;
    }
    
    static NSDictionary *WWANTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // @see https://github.com/appscape/open-rmbt-ios/blob/6125831eadf02ffb4bf356ab1221453ecc6b0e82/Sources/RMBTConnectivity.m
        WWANTypes = @{ CTRadioAccessTechnologyGPRS:            @(WWANType2G),
                       CTRadioAccessTechnologyEdge:            @(WWANType2G),
                       
                       CTRadioAccessTechnologyCDMA1x:          @(WWANType2G),
                       CTRadioAccessTechnologyCDMAEVDORev0:    @(WWANType2G),
                       CTRadioAccessTechnologyCDMAEVDORevA:    @(WWANType2G),
                       CTRadioAccessTechnologyCDMAEVDORevB:    @(WWANType2G),
                       CTRadioAccessTechnologyeHRPD:           @(WWANType2G),
                       
                       CTRadioAccessTechnologyWCDMA:           @(WWANType3G),
                       CTRadioAccessTechnologyHSDPA:           @(WWANType3G),
                       CTRadioAccessTechnologyHSUPA:           @(WWANType3G),
                       
                       CTRadioAccessTechnologyLTE:             @(WWANType4G) };
    });
    
    NSNumber *typeNumber = [WWANTypes objectForKey:currentRadioAccessTechnology];
    return typeNumber ? [typeNumber integerValue] : WWANTypeUnknown;
}

@end

#pragma mark - NetworkType

@implementation Reachability (NetworkType)

+ (NetworkType)currentNetworkType {
    if ([self notReachable]) {
        return NetworkTypeNone;
    }
    if ([self reachableViaWiFi]) {
        return NetworkTypeWiFi;
    }
    if ([self reachableViaWWAN]) {
        switch ([self currentWWANType]) {
            case WWANType2G:
                return NetworkType2G;
            case WWANType3G:
                return NetworkType3G;
            case WWANType4G:
                return NetworkType4G;
            default:
                return NetworkTypeUnknown; // NetworkTypeUnknownWWAN
        }
    }
    return NetworkTypeUnknown;
}

+ (BOOL)reachable {
    return [self currentReachabilityStatus] != NotReachable;
}

+ (BOOL)notReachable {
    return [self currentReachabilityStatus] == NotReachable;
}

+ (BOOL)reachableViaWiFi {
    return [self currentReachabilityStatus] == ReachableViaWiFi;
}

+ (BOOL)reachableViaWWAN {
    return [self currentReachabilityStatus] == ReachableViaWWAN;
}

+ (BOOL)reachableViaWWAN2G {
    return [self reachableViaWWAN] && [self currentWWANType] == WWANType2G;
}

+ (BOOL)reachableViaWWAN3G {
    return [self reachableViaWWAN] && [self currentWWANType] == WWANType3G;
}

+ (BOOL)reachableViaWWAN4G {
    return [self reachableViaWWAN] && [self currentWWANType] == WWANType4G;
}

+ (void)addNetworkTypeChangedNotificationObserver:(id)observer selector:(SEL)selector {
    // !!!: init shared CTTelephonyNetworkInfo instance before add notification observer
    // @see the comments of this method in the header file
    [self sharedTelephonyNetworkInfo];
    // !!!: object is the CTRadioAccessTechnologyXXX instead of the CTTelephonyNetworkInfo instance
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:selector
                                                 name:CTRadioAccessTechnologyDidChangeNotification
                                               object:nil];
}

+ (void)removeNetworkTypeChangedNotificationObserver:(id)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer
                                                    name:CTRadioAccessTechnologyDidChangeNotification
                                                  object:nil];
}

@end
