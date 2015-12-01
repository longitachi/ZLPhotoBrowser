
Pod::Spec.new do |s|
  s.name         = 'ZLPhotoBrowser'
  s.version      = '1.0'
  s.summary      = '简单易用的多选照片框架'

  s.description  = <<-DESC
                   1. 支持预览相册图片快速多选.
                   2. 支持多相册混合多选.
                   3. 支持拍照功能.
		   4. 支持实时监控相册图片变化.
		
		   ZLPhotoBrowser使用起来方便快捷

                   DESC

  s.homepage     = 'https://github.com/longitachi/ZLPhotoBrowser'
  s.license      = 'MIT'
  s.author       = {'longitachi' => 'longitachi@163.com' }
  s.platform     = :ios, '8.0'
  s.source       = {:git => https://github.com/longitachi/ZLPhotoBrowser.git', :tag => s.version}
  s.source_files = 'ZLPhotoBrowser/PhotoBrowser/*.{h,m,xib}"
  s.requires_arc = true
  s.resources    = 'ZLPhotoBrowser/PhotoBrowser/Images/*.png'
end
