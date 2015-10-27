# pod install --no-repo-update

# source 'https://github.com/CocoaPods/Specs.git'
source 'https://gitcafe.com/akuandev/Specs.git'

platform :ios, '7.0'

target :M9Dev do
  pod 'JRSwizzle',      '~> 1.0'
  pod 'AFNetworking',   '~> 2.6'
  # pod 'AFNetworking',   :git => 'https://github.com/iwill/AFNetworking.git', :commit => '5764f5400908b480bdb413b3b2a900916b62d7cc'
  pod 'TMCache',        '~> 1.2'
  pod 'NSString-UrlEncode', '~> 2.0'
  pod 'Masonry',        '~> 0.6'
  pod 'SDWebImage',     '~> 3.7'
  pod 'FLEX',           '~> 2.0', :configurations => ['Debug']
end

# Add podspecs as an exclusive dependency for the M9DevTests target
# target :M9DevTests, :exclusive => true do

target :M9DevTests do
  # pod 'Kiwi',     '~> 2.3'
  pod 'Specta',   '~> 1.0', :inhibit_warnings => true
  # pod 'Specta',   :git => 'https://github.com/specta/specta.git', :tag => 'v0.3.0.beta1'
  pod 'Expecta',  '~> 0.4', :inhibit_warnings => true
  # pod 'KZPlayground'
end
