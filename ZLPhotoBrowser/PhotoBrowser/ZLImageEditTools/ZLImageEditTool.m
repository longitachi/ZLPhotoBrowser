//
//  ZLImageEditTool.m
//  ZLPhotoBrowser
//
//  Created by long on 2018/5/5.
//  Copyright © 2018年 long. All rights reserved.
//

#import "ZLImageEditTool.h"
#import "ZLPhotoConfiguration.h"
#import "ZLClipItem.h"
#import "UIImage+ZLPhotoBrowser.h"
#import "UIButton+EnlargeTouchArea.h"
#import "ZLBrushBoardImageView.h"
#import "ZLDrawItem.h"

@interface ZLImageEditTool ()
{
    NSInteger _layoutCount;
    BOOL _isFirst;
    
    ZLImageEditType _type;
    ZLPhotoConfiguration *_configuration;
    ZLImageEditType _selectToolType;
    
    //计算imageView尺寸时是否交换宽高（旋转图片90°及270°时候值为YES）
    BOOL _exchangeImageWH;
    //是否正在旋转图片
    BOOL _isRotatingImage;
    
    ZLClippingCircle *_ltView;
    ZLClippingCircle *_lbView;
    ZLClippingCircle *_rtView;
    ZLClippingCircle *_rbView;
    
    CGSize _originSize;
}

@property (nonatomic, strong) ZLBrushBoardImageView *imageView;

@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *drawBtn;
@property (nonatomic, strong) UIButton *revokeBtn;

@property (nonatomic, strong) UIButton *rotateBtn;

@property (nonatomic, strong) UIButton *clipBtn;
@property (nonatomic, strong) UIButton *rotateRatioBtn;

@property (nonatomic, strong) UIScrollView *clipMenu;
@property (nonatomic, strong) UIScrollView *drawMenu;

@property (nonatomic, strong) ZLGridLayar *gridLayer;

@property (nonatomic, strong) ZLClipItem *selectClipItem;
@property (nonatomic, strong) ZLClipRatio *selectClipRatio;
@property (nonatomic, assign) CGRect clippingRect;

@property (nonatomic, strong) ZLDrawItem *selectDrawItem;

@end

@implementation ZLImageEditTool

- (void)dealloc
{
//    NSLog(@"---- %s", __FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithEditType:ZLImageEditTypeDraw |
                                  ZLImageEditTypeMosaic |
                                  ZLImageEditTypeClip |
                                  ZLImageEditTypeRotate
                            image:nil
                    configuration:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithEditType:ZLImageEditTypeDraw |
                                  ZLImageEditTypeMosaic |
                                  ZLImageEditTypeClip |
                                  ZLImageEditTypeRotate
                            image:nil
                    configuration:nil];
}

- (instancetype)initWithEditType:(ZLImageEditType)type image:(UIImage *)image configuration:(ZLPhotoConfiguration *)configuration
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        _type = type;
        _configuration = configuration;
        self.editImage = image;
        [self setupUI];
    }
    return self;
}

