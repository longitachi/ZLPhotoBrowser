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
* [使用方法(支持cocoapods安装)](#使用方法)
* [问答](#问答)
* [效果图](#效果图)

### <a id="功能介绍"></a>功能介绍
- [x] 支持横竖屏 (已适配iPhone X)
- [x] 预览快速选择、可设置预览最大数
- [x] 直接进入相册选择
- [x] 预览界面拖拽选择
- [x] 相册内滑动多选
- [x] 裁剪图片(可自定义裁剪比例)
- [x] 编辑视频
- [x] 查看、选择gif、LivePhoto(iOS9.0)、video
- [x] 3D Touch预览image、gif、LivePhoto、video
- [x] 混合选择image、gif、livePhoto、video
- [x] 在线下载iCloud照片
- [x] 控制选择video最大时长
- [x] 多语言国际化(中文简/繁、英文、日文，可设置跟随系统和自行切换)
- [x] 相册内拍照按钮实时显示镜头捕捉画面
- [x] 已选择图片遮罩层标记
- [x] 预览已选择照片
- [x] 预览网络及本地照片(支持长按保存至相册)
- [x] 相册内图片自定义圆角弧度
- [x] 自定义升序降序排列
- [x] 支持点击拍照及长按录制视频 (仿微信)
- [x] 开发者可自定义资源图片

### Feature

> 如果您在使用中有好的需求及建议，或者遇到什么bug，欢迎随时issue，我会及时的回复
 
### 更新日志
```
● 2.5.2: 提取相册配置参数独立为'ZLPhotoConfiguration'对象; 新增状态栏样式api; 优化部分代码;
● 2.5.1: ①：新增自定义相机(仿微信)，开发者可选使用自定义相机或系统相机;
         ②：支持录制视频，可设置最大录制时长及清晰度;
● 2.5.0.2: 新增自行切换框架语言api; 编辑图片界面当只有一个比例且为custom或1:1状态下隐藏比例切换工具条;
● 2.5.0.1: 提供逐个解析图片api，方便 shouldAnialysisAsset 为 NO 时的使用; 提供控制是否可以选择原图参数;
● 2.5.0: 新增选择后是否自动解析图片参数 shouldAnialysisAsset (针对需要选择大量图片的功能，框架一次解析大量图片时，会导致内存瞬间大幅增高，建议此时置该参数为NO，然后拿到asset后自行逐个解析); 修改图片压缩方式，确保原图尺寸不变
● 2.4.9: 新增预览界面拖拽选择的功能; 支持开发者使用自定义图片资源; 开放导航标题颜色、底部工具栏背景色、底部按钮可交互与不可交互标题颜色的设置api;
● 2.4.6: 新增网络图片长按保存至相册功能;
● 2.4.3: 适配iPhone X，优化初次启动进入相册速度，预览网络图片可设置是否显示底部工具条及导航右侧按钮;
● 2.4.2: 新增编辑视频功能;
● 2.4.1: 新增仿iPhone相册滑动多选功能;
● 2.4.0: 新增预览网络及本地图片api，并可进行选择删除;
● 2.3.3: 删除废弃文件，新增在已选择图片上显示遮罩层标记功能;
● 2.3.2: 新增设置导航颜色api，适配横屏，适配iPad;
● 2.2.9: 新增单选模式下选择图片后直接进入编辑界面功能，提供设置裁剪比例api;
● 2.2.8: 更新编辑图片功能，增加裁剪比例选项(1:1, 3:4, 2:3, 9:16,等比例，开发者可根据需求，按照规则自行添加所需比例);
● 2.2.6: ①：可混合选择image、gif、livephoto、video类型;
         ②：支持video、gif、livephoto类型的多选;
         ③：支持控制video最大选择时长;
```

### 框架支持
最低支持：iOS 8.0 

IDE：Xcode 9.0 及以上版本 (由于适配iPhone X使用iOS11api，所以请使用Xcode 9.0及以上版本)

### <a id="使用方法"></a>使用方法

第一步：
* Manually 
  * 1.直接把PhotoBrowser文件夹拖入到您的工程中
  * 2.导入 Photos.framework及PhotosUI.framework
  * 3.项目依赖 `SDWebImage`，所以需要导入该框架
  * 4.导入 "ZLPhotoActionSheet.h"
* Cocoapods
  * 1.在Podfile 中添加 `pod 'ZLPhotoBrowser'`
  * 2.执行 `pod setup`
  * 3.执行 `pod install` 或 `pod update`
  * 4.导入 \<ZLPhotoActionSheet.h\>

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
#import "ZLPhotoActionSheet.h"
    
ZLPhotoActionSheet *ac = [[ZLPhotoActionSheet alloc] init];

//相册参数配置
ZLPhotoConfiguration *configuration = [ZLPhotoConfiguration defaultPhotoConfiguration];
ac.configuration = configuration;

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

- 编辑视频预览图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/editVideo.gif)

- 编辑图片预览图

![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/edit.gif)

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

