
Pod::Spec.new do |s|

  s.name         = "HBPhotoBrowser"
  s.version      = "0.0.1"
  s.summary      = "IOS photo album selection framework"
  s.description  = <<-DESC
  				         简单的视频和照片选择库
                   DESC

  s.homepage     = "https://github.com/WillieWu/HBPhotoBrowser"
  s.license      = "MIT"
  s.author             = { "hongbin.wu" => "hongbin.wu@56qq.com" }
  s.platform     = :ios, "8.0"
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  s.source       = { :git => "https://github.com/WillieWu/HBPhotoBrowser.git", :tag => "#{s.version}" }

  s.source_files  = "HBPhotoBrowser/HBPhotoBrowser-Main/*.swift"
  # s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"
  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"
  s.resource_bundles = {
  	'HBPhotoBrowser-Main' => ['HBPhotoBrowser-Main/Assets/*']
  }

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  s.framework  = "Photos"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
