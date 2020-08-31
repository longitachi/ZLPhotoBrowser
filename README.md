![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/ZLPhotoBrowser.png)

[![Version](https://img.shields.io/cocoapods/v/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)&nbsp;
[![License](https://img.shields.io/cocoapods/l/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
[![Platform](https://img.shields.io/cocoapods/p/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
![Language](https://img.shields.io/badge/Language-%20Swift%20C%20-blue.svg)
<a href="http://www.jianshu.com/u/a02909a8a93b"><img src="https://img.shields.io/badge/JianShu-@longitachi-red.svg?style=flat"></a>

----------------------------------------

## 重要说明
* 框架自 `4.0.0` 版本起，升级为纯`Swift`编写框架，支持最低版本由 `iOS8` 升级到了 `iOS10`
* 添加并增强了一些实用功能（例如图片编辑、预览界面下方小视图显示及拖拽排序等等）
* 删除一些功能（对SDWebImage的依赖，网络图片及视频的预览，force touch 等等）
具体使用请下载demo查看

### 框架整体介绍
* [功能介绍](#功能介绍)
* [更新日志](#更新日志)
* [使用方法(支持cocoapods/carthage安装)](#使用方法)
* [效果图](#效果图)

### <a id="功能介绍"></a>功能介绍
- [x] 支持横竖屏
- [x] 预览快速选择、可设置预览最大数 (支持拖拽选择)
- [x] 直接进入相册选择 （支持滑动多选）
- [x] 编辑图片、视频
- [x] 选择照片、Video、GIF、LivePhoto
- [x] 多语言国际化 (中文简/繁、英文、日文，可设置跟随系统和自行切换，可自定义多语言提示)
- [x] 已选择图片index
- [x] 自定义相机 (仿微信)
> 更多功能请查看 `ZLPhotoConfiguration` 中你那个参数定义

### Feature

> 如果您在使用中有好的需求及建议，或者遇到什么bug，欢迎随时issue，我会及时的回复
 
### 更新日志
> [更多更新日志](https://github.com/longitachi/ZLPhotoBrowser/blob/master/UPDATELOG.md)
```
● 4.0.0: 框架升级为纯`Swift`编写，最低支持右`iOS8`升级到`iOS10`;
● 3.2.0: 添加图片视频选择互斥功能（即只能选择1个视频或最多几张图片）; 添加选择量达到最大值时其他cell显示遮罩功能; 删除`allowMixSelect`,`maxVideoSelectCountInMix`,`minVideoSelectCountInMix`参数;
...
```

### 框架支持
最低支持：iOS 10.0 


### <a id="使用方法"></a>使用方法

第一步：
* Manually 
  * 1.直接把`Sources`文件夹拖入到您的工程中
  
* Cocoapods
  * 1.在Podfile 中添加 `pod 'ZLPhotoBrowser'`
  * 2.执行 `pod install`
  > 如找不到最新版本，可首先执行`pod repo update`
  
* Carthage
  * 1.在Cartfile 中添加 `github "longitachi/ZLPhotoBrowser"`
  * 2.执行 `carthage update ZLPhotoBrowser --platform iOS`
  

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

### <a id="效果图"></a> 效果图
- 多语言国际化效果图
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/english.png)
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/japan.png)
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/zh-hans.png)
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/zh-hant.png)

- iPhone X

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/iPhoneXPortrait.png)

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/IPhoneXLandscape.png)

- 3DTouch预览效果图

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/forceTouch.gif)

- 导出视频添加粒子特效(雪花效果)

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/snowEffect.gif)

- 编辑视频预览图

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/editVideo.gif)

- 编辑图片预览图

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/edit.gif)

- 自定义相机效果图及介绍

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/customCamera.gif)
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/introduce.png)

- 滑动多选预览图

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/slideSelect.gif)

- 拖拽选择预览图

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/dragSelect.gif)

- 混合选择预览图

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/mixSelect.gif)

- 横屏预览图

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/landscape.gif)

- 预览网络图片

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/previewNetImage.gif)

- 遮罩层

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/selectmask.gif)

- 预览快速多选效果图

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/预览图快速选择.gif)
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/预览大图快速选择.gif)

- 直接进入相册选择相片效果图

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/直接进入相册选择相片.gif)

- 预览大图及缩放效果图

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/查看大图支持缩放.gif)
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/预览选择gif.gif)
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/预览选择视频.gif)

- 拍照

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/相册内部拍照.gif)

- 相册内混合选择效果图

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/相册内混合选择.gif)

- 预览已选择照片效果图

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/预览已选择照片.gif)
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/预览确定选择的照片.gif)

- 原图功能效果图

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/原图功能.gif)
 

