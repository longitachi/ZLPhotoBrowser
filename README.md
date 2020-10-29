[![Version](https://img.shields.io/cocoapods/v/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)&nbsp;
[![License](https://img.shields.io/cocoapods/l/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
[![Platform](https://img.shields.io/cocoapods/p/ZLPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/ZLPhotoBrowser)
![Language](https://img.shields.io/badge/Language-%20Swift%20-blue.svg)
<a href="http://www.jianshu.com/u/a02909a8a93b"><img src="https://img.shields.io/badge/JianShu-@longitachi-red.svg?style=flat"></a>

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/preview_with_title.png)

----------------------------------------

ZLPhotoBrowser is a lightweight and pure Swift implemented library for select photos from album. Support select multiple photos, video, gif, livePhoto. Support edit image and crop video.

[中文简介](https://github.com/longitachi/ZLPhotoBrowser/blob/master/README_CN.md)

### Directory
* [Features](#Features)
* [Requirements](#Requirements)
* [Usage](#Usage)
* [Update Log](#UpdateLog)
* [Languages](#Languages)
* [Installation(Support Cocoapods/Carthage/SPM)](#Installation)
* [Demo Effect](#DemoEffect)

Detailed usage of `Swift` and `OC`, please refer to [Wiki](https://github.com/longitachi/ZLPhotoBrowser/wiki) 


### <a id="Features"></a>Features
- [x] iOS14 support.
- [x] Portrait and landscape support.
- [x] Two framework style.
- [x] Preview selection (Support drag and drop).
- [x] Library selection (Support sliding selection).
- [x] Image/Gif/LivePhoto/Video Support.
- [x] Customize the maximum number of previews or selection, the maximum and minimum optional duration of the video.
- [x] Customize the number of columns displayed in each row.
- [x] Image editor (Draw/Crop/Mosaic/Filter), (Draw color can be customized; Crop ratio can be customized; Filter effect can be customized; You can choose the editing tool you want).
- [x] Video editor.
- [x] Custom camera.
- [x] Multi-language.
- [x] Selected index.
- [x] Selected/unselectable state shadow mask.
- [x] The selected photos are displayed at the bottom of the big picture interface, which can be dragged and sorted.
- [x] The camera's internal photo cell can displays the captured images of the camera.
- [x] Customize font.
- [x] The color of each part of the framework can be customized (Provide dynamic color can support light/dark mode).
- [x] Customize images.

> If you have good needs and suggestions in use, or encounter any bugs, please feel free to issue and I will reply in time
 
### <a id="Requirements"></a>Requirements
 * iOS 10.0
 * Swift 5.x
 * Xcode 12.x
 
### <a id="Usage"></a>Usage
 - Preview selection
 ```
 let ps = ZLPhotoPreviewSheet()
 ps.selectImageBlock = { [weak self] (images, assets, isOriginal) in
     // your code
 }
 ps.showPreview(animate: true, sender: self)
 ```
 
 - Library selection
 ```
 let ps = ZLPhotoPreviewSheet()
 ps.selectImageBlock = { [weak self] (images, assets, isOriginal) in
     // your code
 }
 ps.showPhotoLibrary(sender: self)
 ```
 
 - Pay attention, you need to add the following key-value pairs in your app's Info.plist

 ```
 // If you don’t add this key-value pair, multiple languages are not supported, and the album name defaults to English
 Localized resources can be mixed   YES
 
 Privacy - Photo Library Usage Description

 Privacy - Camera Usage Description

 Privacy - Microphone Usage Description
 ```
 
 
### <a id="UpdateLog"></a>Update Log
> [More logs](https://github.com/longitachi/ZLPhotoBrowser/blob/master/UPDATELOG.md)
```
● 4.0.9: 
    Support languages of more countries (French, German, Russian, Vietnamese, Korean, Malay, Italian).
    Support iOS14 limited authority.
    Provides the ability to preview PHAsset, local images and videos, network images and videos together.
    Optimize some UI effects.
● 4.0.8:
    Add filter to image editor.
● 4.0.7: 
    Image editor support crop ratios. 
    Custom camera supports switching camera during recording. 
    bug fixed.
...
```

### <a id="Languages"></a>Languages
🇨🇳 Chinese, 🇺🇸 English, 🇯🇵 Japanese, 🇫🇷 French, 🇩🇪 German, 🇷🇺 Russian, 🇻🇳 Vietnamese, 🇰🇷 Korean, 🇲🇾 Malay, 🇮🇹 Italian.

### <a id="Installation"></a>Installation
There are four ways to use ZLPhotoBrowser in your project:

  - using CocoaPods
  - using Carthage
  - using Swift Package Manager
  - manual install (build frameworks or embed Xcode Project)

#### CocoaPods
To integrate ZLPhotoBrowser into your Xcode project using CocoaPods, specify it to a target in your Podfile:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
  # your other pod
  # ...
  pod 'ZLPhotoBrowser'
end
```

Then, run the following command:

```
$ pod install
```

> If you cannot find the latest version, you can execute `pod repo update` first

#### Carthage
To integrate ZLPhotoBrowser into your Xcode project using Carthage, specify it in your Cartfile:

```
github "longitachi/ZLPhotoBrowser"
```

Then, run the following command to build the ZLPhotoBrowser framework:

```
$ carthage update ZLPhotoBrowser
```

#### Swift Package Manager
1. Select File > Swift Packages > Add Package Dependency. Enter https://github.com/longitachi/ZLPhotoBrowser.git in the "Choose Package Repository" dialog.
2. In the next page, specify the version resolving rule as "Up to Next Major" with "4.0.8" as its earliest version.
3. After Xcode checking out the source and resolving the version, you can choose the "ZLPhotoBrowser" library and add it to your app target.

### <a id="DemoEffect"></a> Demo Effect
- Selection
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/%E5%BF%AB%E9%80%9F%E9%80%89%E6%8B%A9.gif)
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/%E7%9B%B8%E5%86%8C%E5%86%85%E9%83%A8%E9%80%89%E6%8B%A9.gif)
![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/%E9%A2%84%E8%A7%88%E5%A4%A7%E5%9B%BE.gif)

- Image editor

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/editImage.gif)

- Video editor

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/editVideo.gif)

- Multi-language

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/%E5%A4%9A%E8%AF%AD%E8%A8%80.gif)

- Custom camera

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/introduce.png)