- (void)setEditImage:(UIImage *)editImage
{
    _editImage = editImage;
    _originSize = editImage.size;
    _imageView.image = editImage;
    _layoutCount = 0;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _layoutCount++;
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (@available(iOS 11, *)) {
        inset = self.superview.safeAreaInsets;
    }
    
    self.cancelBtn.frame = CGRectMake(15+inset.left, inset.top+5, GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserCancelText), 15, YES, 30), 30);
    CGFloat doneBtnW = GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserDoneText), 15, YES, 30);
    self.doneBtn.frame = CGRectMake(kViewWidth-doneBtnW-inset.right-15, inset.top+5, doneBtnW, 30);
    
    [self setImageViewFrame:_layoutCount != 1];
    if (_selectToolType & ZLImageEditTypeClip) {
        self.gridLayer.frame = self.imageView.bounds;
        [self clippingRatioDidChange];
    }
    
    self.bottomView.frame = CGRectMake(0, kViewHeight-44-inset.bottom, kViewWidth, 44);
    NSInteger toolCount = [self toolCount];
    CGFloat disW = kViewWidth/(toolCount+1);
    
    CGFloat bx = disW;
    CGFloat bottomBtnW = 40;
    
    if (_type & ZLImageEditTypeDraw) {
        self.drawBtn.frame = CGRectMake(bx-bottomBtnW/2, 2, bottomBtnW, bottomBtnW);
        bx += disW;
    }
    if (_type & ZLImageEditTypeRotate) {
        self.rotateBtn.frame = CGRectMake(bx-bottomBtnW/2, 2, bottomBtnW, bottomBtnW);
        bx += disW;
    }
    if (_type & ZLImageEditTypeClip) {
        self.clipBtn.frame = CGRectMake(bx-bottomBtnW/2, 2, bottomBtnW, bottomBtnW);
        bx += disW;
    }
    
    CGFloat menuMaxY = CGRectGetMinY(self.bottomView.frame);
    
    _drawMenu.frame = CGRectMake(inset.left+30, menuMaxY-40, kViewWidth-inset.left-inset.right-30-60, 40);
    _revokeBtn.frame = CGRectMake(kViewWidth-60-inset.right, menuMaxY-40, 40, 40);
    
    BOOL hideClipRatioView = _configuration.hideClipRatiosToolBar ?: [self shouldHideClipRatioView];
    
    if (hideClipRatioView) {
        _rotateRatioBtn.hidden = YES;
        _clipMenu.hidden = YES;
    } else {
        _rotateRatioBtn.superview.frame = CGRectMake(kViewWidth-70-inset.right, menuMaxY-80, 70, 80);
        _clipMenu.frame = CGRectMake(inset.left, menuMaxY-80, kViewWidth-70-inset.left-inset.right, 80);
    }
    
    // 暂时只留下裁剪功能
    if (_layoutCount == 1 && _selectToolType != ZLImageEditTypeClip) {
        [self clipBtn_click];
        self.clipBtn.userInteractionEnabled = NO;
    }
}

- (void)setImageViewFrame:(BOOL)animate
{
    if (!_editImage) return;
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (@available(iOS 11, *)) {
        inset = self.superview.safeAreaInsets;
    }
    
    BOOL showMenu = NO;
    if (_selectToolType & ZLImageEditTypeClip) {
        showMenu = ![self shouldHideClipRatioView];
    }
    
    //隐藏时 底部工具条高44，间距设置4即可，不隐藏时，比例view高度80，则为128
    CGFloat flag = showMenu ? 128 : 48;
    
    CGFloat diffXMarigin = showMenu ? 40 : 20;
    CGFloat w = kViewWidth-diffXMarigin-inset.left-inset.right;
    CGFloat maxH = kViewHeight-flag-inset.bottom-inset.top-80;
    
    CGFloat imgW = _exchangeImageWH ? _originSize.height : _originSize.width;
    CGFloat imgH = _exchangeImageWH ? _originSize.width : _originSize.height;
    
    CGFloat h = w * imgH / imgW;
    if (h > maxH) {
        h = maxH;
        w = h * imgW / imgH;
    }
    CGRect frame = CGRectMake((kViewWidth-w)/2, (kViewHeight-h-flag+40)/2, w, h);
    
    if (animate && !_isRotatingImage) {
        [UIView animateWithDuration:0.2 animations:^{
            self->_imageView.frame = frame;
        }];
    } else {
        _imageView.frame = frame;
    }
}

//当裁剪比例只有 custom 或者 1:1 的时候隐藏比例视图
- (BOOL)shouldHideClipRatioView
{
    if (_configuration.clipRatios.count <= 1) {
        NSInteger value1 = [_configuration.clipRatios.firstObject[ClippingRatioValue1] integerValue];
        NSInteger value2 = [_configuration.clipRatios.firstObject[ClippingRatioValue2] integerValue];
        if ((value1==0 && value2==0) || (value1==1 && value2==1)) {
            return YES;
        }
    }
    return NO;
}

