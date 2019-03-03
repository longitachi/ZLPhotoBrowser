![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/ZLPhotoBrowser.png)

[![Version](https://img.shields.io/cocoapods/v/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
[![License](https://img.shields.io/cocoapods/l/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
[![Platform](https://img.shields.io/cocoapods/p/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
![Language](https://img.shields.io/badge/Language-%20Objective%20C%20-blue.svg)
<a href="http://www.jianshu.com/u/a02909a8a93b"><img src="https://img.shields.io/badge/JianShu-@longitachi-red.svg?style=flat"></a>

----------------------------------------

### 框架整体介绍
* [功能介绍](#功能介绍)
* [更新日志](#更新日志)
* [使用方法(支持cocoapods/carthage安装)](#使用方法)
* [English Document](#English)
* [问答](#问答)
* [效果图](#效果图)

### <a id="功能介绍"></a>功能介绍
- [x] 支持横竖屏 (已适配iPhone X)
- [x] 预览快速选择、可设置预览最大数 (支持拖拽选择)
- [x] 直接进入相册选择 （支持滑动多选）
- [x] 编辑图片 (支持多种滤镜，可自定义裁剪比例)
- [x] 编辑视频
- [x] 查看、选择gif、LivePhoto(iOS9.0)、video
- [x] 3D Touch预览image、gif、LivePhoto、video
- [x] 混合选择image、gif、livePhoto、video
- [x] 在线下载iCloud照片
- [x] 控制选择video最大时长
- [x] 多语言国际化 (中文简/繁、英文、日文，可设置跟随系统和自行切换，可自定义多语言提示)
- [x] 相册内拍照按钮实时显示镜头捕捉画面
- [x] 已选择图片遮罩层标记
- [x] 预览已选择照片
- [x] 预览网络及本地 图片/视频 (图片支持长按保存至相册)
- [x] 相册内图片自定义圆角弧度
- [x] 自定义升序降序排列
- [x] 支持点击拍照及长按录制视频 (仿微信)
- [x] 开发者可自定义资源图片
- [x] 支持导出视频 (可指定导出视频尺寸、添加图片水印、粒子特效 ps:文字水印暂不支持)

###
下载完Demo请执行`carthage update --platform iOS`

### Feature

> 如果您在使用中有好的需求及建议，或者遇到什么bug，欢迎随时issue，我会及时的回复
 
### 更新日志
> [更多更新日志](https://github.com/longitachi/ZLPhotoBrowser/blob/master/UPDATELOG.md)
```
● 3.0.0: 支持carthage; 去除GPUImage滤镜;
● 2.7.8: 添加iCloud图片加载进度条，支持iCloud视频播放;
● 2.7.6: 预览大图界面支持precent情况下的下拉返回;
● 2.7.5: 编辑图片支持自定义工具类型; bug fixed;
● 2.7.4: 横滑大图界面添加下拉返回; 不允许录制视频时候不请求麦克风权限;
● 2.7.1: 支持自定义导航返回按钮图片;
● 2.7.0: 图片资源加上前缀，解决9.0无法选择图片问题; 
● 2.6.9: 重构编辑图片功能，添加滤镜;
● 2.6.7: 优化视频编辑界面，极大减少进入时的等待时间;
● 2.6.6: Fix #216; 新增隐藏裁剪图片界面比例工具条功能;
● 2.6.5: 新增隐藏"已隐藏"照片及相册的功能; Fix #221, 优化预览网络图片/视频时根据url后缀判断的类型方式;
● 2.6.4: Fix #181, #184, #185;
● 2.6.3: 新增自定义多语言文本功能; 新增预览网络视频功能;
● 2.6.2: 新增是否保存已编辑图片的参数; 优化编辑图片旋转体验; 新增取消选择回调;
● 2.6.1: 新增导出视频添加粒子特效功能(如下雪特效); 新增编辑图片时旋转图片功能;
● 2.6.0: ①：新增调用系统相机录制视频功能;
         ②：支持导出指定尺寸的视频，支持导出视频添加图片水印;
         ③：优化部分UI显示;
● 2.5.5: 视频导出方法中添加压缩设置参数; 支持app名字国际化的获取; 删除视频导出3gp格式; fix #157;
● 2.5.4: 新增视频导出功能; 新增获取图片路径api; 优化自定义相机，当相机消失后恢复其他音乐软件的播放;
● 2.5.3: 拍摄视频及编辑视频支持多种格式(mov, mp4, 3gp); 新增相册名字等多语言，以完善手动设置语言时相册名字跟随系统的问题; 简化相册调用，configuration 由必传参数修改为非必传参数;
● 2.5.2: 提取相册配置参数独立为'ZLPhotoConfiguration'对象; 新增状态栏样式api; 优化部分代码;
● 2.5.1: ①：新增自定义相机(仿微信)，开发者可选使用自定义相机或系统相机;
         ②：支持录制视频，可设置最大录制时长及清晰度;
```

### 框架支持
最低支持：iOS 8.0 

IDE：Xcode 9.0 及以上版本 (由于适配iPhone X使用iOS11api，所以请使用Xcode 9.0及以上版本)

### <a id="使用方法"></a>使用方法

第一步：
* Manually 
  * 1.直接把PhotoBrowser文件夹拖入到您的工程中
  * 2.导入 Photos.framework及PhotosUI.framework
  * 3.项目依赖 `SDWebImage`、`GPUImage` 所以需要导入这两个框架
  * 4.导入 "ZLPhotoBrowser.h"
* Cocoapods
  * 1.在Podfile 中添加 `pod 'ZLPhotoBrowser'`
  * 2.执行 `pod setup`
  * 3.执行 `pod install` 或 `pod update`
  * 4.导入 \<ZLPhotoBrowser/ZLPhotoBrowser.h\>
* Carthage
  * 1.在Cartfile 中添加 `github "longitachi/ZLPhotoBrowser"`
  * 2.执行 `carthage update`
  * 3.导入 \<ZLPhotoBrowser/ZLPhotoBrowser.h\>

第二步：
- 在项目plist配置文件中添加如下键值对
```objc
//如果不添加该键值对，则不支持多语言，相册名称默认为英文
Localized resources can be mixed YES
//或者右键plist文件Open As->Source Code 添加
<key>CFBundleAllowMixedLocalizations</key>
<true/>

//相册使用权限描述
Privacy - Photo Library Usage Description
//相机使用权限描述
Privacy - Camera Usage Description
//麦克风使用权限描述
Privacy - Microphone Usage Description
```

代码中调用
```objc
#import <ZLPhotoBrowser/ZLPhotoBrowser.h>
    
ZLPhotoActionSheet *ac = [[ZLPhotoActionSheet alloc] init];

//相册参数配置，configuration有默认值，可直接使用并对其属性进行修改
ac.configuration.maxSelectCount = 5;
ac.configuration.maxPreviewCount = 10;

//如调用的方法无sender参数，则该参数必传
ac.sender = self;

//选择回调
[ac setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
    //your codes
}];

//调用相册
[ac showPreviewAnimated:YES];

//预览网络图片
[ac previewPhotos:arrNetImages index:0 hideToolBar:YES complete:^(NSArray * _Nonnull photos) {
    //your codes
}];
```

------------------
### <a id="English"></a>English
> 可能有翻译不正确的地方，还请英语大佬校准校准

#### Functions
- [x] Multiple orientations support: Portrait, Landscape
- [x] Adaption with iPhone X
- [x] Supports quick selection in preview list, can set maximum preview numbers (drag selection supported)
- [x] Select from album directly (slide to select multiple images is supported)
- [x] Edit images (image filter, cut-out proportion can be customized)
- [x] Edit videos
- [x] View and select gif, LivePhoto(iOS 9.0+), video
- [x] 3D Touch preview image, gif, LivePhoto, video
- [x] Select image, gif, LivePhoto, video assembly
- [x] Download photos from iCloud online
- [x] Control to select video max play time
- [x] Internationalization (current supported: Simple Chinese, English, Japanese, Traditional Chinese. Can follow system or changed in code. Can specify the other language)
- [x] Including camera cell in album, rendering captured image in real time
- [x] Able to have a mask on selected items
- [x] Preview selected items
- [x] Preview images/videos saved locally or online (long press to save image to album is supported)
- [x] Customize radius of images in album
- [x] Able to sort ascending items or descending items
- [x] Click to take photos or long press to record videos is supported (just like WeChat)
- [x] Can customize resource images
- [x] Able to Export video (Can specify video size or add an image watermark or particle effects. PS: text watermark is not supported currently)

#### Requirements
iOS 8.0+
Xcode 9.0+

#### Usage
Step1
 * Manually
  * 1. Drag PhotoBrowser/ folder into your project
  * 2. Import Photos.framework and PhotosUI.framework
  * 3. This repo relays on SDWebImage and GPUImage, so you also need it
  * 4. Import "ZLPhotoActionSheet.h" at where you wanna use it

 * Cocoapods
  * 1. Add `pod 'ZLPhotoBrowser'` to your Podfile
  * 2. `pod setup`
  * 3. `pod install` or `pod update`
  * 4. import `<ZLPhotoBrowser/ZLPhotoBrowser.h>`
* Carthage
  * 1.Add `github "longitachi/ZLPhotoBrowser"` to your Cartfile 
  * 2.Run `carthage update --platform ios` and add the framework to your project.
  * 3.import `<ZLPhotoBrowser/ZLPhotoBrowser.h>`

Step2
 * add description in info.plist
```objc
Localized resources can be mixed YES
Privacy - Photo Library Usage Description
Privacy - Camera Usage Description
Privacy - Microphone Usage Description
```

### <a id="问答"></a>问答
* 关于 `@available(9.0, *)` 报错 ([#90](https://github.com/longitachi/ZLPhotoBrowser/issues/90))
> 该错误会出现在XCode 9.0以下版本，把该代码替换为 `[UIDevice currentDevice].systemVersion.floatValue >= 9.0` 即可

* 从 `pod 2.4.3` 以下版本更新到 `pod 2.4.3` 以上版本报如下错误 `Terminating app due to uncaught exception 'NSUnknownKeyException', reason: '[<ZLThumbnailViewController 0x15bed0d10> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key verLeftSpace.'`
> 由于 `pod 2.4.3` 版本删除对应xib，所以请执行 `command+shift+k` clean项目，重启Xcode即可

### <a id="效果图"></a> 效果图
- 多语言国际化效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/english.png)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/japan.png)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/zh-hans.png)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/zh-hant.png)

- iPhone X

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/iPhoneXPortrait.png)

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/IPhoneXLandscape.png)

- 3DTouch预览效果图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/forceTouch.gif)

- 导出视频添加粒子特效(雪花效果)

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/snowEffect.gif)

- 编辑视频预览图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/editVideo.gif)

- 编辑图片预览图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/edit.gif)

- 滤镜

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/filter.png)

- 自定义相机效果图及介绍

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/customCamera.gif)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/introduce.png)

- 滑动多选预览图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/slideSelect.gif)

- 拖拽选择预览图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/dragSelect.gif)

- 混合选择预览图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/mixSelect.gif)

- 横屏预览图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/landscape.gif)

- 预览网络图片

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/previewNetImage.gif)

- 遮罩层

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/selectmask.gif)

- 预览快速多选效果图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览图快速选择.gif)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览大图快速选择.gif)

- 直接进入相册选择相片效果图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/直接进入相册选择相片.gif)

- 预览大图及缩放效果图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/查看大图支持缩放.gif)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览选择gif.gif)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览选择视频.gif)

- 拍照

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/相册内部拍照.gif)

- 相册内混合选择效果图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/相册内混合选择.gif)

- 预览已选择照片效果图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览已选择照片.gif)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览确定选择的照片.gif)

- 原图功能效果图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/原图功能.gif)
 

