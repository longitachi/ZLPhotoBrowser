//
//  ZLFilterTool.m
//  ZLPhotoBrowser
//
//  Created by long on 2018/5/6.
//  Copyright © 2018年 long. All rights reserved.
//

#import "ZLFilterTool.h"

@implementation ZLFilterTool

+ (UIImage *)filterImage:(UIImage *)image filterType:(ZLFilterType)filterType
{
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    id filter;
    
    switch (filterType) {
        case ZLFilterTypeOriginal:
            return image;
        case ZLFilterTypeSepia:
        {
            filter = [[GPUImageSepiaFilter alloc] init];
            break;
        }
        case ZLFilterTypeGrayscale:
        {
            filter = [[GPUImageGrayscaleFilter alloc] init];
            break;
        }
        case ZLFilterTypeBrightness:
        {
            filter = [[GPUImageBrightnessFilter alloc] init];
            ((GPUImageBrightnessFilter *)filter).brightness = 0.1;
            break;
        }
        case ZLFilterTypeSketch:
        {
            filter = [[GPUImageSketchFilter alloc] init];
            break;
        }
        case ZLFilterTypeSmoothToon:
        {
            filter = [[GPUImageSmoothToonFilter alloc] init];
            break;
        }
        case ZLFilterTypeGaussianBlur:
        {
            filter = [[GPUImageGaussianBlurFilter alloc] init];
            ((GPUImageGaussianBlurFilter *)filter).blurRadiusInPixels = 5.0f;
            break;
        }
        case ZLFilterTypeVignette:
        {
            filter = [[GPUImageVignetteFilter alloc] init];
            break;
        }
        case ZLFilterTypeEmboss:
        {
            filter = [[GPUImageEmbossFilter alloc] init];
            ((GPUImageEmbossFilter *)filter).intensity = 1;
            break;
        }
        case ZLFilterTypeGamma:
        {
            filter = [[GPUImageGammaFilter alloc] init];
            ((GPUImageGammaFilter *)filter).gamma = 1.5;
            break;
        }
        case ZLFilterTypeBulgeDistortion:
        {
            filter = [[GPUImageBulgeDistortionFilter alloc] init];
            ((GPUImageBulgeDistortionFilter *)filter).radius = 0.5;
            break;
        }
        case ZLFilterTypeStretchDistortion:
        {
            filter = [[GPUImageStretchDistortionFilter alloc] init];
            break;
        }
        case ZLFilterTypePinchDistortion:
        {
            filter = [[GPUImagePinchDistortionFilter alloc] init];
            break;
        }
        case ZLFilterTypeColorInvert:
        {
            filter = [[GPUImageColorInvertFilter alloc] init];
            break;
        }
        default:
            return image;
    }
    
    [filter useNextFrameForImageCapture];
    [pic addTarget:filter];
    [pic processImage];
    
    return [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
}

@end