- (void)setupUI
{
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelBtn setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCancelText) forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(cancelBtn_click) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn setEnlargeEdgeWithTop:0 right:10 bottom:10 left:0];
    [self addSubview:self.cancelBtn];
    
    self.doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneBtn setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateNormal];
    [self.doneBtn setTitleColor:_configuration.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
    self.doneBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.doneBtn.layer.masksToBounds = YES;
    self.doneBtn.layer.cornerRadius = 3.0f;
    [self.doneBtn addTarget:self action:@selector(btnDone_click) forControlEvents:UIControlEventTouchUpInside];
    [self.doneBtn setEnlargeEdgeWithTop:0 right:0 bottom:10 left:10];
    [self addSubview:_doneBtn];
    
    //imageView
    self.imageView = [[ZLBrushBoardImageView alloc] init];
    self.imageView.image = _editImage;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];
    
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGridView:)];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:panGesture];
    
    //下方视图
    self.bottomView = [[UIView alloc] init];
    [self addSubview:self.bottomView];
    
    {
        if (_type & ZLImageEditTypeClip) {
            self.clipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.clipBtn setImage:GetImageWithName(@"zl_clip") forState:UIControlStateNormal];
            [self.clipBtn addTarget:self action:@selector(clipBtn_click) forControlEvents:UIControlEventTouchUpInside];
            [self.bottomView addSubview:self.clipBtn];
        }
        
        if (_type & ZLImageEditTypeRotate) {
            self.rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.rotateBtn setImage:GetImageWithName(@"zl_rotateimage") forState:UIControlStateNormal];
            [self.rotateBtn addTarget:self action:@selector(rotateImageBtn_click) forControlEvents:UIControlEventTouchUpInside];
            [self.bottomView addSubview:self.rotateBtn];
        }
        
        if (_type & ZLImageEditTypeDraw) {
            self.drawBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.drawBtn setImage:GetImageWithName(@"zl_draw") forState:UIControlStateNormal];
            [self.drawBtn addTarget:self action:@selector(drawBtn_click) forControlEvents:UIControlEventTouchUpInside];
            [self.bottomView addSubview:self.drawBtn];
        }
    }
    
    [self sendSubviewToBack:self.imageView];
}

- (ZLClippingCircle*)clippingCircleWithTag:(NSInteger)tag
{
    ZLClippingCircle *view = [[ZLClippingCircle alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    view.backgroundColor = [UIColor clearColor];
    view.bgColor = [UIColor whiteColor];
    view.tag = tag;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCircleView:)];
    [view addGestureRecognizer:panGesture];
    
    [self addSubview:view];
    
    return view;
}

- (NSInteger)toolCount
{
    NSArray *arr = @[@(ZLImageEditTypeClip), @(ZLImageEditTypeRotate), @(ZLImageEditTypeDraw), @(ZLImageEditTypeMosaic)];
    NSInteger count = 0;
    for (NSNumber *num in arr) {
        if (_type & num.integerValue) {
            count++;
        }
    }
    return count;
}

#pragma mark - menu

- (void)setupDrawMenu
{
    if (_drawMenu) return;
    
    //这只是初始坐标，实际坐标在viewdidlayoutsubviews里面布局
    _drawMenu = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _drawMenu.backgroundColor = [UIColor clearColor];
    _drawMenu.showsHorizontalScrollIndicator = NO;
    _drawMenu.clipsToBounds = NO;
    [self addSubview:_drawMenu];
    
    self.revokeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.revokeBtn setImage:GetImageWithName(@"zl_revoke") forState:UIControlStateNormal];
    [self.revokeBtn addTarget:self action:@selector(revokeBtn_click) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.revokeBtn];
    
    CGFloat W = 40;
    CGFloat H = 40;
    CGFloat x = 0;
    
    for (int i = ZLDrawItemColorTypeWhite; i <= ZLDrawItemColorTypePurple; i++) {
        ZLDrawItem *item = [[ZLDrawItem alloc] initWithFrame:CGRectMake(x, 0, W, H) colorType:i target:self action:@selector(tapDrawColor:)];
        [_drawMenu addSubview:item];
        
        if (!self.selectDrawItem) {
            self.selectDrawItem = item;
        }
        x += W;
    }
    _drawMenu.contentSize = CGSizeMake(MAX(x, _drawMenu.frame.size.width+1), 0);
}

