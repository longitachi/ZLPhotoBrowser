# ZLPhotoBrowser

###框架整体介绍
* 该框架为一个多选照片（不支持视频）的框架，兼容设备开启的iCloud照片存储，并在加载和选择iCloud端照片时做部分细节处理。
  * 1.支持预览多选(预览图数量及最大多选数可设置)
    * [预览快速多选效果图] (#预览快速多选效果图)
  * 2.支持预览大图，大图的缩放等
    * [预览大图及缩放效果图] (#预览大图及缩放效果图)
  * 3.支持实时拍照
  * 4.支持多相册(不同的相册名字)图片混合多选
    * [相册内混合选择效果图] (#相册内混合选择效果图)
  * 5.预览已选择照片
    * [预览已选择照片效果图] (#预览已选择照片效果图)
  * 6.原图功能
    * [原图功能效果图] (#原图功能效果图)
  * 7.可实时监测相册图片变化(即在预览图时，如果用户触发截屏等操作，会实时的加载出该图片)
    * [实时监测相册内图片变化] (#实时监测相册内图片变化)
  * 8.加载iCloud端照片(所有照片加载时都会先加载模糊的图片，然后过渡高清图，iCloud端照片加载更加明显)
    * [加载iCloud端照片效果图] (#加载iCloud端照片效果图)
* [常用Api] (#常用Api)
* [使用方法(支持cocoapods安装)] (#使用方法)

###框架支持与框架依赖
该框架最低支持到iOS8.0，采用arc模式</br>
需要导入Photos.framework

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
NS_ASSUME_NONNULL_BEGIN

@class ZLSelectPhotoModel;

@interface ZLPhotoActionSheet : UIView

@property (nonatomic, weak) UIViewController *sender;

@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

/** 最大选择数 default is 10 */
@property (nonatomic, assign) NSInteger maxSelectCount;

/** 预览图最大显示数 default is 20 */
@property (nonatomic, assign) NSInteger maxPreviewCount;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/**
 * @brief 显示多选照片视图
 * @param sender
 *              调用该空间的视图控制器
 * @param animate
 *              是否显示动画效果
 * @param selectedAssets
 *              已选择的PHAsset，再次调用"showWithSender:animate:lastSelectPhotoModels:completion:"方法之前，可以把上次回调中selectAssets赋值给该属性，便可实现记录上次选择照片的功能，若不需要记录上次选择照片的功能，则该值传nil即可
 * @param completion
 *              完成回调
 */
- (void)showWithSender:(UIViewController *)sender
               animate:(BOOL)animate
        lastSelectPhotoModels:( NSArray<ZLSelectPhotoModel *> * _Nullable )lastSelectPhotoModels
            completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<ZLSelectPhotoModel *> *selectPhotoModels))completion;

NS_ASSUME_NONNULL_END

@end
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
[actionSheet showWithSender:self animate:YES completion:^(NSArray<UIImage *> * _Nonnull selectPhotos) {
    // your codes
}];
    
```

### <a id="预览快速多选效果图"></a>预览快速多选效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览图快速选择.gif)
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览大图快速选择.gif)

### <a id="预览大图及缩放效果图"></a>预览大图及缩放效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/查看大图支持缩放.gif)

### <a id="相册内混合选择效果图"></a>相册内混合选择效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/相册内混合选择.gif)

### <a id="预览已选择照片效果图"></a>预览已选择照片效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览已选择照片.gif)

### <a id="原图功能效果图"></a>原图功能效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/原图功能.gif)

### <a id="实时监测相册内图片变化"></a>实时监测相册内图片变化
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/实时监控相册变化.gif)

### <a id="加载iCloud端照片效果图"></a>加载iCloud端照片效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/加载iCloud照片.gif)
