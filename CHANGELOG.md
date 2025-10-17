# Change Log

-----

## [4.7.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.7.3) (2025-10-17)
### Fix:
* Fixed the issue where the eraser position was displayed incorrectly when editing pictures. [#1025](https://github.com/longitachi/ZLPhotoBrowser/issues/1025)

---

## [4.7.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.7.2) (2025-09-29)
### Add:
* Improved video editing experience:
    * Added a shadow area mask for a clearer view of the currently selected video clip.
    * Added a feature to display the duration of the currently selected clip.
* The ZLImagePreviewController interface supports disabling the pull-down return gesture.
* Change the permission of ZLPhotoPreviewSheet to private.

### Fix:
* Fixed a bug where the UI of the thumbnail interface might display an error when the permission is "limited".

---

## [4.7.0 ~ 4.7.0.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.7.0) (2025-07-29)
### Add:
* Support page loading.
* Provide a block that enables external control over whether the camera interface can be accessed.
* Replace some deprecated APIs.
* Support long-press gestures for more data types in ZLImagePreviewController. Support setting cover images for network videos.
* The ZLImagePreviewController interface supports disabling the pull-down return gesture.

---

## [4.6.0 ~ 4.6.0.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.6.0.1) (2025-03-31)
### Add:
* Support SwiftUI.
* Support for locked output orientation in custom camera. [#976](https://github.com/longitachi/ZLPhotoBrowser/pull/976) @tsinis
* Optimize the playback experience of album videos and online videos.
* Add will-capture-block for customizable capture actions. [#988](https://github.com/longitachi/ZLPhotoBrowser/pull/988) @tsinis
* Replace ZLPhotoPreviewSheet with ZLPhotoPicker. The permission of ZLPhotoPreviewSheet will be changed to private later. [#996](https://github.com/longitachi/ZLPhotoBrowser/pull/996)
* Enhance the text sticker feature by adding text outline and shadow effects.

### Fix:
* Fixed the bug that the time of automatically stopping recording is incorrect when clicking to record a video.
* Fix the issue where the width and height calculations of some videos are inaccurate when previewing online videos.

---

## [4.5.8](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.5.8) (2025-02-18)
### Add:
* Add video stabilization support in custom camera. [#959](https://github.com/longitachi/ZLPhotoBrowser/pull/959) @tsinis

### Fix:
* Fix video recording with both torch-on and wide cameras. [#960](https://github.com/longitachi/ZLPhotoBrowser/pull/960) @tsinis
* Fixed the problem of freezing caused by calculating the frame when previewing network videos. [#967](https://github.com/longitachi/ZLPhotoBrowser/issues/967)
* Fix the memory leak issue in the ZLEditImageViewController interface. [#968](https://github.com/longitachi/ZLPhotoBrowser/issues/968)
* After the initial request for album permissions is denied, the permission guidance alert will no longer be displayed. [#969](https://github.com/longitachi/ZLPhotoBrowser/issues/969)
* Correct eraser misalignment after image cropping. [#971](https://github.com/longitachi/ZLPhotoBrowser/pull/971) @vcicis

---

## [4.5.7](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.5.7) (2024-12-02)
### Add:
* Custom camera supports tap-to-record mode. [#944](https://github.com/longitachi/ZLPhotoBrowser/pull/944) @tsinis
* Custom camera supports wide-angle lenses on iOS 13 and above. [#948](https://github.com/longitachi/ZLPhotoBrowser/pull/948) @tsinis
* Custom camera allows adding a custom overlay view. [#951](https://github.com/longitachi/ZLPhotoBrowser/pull/951) @tsinis
* Video editing controller adds a callback block for canceling edits. [#953](https://github.com/longitachi/ZLPhotoBrowser/pull/953) @tsinis
* Added `ZLImagePreviewControllerDelegate` protocol to receive event callbacks in `ZLImagePreviewController`.

---

## [4.5.6](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.5.6) (2024-10-21)
### Add:
* Support iOS18.
* When saving pictures and videos, add error parameters in the callback.
  
---
 
## [4.5.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.5.5) (2024-09-18)
### Add:
* The ZLImagePreviewController interface supports gesture-driven pull-down return animations.
* Update the API for obtaining album permissions.
  
### Fix:
* Fixed the bug that mosaics were not displayed during painting.

---

## [4.5.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.5.4) (2024-07-05)
### Add:
* Support iOS18. [#909](https://github.com/longitachi/ZLPhotoBrowser/pull/909) @patryk-sredzinski
* Enhance the user experience of the image cropping interface and optimize the animation effects.
* Support for setting `VideoMirrored` in the custom camera. [#912](https://github.com/longitachi/ZLPhotoBrowser/issues/912)
  
### Fix:
* Fix the issue where some UI elements are displayed incorrectly on phones without a notch. [#914](https://github.com/longitachi/ZLPhotoBrowser/issues/914)

---

## [4.5.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.5.3) (2024-05-23)
### Add:
* Support customizing the alert for when there is no permission. [#900](https://github.com/longitachi/ZLPhotoBrowser/pull/900) @xiaoyouPrince
* Add configuration option to center tools in tools collection view. [#903](https://github.com/longitachi/ZLPhotoBrowser/pull/903) @patryk-sredzinski

### Fix:
* Fix the bug where the crop ratio view is not hidden when there is only one ratio in the cropping interface.
* Fix a bug that may cause failure when saving images from iCloud to local storage. [#901](https://github.com/longitachi/ZLPhotoBrowser/pull/901) @ilfocus

---

## [4.5.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.5.2) (2024-04-15)
### Fix:
* Fix the bug in the image cropping interface where the image is not displayed correctly when zooming in and the crop ratio is not 0.

---

## [4.5.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.5.1) (2024-03-29)
### Add:
* Add xcprivacy file to the project.

### Fix:
* Fix the bug causing a crash when continuously switching between front and rear cameras. [#894](https://github.com/longitachi/ZLPhotoBrowser/issues/894)
* Fix the bug where the status bar in the album thumbnail interface sometimes does not display.

---

## [4.5.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.5.0) (2024-03-21)
### Add:
* Adapt the text sticker input interface for iPad landscape mode.

### Fix:
* Resolve the issue causing errors during SPM installation. [#892](https://github.com/longitachi/ZLPhotoBrowser/issues/892)
* Fix the bug where cropping square images to circular shape fails. [#893](https://github.com/longitachi/ZLPhotoBrowser/pull/893) @patryk-sredzinski

---

## [4.4.9](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.4.9) (2024-02-02)
### Add:
* Support for setting the initial index of the first image.
* Define the text for the "Done" button on different screens with different keys to facilitate customizing the text.

---
    
## [4.4.8.2 - 4.4.8 Patch](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.4.8.2) (2023-12-05)
### Fix:
* Fix the bug where the camera does not disappear when clicking cancel in the system camera. [#879](https://github.com/longitachi/ZLPhotoBrowser/issues/879)

---

## [4.4.8.1 - 4.4.8 Patch](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.4.8.1) (2023-11-27)

---

## [4.4.8](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.4.8) (2023-11-23)
### Add:
* Adapt to iOS 17, replace `UIGraphicsBeginImageContextWithOptions` with `UIGraphicsImageRenderer`.

### Fix:
* Fix the bug in `ZLImagePreviewController` where videos cannot be played. [#875](https://github.com/longitachi/ZLPhotoBrowser/issues/875)
    
--- 

## [4.4.7](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.4.7) (2023-11-17)
### Add:
* Enhancing the drawing tool with an eraser function.
* Display the total size of selected photos when the full image button is selected.

### Fix:
* Fix a bug where the video's start time is incorrect when cropping the video. [#793](https://github.com/longitachi/ZLPhotoBrowser/issues/793)
    
--- 

## [4.4.6](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.4.6) (2023-10-20)
### Add:
* Supports setting whether the serial number is displayed on the selection button or not.
* Add scroll to bottom button on Gallery picker. [#860](https://github.com/longitachi/ZLPhotoBrowser/pull/860) @patryk-sredzinski
* In the image editor, all operations support undo and redo. [#861](https://github.com/longitachi/ZLPhotoBrowser/pull/860)
* Dutch support added.
* Supports setting the default font for text stickers.
* Optimize the drop-down return effect of the preview interface.
* Optimize screen rotation experience.

### Fix:
* Fix the bug that text stickers are not displayed when typing in Arabic. [ZLImageEditor #48](https://github.com/longitachi/ZLImageEditor/issues/48)
    
--- 

## [4.4.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.4.5) (2023-09-14)
### Add:
* Can set whether maintain shadow background during photo clipping. [#851](https://github.com/longitachi/ZLPhotoBrowser/pull/851)

### Fix:
* When there are too many photos, the album may crash when opened. [#684](https://github.com/longitachi/ZLPhotoBrowser/issues/684)
* Crash on simulator version 14.0.1. [#849](https://github.com/longitachi/ZLPhotoBrowser/pull/849)
* In the image editor where the sticker position was incorrect after the image was rotated.
    
--- 

## [4.4.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.4.4) (2023-08-25)

### Add:
* Support downloading video data from iCloud before selecting a video.
* Makes the drawn curves smoother when editing images.

### Fix:
* Fix a bug that may fail to save videos stored on iCloud.

---

## [4.4.3.2 - 4.4.3 Patch](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.4.3.2) (2023-07-26)

### Fix:
* Disable TextView when user ends editing.

---

## [4.4.3.1 - 4.4.3 Patch](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.4.3.1) (2023-07-26)

### Fix:
* Delete some time-consuming codes to improve the image loading speed of the thumbnail interface.

---

## [4.4.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.4.3) (2023-07-24)

### Add:
* Support to limit the data size of the video.
* Add two blocks, called when asset is selected and deselected.
* Support setting video codec type in custom camera. [#831](https://github.com/longitachi/ZLPhotoBrowser/pull/831)
* Text stickers support display background color.

---
    
## [4.4.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.4.2) (2023-06-08)

### Add:
* Preserve the alpha channel of the edited image. [#818](https://github.com/longitachi/ZLPhotoBrowser/pull/818)

### Fix:
* Fix a crash caused by UI modification in a sub-thread. [#821](https://github.com/longitachi/ZLPhotoBrowser/pull/821)

---

## [4.4.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.4.1) (2023-04-25)

### Add:
* Adapt to RTL.

### Fix:
* Fix the problem that the image editor does not work properly when the scale of the picture is not 1.
* Fixed some UI display issue in the image preview interface. [#812](https://github.com/longitachi/ZLPhotoBrowser/pull/812)

---

    
## [4.4.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.4.0) (2023-03-28)

### Add:
* Limit the maximum number of frames of GIF images to avoid crashes caused by loading too many frames of GIFs, and provide a series of blocks to support custom implementation of GIF image playback.
* Modify the UI effect of text input in the image editor.
* Support set the default camera position.

---
    
## [4.3.9](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.3.9) (2023-02-17)

### Add:
* Support for customizing the item spacing, row spacing, and column count of the thumbnail view controller.
* Moves the camera configuration-related properties from ZLPhotoConfiguration to ZLCameraConfiguration.
* Update the UI style of camera interface.
* Support callback directly after taking picture.
* Increase the maximum zoom ratio of stickers.

---

## [4.3.8](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.3.8) (2022-12-13)

### Add:
* Support direct callback after selecting thumbnail.
* Add horizontal adjust slider.
  
### Fix:
* Fix the bug of wrong size when merging videos. [#788](https://github.com/longitachi/ZLPhotoBrowser/issues/788)
* Hide redo button when filtering or color adjusting.

---

## [4.3.7](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.3.7) (2022-09-28)

### Add:
* Modify the parameter type of `selectImageBlock` and use `ZLResultModel` for callback. Delete `shouldAnialysisAsset` property.
* Photo editor adapts to iPad.
* Arabic supported. @LastSoul
* Support redo in graffiti and mosaic tools.
* Support for modifying the tint color of the image editor icon.

### Fix:
* Fix the bug of getting the wrong version of the video when editing the video.

---

## [4.3.6](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.3.6) (2022-09-06)

### Add:
* Provide a method to save the PHAsset to local.
* Updated the method of parsing GIF.[#752](https://github.com/longitachi/ZLPhotoBrowser/issues/752)

### Fix:
* Fixed crash in pop interactive transition.[#753](https://github.com/longitachi/ZLPhotoBrowser/issues/753)

---

## [4.3.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.3.5) (2022-07-07)

### Add:
* Support custom alert style.
* Improve the experience of image editor.

---

## [4.3.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.3.4) (2022-06-27)

### Fix:
* Fix a bug of the image editor.

---

## [4.3.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.3.3) (2022-06-21)
### Add:
* Adjust loading progress hud style to make it prettier.
* Add wrapper for ZLPhotoBrowser compatible types.
* Support for requesting original images when 'allowSelectOriginal = false'.

---

## [4.3.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.3.2) (2022-05-25)
### Add:
* Add Tolerance in Video Editing.
* Format code style.
  
### Fix:
* Fix some bugs when iOS14 album permissions are limited.

---

## [4.3.1 - 4.3.0 Patch](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.3.1) (2022-04-28)
### Add:
* Remove deprecated properties. 
* Moved some UI related properties to ZLPhotoUIConfiguration.
* Add ZLEnlargeButton class instead of extending UIControl to enlarge button click area.
* Add fade animation when taking photos.

---

## [4.3.0 - Beta](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.3.0) (2022-04-19)
### Add:
* Turkish supported.[#712](https://github.com/longitachi/ZLPhotoBrowser/pull/712)
* Separate UI-related properties such as color, text, font, and image from ZLPhotoConfiguration and put them in ZLPhotoUIConfiguration.
* Change 'ZLPhotoThemeColorDeploy' to 'ZLPhotoColorConfiguration'.
* Add some properties to edit configuration to support Objective-C.
* Add some customize color properties.
* Add long press callback in ZLImagePreviewController.
* Add property to allow user to do something before select photo result callback.

---

## [4.2.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.2.5) (2022-03-21)
### Fix:
* Fix the bug of failing to archive with Xcode 13.3.[#699](https://github.com/longitachi/ZLPhotoBrowser/issues/699)

---

## [4.2.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.2.4) (2022-03-14)
### Fix:
* Fixes the bug when select the original photo in the preview.

---

## [4.2.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.2.3) (2022-03-07)
### Add:
* Done button title color can be defined separately.

---

## [4.2.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.2.2) (2022-01-13)
### Add:
* Support Spanish and Portuguese.[#677](https://github.com/longitachi/ZLPhotoBrowser/pull/677)
  
### Fix:
* Fix the crash when UIAlertController is displayed on iPad.

---

## [4.2.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.2.1) (2021-12-22)
### Add:
* Support adjusting the brightness and contrast and saturation of an image.[#673](https://github.com/longitachi/ZLPhotoBrowser/pull/673)
* Support Indonesian.
* Add ZLEditImageConfiguration class to configuration the image editor.
  
### Fix:
* Crash when calling showPhotoLibrary in UISplitViewController.[#671](https://github.com/longitachi/ZLPhotoBrowser/issues/671)

---

## [4.2.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.2.0) (2021-11-24)
### Add:
* Add chained calls.
* Optmize the custom camera code.
* Add image style of cancel button.
  
### Fix:
* Selected video duplicates after editing mode.[#655](https://github.com/longitachi/ZLPhotoBrowser/issues/655)
* Unable to deselect photos under certain conditions.[#659](https://github.com/longitachi/ZLPhotoBrowser/issues/659)

---

## [4.1.9](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.1.9) (2021-09-27)
### Fix:
* Remove CallKit because it resulted in rejection of app review.[#650](https://github.com/longitachi/ZLPhotoBrowser/issues/650)

---

## [4.1.8](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.1.8) (2021-09-18)
### Add:
* Support crop round image.
* Show an alert to prompt that app cannot access the microphone.[#643](https://github.com/longitachi/ZLPhotoBrowser/issues/643)
* Wrap to display when the text is too long.
* The http header of the network video can be configured.[#642](https://github.com/longitachi/ZLPhotoBrowser/issues/642)
* Improve the judgment logic of Live Photo.[#648](https://github.com/longitachi/ZLPhotoBrowser/issues/648)
* Edit the image directly after taking the photo.

### Fix:
* Camera cannot turning on while calling.[#641](https://github.com/longitachi/ZLPhotoBrowser/issues/641)

---

## [4.1.7](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.1.7) (2021-07-30)
### Add:
* Add a property to control whether to display the selection button animation when selecting.
* Separate the colors shared by album list interface and perview interface.
* Add a cancel block in the camera view controller.
* Support export video.

### Fix:
* Modify some force cast.[#629](https://github.com/longitachi/ZLPhotoBrowser/issues/629)

---

## [4.1.6](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.1.6) (2021-05-26)

### Add:
* Add ZLCameraConfiguration class to deploy camera.
* Call select image block after dismiss.
* Optimizing the method of processing images.

### Fix:
* UI frame is incorrect when preview the long image. [#610](https://github.com/longitachi/ZLPhotoBrowser/issues/610)

---

## [4.1.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.1.5) (2021-04-13)

### Add:
* Provide a method to reset the configuration.
* Cancel the image request when operation is cancelled.

---

## [4.1.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.1.4) (2021-03-09)

### Add:
* In the iOS14 photo limit authority, show WeChat-style “go to setting” tips view.
* Support customize animation duration for select button.

### Fix:
* Sometimes gif is not playing.

---

## [4.1.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.1.3) (2021-02-22)

### Add:
* Add a callback after closing the framework's no authority alert.
* Can control whether to show the status bar when previewing photos.
* Can separately control whether to display the selection button and bottom view in ZLImagePreviewController.[#587](https://github.com/longitachi/ZLPhotoBrowser/issues/587)
  
---

## [4.1.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.1.2) (2020-12-31)

### Add:
* When the slide select is active, it will auto scroll like system library.
* Show edit tag in thumbnail interface.
* Add progress when loading iCloud video.
* Can crop the video directly after select thumbnail in non-mixed selection mode.

### Fix:
* The Image crop interface UI frame is incorrect when enter from landscape.[#558](https://github.com/longitachi/ZLPhotoBrowser/issues/558)
* The navigation view height is incorrect in iOS 10.x.[#561](https://github.com/longitachi/ZLPhotoBrowser/issues/561)
  
---

## [4.1.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.1.1) (2020-11-25)

### Fix
* Fix a crash when using zoom to preview local images and network images.[#556](https://github.com/longitachi/ZLPhotoBrowser/issues/556)

---

## [4.1.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.1.0) (2020-11-21)

### Add
* Image editor add text sticker and image sticker feature.[#552](https://github.com/longitachi/ZLPhotoBrowser/pull/552)
* Customizable order of editing image tools.
* Can set the maximum and minimum number of choices for the video.
* Pinch to adjust zoom factor of the custom camera.
* Long press to save the local image and network image.
* iOS14 limited mode, change the way to select more photos.[#548](https://github.com/longitachi/ZLPhotoBrowser/pull/548)

### Fix
* Fix the bug that will crash when has request failed images.[#549](https://github.com/longitachi/ZLPhotoBrowser/pull/549)

---


## [4.0.9](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.0.9) (2020-10-29)

### Add
* Support languages of more countries (French, German, Russian, Vietnamese, Korean, Malay, Italian).
* Support iOS14 limited authority.
* Provides the ability to preview PHAsset, local images and videos, network images and videos together.
* Optimize some UI effects.
* Support show image crop vc directly.

### Fix
* Fixed the bug that the selected index is displayed in the video cell after recording the video.[#546](https://github.com/longitachi/ZLPhotoBrowser/issues/546)

---


## [4.0.8](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.0.8) (2020-10-10)

### Add
* Add filter to image editor. [#530](https://github.com/longitachi/ZLPhotoBrowser/pull/530)

---


## [4.0.7](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.0.7) (2020-09-28)

### Add
* Image editor support crop ratios. [#524](https://github.com/longitachi/ZLPhotoBrowser/pull/524)
* Custom camera supports switching camera during recording. [#521](https://github.com/longitachi/ZLPhotoBrowser/issues/521)
* Can show border color in selected cell.
* Whether to allow preview of large images.
* Whether to allow preview of selected photos.
* Optimize the front camera to take pictures and video mirror flip issues.

### Fix
* Some toast‘s show condition was wrong.
* Cannot edit when the maximum number of choices is reached. 

---


## [4.0.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.0.5) (2020-09-20)

### Add
* iOS14 limited authority supported. [#517](https://github.com/longitachi/ZLPhotoBrowser/issues/517)
* Optimize picture preview display.

### Fix
* Fix bug of hud. [#518](https://github.com/longitachi/ZLPhotoBrowser/issues/518)

---

## [4.0.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.0.4) (2020-09-13)

### Add
* Record the editing status of the image, and can continue the last editing.
* Add a property to control whether it is allowed to take photos.[#512](https://github.com/longitachi/ZLPhotoBrowser/issues/512)

### Fix
* Optimize the method of fetch photos in descending order. [#145](https://github.com/longitachi/ZLPhotoBrowser/issues/145)
* Compatible `FDFullscreenPopGesture`. [#510](https://github.com/longitachi/ZLPhotoBrowser/issues/510)
* Add `@objc` mark to the call back of custom camera. [#513](https://github.com/longitachi/ZLPhotoBrowser/issues/513)
* Fix in `embedAlbumList` style, albums not reload after take a photo.
* Fix `statusBarStyle` is invalide.
* Fix the mask of can't be selected cells not showing.

---

## [4.0.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.0.2) (2020-09-08)

### Add
* 新增框架样式设置(新增一种仿微信的样式);
* 编辑图片添加马赛克功能;
* 添加下拉返回动画;
* 自定义相机支持最短录制时间设置;
* 优化gif照片的回调，选中的gif照片将直接转换成动图回调出去;

---

## [4.0.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.0.1) (2020-09-02)

### Add
* 优化视频编辑功能;
* 增加自定义列数功能;

### Fix
* 修复单选情况下点击直接进入编辑界面未跳转的bug;
* 修复拖拽选择的bug;
* 修复视频播放完成后未恢复原状的bug;

---

## [4.0.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/4.0.0) (2020-08-31)

### Add
* 升级为纯`Swift`编写框架，支持最低版本由 `iOS8` 升级到了 `iOS10`;
* 添加并增强了一些实用功能（例如图片编辑、预览界面下方小视图显示及拖拽排序等等）;
* 删除一些功能（对SDWebImage的依赖，网络图片及视频的预览，force touch 等等）;

---

## [3.2.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.2.0) (2020-06-05)

### Add
* 添加图片视频选择互斥功能（即只能选择1个视频或最多几张图片）;
* 添加选择量达到最大值时其他cell显示遮罩功能;
* 删除`allowMixSelect`,`maxVideoSelectCountInMix`,`minVideoSelectCountInMix`参数;

---

## [3.1.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.1.4) (2020-04-08)

### Add
* 添加自定义相机分辨率(320*240, 960*540);
* 编辑视频最小允许编辑5s;
* 添加相机是否可用检测;


### Fix
* 修正拍照后图片方向. [#472](https://github.com/longitachi/ZLPhotoBrowser/issues/472);
* 修正部分多语言错误的问题. [#469](https://github.com/longitachi/ZLPhotoBrowser/issues/469);

---

## [3.1.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.1.3) (2020-01-13)

### Add
* 修改曝光模式;
* 拍照界面显示 "轻触拍照，按住摄像" 提示;
* 增加直接调用编辑图片api;

---

## [3.1.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.1.2) (2019-10-24)

### Add
* SDWebImage 不在指定依赖版本号;

---

## [3.1.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.1.1) (2019-10-17)

### Add
* 优化进入相册速度及从相册列表进入选择界面流程;
* 选择相片时候添加progress;

### Fix
* 解决原图显示0B的bug.[#349](https://github.com/longitachi/ZLPhotoBrowser/issues/349)
* 解决视频录制小于0.3s，按照拍照返回没有图片数据的bug.[#386](https://github.com/longitachi/ZLPhotoBrowser/issues/386)

---

## [3.1.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.1.0) (2019-09-26)

### Add
* 初步适配iOS13;
* 修改拍摄视频时1s以下不给保存的时间点为0.3s，即自定义相机拍摄视频时0.3s以下按拍照处理;

---

## [3.0.7](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.0.7) (2019-09-04)

### Add
* 网络视频播放添加进度条;
* SDWebImage依赖升级5.1.0以上版本;

### Fix
* 选中图片index角标bug.[#405](https://github.com/longitachi/ZLPhotoBrowser/issues/405)

---


## [3.0.6](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.0.6) (2019-07-31)

### Add
* 添加选中图片显示index功能;
* 新增(及修改)部分颜色api，方便修改框架内部颜色;
*  修改框架默认风格为微信的风格; 
* 压缩图片资源;

---

## [3.0.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.0.5) (2019-06-27)

### Add
* 预览快速选择界面文字颜色支持自定义; 
* 编辑界面按钮增大;

### Fix
* 解决录制视频超过10s没有声音的bug.[#381](https://github.com/longitachi/ZLPhotoBrowser/issues/381)

---


## [3.0.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.0.4) (2019-05-19)

### Add
* 添加视频选择最大最小个数限制;.

### Fix
* 解决网络gif图片无法播放的bug.[#372](https://github.com/longitachi/ZLPhotoBrowser/pull/372)
* fix已知bug.[#371](https://github.com/longitachi/ZLPhotoBrowser/issues/371)

---


## [3.0.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.0.3) (2019-05-09)

### Add
* 依赖库SDWebImage升级为5.0.2以上; 
* 支持直接调用相机;

### Fix
* 解决图片浏览器关闭时取消所有sd图片请求的bug.[#366](https://github.com/longitachi/ZLPhotoBrowser/issues/366)

---


## [3.0.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.0.1) (2019-04-08)

### Add
* 压缩bundle内图片;
* 支持直接选择iCloud照片，并添加解析图片超时时间属性;

---

## [3.0.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/3.0.0) (2019-02-20)

### Add
* 支持carthage集成;
* 删除滤镜功能;

---

## [2.7.8](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.8) (2019-02-20)

### Add
* 添加iCloud图片加载进度条;
* 支持iCloud视频播放;
* 优化部分体验;

---

## [2.7.6](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.6) (2018-11-29)

### Add
* 预览大图界面支持precent情况下的下拉返回;

---

## [2.7.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.5) (2018-11-07)

### Add
* 编辑图片支持自定义工具类型.

### Fix
* 视频加水印可能报错.[#314](https://github.com/longitachi/ZLPhotoBrowser/issues/314)
* 查看大图界面选择照片后，下拉返回上个界面未刷新选中状态.[#318](https://github.com/longitachi/ZLPhotoBrowser/issues/318)

---

## [2.7.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.4) (2018-08-16)

### Add
* 横滑大图界面添加下拉返回功能.

### Fix
* 不允许录制视频时候，不请求麦克风权限.[#299](https://github.com/longitachi/ZLPhotoBrowser/issues/299)

---

## [2.7.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.3) (2018-07-11)

### Fix
* 解决预览已选择图片多张状态下仍显示编辑按钮，确定按钮已选择个数不正确及crash的bug.[#269](https://github.com/longitachi/ZLPhotoBrowser/issues/269)
* 解决选择视频时仍显示原图按钮的bug.[#274](https://github.com/longitachi/ZLPhotoBrowser/issues/274)

---

## [2.7.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.2) (2018-07-04)

### Fix
* merge request [#276](https://github.com/longitachi/ZLPhotoBrowser/issues/276)

---

## [2.7.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.1) (2018-06-20)

### Add
* 可自定义导航返回按钮图片

### Fix
* 解决录制视频大于最大选择时长时自动选择的bug.[#264](https://github.com/longitachi/ZLPhotoBrowser/issues/264)

---

## [2.7.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.7.0) (2018-06-03)

### Add
* 所有图片资源加上前缀

---

## [2.6.9](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.9) (2018-05-11)

### Add
* 重构图片编辑界面，添加滤镜功能

### Fix
* 解决相册图片列表界面底部工具栏消失的bug.[#238](https://github.com/longitachi/ZLPhotoBrowser/issues/238)
* 解决预览网络视频崩溃的bug. [#240](https://github.com/longitachi/ZLPhotoBrowser/issues/240)

---

## [2.6.7](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.7) (2018-05-03)

### Add
* 优化视频编辑界面，极大减少进入时的等待时间. [#234](https://github.com/longitachi/ZLPhotoBrowser/issues/234)

---

## [2.6.6](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.6) (2018-04-21)

### Add
* 新增隐藏裁剪图片界面比例工具条功能.

### Fix
* 解决iOS11之前预览网络视频crash的bug. [#216](https://github.com/longitachi/ZLPhotoBrowser/issues/216)

---

## [2.6.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.5) (2018-03-31)

### Add
* 新增隐藏"已隐藏"照片及相册的功能.

### Fix
* 优化预览网络图片/视频时根据url后缀判断的类型方式. [#221](https://github.com/longitachi/ZLPhotoBrowser/issues/221)

---

## [2.6.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.4) (2018-01-17)

### Add
* 优化部分代码，提升性能.

### Fix
* 解决无权限视图中右上角返回按钮设置颜色无效的bug.
* 解决放大后继续滑动图片导致缩放比例不正确的bug. [#181](https://github.com/longitachi/ZLPhotoBrowser/issues/181)
* 解决当 ZLPhotoActionSheet 对象为类属性时通过特定操作出现bug及显示的问题. [#184](https://github.com/longitachi/ZLPhotoBrowser/issues/184)
* 解决iOS8系统下，保存编辑视频出错的bug. [#185](https://github.com/longitachi/ZLPhotoBrowser/issues/185)

---

## [2.6.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.3) (2018-01-10)

### Add
* 新增自定义多语言文本功能.
* 新增预览网络视频功能.

### Fix
* 解决最大选择数为1时候，设置是否显示选择按钮无效的问题.
* 解决不允许选择照片，但允许选择及拍摄视频时，相册内部拍照按钮不显示的bug. [#175](https://github.com/longitachi/ZLPhotoBrowser/issues/175)

---

## [2.6.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.2) (2018-01-03)

### Add
* 新增编辑图片后可选是否保存新图片参数.
* 添加取消选择图片回调.

### Fix
* 优化编辑图片时候的旋转操作，避免了快速连续点击时导致图片裁剪区域显示错误的问题.

---

## [2.6.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.1) (2017-12-26)

### Add
* 新增导出视频添加粒子特效功能(如下雪特效).
* 新增编辑图片时旋转图片功能.
* 优化预览界面对宽高比超大的图片的显示.

---

## [2.6.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.6.0) (2017-12-21)

### Add
* 新增调用系统相机录制视频功能.
* 支持导出指定尺寸的视频，支持导出视频添加图片水印.
* 优化部分UI显示.

### Fix
* 解决 `iOS11.2` 版本 原图按钮显示不全的bug. [#164](https://github.com/longitachi/ZLPhotoBrowser/issues/164)
* 导出指定尺寸视频. [#166](https://github.com/longitachi/ZLPhotoBrowser/issues/166)

---

## [2.5.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.5) (2017-12-13)

### Add
* 导出视频支持压缩.
* 优化视频导出格式，删除3gp格式.

---

## [2.5.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.4) (2017-12-05)

### Add
* 新增视频导出方法.
* 新增获取照片及视频路径的方法.

### Fix
* 解决了自定义相机消失后，其他软件音乐不恢复播放的问题. [#152](https://github.com/longitachi/ZLPhotoBrowser/issues/152)

---

## [2.5.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.3) (2017-11-27)

### Add
* 拍摄视频及编辑视频支持多种格式(mov, mp4, 3gp).
* 新增相册名字等多语言，以完善手动设置语言时相册名字跟随系统的问题.
* 简化相册调用，configuration 由必传参数修改为非必传参数.

---

## [2.5.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.2) (2017-11-20)

### Add
* 抽取相册属性独立为 `ZLPhotoConfiguration` 对象.
* 新增设置状态栏样式api.

### Fix
* 解决预览已选择图片和网络图片时候内存泄漏的问题.

---

## [2.5.1.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.1.1) (2017-11-15)

### Fix
* 解决创建相册时候获取app名字为null的bug. [#141](https://github.com/longitachi/ZLPhotoBrowser/issues/152)

---

## [2.5.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.1) (2017-11-11)

### Add
* 新增自定义相机(仿微信)，开发者可选使用自定义相机或系统相机.
* 支持录制视频，可设置最大录制时长及清晰度.

### Fix
* 解决裁剪比例只有一个且为1:1时候，下方比例工具条不隐藏的bug.

---

## [2.5.0.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.0.2) (2017-11-04)

### Add
* 新增自行切换框架语言api.
* 当编辑比例只有一个且为custom或1:1时候，隐藏裁剪比例工具条.

### Fix
* 无相册访问权限时候，跳往无权限视图方法走两次. [#132](https://github.com/longitachi/ZLPhotoBrowser/issues/132)
* 使用系统tabbar时，预览视图位置偏上. [#124](https://github.com/longitachi/ZLPhotoBrowser/issues/124)

---

## [2.5.0.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.0.1) (2017-10-26)

### Add
* 提供逐个解析图片api方法，方便 `shouldAnialysisAsset` 为 `NO` 时的使用.
* 提供控制是否可以选择原图参数.

---

## [2.5.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.5.0) (2017-10-23)

###
* 新增选择后是否自动解析图片参数 shouldAnialysisAsset (针对需要选择大量图片的功能，框架一次解析大量图片时，会导致内存瞬间大幅增高，建议此时置该参数为NO，然后拿到asset后自行逐个解析).
* 修改图片压缩方式，确保原图尺寸不变.

### Fix
* 解决部分关于UI的代码在子线程执行的问题. [#113](https://github.com/longitachi/ZLPhotoBrowser/issues/113)
* 优化 `iOS11` 中如果设置 `[[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];` 导致内部控件上移64像素的问题. [#114](https://github.com/longitachi/ZLPhotoBrowser/issues/114)
* 优化一次选择多张照片，同时解析导致内存暴涨并crash的bug. [#118](https://github.com/longitachi/ZLPhotoBrowser/issues/118)

---

## [2.4.8~2.4.9](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.9) (2017-10-17)

### Add
* 新增预览界面拖拽选择功能.
* 支持开发者使用自定义图片资源.
* 开放导航标题颜色、底部工具栏背景色、底部按钮可交互与不可交互标题颜色的设置api.

### Fix
* 解决weakify(var)，strongify(var)与其他类库发生宏定义冲突的问题.
* 解决项目为状态栏隐藏，调用框架后状态栏显示的问题.

---

## [2.4.7](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.7) (2017-10-13)

### Fix
* 解决多次进入相册可能导致crash的bug. [#108](https://github.com/longitachi/ZLPhotoBrowser/issues/108)

---

## [2.4.6](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.6) (2017-10-09)

### Add
* 新增预览网络图片长按保存至相册功能.

### Fix
* 解决相册查看大图界面单机会回到第一张的bug. [#103](https://github.com/longitachi/ZLPhotoBrowser/issues/103)

---

## [2.4.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.5) (2017-09-29)

### Add
* 预览已选择图片时候增加是否为原图参数. [#101](https://github.com/longitachi/ZLPhotoBrowser/issues/101)

### Fix
* 解决设置相册内部隐藏拍照按钮无效的bug. [#102](https://github.com/longitachi/ZLPhotoBrowser/issues/101)

---

## [2.4.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.4) (2017-09-27)

### Fix
* 解决相册内部拍照按钮不显示的bug. [#100](https://github.com/longitachi/ZLPhotoBrowser/issues/100)

---

## [2.4.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.3) (2017-09-22)

### Add
* 适配 iPhone X.
* 优化启动进入相册速度.
* 预览网络图片可设置是否显示底部工具条及导航右侧按钮.

---

## [2.4.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.2) (2017-09-18)

### Add
* 新增视频编辑功能(仿微信).
* 优化代码，提升滑动性能及流畅度.

---

## [2.4.1](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.1) (2017-09-14)

### Add
* 新增仿iPhone相册滑动多选功能.

---

## [2.4.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.4.0) (2017-09-07)

### Add
* 新增预览网络图片及本地图片功能.

---

## [2.3.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.3.3) (2017-09-01)

### Add
* 删除废弃文件，新增已选择图片遮罩层标记功能.

---

## [2.3.1~2.3.2](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.3.2) (2017-08-31)

### Add
* 新增设置导航条颜色api.
* 适配横屏.
* 适配iPad，优化iPad下显示.

### Fix
* 解决 `iOS9` 以下系统判断 `ForceTouch` 可用性崩溃的bug.

---

## [2.2.9~2.3.0](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.3.0) (2017-08-18)

### Add
* 新增单选模式下选择图片后直接进入编辑界面功能.
* 开放设置图片裁剪比例api.

---

## [2.2.8](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.2.8) (2017-08-16)

### Add
* 优化部分显示问题.
* 扩展图片编辑功能，增加裁剪比例选项.

---

## [2.2.7](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.2.7) (2017-08-03)

### Add
* 扩大选择按钮点击区域.
* 删除多余图片及xib文件.
* 优化性能.

---

## [2.2.6](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.2.6) (2017-07-26)

### Add
* 新增混合选择image、gif、livephoto、video类型.
* 支持video、gif、livephoto类型的多选.
* 支持控制video最大选择时长.
* 废弃部分api，考虑不给使用者由于更新带来的错误，暂未删除废弃文件及api，后续更新版本会删除.

---

## [2.2.5](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.2.5) (2017-07-03)

### Fix
* 修复 `ForceTouch` 点击内部拍照按钮时闪退的bug.

---

## [2.2.4](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.2.4) (2017-06-28)

### Add
* 去除原图时视频字节显示.
* 优化图片加载显示方式.

### Fix
* 优化 `ForceTouch` 造成的内存泄漏的问题.

---

## [2.2.3](https://github.com/longitachi/ZLPhotoBrowser/releases/tag/2.2.3) (2017-06-23)

### Add
* 增加图片编辑裁剪功能.

---

## 2.2.2 (2017-06-20)

### Add
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