- (void)setupClipMenu
{
    if (_clipMenu) return;
    
    self.gridLayer = [[ZLGridLayar alloc] init];
    self.gridLayer.bgColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    self.gridLayer.gridColor = [UIColor whiteColor];
    [self.imageView.layer addSublayer:self.gridLayer];
    
    _ltView = [self clippingCircleWithTag:0];
    _lbView = [self clippingCircleWithTag:1];
    _rtView = [self clippingCircleWithTag:2];
    _rbView = [self clippingCircleWithTag:3];
    
    //这只是初始坐标，实际坐标在viewdidlayoutsubviews里面布局
    _clipMenu = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _clipMenu.backgroundColor = [UIColor clearColor];
    _clipMenu.showsHorizontalScrollIndicator = NO;
    _clipMenu.clipsToBounds = NO;
    [self addSubview:_clipMenu];
    
    //旋转按钮
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
    view.hidden = YES;
    [self addSubview:view];
    _rotateRatioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rotateRatioBtn.frame = CGRectMake(15, 20, 40, 40);
    _rotateRatioBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_rotateRatioBtn setBackgroundImage:GetImageWithName(@"zl_btn_rotate") forState:UIControlStateNormal];
    [_rotateRatioBtn addTarget:self action:@selector(rotateRadioBtn_click) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_rotateRatioBtn];
    
    CGFloat W = 70;
    CGFloat H = 80;
    CGFloat x = 0;
    
    CGSize  imgSize = self.editImage.size;
    CGFloat maxW = MIN(imgSize.width, imgSize.height);
    UIImage *iconImage = [self scaleImage:self.editImage toSize:CGSizeMake(W * imgSize.width/maxW, W * imgSize.height/maxW)];
    
    //如需要其他比例，请按照格式自行设置
    for(NSDictionary *info in _configuration.clipRatios){
        CGFloat val1 = [info[@"value1"] floatValue];
        CGFloat val2 = [info[@"value2"] floatValue];
        
        ZLClipRatio *ratio = [[ZLClipRatio alloc] initWithValue1:val1 value2:val2];
        ratio.titleFormat = info[@"titleFormat"];
        
        ratio.isLandscape = val1 > val2;
        
        ZLClipItem *item = [[ZLClipItem alloc] initWithFrame:CGRectMake(x, 0, W, H) image:iconImage target:self action:@selector(tapRadio:)];
        item.ratio = ratio;
        [item refreshViews];
        
        [_clipMenu addSubview:item];
        x += W;
        
        if (!self.selectClipItem){
            self.selectClipItem = item;
        }
    }
    
    _clipMenu.contentSize = CGSizeMake(MAX(x, _clipMenu.frame.size.width+1), 0);
}

#pragma mark - btn action
- (void)cancelBtn_click
{
    if (self.cancelEditBlock) {
        self.cancelEditBlock();
    }
}

- (void)btnDone_click
{
    UIImage *image = [self clipImage];
    
    if (self.doneEditBlock) {
        self.doneEditBlock(image);
    }
}

- (void)clipBtn_click
{
    [self switchTool:ZLImageEditTypeClip];
}

