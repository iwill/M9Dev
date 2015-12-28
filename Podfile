# pod install --no-repo-update

# source 'https://github.com/CocoaPods/Specs.git'
source 'https://gitcafe.com/akuandev/Specs.git'

platform :ios, '7.0'
inhibit_all_warnings!

target :M9Dev do
    pod 'JRSwizzle'
    pod 'AFNetworking',         '~> 2.6'
    pod 'Reachability'
    pod 'TMCache'
    pod 'NSString-UrlEncode'
    pod 'YYModel'
    pod 'Masonry'
    pod 'SDWebImage'
    pod 'CocoaLumberjack'
    pod 'FLEX',                 '~> 2.0', :configurations => ['Debug']
end

# Add podspecs as an exclusive dependency for the M9DevTests target
# target :M9DevTests, :exclusive => true do

target :M9DevTests do
    # pod 'Kiwi',     '~> 2.3'
    pod 'Specta',   '~> 1.0'
    pod 'Expecta',  '~> 1.0'
    # pod 'KZPlayground'
end
