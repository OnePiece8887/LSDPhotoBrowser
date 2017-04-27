//
//  LSDPhotoBrowser.m
//  LSDPhotoBrowser
//
//  Created by 神州锐达 on 2017/4/25.
//  Copyright © 2017年 OnePiece. All rights reserved.
//

#import "LSDPhotoBrowser.h"
#import "LSDPhotoBrowserView.h"
#import "LSDPhotoCollectionView.h"
@interface LSDPhotoBrowser ()


@end

@implementation LSDPhotoBrowser
{
    
    UIScrollView *_scrollview;
    BOOL _hasShowedFirstView;
    ///显示index的label
    UILabel *_indexLabel;
    ///保存按钮
    UIButton *_saveButton;
    ///信号菊花指示器
    UIActivityIndicatorView *_indicatorView;
    ///contentView
    UIView *_contentView;
    ///页码指示器
    UIPageControl *_pageControl;
    ///保存图片提示框
    UIAlertView *_savePhotoAlertView;
    
}

-(instancetype)initWithFrame:(CGRect)frame
{

    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = LSDPhotoBrowserBackgroundColor;
        
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)didMoveToSuperview{

    [self setupScrollView];
    
    [self setupToolbars];
}

///添加scrollview
-(void)setupScrollView
{

    _scrollview = [[UIScrollView alloc] init];
    _scrollview.delegate = self;
    _scrollview.showsHorizontalScrollIndicator = NO;
    _scrollview.showsVerticalScrollIndicator = NO;
    _scrollview.pagingEnabled = YES;
    [self addSubview:_scrollview];
    
    for (int i = 0; i < self.imageCount; i++) {

        LSDPhotoBrowserView *photoView = [[LSDPhotoBrowserView alloc]init];
        photoView.imageview.tag = i;
        photoView.isLocalImage = self.isLocalImage;
        __weak typeof(self)weakSelf = self;
        photoView.singleTapBlock = ^(UITapGestureRecognizer *recognizer) {
            __strong typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf photoClick:recognizer];
            
        };
        
        photoView.longTapBlock = ^(UILongPressGestureRecognizer *recognizer) {
            __strong typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf photoLongClick:recognizer];
        };
        
        [_scrollview addSubview:photoView];
    }
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
    
    
}

///底部控件
-(void)setupToolbars
{
    UILabel *indexLabel = [[UILabel alloc]init];
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont boldSystemFontOfSize:20];
    indexLabel.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
    indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    indexLabel.center = CGPointMake(ScreenWidth * 0.5, 30);
    indexLabel.layer.cornerRadius = 15;
    indexLabel.clipsToBounds = YES;
    
    if (self.imageCount > 1) {
        indexLabel.text = [NSString stringWithFormat:@"1/%ld", (long)self.imageCount];
        _indexLabel = indexLabel;
        [self addSubview:indexLabel];
    }
    
    UIPageControl *page = [[UIPageControl alloc] init];
    page.pageIndicatorTintColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    page.currentPageIndicatorTintColor = [UIColor whiteColor];
    page.numberOfPages = self.imageCount;
    [self addSubview:page];
    _pageControl = page;
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bounds.size.width * 0.5 - _pageControl.frame.size.width * 0.5);
        make.top.mas_equalTo(self.bounds.size.height - 30 - 37);
    }];
    
    if (self.imageCount == 1) {
        _pageControl.hidden = YES;
    }
    ///是显示pageNumLabel还是显示pageControl
    BOOL showNumPage = LSDPageType == LSDNumPageType ? YES : NO;
    if (showNumPage) {
        [_pageControl removeFromSuperview];
        _pageControl = nil;
    } else {
        [_indexLabel removeFromSuperview];
        _indexLabel = nil;
    }
    
    
}

