[![Version](https://img.shields.io/cocoapods/v/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)&nbsp;
[![License](https://img.shields.io/cocoapods/l/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
[![Platform](https://img.shields.io/cocoapods/p/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
![Language](https://img.shields.io/badge/Language-%20Swift%20-blue.svg)
<a href="http://www.jianshu.com/u/a02909a8a93b"><img src="https://img.shields.io/badge/JianShu-@longitachi-red.svg?style=flat"></a>

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/preview_with_title.png)

----------------------------------------

## 重要说明
* 框架自 `4.0.0` 版本起，升级为纯`Swift`编写框架，支持最低版本由 `iOS8` 升级到了 `iOS10`
* 添加并增强了一些实用功能（例如图片编辑、预览界面下方小视图显示及拖拽排序等等）
* 删除一些功能（网络图片及视频的预览，force touch 等等）
具体使用请下载demo查看

> `Swift` 版本兼容 `oc` app调用；  如需使用之前的`oc`版本（`oc`版本不再维护），请点[这里](https://github.com/longitachi/ZLPhotoBrowser-objc)

### 框架整体介绍
* [功能介绍](#功能介绍)
* [使用示例](#使用示例)
* [更新日志](#更新日志)
* [安装方法(支持Cocoapods/Carthage/SPM安装)](#安装方法)
* [效果图](#效果图)

详细使用方法请查看[Wiki](https://github.com/longitachi/ZLPhotoBrowser/wiki)

### <a id="功能介绍"></a>功能介绍
你想要的应有尽有，预留给开发者自定义框架参数多达50个（没有的话欢迎提 issue ，功能建议好的话会采纳并着手开发）
- [x] 支持横竖屏
- [x] 自选框架样式
- [x] 预览快速选择（支持拖拽选择，效果参照QQ）
- [x] 相册内部选择（支持滑动选择）
- [x] 图片/Gif/LivePhoto/Video 混合选择
- [x] 自定义最大预览数/选择数/视频最大最小可选时长，控制可否选择原图
- [x] 自定义每行显示列数
- [x] 图片编辑（涂鸦/裁剪/马赛克）（图片编辑可编辑多张；涂鸦颜色可自定义，裁剪工具也可根据需要自行选择）
- [x] 视频编辑（自定义最大裁剪时长）（效果参照微信视频编辑；支持编辑本地视频）
- [x] 自定义相机（效果参照微信拍照，点击拍照、长按拍摄；上滑调整焦距；可设置最大/最小录制时间及视频分辨率；可设置闪光灯模式及视频导出格式；可根据自己需要控制是否使用自定义相机）
- [x] 多语言国际化支持（中文简/繁，英文，日文，开发者可选根据系统或自己指定，多语言文案可自定义）
- [x] 已选择照片index
- [x] 已选/不可选 状态下mask阴影遮罩
- [x] 大图界面下方显示已选择照片，可拖拽排序（可根据自己需要控制是否显示）
- [x] 大图界面下拉返回
- [x] 相机内部拍照cell实时显示相机俘获画面
- [x] 可自定义框架字体
- [x] 框架各个部位颜色均可自定义（传入dynamic color即可支持 light/dark mode）
- [x] 框架内图片资源可自定义
> 更多功能请查看 `ZLPhotoConfiguration` 中的参数定义

> 如果你在使用中有好的需求及建议，或者遇到什么bug，欢迎随时issue，我会及时的回复
 
 ### 框架支持
 * iOS 10.0
 * Swift 5.x
 * Xcode 11.x
 
 ### <a id="使用示例"></a>使用示例
 - 快速选择
 ```
 let ac = ZLPhotoPreviewSheet()
 ac.selectImageBlock = { [weak self] (images, assets, isOriginal) in
     // your code
 }
 ac.showPreview(animate: true, sender: self)
 ```
 
 - 直接进入相册选择
 ```
 let ac = ZLPhotoPreviewSheet()
 ac.selectImageBlock = { [weak self] (images, assets, isOriginal) in
     // your code
 }
 ac.showPhotoLibrary(sender: self)
 ```
 
 - 需要注意的地方，你需要在你app的 `Info.plist` 中添加如下键值对
 ```
 //如果不添加该键值对，则不支持多语言，相册名称默认为英文
 Localized resources can be mixed YES
 //或者右键plist文件Open As->Source Code 添加
 CFBundleAllowMixedLocalizations
 
 //相册使用权限描述
 Privacy - Photo Library Usage Description
 //相机使用权限描述
 Privacy - Camera Usage Description
 //麦克风使用权限描述
 Privacy - Microphone Usage Description
 ```
 
 
### 更新日志
> [更多更新日志](https://github.com/longitachi/ZLPhotoBrowser/blob/master/UPDATELOG.md)
```
● 4.0.5: 适配iOS14 limited权限; 优化图片预览显示; 优化大长/宽图编辑; 
● 4.0.4: 优化图片编辑体验，记录之前编辑状态; 添加是否允许拍照参数; 优化降序照片获取顺序; fix #510, fix #513; 修复其他已知bug;
● 4.0.2: 新增框架样式设置(新增一种仿微信的样式); 编辑图片添加马赛克功能; 添加下拉返回动画; 自定义相机支持最短录制时间设置; 优化gif照片的回调;
● 4.0.1: 优化视频编辑功能; 增加自定义列数功能; 修复一些bug;
● 4.0.0: 框架升级为纯`Swift`编写，最低支持右`iOS8`升级到`iOS10`;
...
```

### <a id="安装方法"></a>使用方法

* Manually 
  * 1.直接把`Sources`文件夹拖入到你的工程中
  
* Cocoapods
  * 1.在Podfile 中添加 `pod 'ZLPhotoBrowser'`
  * 2.执行 `pod install`
  > 如找不到最新版本，可首先执行`pod repo update`
  
* Carthage
  * 1.在Cartfile 中添加 `github "longitachi/ZLPhotoBrowser" ~> 4.0.0`
  * 2.执行 `carthage update ZLPhotoBrowser --platform iOS`
  
* Swift Package Manager (该方式集成暂时有问题，图片及多语言资源无法读取，请暂时先用其他方式)
  * 1. 选择 File > Swift Packages > Add Package Dependency，输入 `https://github.com/longitachi/ZLPhotoBrowser.git`
  * 2. 输入对应版本号（SPM 最低版本为 `4.0.5`）
  * 3. 等Xcode下载完成后确定即可

### <a id="效果图"></a> 效果图
- 选择
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/%E5%BF%AB%E9%80%9F%E9%80%89%E6%8B%A9.gif)
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/%E7%9B%B8%E5%86%8C%E5%86%85%E9%83%A8%E9%80%89%E6%8B%A9.gif)
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/%E9%A2%84%E8%A7%88%E5%A4%A7%E5%9B%BE.gif)

- 编辑图片

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/editImage.gif)

- 编辑视频

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/editVideo.gif)

- 多语言

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/%E5%A4%9A%E8%AF%AD%E8%A8%80.gif)

- 自定义相机介绍

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/introduce.png)


