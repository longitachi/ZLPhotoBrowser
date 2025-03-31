[![Version](https://img.shields.io/github/v/tag/longitachi/ZLPhotoBrowser.svg?color=blue&include_prereleases=&sort=semver)](https://cocoapods.org/pods/ZLPhotoBrowser)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![SPM supported](https://img.shields.io/badge/SwiftPM-supported-E57141.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-black)](https://raw.githubusercontent.com/longitachi/ZLPhotoBrowser/master/LICENSE)
[![Platform](https://img.shields.io/badge/Platforms-iOS-blue?style=flat)](https://img.shields.io/badge/Platforms-iOS-blue?style=flat)
![Language](https://img.shields.io/badge/Language-%20Swift%20-E57141.svg)
[![Usage](https://img.shields.io/badge/Usage-Doc-yarn?style=flat)](https://github.com/longitachi/ZLPhotoBrowser/wiki/How-to-use-(Swift))

![image](https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/preview_with_title.png)

----------------------------------------

English | [简体中文](https://github.com/longitachi/ZLPhotoBrowser/blob/master/README_CN.md)

ZLPhotoBrowser is a Wechat-like image picker. Support select normal photos, videos, gif and livePhoto. Support edit image and crop video.

### Directory
* [Features](#features)
* [Requirements](#requirements)
* [Usage](#usage)
* [Change Log](#change-log)
* [Languages](#languages)
* [Installation(Support Cocoapods/Carthage/SPM)](#installation)
* [Support](#support)
* [Demo Effect](#demo-effect)

Detailed usage of `Swift` and `OC`, please refer to [Wiki](https://github.com/longitachi/ZLPhotoBrowser/wiki).

If you only want to use the image edit feature, please move to [ZLImageEditor](https://github.com/longitachi/ZLImageEditor).

### Features
- [x] Support SwiftUI.
- [x] Portrait and landscape.
- [x] Two framework style.
- [x] Preview selection (Support drag and drop).
- [x] Library selection (Support sliding selection).
- [x] Image/Gif/LivePhoto/Video.
- [x] Customize the maximum number of previews or selection, the maximum and minimum optional duration of the video.
- [x] Customize the number of columns displayed in each row.
- [x] Image editor (Draw/Crop/Image sticker/Text sticker/Mosaic/Filter/Adjust(Brightness, Contrast and Saturation)), (Draw color can be customized; Crop ratio can be customized; Filter effect can be customized; You can choose the editing tool you want).
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

> If you have good needs and suggestions in use, or encounter any bugs, please create an issue and I will reply in time.
 
### Requirements
 * iOS 10.0
 * Swift 5.x
 * Xcode 13.x
 
### Usage
 - Preview selection
 ```swift
 let ps = ZLPhotoPreviewSheet()
 ps.selectImageBlock = { [weak self] results, isOriginal in
     // your code
 }
 ps.showPreview(animate: true, sender: self)
 ```
 
 - Library selection
 ```swift
 let ps = ZLPhotoPreviewSheet()
 ps.selectImageBlock = { [weak self] results, isOriginal in
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
 
 
### Change Log
> [More logs](https://github.com/longitachi/ZLPhotoBrowser/blob/master/CHANGELOG.md)
```
● 4.6.0.1
  Add:
    Support SwiftUI.
    Support for locked output orientation in custom camera.
    Optimize the playback experience of album videos and online videos.
    Add will-capture-block for customizable capture actions.
    Replace ZLPhotoPreviewSheet with ZLPhotoPicker. The permission of ZLPhotoPreviewSheet will be changed to private later.
    Enhance the text sticker feature by adding text outline and shadow effects.
  Fix:
    Fixed the bug that the time of automatically stopping recording is incorrect when clicking to record a video.
    Fix the issue where the width and height calculations of some videos are inaccurate when previewing online videos.
● 4.5.8
  Add:
    Add video stabilization mode to camera configuration.
  Fix:
    Fix video recording with both torch-on and wide cameras.
    Fixed the problem of freezing caused by calculating the frame when previewing network videos.
    Fix the memory leak issue in the ZLEditImageViewController interface.
    After the initial request for album permissions is denied, the permission guidance alert will no longer be displayed.
    Correct eraser misalignment after image cropping.
● 4.5.7
  Add:
    Custom camera supports tap-to-record mode.
    Custom camera supports wide-angle lenses on iOS 13 and above.
    Custom camera allows adding a custom overlay view.
    Video editing controller adds a callback block for canceling edits.
    Added `ZLImagePreviewControllerDelegate` protocol to receive event callbacks in ZLImagePreviewController.
...
```

### Languages
🇨🇳 Chinese, 🇺🇸 English, 🇯🇵 Japanese, 🇫🇷 French, 🇩🇪 German, 🇷🇺 Russian, 🇻🇳 Vietnamese, 🇰🇷 Korean, 🇲🇾 Malay, 🇮🇹 Italian, 🇮🇩 Indonesian, 🇪🇸 Spanish, 🇵🇹 Portuguese, 🇹🇷 Turkish, 🇸🇦 Arabic, 🇳🇱 Dutch.

### Installation
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

```shell
$ carthage update
```

If you get an error like `Building universal frameworks with common architectures is not possible. The device and simulator slices for "ZLPhotoBrowser" both build for: arm64
Rebuild with --use-xcframeworks to create an xcframework bundle instead.` [Click this link](https://github.com/Carthage/Carthage/blob/master/Documentation/Xcode12Workaround.md).

#### Swift Package Manager
1. Select File > Add Packages. Enter https://github.com/longitachi/ZLPhotoBrowser.git in the "Choose Package Repository" dialog.
2. In the next page, specify the version resolving rule as "Up to Next Major" with "4.6.0.1" as its earliest version.
3. After Xcode checking out the source and resolving the version, you can choose the "ZLPhotoBrowser" library and add it to your app target.

### Support
* [**★ Star**](#) this repo.
* Support with <img src="https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/ap.png" width = "100" height = "125" /> or <img src="https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/wp.png" width = "100" height = "125" /> or <img src="https://github.com/longitachi/ImageFolder/blob/master/ZLPhotoBrowser/pp.png" width = "150" height = "125" />

### Demo Effect
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