-(void)layoutSubviews
{

    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.size.width += LSDPhotoBrowserImageViewMargin * 2;
    _scrollview.bounds = rect;
    _scrollview.center = CGPointMake(self.bounds.size.width *0.5, self.bounds.size.height *0.5);
    
    CGFloat y = 0;
    __block CGFloat w = _scrollview.frame.size.width - LSDPhotoBrowserImageViewMargin * 2;
    CGFloat h = _scrollview.frame.size.height;
    
    [_scrollview.subviews enumerateObjectsUsingBlock:^(LSDPhotoBrowserView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = LSDPhotoBrowserImageViewMargin + idx * (LSDPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    ///设置scollview的contentSize和contentOffset
    _scrollview.contentSize = CGSizeMake(_scrollview.subviews.count * _scrollview.frame.size.width, _scrollview.frame.size.height);
    _scrollview.contentOffset = CGPointMake(self.currentImageIndex * _scrollview.frame.size.width, 0);
    
    ///第一次出现时调用
    if (!_hasShowedFirstView) {
        [self showFirstImage];
    }
    
    _indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    _indexLabel.center = CGPointMake(self.bounds.size.width * 0.5, 30);
    _saveButton.frame = CGRectMake(30, self.bounds.size.height - 70, 55, 30);
    
    
    if (_pageControl) {
        [_pageControl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.bounds.size.width * 0.5 - _pageControl.frame.size.width * 0.5);
            make.top.mas_equalTo(self.bounds.size.height - 30 - 37);
        }];
    }
    
}

#pragma mark -- 开启大图模式
-(void)showFirstImage
{
    
    LSDPhotoCollectionView *collectionView = (LSDPhotoCollectionView *)self.sourceImagesContainerView;
    
    UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentImageIndex inSection:0]];
    
    
    CGRect rect = [self.sourceImagesContainerView convertRect:cell.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.frame = rect;
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    [self addSubview:tempView];
    tempView.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat placeImageSizeW = tempView.image.size.width;
    CGFloat placeImageSizeH = tempView.image.size.height;
    CGRect targetTemp;
    
    CGFloat placeHolderH = (placeImageSizeH * ScreenWidth)/placeImageSizeW;
    if (placeHolderH <= ScreenHeight) {
        targetTemp = CGRectMake(0, (ScreenHeight - placeHolderH) * 0.5 , ScreenWidth, placeHolderH);
    } else {
        targetTemp = CGRectMake(0, 0, ScreenHeight, placeHolderH);
    }
    
    _scrollview.hidden = YES;
    _indexLabel.hidden = YES;
    _saveButton.hidden = YES;
    _pageControl.hidden = YES;
    
    
    [UIView animateWithDuration:LSDPhotoBrowserShowImageAnimationDuration animations:^{
        tempView.frame = targetTemp;
    } completion:^(BOOL finished) {
        _hasShowedFirstView = YES;
        [tempView removeFromSuperview];
        _scrollview.hidden = NO;
        _indexLabel.hidden = NO;
        _saveButton.hidden = NO;
        _pageControl.hidden = NO;
    }];

}

///为每一个LSDPhotoBrowserView配置图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index
{
    LSDPhotoBrowserView *view = _scrollview.subviews[index];
    ///网络图片
    if (!self.isLocalImage) {
        if (view.beginLoadingImage) return;
        if ([self highQualityImageURLForIndex:index]) {
            [view setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
        } else {
            view.imageview.image = [self placeholderImageForIndex:index];
        }
        view.beginLoadingImage = YES;
    }else
    {
        ///本地图片
        [view setImageWithURL:nil placeholderImage:[self placeholderImageForIndex:index]];
    }
   
}

-(void)show
{

    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = LSDPhotoBrowserBackgroundColor;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    _contentView.center = window.center;
    _contentView.bounds = window.bounds;
    
    self.center = CGPointMake(_contentView.bounds.size.width * 0.5, _contentView.bounds.size.height * 0.5);
    self.bounds = CGRectMake(0, 0, _contentView.bounds.size.width, _contentView.bounds.size.height);
    
    [_contentView addSubview:self];
    
    window.windowLevel = UIWindowLevelStatusBar+10.0f;
    
    ///支持横竖屏
    [self performSelector:@selector(onDeviceOrientationChangeWithObserver) withObject:nil afterDelay:LSDPhotoBrowserShowImageAnimationDuration + 0.2];
   
    [window addSubview:_contentView];
    
}

///支持横竖屏
- (void)onDeviceOrientationChangeWithObserver
{
    [self onDeviceOrientationChange];
    ///添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)onDeviceOrientationChange
{
    
    if (!LSDISShouldLandscape) {
        return;
    }
    
    LSDPhotoBrowserView *currentView = _scrollview.subviews[self.currentImageIndex];
    
    [currentView.scrollview setZoomScale:1.0 animated:YES];

    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        
        ///横屏
    [UIView animateWithDuration:LSDAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)orientation];
        
        self.transform = (orientation == UIDeviceOrientationLandscapeRight)? CGAffineTransformMakeRotation(M_PI*1.5):CGAffineTransformMakeRotation(M_PI/2);
        
        self.bounds = CGRectMake(0, 0,screenBounds.size.height , screenBounds.size.width);
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
        
    }else if(orientation==UIDeviceOrientationPortrait)
    {
        ///竖屏
        [UIView animateWithDuration:LSDAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)orientation];
            self.transform = (orientation==UIDeviceOrientationPortrait)?CGAffineTransformIdentity:CGAffineTransformMakeRotation(M_PI);
            self.bounds = screenBounds;
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:nil];
    }
    
    
}

