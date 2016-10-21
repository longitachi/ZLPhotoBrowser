# ZLPhotoBrowser
[![Version](https://img.shields.io/cocoapods/v/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
[![License](https://img.shields.io/cocoapods/l/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
[![Platform](https://img.shields.io/cocoapods/p/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
![Language](https://img.shields.io/badge/Language-%20Objective%20C%20-blue.svg)

###框架整体介绍
* 该框架为一个多选照片（不支持视频）的框架，兼容设备开启的iCloud照片存储，并在加载和选择iCloud端照片时做部分细节处理(快速滑动切换图片不会导致图片显示混乱)，支持记录历史选择照片。
  * 1.支持多语言国际化(中:简繁, 英，日)
    * [多语言国际化效果图] (#多语言国际化效果图)
  * 2.支持预览多选(预览图数量及最大多选数可设置)
    * [预览快速多选效果图] (#预览快速多选效果图)
  * 3.支持直接进入相册多选
    * [直接进入相册选择相片效果图] (#直接进入相册选择相片效果图)
  * 4.支持预览大图，大图的缩放等
    * [预览大图及缩放效果图] (#预览大图及缩放效果图)
  * 5.支持实时拍照
  * 6.支持多相册(不同的相册名字)图片混合多选
    * [相册内混合选择效果图] (#相册内混合选择效果图)
  * 7.预览已选择照片
    * [预览已选择照片效果图] (#预览已选择照片效果图)
  * 8.原图功能
    * [原图功能效果图] (#原图功能效果图)
  * 9.可实时监测相册图片变化(即在预览图时，如果用户触发截屏等操作，会实时的加载出该图片)
    * [实时监测相册内图片变化] (#实时监测相册内图片变化)
  * 10.加载iCloud端照片(所有照片加载时都会先加载模糊的图片，然后过渡高清图，iCloud端照片加载更加明显)
    * [加载iCloud端照片效果图] (#加载iCloud端照片效果图)
* [常用Api] (#常用Api)
* [过期Api] (#过期Api)
* [使用方法(支持cocoapods安装)] (#使用方法)

###框架支持与框架依赖
* iOS8.0, * (采用arc模式)
* XCode8.0, * (需要导入Photos.framework)

###注意点
如果项目中设置了
```objc
[[UINavigationBar appearance] setTranslucent:NO];
```
则需要在ZLDefine.h里 把kViewHeight 修改为
```objc
#define kViewHeight [[UIScreen mainScreen] bounds].size.height - 64
```

###<a id="常用Api"></a>常用Api
```objc
/** 最大选择数 default is 10 */
@property (nonatomic, assign) NSInteger maxSelectCount;

/** 预览图最大显示数 default is 20 */
@property (nonatomic, assign) NSInteger maxPreviewCount;

/**
 * @brief 显示多选照片视图，带预览效果
 * @param sender 调用该控件的视图控制器
 * @param animate 是否显示动画效果
 * @param lastSelectPhotoModels 已选择的PHAsset，再次调用"showWithSender:animate:lastSelectPhotoModels:completion:"方法之前，可以把上次回调中selectPhotoModels赋值给该属性，便可实现记录上次选择照片的功能，若不需要记录上次选择照片的功能，则该值传nil即可
 * @param completion 完成回调
 */
- (void)showPreviewPhotoWithSender:(UIViewController *)sender
                 animate:(BOOL)animate
   lastSelectPhotoModels:(NSArray<ZLSelectPhotoModel *> * _Nullable)lastSelectPhotoModels
              completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<ZLSelectPhotoModel *> *selectPhotoModels))completion;

/**
 * @brief 显示多选照片视图，直接进入相册选择界面
 * 参数含义同上
 */
- (void)showPhotoLibraryWithSender:(UIViewController *)sender
             lastSelectPhotoModels:(NSArray<ZLSelectPhotoModel *> * _Nullable)lastSelectPhotoModels
                        completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<ZLSelectPhotoModel *> *selectPhotoModels))completion;

```

###<a id="过期Api"></a>过期Api
```objc
//如继续使用该api，将默认调用显示预览视图的效果api
- (void)showWithSender:(UIViewController *)sender
               animate:(BOOL)animate
        lastSelectPhotoModels:(NSArray<ZLSelectPhotoModel *> * _Nullable)lastSelectPhotoModels
            completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<ZLSelectPhotoModel *> *selectPhotoModels))completion NS_DEPRECATED(2.0, 2.0, 2.0, 8.0, "Use - showPreviewPhotoWithSender:animate:lastSelectPhotoModels:completion:");
```

###<a id="使用方法"></a>使用方法
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
//设置最大选择数量
actionSheet.maxSelectCount = 5;
//设置预览图最大数目
actionSheet.maxPreviewCount = 20;
[actionSheet showPreviewPhotoWithSender:self animate:YES lastSelectPhotoModels:self.lastSelectMoldels completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<ZLSelectPhotoModel *> * _Nonnull selectPhotoModels) {
        // your codes...
}];
    
```

###<a id="多语言国际化效果图"></a>多语言国际化效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/english.png)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/japan.png)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/zh-hans.png)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/zh-hant.png)

###<a id="预览快速多选效果图"></a>预览快速多选效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览图快速选择.gif)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览大图快速选择.gif)

###<a id="直接进入相册选择相片效果图"></a>直接进入相册选择相片效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/直接进入相册选择相片.gif)

###<a id="预览大图及缩放效果图"></a>预览大图及缩放效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/查看大图支持缩放.gif)

###<a id="相册内混合选择效果图"></a>相册内混合选择效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/相册内混合选择.gif)

###<a id="预览已选择照片效果图"></a>预览已选择照片效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览已选择照片.gif)

###<a id="原图功能效果图"></a>原图功能效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/原图功能.gif)

###<a id="实时监测相册内图片变化"></a>实时监测相册内图片变化
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/实时监控相册变化.gif)

###<a id="加载iCloud端照片效果图"></a>加载iCloud端照片效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/加载iCloud照片.gif)