- (void)rotateImageBtn_click
{
    if (_isRotatingImage) {
        //旋转过程中不接受再次旋转
        return;
    }
    _isRotatingImage = YES;
    
    _editImage = [_editImage rotate:UIImageOrientationLeft];
    UIImage *newImage = [_imageView.image rotate:UIImageOrientationLeft];
    
    _exchangeImageWH = !_exchangeImageWH;
    
    [self switchCircleAndGridLayerShowStatus:NO];
    
    [UIView animateWithDuration:0.25 animations:^{
        self->_imageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    } completion:^(BOOL finished) {
        self->_imageView.image = newImage;
        [self setImageViewFrame:NO];
        self->_imageView.transform = CGAffineTransformIdentity;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self->_isRotatingImage = NO;
        });
    }];
    
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCircleAndGrid) object:nil];
    if (_selectToolType & ZLImageEditTypeClip) {
        [self performSelector:@selector(showCircleAndGrid) withObject:nil afterDelay:0.5];
    }
}

- (void)showCircleAndGrid
{
    [self switchCircleAndGridLayerShowStatus:YES];
}

- (void)rotateRadioBtn_click
{
    for (ZLClipItem *item in _clipMenu.subviews){
        if([item isKindOfClass:[ZLClipItem class]]){
            [item changeOrientation];
        }
    }
    
    if (self.selectClipRatio.ratio != 0 &&
        self.selectClipRatio.ratio != 1){
        [self clippingRatioDidChange];
    }
}

- (void)drawBtn_click
{
    [self switchTool:ZLImageEditTypeDraw];
}

- (void)switchTool:(ZLImageEditType)type
{
    if (!self.editImage) return;
    
    if (_selectToolType & type) {
        _selectToolType = 0;
    } else {
        _selectToolType = type;
    }
    
    switch (_selectToolType) {
        case ZLImageEditTypeClip:
            [self setupClipMenu];
            break;
        case ZLImageEditTypeDraw:
            [self setupDrawMenu];
            break;
        default:
            break;
    }
    
    [self setNeedsLayout];
    
    if (_selectToolType == 0) {
        _clipMenu.hidden = YES;
        _rotateRatioBtn.superview.hidden = YES;
        [self switchBtnStatus:nil];
        [self switchCircleAndGridLayerShowStatus:NO];
        return;
    }
    if (_selectToolType & ZLImageEditTypeDraw) {
        _drawMenu.hidden = NO;
        _clipMenu.hidden = YES;
        _rotateRatioBtn.superview.hidden = YES;
        self.imageView.drawEnable = YES;
        [self switchCircleAndGridLayerShowStatus:NO];
        [self switchBtnStatus:self.drawBtn];
    } else if (_selectToolType & ZLImageEditTypeClip) {
        _drawMenu.hidden = YES;
        _clipMenu.hidden = NO;
        _rotateRatioBtn.superview.hidden = NO;
        self.imageView.drawEnable = NO;
        [self switchCircleAndGridLayerShowStatus:YES];
        [self switchBtnStatus:self.clipBtn];
    }
}

- (void)switchBtnStatus:(UIButton *)btn
{
    UIButton *b = [UIButton new];
    NSArray *arr = @[self.drawBtn?: b, self.rotateBtn?: b, self.clipBtn?: b];
    for (UIButton *b in arr) {
        if (b == btn) {
            [b setBackgroundColor:[UIColor colorWithWhite:1 alpha:.15]];
        } else {
            [b setBackgroundColor:[UIColor clearColor]];
        }
    }
}

- (void)switchCircleAndGridLayerShowStatus:(BOOL)show
{
    if (!show) {
        self.clippingRect = CGRectZero;
    }
    
    _gridLayer.hidden = !show;
    _ltView.hidden = !show;
    _lbView.hidden = !show;
    _rtView.hidden = !show;
    _rbView.hidden = !show;
}

#pragma mark - draw
- (void)tapDrawColor:(UITapGestureRecognizer *)sender
{
    ZLDrawItem *item = (ZLDrawItem *)sender.view;
    if (self.selectDrawItem == item) return;
    
    self.selectDrawItem = item;
}

