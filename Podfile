source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'

target :M9Dev do
  # pod 'AFNetworking', '~> 2.4'
  pod 'AFNetworking', :git => 'https://github.com/iwill/AFNetworking.git', :commit => '5764f5400908b480bdb413b3b2a900916b62d7cc'
  pod 'TMCache', '~> 1.2'
  pod 'SDWebImage', '~> 3.7'
end

# Add podspecs as an exclusive dependency for the M9DevTests target
target :M9DevTests, :exclusive => true do
  pod 'Kiwi', '~> 2.3'
  # pod 'Specta',   '~> 0.2'
  # pod 'Specta', :git => 'https://github.com/specta/specta.git', :tag => 'v0.3.0.beta1'
  pod 'Expecta',  '~> 0.3'
end
