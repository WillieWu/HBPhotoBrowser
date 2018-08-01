
Pod::Spec.new do |s|

  s.name         = "whb_HBPhotoBrowser"                               
  s.version      = "0.0.1"                                        
  s.summary      = "iOS whb_HBPhotoBrowser"


  s.homepage     = "https://github.com/WillieWu/HBPhotoBrowser"  

  s.author       = { "hongbin.wu" => "601479318@qq.com" }
  s.license      = "MIT"            
  s.platform     = :ios, "8.0"                                    
  s.source       = { :git => "https://github.com/WillieWu/HBPhotoBrowser.git", :tag => "0.0.1" } 
  s.source_files  = "HBPhotoBrowser/HBPhotoBrowser-Main", "HBPhotoBrowser/HBPhotoBrowser-Main/*.{swift}"
  s.public_header_files = "HBPhotoBrowser/HBPhotoBrowser-Main/*.{swift}"
  s.resource_bundles = {'HBPhotoBrowser' => ['HBPhotoBrowser/HBPhotoBrowser-Main/Resources/*.png']}
  s.requires_arc = true
  s.framework = 'Photos'
  s.swift_version = '3.2'

end