- (void)setSelectDrawItem:(ZLDrawItem *)selectDrawItem
{
    if (selectDrawItem != _selectDrawItem) {
        _selectDrawItem.selected = NO;
        _selectDrawItem = selectDrawItem;
        _selectDrawItem.selected = YES;
        self.imageView.drawColor = _selectDrawItem.color;
    }
}

- (void)revokeBtn_click
{
    [self.imageView revoke];
}

#pragma mark - 裁剪
- (void)tapRadio:(UITapGestureRecognizer *)sender
{
    ZLClipItem *item = (ZLClipItem *)sender.view;
    
    self.selectClipItem = item;
}

- (void)setSelectClipItem:(ZLClipItem *)selectClipItem
{
    if (selectClipItem != _selectClipItem){
        _selectClipItem.backgroundColor = [UIColor clearColor];
        _selectClipItem = selectClipItem;
        _selectClipItem.backgroundColor = [UIColor colorWithWhite:1 alpha:.15];
        
        if(selectClipItem.ratio.ratio==0){
            self.selectClipRatio = nil;
        } else {
            self.selectClipRatio = selectClipItem.ratio;
        }
    }
}

- (void)setSelectClipRatio:(ZLClipRatio *)selectClipRatio
{
    if(selectClipRatio != _selectClipRatio){
        _selectClipRatio = selectClipRatio;
        [self clippingRatioDidChange];
    }
}

- (void)clippingRatioDidChange
{
    CGRect rect = _imageView.bounds;
    if (self.selectClipRatio) {
        CGFloat H = rect.size.width * self.selectClipRatio.ratio;
        if (H <= rect.size.height) {
            rect.size.height = H;
        } else {
            rect.size.width *= rect.size.height / H;
        }

        rect.origin.x = (_imageView.bounds.size.width - rect.size.width) / 2;
        rect.origin.y = (_imageView.bounds.size.height - rect.size.height) / 2;
    }
    [self setClippingRect:rect animated:YES];
}

- (void)setClippingRect:(CGRect)clippingRect animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self->_ltView.center = [self convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y) fromView:self->_imageView];
            self->_lbView.center = [self convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y+clippingRect.size.height) fromView:self->_imageView];
            self->_rtView.center = [self convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y) fromView:self->_imageView];
            self->_rbView.center = [self convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y+clippingRect.size.height) fromView:self->_imageView];
        }
         ];

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"clippingRect"];
        animation.duration = 0.2;
        animation.fromValue = [NSValue valueWithCGRect:_clippingRect];
        animation.toValue = [NSValue valueWithCGRect:clippingRect];
        [_gridLayer addAnimation:animation forKey:nil];

        _gridLayer.clippingRect = clippingRect;
        _clippingRect = clippingRect;
        [_gridLayer setNeedsDisplay];
    } else {
        self.clippingRect = clippingRect;
    }
}

- (void)setClippingRect:(CGRect)clippingRect
{
    _clippingRect = clippingRect;
    
    _ltView.center = [self convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y) fromView:_imageView];
    _lbView.center = [self convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y+_clippingRect.size.height) fromView:_imageView];
    _rtView.center = [self convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y) fromView:_imageView];
    _rbView.center = [self convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y+_clippingRect.size.height) fromView:_imageView];
    
    _gridLayer.clippingRect = clippingRect;
    [_gridLayer setNeedsDisplay];
}

