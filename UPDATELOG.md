# Update Log

-----

## [3.1.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.1.4) (2020-04-08)

#### Add
* 添加自定义相机分辨率(320*240, 960*540);
* 编辑视频最小允许编辑5s;
* 添加相机是否可用检测;


#### Fix
* 修正拍照后图片方向. [#472](https://github.com/longitachi/ZLPhotoBrowser/issues/472);
* 修正部分多语言错误的问题. [#469](https://github.com/longitachi/ZLPhotoBrowser/issues/469);

---

## [3.1.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.1.3) (2020-01-13)

#### Add
* 修改曝光模式;
* 拍照界面显示 "轻触拍照，按住摄像" 提示;
* 增加直接调用编辑图片api;

---

## [3.1.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.1.2) (2019-10-24)

#### Add
* SDWebImage 不在指定依赖版本号;

---

## [3.1.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.1.1) (2019-10-17)

#### Add
* 优化进入相册速度及从相册列表进入选择界面流程;
* 选择相片时候添加progress;

#### Fix
* 解决原图显示0B的bug.[#349](https://github.com/longitachi/ZLPhotoBrowser/issues/349)
* 解决视频录制小于0.3s，按照拍照返回没有图片数据的bug.[#386](https://github.com/longitachi/ZLPhotoBrowser/issues/386)

---

## [3.1.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.1.0) (2019-09-26)

#### Add
* 初步适配iOS13;
* 修改拍摄视频时1s以下不给保存的时间点为0.3s，即自定义相机拍摄视频时0.3s以下按拍照处理;

---

## [3.0.7](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.0.7) (2019-09-04)

#### Add
* 网络视频播放添加进度条;
* SDWebImage依赖升级5.1.0以上版本;

#### Fix
* 选中图片index角标bug.[#405](https://github.com/longitachi/ZLPhotoBrowser/issues/405)

---


## [3.0.6](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.0.6) (2019-07-31)

#### Add
* 添加选中图片显示index功能;
* 新增(及修改)部分颜色api，方便修改框架内部颜色;
*  修改框架默认风格为微信的风格; 
* 压缩图片资源;

---

## [3.0.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.0.5) (2019-06-27)

#### Add
* 预览快速选择界面文字颜色支持自定义; 
* 编辑界面按钮增大;

### Fix
* 解决录制视频超过10s没有声音的bug.[#381](https://github.com/longitachi/ZLPhotoBrowser/issues/381)

---


## [3.0.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.0.4) (2019-05-19)

#### Add
* 添加视频选择最大最小个数限制;.

### Fix
* 解决网络gif图片无法播放的bug.[#372](https://github.com/longitachi/ZLPhotoBrowser/pull/372)
* fix已知bug.[#371](https://github.com/longitachi/ZLPhotoBrowser/issues/371)

---


## [3.0.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.0.3) (2019-05-09)

#### Add
* 依赖库SDWebImage升级为5.0.2以上; 
* 支持直接调用相机;

### Fix
* 解决图片浏览器关闭时取消所有sd图片请求的bug.[#366](https://github.com/longitachi/ZLPhotoBrowser/issues/366)

---


## [3.0.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.0.1) (2019-04-08)

#### Add
* 压缩bundle内图片;
* 支持直接选择iCloud照片，并添加解析图片超时时间属性;

---

## [3.0.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.0.0) (2019-02-20)

#### Add
* 支持carthage集成;
* 删除滤镜功能;

---

## [2.7.8](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.8) (2019-02-20)

#### Add
* 添加iCloud图片加载进度条;
* 支持iCloud视频播放;
* 优化部分体验;

---

## [2.7.6](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.6) (2018-11-29)

#### Add
* 预览大图界面支持precent情况下的下拉返回;

---

## [2.7.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.5) (2018-11-07)

#### Add
* 编辑图片支持自定义工具类型.

#### Fix
* 视频加水印可能报错.[#314](https://github.com/longitachi/ZLPhotoBrowser/issues/314)
* 查看大图界面选择照片后，下拉返回上个界面未刷新选中状态.[#318](https://github.com/longitachi/ZLPhotoBrowser/issues/318)

---

## [2.7.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.4) (2018-08-16)

#### Add
* 横滑大图界面添加下拉返回功能.

#### Fix
* 不允许录制视频时候，不请求麦克风权限.[#299](https://github.com/longitachi/ZLPhotoBrowser/issues/299)

---

## [2.7.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.3) (2018-07-11)

#### Fix
* 解决预览已选择图片多张状态下仍显示编辑按钮，确定按钮已选择个数不正确及crash的bug.[#269](https://github.com/longitachi/ZLPhotoBrowser/issues/269)
* 解决选择视频时仍显示原图按钮的bug.[#274](https://github.com/longitachi/ZLPhotoBrowser/issues/274)

---

## [2.7.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.2) (2018-07-04)

#### Fix
* merge request [#276](https://github.com/longitachi/ZLPhotoBrowser/issues/276)

---

## [2.7.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.1) (2018-06-20)

#### Add
* 可自定义导航返回按钮图片

#### Fix
* 解决录制视频大于最大选择时长时自动选择的bug.[#264](https://github.com/longitachi/ZLPhotoBrowser/issues/264)

---

## [2.7.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.0) (2018-06-03)

#### Add
* 所有图片资源加上前缀

---

## [2.6.9](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.9) (2018-05-11)

#### Add
* 重构图片编辑界面，添加滤镜功能

#### Fix
* 解决相册图片列表界面底部工具栏消失的bug.[#238](https://github.com/longitachi/ZLPhotoBrowser/issues/238)
* 解决预览网络视频崩溃的bug. [#240](https://github.com/longitachi/ZLPhotoBrowser/issues/240)

---

## [2.6.7](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.7) (2018-05-03)

#### Add
* 优化视频编辑界面，极大减少进入时的等待时间. [#234](https://github.com/longitachi/ZLPhotoBrowser/issues/234)

---

## [2.6.6](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.6) (2018-04-21)

#### Add
* 新增隐藏裁剪图片界面比例工具条功能.

#### Fix
* 解决iOS11之前预览网络视频crash的bug. [#216](https://github.com/longitachi/ZLPhotoBrowser/issues/216)

---

## [2.6.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.5) (2018-03-31)

#### Add
* 新增隐藏"已隐藏"照片及相册的功能.

#### Fix
* 优化预览网络图片/视频时根据url后缀判断的类型方式. [#221](https://github.com/longitachi/ZLPhotoBrowser/issues/221)

---

## [2.6.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.4) (2018-01-17)

#### Add
* 优化部分代码，提升性能.

#### Fix
* 解决无权限视图中右上角返回按钮设置颜色无效的bug.
* 解决放大后继续滑动图片导致缩放比例不正确的bug. [#181](https://github.com/longitachi/ZLPhotoBrowser/issues/181)
* 解决当 ZLPhotoActionSheet 对象为类属性时通过特定操作出现bug及显示的问题. [#184](https://github.com/longitachi/ZLPhotoBrowser/issues/184)
* 解决iOS8系统下，保存编辑视频出错的bug. [#185](https://github.com/longitachi/ZLPhotoBrowser/issues/185)

---

## [2.6.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.3) (2018-01-10)

#### Add
* 新增自定义多语言文本功能.
* 新增预览网络视频功能.

#### Fix
* 解决最大选择数为1时候，设置是否显示选择按钮无效的问题.
* 解决不允许选择照片，但允许选择及拍摄视频时，相册内部拍照按钮不显示的bug. [#175](https://github.com/longitachi/ZLPhotoBrowser/issues/175)

---

## [2.6.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.2) (2018-01-03)

#### Add
* 新增编辑图片后可选是否保存新图片参数.
* 添加取消选择图片回调.

#### Fix
* 优化编辑图片时候的旋转操作，避免了快速连续点击时导致图片裁剪区域显示错误的问题.

---

## [2.6.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.1) (2017-12-26)

#### Add
* 新增导出视频添加粒子特效功能(如下雪特效).
* 新增编辑图片时旋转图片功能.
* 优化预览界面对宽高比超大的图片的显示.

---

## [2.6.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.0) (2017-12-21)

#### Add
* 新增调用系统相机录制视频功能.
* 支持导出指定尺寸的视频，支持导出视频添加图片水印.
* 优化部分UI显示.

#### Fix
* 解决 `iOS11.2` 版本 原图按钮显示不全的bug. [#164](https://github.com/longitachi/ZLPhotoBrowser/issues/164)
* 导出指定尺寸视频. [#166](https://github.com/longitachi/ZLPhotoBrowser/issues/166)

---

## [2.5.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.5) (2017-12-13)

#### Add
* 导出视频支持压缩.
* 优化视频导出格式，删除3gp格式.

---

## [2.5.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.4) (2017-12-05)

#### Add
* 新增视频导出方法.
* 新增获取照片及视频路径的方法.

#### Fix
* 解决了自定义相机消失后，其他软件音乐不恢复播放的问题. [#152](https://github.com/longitachi/ZLPhotoBrowser/issues/152)

---

## [2.5.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.3) (2017-11-27)

#### Add
* 拍摄视频及编辑视频支持多种格式(mov, mp4, 3gp).
* 新增相册名字等多语言，以完善手动设置语言时相册名字跟随系统的问题.
* 简化相册调用，configuration 由必传参数修改为非必传参数.

---

## [2.5.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.2) (2017-11-20)

#### Add
* 抽取相册属性独立为 `ZLPhotoConfiguration` 对象.
* 新增设置状态栏样式api.

#### Fix
* 解决预览已选择图片和网络图片时候内存泄漏的问题.

---

## [2.5.1.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.1.1) (2017-11-15)

#### Fix
* 解决创建相册时候获取app名字为null的bug. [#141](https://github.com/longitachi/ZLPhotoBrowser/issues/152)

---

## [2.5.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.1) (2017-11-11)

#### Add
* 新增自定义相机(仿微信)，开发者可选使用自定义相机或系统相机.
* 支持录制视频，可设置最大录制时长及清晰度.

#### Fix
* 解决裁剪比例只有一个且为1:1时候，下方比例工具条不隐藏的bug.

---

## [2.5.0.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.0.2) (2017-11-04)

#### Add
* 新增自行切换框架语言api.
* 当编辑比例只有一个且为custom或1:1时候，隐藏裁剪比例工具条.

#### Fix
* 无相册访问权限时候，跳往无权限视图方法走两次. [#132](https://github.com/longitachi/ZLPhotoBrowser/issues/132)
* 使用系统tabbar时，预览视图位置偏上. [#124](https://github.com/longitachi/ZLPhotoBrowser/issues/124)

---

## [2.5.0.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.0.1) (2017-10-26)

#### Add
* 提供逐个解析图片api方法，方便 `shouldAnialysisAsset` 为 `NO` 时的使用.
* 提供控制是否可以选择原图参数.

---

## [2.5.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.0) (2017-10-23)

####
* 新增选择后是否自动解析图片参数 shouldAnialysisAsset (针对需要选择大量图片的功能，框架一次解析大量图片时，会导致内存瞬间大幅增高，建议此时置该参数为NO，然后拿到asset后自行逐个解析).
* 修改图片压缩方式，确保原图尺寸不变.

#### Fix
* 解决部分关于UI的代码在子线程执行的问题. [#113](https://github.com/longitachi/ZLPhotoBrowser/issues/113)
* 优化 `iOS11` 中如果设置 `[[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];` 导致内部控件上移64像素的问题. [#114](https://github.com/longitachi/ZLPhotoBrowser/issues/114)
* 优化一次选择多张照片，同时解析导致内存暴涨并crash的bug. [#118](https://github.com/longitachi/ZLPhotoBrowser/issues/118)

---

## [2.4.8~2.4.9](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.9) (2017-10-17)

#### Add
* 新增预览界面拖拽选择功能.
* 支持开发者使用自定义图片资源.
* 开放导航标题颜色、底部工具栏背景色、底部按钮可交互与不可交互标题颜色的设置api.

#### Fix
* 解决weakify(var)，strongify(var)与其他类库发生宏定义冲突的问题.
* 解决项目为状态栏隐藏，调用框架后状态栏显示的问题.

---

## [2.4.7](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.7) (2017-10-13)

#### Fix
* 解决多次进入相册可能导致crash的bug. [#108](https://github.com/longitachi/ZLPhotoBrowser/issues/108)

---

## [2.4.6](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.6) (2017-10-09)

#### Add
* 新增预览网络图片长按保存至相册功能.

#### Fix
* 解决相册查看大图界面单机会回到第一张的bug. [#103](https://github.com/longitachi/ZLPhotoBrowser/issues/103)

---

## [2.4.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.5) (2017-09-29)

#### Add
* 预览已选择图片时候增加是否为原图参数. [#101](https://github.com/longitachi/ZLPhotoBrowser/issues/101)

#### Fix
* 解决设置相册内部隐藏拍照按钮无效的bug. [#102](https://github.com/longitachi/ZLPhotoBrowser/issues/101)

---

## [2.4.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.4) (2017-09-27)

#### Fix
* 解决相册内部拍照按钮不显示的bug. [#100](https://github.com/longitachi/ZLPhotoBrowser/issues/100)

---

## [2.4.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.3) (2017-09-22)

#### Add
* 适配 iPhone X.
* 优化启动进入相册速度.
* 预览网络图片可设置是否显示底部工具条及导航右侧按钮.

---

## [2.4.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.2) (2017-09-18)

#### Add
* 新增视频编辑功能(仿微信).
* 优化代码，提升滑动性能及流畅度.

---

## [2.4.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.1) (2017-09-14)

#### Add
* 新增仿iPhone相册滑动多选功能.

---

## [2.4.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.0) (2017-09-07)

#### Add
* 新增预览网络图片及本地图片功能.

---

## [2.3.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.3.3) (2017-09-01)

#### Add
* 删除废弃文件，新增已选择图片遮罩层标记功能.

---

## [2.3.1~2.3.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.3.2) (2017-08-31)

#### Add
* 新增设置导航条颜色api.
* 适配横屏.
* 适配iPad，优化iPad下显示.

#### Fix
* 解决 `iOS9` 以下系统判断 `ForceTouch` 可用性崩溃的bug.

---

## [2.2.9~2.3.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.3.0) (2017-08-18)

#### Add
* 新增单选模式下选择图片后直接进入编辑界面功能.
* 开放设置图片裁剪比例api.

---

## [2.2.8](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.2.8) (2017-08-16)

#### Add
* 优化部分显示问题.
* 扩展图片编辑功能，增加裁剪比例选项.

---

## [2.2.7](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.2.7) (2017-08-03)

#### Add
* 扩大选择按钮点击区域.
* 删除多余图片及xib文件.
* 优化性能.

---

## [2.2.6](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.2.6) (2017-07-26)

#### Add
* 新增混合选择image、gif、livephoto、video类型.
* 支持video、gif、livephoto类型的多选.
* 支持控制video最大选择时长.
* 废弃部分api，考虑不给使用者由于更新带来的错误，暂未删除废弃文件及api，后续更新版本会删除.

---

## [2.2.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.2.5) (2017-07-03)

#### Fix
* 修复 `ForceTouch` 点击内部拍照按钮时闪退的bug.

---

## [2.2.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.2.4) (2017-06-28)

#### Add
* 去除原图时视频字节显示.
* 优化图片加载显示方式.

#### Fix
* 优化 `ForceTouch` 造成的内存泄漏的问题.

---

## [2.2.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.2.3) (2017-06-23)

#### Add
* 增加图片编辑裁剪功能.

---

## 2.2.2 (2017-06-20)

#### Add
* 新增 3DTouch 预览功能.

---

early

* 新增 LivePhoto 选择功能.
* 新增内部相机拍照按钮实时显示相机俘获画面功能.
* 新增cell圆角弧度自定义功能.
* 支持选择视频、gif.
* 支持相册内拍照(可拍照多张).
* 支持预览确定选择的图片，并可选择修改.
* 支持预览确定选择的gif、video.
...

