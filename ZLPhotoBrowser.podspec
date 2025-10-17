Pod::Spec.new do |s|
  s.name                  = 'ZLPhotoBrowser'
  s.version               = '4.7.3'
  s.summary               = 'A lightweight and pure Swift implemented library for select photos from album'

  s.description           = <<-DESC
                              Wechat-like image picker. Support select photos, videos, gif and livePhoto. Support edit image and crop video.
                              DESC

  s.homepage              = 'https://github.com/longitachi/ZLPhotoBrowser'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }

  s.author                = {'longitachi' => 'longitachi@163.com'}
  s.social_media_url      = 'https://github.com/longitachi'

  s.source                = {:git => 'https://github.com/longitachi/ZLPhotoBrowser.git', :tag => s.version}

  s.ios.deployment_target = '10.0'

  s.swift_versions        = ['5.0', '5.1', '5.2']

  s.requires_arc          = true
  s.frameworks            = 'UIKit','Photos','PhotosUI','AVFoundation','CoreMotion', 'Accelerate'

  s.resources             = 'Sources/*.{png,bundle}'
  s.resource_bundles      = {'ZLPhotoBrowser_Privacy' => ['Sources/PrivacyInfo.xcprivacy']}

  s.subspec "Core" do |sp|
    sp.source_files       = ['Sources/**/*.{swift,h,m}', 'Sources/ZLPhotoBrowser.h']
    sp.exclude_files      = ['Sources/General/ZLWeakProxy.swift']
  end

end