#pragma mark - 拖动
- (void)panCircleView:(UIPanGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:_imageView];
    CGPoint dp = [sender translationInView:_imageView];
    
    CGRect rct = self.clippingRect;
    
    const CGFloat W = _imageView.frame.size.width;
    const CGFloat H = _imageView.frame.size.height;
    CGFloat minX = 0;
    CGFloat minY = 0;
    CGFloat maxX = W;
    CGFloat maxY = H;
    
    CGFloat ratio = (sender.view.tag == 1 || sender.view.tag==2) ? -self.selectClipRatio.ratio : self.selectClipRatio.ratio;
    
    switch (sender.view.tag) {
        case 0: // upper left
        {
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if (ratio!=0) {
                CGFloat y0 = rct.origin.y - ratio * rct.origin.x;
                CGFloat x0 = -y0 / ratio;
                minX = MAX(x0, 0);
                minY = MAX(y0, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            } else {
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.x = point.x;
            rct.origin.y = point.y;
            break;
        }
        case 1: // lower left
        {
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if (ratio!=0) {
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio* rct.origin.x ;
                CGFloat xh = (H - y0) / ratio;
                minX = MAX(xh, 0);
                maxY = MIN(y0, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            } else {
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = point.y - rct.origin.y;
            rct.origin.x = point.x;
            break;
        }
        case 2: // upper right
        {
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if (ratio!=0) {
                CGFloat y0 = rct.origin.y - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat x0 = -y0 / ratio;
                maxX = MIN(x0, W);
                minY = MAX(yw, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            } else {
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.y = point.y;
            break;
        }
        case 3: // lower right
        {
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if (ratio!=0) {
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat xh = (H - y0) / ratio;
                maxX = MIN(xh, W);
                maxY = MIN(yw, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            } else {
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = point.y - rct.origin.y;
            break;
        }
        default:
            break;
    }
    self.clippingRect = rct;
}

- (void)panGridView:(UIPanGestureRecognizer*)sender
{
    if (_selectToolType != ZLImageEditTypeClip) {
        return;
    }
    
    static BOOL dragging = NO;
    static CGRect initialRect;
    
    if (sender.state==UIGestureRecognizerStateBegan) {
        CGPoint point = [sender locationInView:_imageView];
        dragging = CGRectContainsPoint(_clippingRect, point);
        initialRect = self.clippingRect;
    } else if(dragging) {
        CGPoint point = [sender translationInView:_imageView];
        CGFloat left  = MIN(MAX(initialRect.origin.x + point.x, 0), _imageView.frame.size.width-initialRect.size.width);
        CGFloat top   = MIN(MAX(initialRect.origin.y + point.y, 0), _imageView.frame.size.height-initialRect.size.height);
        
        CGRect rct = self.clippingRect;
        rct.origin.x = left;
        rct.origin.y = top;
        self.clippingRect = rct;
    }
}

#pragma mark - 裁剪
- (UIImage *)clipImage
{
    CGFloat zoomScale = _imageView.bounds.size.width / _imageView.image.size.width;
    CGRect rct = CGRectEqualToRect(self.clippingRect, CGRectZero) ? _imageView.bounds : self.clippingRect;
    rct.size.width  /= zoomScale;
    rct.size.height /= zoomScale;
    rct.origin.x    /= zoomScale;
    rct.origin.y    /= zoomScale;
    
    CGPoint origin = CGPointMake(-rct.origin.x, -rct.origin.y);
    UIImage *img = nil;
    
    UIGraphicsBeginImageContextWithOptions(rct.size, NO, _imageView.image.scale);
    [_imageView.image drawAtPoint:origin];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    return [self scaledlmageWithData:data withSize:size scale:1.0 orientation:image.imageOrientation];
}

- (UIImage *)scaledlmageWithData:(NSData *)data withSize:(CGSize)size scale:(CGFloat)scale orientation:(UIImageOrientation)orientation {
    CGFloat maxPixelSize = MAX(size.width, size.height);
    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
    NSDictionary *options = @{(__bridge id)kCGImageSourceCreateThumbnailFromImageAlways:(__bridge id)kCFBooleanTrue,
                              (__bridge id)kCGImageSourceThumbnailMaxPixelSize:[NSNumber numberWithFloat:maxPixelSize]};
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)options);
    UIImage *resultlmage = [UIImage imageWithCGImage:imageRef scale:scale orientation:orientation];
    CGImageRelease(imageRef);
    CFRelease(sourceRef);
    return resultlmage;
}

@end
