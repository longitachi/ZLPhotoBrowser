Pod::Spec.new do |s|
  s.name         = 'ZLPhotoBrowser'
  s.version      = '3.1.1'
  s.summary      = 'A simple way to multiselect photos from ablum, force touch to preview photo, support portrait and landscape, edit photo, multiple languages(Chinese,English,Japanese)'
  s.homepage     = 'https://github.com/longitachi/ZLPhotoBrowser'
  s.license      = 'MIT'
  s.platform     = :ios
  s.author       = {'longitachi' => 'longitachi@163.com'}

  s.ios.deployment_target = '8.0'
  s.source       = {:git => 'https://github.com/longitachi/ZLPhotoBrowser.git', :tag => s.version}
  s.source_files = 'ZLPhotoBrowser/PhotoBrowser/**/*.{h,m}'
  s.resources    = 'ZLPhotoBrowser/PhotoBrowser/resource/*.{png,xib,nib,bundle}'

  s.requires_arc = true
  s.frameworks   = 'UIKit','Photos','PhotosUI'

  s.dependency 'SDWebImage', '~> 5.1.0'
end
