# M9Dev
Objective-C development utilities for iOS.

# NSLOG

`NSLOG` = [`DDLog`](https://github.com/CocoaLumberjack/CocoaLumberjack) + [`XcodeColors`](https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Documentation/XcodeColors.md)

Enable NSLOG for project by setting `GCC_PREPROCESSOR_DEFINITIONS`:
```
M9_NSLOG_ENABLED=1
```

Enable NSLOG for pod project by CocoaPods [post_install](http://guides.cocoapods.org/syntax/podfile.html#post_install):
```ruby
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'M9Dev'
            target.build_configurations.each do |config|
                if config.name == 'Debug'
                    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'DEBUG=1', 'M9_NSLOG_ENABLED=1']
                end
            end
        end
    end
end
```

Setup NSLOG and colors:
```objc
[M9Utilities setupNSLOG];
```

Code snippts:
```objc
NSERR(@"<#NSString *format#>"); // error
NSWAR(@"<#NSString *format#>"); // warn
NSINF(@"<#NSString *format#>"); // info
NSDEB(@"<#NSString *format#>"); // debug
NSVER(@"<#NSString *format#>"); // verbose
// same to NSINF
NSLOG(@"<#NSString *format#>");
// system NSLog
NSLog(@"<#NSString *format#>");
```

