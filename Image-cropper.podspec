
Pod::Spec.new do |s|
  s.name             = 'Image-cropper'
  s.version          = '1.0.0'
  s.swift_versions   = "5.0"
  s.summary          = 'Image Cropper is an open-source swift library that provides rich cropping interactions for your iOS.'
  s.description      = "Image Cropper is an open-source swift library that provides rich cropping interactions for your iOS. Image Cropper also provide rich crop shapes from the basic ( 1:1, 6:4 and 4:6 ) to polygon to arbitrary paths"
  s.homepage         = 'https://github.com/songvuthy/Image-cropper'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '32827363' => 'songvuthy93@gmail.com' }
  s.source           = { :git => 'https://github.com/songvuthy/Image-cropper.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'
  s.source_files = 'Image-cropper/Classes/**/*'
  s.resources    = "Image-cropper/Assets/**/*.xcassets"
  
  s.frameworks   = 'UIKit', 'AVFoundation'
  s.dependency 'SnapKit', '~> 5.0.0'
end
