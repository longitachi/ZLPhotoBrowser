# ZLPhotoBrowser
[![Version](https://img.shields.io/cocoapods/v/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
[![License](https://img.shields.io/cocoapods/l/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
[![Platform](https://img.shields.io/cocoapods/p/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
![Language](https://img.shields.io/badge/Language-%20Objective%20C%20-blue.svg)

### 框架整体介绍
* 该框架为一个多选照片（支持视频、gif）的框架，兼容设备开启的iCloud照片存储，支持记录历史选择照片。
  * 1.支持多语言国际化(中:简繁, 英，日)
    * [多语言国际化效果图](#多语言国际化效果图)
  * 2.支持预览多选(预览图数量及最大多选数可设置)
    * [预览快速多选效果图](#预览快速多选效果图)
  * 3.支持直接进入相册多选
    * [直接进入相册选择相片效果图](#直接进入相册选择相片效果图)
  * 4.支持预览大图，大图的缩放等（预览视频、gif）
    * [预览大图及缩放效果图](#预览大图及缩放效果图)
  * 5.支持预览界面和相册内实时拍照
    * [拍照](#拍照)
  * 6.支持多相册图片混合多选
    * [相册内混合选择效果图](#相册内混合选择效果图)
  * 7.预览已选择照片
    * [预览已选择照片效果图](#预览已选择照片效果图)
  * 8.原图功能
    * [原图功能效果图](#原图功能效果图)
* [常用Api](#常用Api)
* [使用方法(支持cocoapods安装)](#使用方法)

### 框架支持与框架依赖
* iOS8.0
  * (采用arc模式)
* XCode8.0
  * (需要导入Photos.framework)

### <a id="常用Api"></a>常用Api
```objc
/**
 显示ZLPhotoActionSheet选择照片视图
 
 @warning 需提前赋值 sender 对象
 @param animate 是否显示动画效果
 */
- (void)showPreviewAnimated:(BOOL)animate;

/**
 显示ZLPhotoActionSheet选择照片视图

 @param animate 是否显示动画效果
 @param sender 调用该对象的控制器
 */
- (void)showPreviewAnimated:(BOOL)animate sender:(UIViewController *)sender;

/**
 直接进入相册选择界面
 */
- (void)showPhotoLibrary;

/**
 直接进入相册选择界面
 
 @param sender 调用该对象的控制器
 */
- (void)showPhotoLibraryWithSender:(UIViewController *)sender;

/**
 提供 预览用户已选择的照片(非gif与video类型)，并可以取消已选择的照片

 @param photos 已选择的uiimage照片数组
 @param assets 已选择的phasset照片数组
 @param index 点击的照片索引
 */
- (void)previewSelectedPhotos:(NSArray<UIImage *> *)photos assets:(NSArray<PHAsset *> *)assets index:(NSInteger)index;

```

### <a id="使用方法"></a>使用方法
- 直接把PhotoBrowser文件夹拖入到您的工程中
- Cocoapods安装
```objc
pod search ZLPhotoBrowser
```
- 在项目plist配置文件中添加如下键，值并设为YES
```objc
Localized resources can be mixed YES
//或者右键plist文件Open As->Source Code 添加
<key>CFBundleAllowMixedLocalizations</key>
<true/>
```

```objc
    #import "ZLPhotoActionSheet.h"
    
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大预览数
    actionSheet.maxPreviewCount = 20;
    //设置照片最大选择数
    actionSheet.maxSelectCount = 10;
    actionSheet.sender = self;
    
    [actionSheet setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        //your codes
    }];
    [actionSheet setSelectGifBlock:^(UIImage * _Nonnull gif, PHAsset * _Nonnull asset) {
        //your codes
    }];
    [actionSheet setSelectVideoBlock:^(UIImage * _Nonnull coverImage, PHAsset * _Nonnull asset) {
        //your codes
    }];
```

### <a id="多语言国际化效果图"></a> 多语言国际化效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/english.png)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/japan.png)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/zh-hans.png)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/zh-hant.png)

### <a id="预览快速多选效果图"></a> 预览快速多选效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览图快速选择.gif)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览大图快速选择.gif)

### <a id="直接进入相册选择相片效果图"></a> 直接进入相册选择相片效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/直接进入相册选择相片.gif)

### <a id="预览大图及缩放效果图"></a>预览大图及缩放效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/查看大图支持缩放.gif)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览选择gif.gif)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览选择视频.gif)

### <a id="拍照"></a>拍照
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/相册内部拍照.gif)

### <a id="相册内混合选择效果图"></a>相册内混合选择效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/相册内混合选择.gif)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/不能同时选择照片和gif或video.gif)

### <a id="预览已选择照片效果图"></a>预览已选择照片效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览已选择照片.gif)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览确定选择的照片.gif)

### <a id="原图功能效果图"></a>原图功能效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/原图功能.gif)