#pragma mark -- 单击手势
-(void)photoClick:(UITapGestureRecognizer *)recognizer
{

    ///当前单击的视图
    LSDPhotoBrowserView *currentView = _scrollview.subviews[self.currentImageIndex];
    ///恢复正常scale
    [currentView.scrollview setZoomScale:1.0 animated:YES];
    
    _indexLabel.hidden = YES;
    _saveButton.hidden = YES;
    _pageControl.hidden = YES;
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    ///横屏
    if (UIDeviceOrientationIsLandscape(orientation)) {
        
    }else
    {
        [self hidePhotoBrowser:recognizer];
    }
}

#pragma mark -- 长按手势
-(void)photoLongClick:(UILongPressGestureRecognizer *)recognizer
{
    if (_savePhotoAlertView != nil) {
        return;
    }
    _savePhotoAlertView = [[UIAlertView alloc] initWithTitle:@"保存图片" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
    [_savePhotoAlertView show];
    

}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
    }else if (buttonIndex == 1){
        [self saveImage];
    }
    _savePhotoAlertView = nil;
}


#pragma mark - 退出大图模式
- (void)hidePhotoBrowser:(UITapGestureRecognizer *)recognizer
{

    LSDPhotoBrowserView *view = (LSDPhotoBrowserView *)recognizer.view;
    ///当前的imageView
    UIImageView *currentImageView = view.imageview;
    
    LSDPhotoCollectionView *collectionView = (LSDPhotoCollectionView *)self.sourceImagesContainerView;

    ///找到当前index所对应的cell
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentImageIndex inSection:0]];
    
    ///将cell的frame转化为当前视图的frame位置
    CGRect targetFrame = [self.sourceImagesContainerView convertRect:cell.frame toView:self];
    
    ///创建一个临时的UIImageView
    UIImageView *tempImageView = [[UIImageView alloc]init];
    tempImageView.image = currentImageView.image;
    CGFloat tempImageSizeH = tempImageView.image.size.height;
   
    CGFloat tempImageSizeW = tempImageView.image.size.width;
    
    CGFloat tempImageViewH = tempImageSizeH * ScreenWidth / tempImageSizeW;
    
    ///临时tempImageView的大小与屏幕高度作比较
    if (tempImageViewH < ScreenHeight) {
    
        tempImageView.frame = CGRectMake(0, (ScreenHeight - tempImageViewH) * 0.5, ScreenWidth, tempImageViewH);
    }else
    {
        tempImageView.frame = CGRectMake(0, 0, ScreenWidth, tempImageViewH);
    }
    
    [self addSubview:tempImageView];
    
    _saveButton.hidden = YES;
    _indexLabel.hidden = YES;
    _scrollview.hidden = YES;
    _pageControl.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    _contentView.backgroundColor = [UIColor clearColor];
    self.window.windowLevel = UIWindowLevelNormal;
    
    [UIView animateWithDuration:LSDPhotoBrowserHideImageAnimationDuration animations:^{
        tempImageView.frame = targetFrame;
    } completion:^(BOOL finished) {
        [_contentView removeFromSuperview];
        [tempImageView removeFromSuperview];
    }];
    
}


#pragma mark -- 代理方法
- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageUrlForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageUrlForIndex:index];
    }
    return nil;
}

#pragma mark - scrollview代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + _scrollview.bounds.size.width * 0.5) / _scrollview.bounds.size.width;
    _indexLabel.text = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
    
    _pageControl.currentPage = index;
    
    long left = index - 1;
    long right = index + 1;
    left = left>0?left : 0;
    right = right>self.imageCount?self.imageCount:right;
    
    for (long i = left; i < right; i++) {
        [self setupImageOfImageViewForIndex:i];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int autualIndex = scrollView.contentOffset.x  / _scrollview.bounds.size.width;
    ///定位当前展示的图片index
    self.currentImageIndex = autualIndex;
    for (LSDPhotoBrowserView *view in _scrollview.subviews) {
        if (view.imageview.tag != autualIndex) {
            view.scrollview.zoomScale = 1.0;
        }
    }
}

#pragma mark 保存图像
- (void)saveImage
{
    int index = _scrollview.contentOffset.x / _scrollview.bounds.size.width;
    
    LSDPhotoBrowserView *currentView = _scrollview.subviews[index];
    
    UIImageWriteToSavedPhotosAlbum(currentView.imageview.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [_indicatorView removeFromSuperview];
    
    NSString *success = LSDPhotoBrowserSaveImageSuccessText;
    NSString *fail = LSDPhotoBrowserSaveImageFailText;
    NSString *successImage = @"success.png";
    NSString *errorImage = @"error.png";
    if (error) {
        UIView *view = [[UIApplication sharedApplication].windows lastObject];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.label.text = fail;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", errorImage]]];
        hud.mode = MBProgressHUDModeCustomView;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:1.0];
    } else {
        UIView *view = [[UIApplication sharedApplication].windows lastObject];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.label.text = success;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", successImage]]];
        hud.mode = MBProgressHUDModeCustomView;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:1.0];
    }
}


@end
























