# ZLPhotoBrowser

###项目整体介绍
* 该框架为一个多选照片（不支持视频）的框架
  * 1.支持预览多选(预览图数量及最大多选数可设置)
    * [预览快速多选效果图] (#预览快速多选效果图)
  * 2.支持预览大图，大图的缩放等
    * [预览大图及缩放效果图] (#预览大图及缩放效果图)
  * 3.支持实时拍照
  * 4.支持多相册(不同的相册名字)图片混合多选
    * [相册内混合选择效果图] (#相册内混合选择效果图)
  * 5.预览已选择照片
    * [预览已选择照片效果图] (#预览已选择照片效果图)
  * 6.可实时监测相册图片变化(即在预览图时，如果用户触发截屏等操作，会实时的加载出该图片)
    * [实时监测相册内图片变化] (#实时监测相册内图片变化)
* [常用Api] (#常用Api)
* [使用方法] (#使用方法)

###框架支持与框架依赖
该框架最低支持到iOS8.0，采用arc模式</br>
需要导入Photos.framework

###<a id="常用Api"></a>常用Api
```objc
NS_ASSUME_NONNULL_BEGIN

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
 *              调用该空间的试图控制器
 * @param animate
 *              是否显示动画效果
 * @param completion
 *              完成回调
 */
- (void)showWithSender:(UIViewController *)sender animate:(BOOL)animate completion:(void (^)(NSArray<UIImage *> *selectPhotos))completion;

NS_ASSUME_NONNULL_END

@end
```

###<a id="使用方法"></a>使用方法
把PhotoBrowser文件夹拖入到您的工程中

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
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览大图快速多选.gif)

### <a id="预览大图及缩放效果图"></a>预览大图及缩放效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/查看大图支持缩放.gif)

### <a id="相册内混合选择效果图"></a>相册内混合选择效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/相册内混合选择.gif)

### <a id="预览已选择照片效果图"></a>预览已选择照片效果图
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/预览已选择照片.gif)

### <a id="实时监测相册内图片变化"></a>实时监测相册内图片变化
![image](https://github.com/longitachi/ZLPhotoBrowser/blob/master/效果图/实时监控相册变化.gif)
