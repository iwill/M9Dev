#
#  Be sure to run `pod spec lint M9Dev.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "M9Dev"
  s.version      = "0.0.17"
  s.summary      = "Objective-C development utilities for iOS."

  s.description  = <<-DESC
                   M9Dev
                   =====
                   
                   Objective-C development utilities for iOS.
                   
                   DESC

  s.homepage     = "http://iwill.im/"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  # s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  s.author             = { "iwill" => "minglq.9@gmail.com" }
  # Or just: s.author    = "iwill"
  # s.authors            = { "iwill" => "minglq.9@gmail.com" }
  s.social_media_url   = "https://github.com/iwill"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
  s.platform     = :ios, "7.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source = { :git => "https://github.com/iwill/M9Dev.git", :tag => s.version }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  # s.public_header_files = "M9Dev/**/*.h", "Libraries/**/*.h"

  # s.source_files  = "M9Dev", "Libraries/**/*.{h,m}"
  # s.exclude_files = "Classes/Exclude"

  s.source_files  = "M9Dev/M9Dev.h"
  s.public_header_files = "M9Dev/M9Dev.h"

  s.subspec 'Libraries' do |ss|
    ss.subspec 'BlocksKit' do |sss|
      sss.public_header_files = 'Libraries/BlocksKit/*.h'
      sss.source_files = "Libraries/BlocksKit/*.{h,m}"
    end
    ss.subspec 'CompareToVersion' do |sss|
      sss.public_header_files = 'Libraries/CompareToVersion/*.h'
      sss.source_files = "Libraries/CompareToVersion/*.{h,m}"
    end
    # ss.public_header_files = 'Libraries/**/*.h'
    # ss.source_files = "Libraries/**/*.{h,m}"
  end

  s.subspec 'M9Dev' do |ss|
    ss.public_header_files = 'M9Dev/**/*.h'
    ss.source_files = "M9Dev/**/*.{h,m}"
    ss.dependency "M9Dev/Libraries"
  end


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"
  s.resource_bundles = {
    "M9Dev" => ["M9Dev.bundle/*"]
  }

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  s.frameworks = "Accelerate", "CoreGraphics", "Foundation", "UIKit", "QuartzCore"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  
  s.dependency "libextobjc/EXTScope"
  s.dependency "JRSwizzle"
  s.dependency "Masonry"
  s.dependency "NSString-UrlEncode"
  s.dependency "Reachability"
  # s.dependency "YYModel"

end
