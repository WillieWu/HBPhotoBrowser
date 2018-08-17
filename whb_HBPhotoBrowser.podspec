
Pod::Spec.new do |s|

  s.name         = "whb_HBPhotoBrowser"                               
  s.version      = "0.1.2"                                        
  s.summary      = "iOS whb_HBPhotoBrowser"


  s.homepage     = "https://github.com/WillieWu/HBPhotoBrowser"  

  s.author       = { "hongbin.wu" => "601479318@qq.com" }
  s.license      = "MIT"            
  s.platform     = :ios, "8.0"                                    
  s.source       = { :git => "https://github.com/WillieWu/HBPhotoBrowser.git", :tag => "0.1.2" } 
  s.source_files  = "HBPhotoBrowser/HBPhotoBrowser-Main", "HBPhotoBrowser/HBPhotoBrowser-Main/*.{swift}"

  # s.resource_bundles = {'HBPhotoBrowser' => ['HBPhotoBrowser/HBPhotoBrowser-Main/HBPhotoBrowser.bundle']}
  s.resources     = "HBPhotoBrowser/HBPhotoBrowser-Main/HBPhotoBrowser.bundle"
  s.requires_arc = true
  s.framework    = "UIKit","Foundation","Photos"
  s.swift_version = '3.2'

end