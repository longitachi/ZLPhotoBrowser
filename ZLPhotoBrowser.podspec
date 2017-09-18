Pod::Spec.new do |s|
  s.name         = 'ZLPhotoBrowser'
  s.version      = '2.4.2'
  s.summary      = 'An easy way to Multiselect photos,video,gif,livephoto from ablum,force touch to preview image,support portrait and landscape,multiple languages(Chinese,English,Japanese)'
  s.homepage     = 'https://github.com/longitachi/ZLPhotoBrowser'
  s.license      = 'MIT'
  s.platform     = :ios
  s.author       = {'longitachi' => 'longitachi@163.com'}

  s.ios.deployment_target = '8.0'
  s.source       = {:git => 'https://github.com/longitachi/ZLPhotoBrowser.git', :tag => s.version}
  s.source_files = 'PhotoBrowser/*.{h,m}'
  s.resources    = 'PhotoBrowser/resource/*.{png,xib,nib,bundle}'

  s.requires_arc = true
  s.frameworks   = 'UIKit','Photos','PhotosUI'

  s.dependency 'SDWebImage'
end
