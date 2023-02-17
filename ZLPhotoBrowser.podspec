Pod::Spec.new do |s|
  s.name                  = 'ZLPhotoBrowser'
  s.version               = '4.3.9'
  s.summary               = 'A lightweight and pure Swift implemented library for select photos from album'

  s.description           = <<-DESC
                              ZLPhotoBrowser 是一款纯swift实现的框架
                              * 支持图片、视频、GIF、LivePhoto选择
                              * 支持图片、视频编辑
                              * 支持自定义相机拍照及录像
                              更多自定义功能请查看 ZLPhotoConfiguration 定义
                              DESC

  s.homepage              = 'https://github.com/longitachi/ZLPhotoBrowser'
  s.license               = { :type => "MIT", :file => "LICENSE" }

  s.author                = {'longitachi' => 'longitachi@163.com'}
  s.social_media_url      = "https://github.com/longitachi"

  s.source                = {:git => 'https://github.com/longitachi/ZLPhotoBrowser.git', :tag => s.version}

  s.ios.deployment_target = '10.0'

  s.swift_versions        = ['5.0', '5.1', '5.2']

  s.requires_arc          = true
  s.frameworks            = 'UIKit','Photos','PhotosUI','AVFoundation','CoreMotion', 'Accelerate'

  s.resources             = 'Sources/*.{png,bundle}'

  s.subspec "Core" do |sp|
    sp.source_files  = ["Sources/**/*.swift", "Sources/ZLPhotoBrowser.h"]
  end

end
