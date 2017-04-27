//
//  LSDPhotoBrowserView.m
//  LSDPhotoBrowser
//
//  Created by 神州锐达 on 2017/4/26.
//  Copyright © 2017年 OnePiece. All rights reserved.
//

#import "LSDPhotoBrowserView.h"
#import "LSDWaitingView.h"
@interface LSDPhotoBrowserView ()<UIScrollViewDelegate>

///等待视图
@property(weak,nonatomic)LSDWaitingView *waitingView;
///双击手势
@property (nonatomic,strong) UITapGestureRecognizer *doubleTap;
///单击手势
@property (nonatomic,strong) UITapGestureRecognizer *singleTap;
///长按手势
@property (nonatomic,strong) UILongPressGestureRecognizer *longTap;
///图片url
@property (nonatomic, strong) NSURL *imageUrl;
///占位图
@property (nonatomic, strong) UIImage *placeHolderImage;
///重新加载按钮
@property (nonatomic, strong) UIButton *reloadButton;
///是否加载图片
@property (nonatomic, assign) BOOL hasLoadedImage;

@end

@implementation LSDPhotoBrowserView

-(instancetype)initWithFrame:(CGRect)frame
{

    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.scrollview];
        [self addGestureRecognizer:self.doubleTap];
        [self addGestureRecognizer:self.singleTap];
        [self addGestureRecognizer:self.longTap];
    }
    return self;
}


-(void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{

    if (_reloadButton) {
        [_reloadButton removeFromSuperview];
    }
    
    _imageUrl = url;
    _placeHolderImage = placeholder;

    ///添加等待视图
    LSDWaitingView *waitingView = [[LSDWaitingView alloc]init];
    waitingView.mode = LSDWaitingViewProgressMode;
    waitingView.center = CGPointMake(ScreenWidth * 0.5, ScreenHeight * 0.5);
    self.waitingView = waitingView;
    [self addSubview:waitingView];
    
    __weak typeof(self)weakSelf = self;
    [_imageview sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!self.isLocalImage) {
            strongSelf.waitingView.progress = (CGFloat)receivedSize / expectedSize;
        }else
        {
        strongSelf.waitingView.progress = 1.0;
        }
     
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [_waitingView removeFromSuperview];
        
        if (!self.isLocalImage) {
            ///加载失败 添加重新加载按钮
            if (error) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                strongSelf.reloadButton = button;
                button.layer.cornerRadius = 2;
                button.clipsToBounds = YES;
                button.bounds = CGRectMake(0, 0, 200, 60);
                button.center = CGPointMake(ScreenWidth * 0.5, ScreenHeight * 0.5);
                button.titleLabel.font = [UIFont systemFontOfSize:14];
                button.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
                [button setTitle:@"加载失败，点击重新加载" forState:UIControlStateNormal];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button addTarget:strongSelf action:@selector(reloadImage) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:button];
                
            }
        }
      
        ///已加载完成图片
        strongSelf.hasLoadedImage = YES;
    }];

}

#pragma mark 双击 放大和缩小
- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    ///没有图片直接返回
    if (!self.hasLoadedImage) {
        return;
    }
    
    CGPoint touchPoint = [recognizer locationInView:self];
    
    if (self.scrollview.zoomScale <= 1.0) {
        ///放大
        CGFloat scaleX = touchPoint.x + self.scrollview.contentOffset.x;
        CGFloat sclaeY = touchPoint.y + self.scrollview.contentOffset.y;
        [self.scrollview zoomToRect:CGRectMake(scaleX, sclaeY, 10, 10) animated:YES];
        
    }else
    {
        ///恢复正常scale
        [self.scrollview setZoomScale:1.0 animated:YES];
        
    }
    
}

#pragma mark 单击
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (self.singleTapBlock) {
        self.singleTapBlock(recognizer);
    }
}
#pragma mark - 长按
-(void)handleLongTap:(UILongPressGestureRecognizer *)recognizer {
    if (self.longTapBlock) {
        self.longTapBlock(recognizer);
    }
}

///设置下载进度
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    _waitingView.progress = progress;
}
///重新加载图片
- (void)reloadImage
{
    [self setImageWithURL:_imageUrl placeholderImage:_placeHolderImage];
}

- (void)layoutSubviews
{
    
    [super layoutSubviews];
    _waitingView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    _scrollview.frame = self.bounds;
    _waitingView.center = _scrollview.center;
    [self adjustFrame];

}

///调整frame
-(void)adjustFrame
{
    
    CGRect frame = self.scrollview.frame;
    
    
    NSLog(@"%@-----%@",self.imageview,self.imageview.image);


    if (self.imageview.image) {
        ///取出当前图片的size
        CGSize imageSize = self.imageview.image.size;
        
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        
        //是否在横屏的时候直接满宽度，而不是满高度
        if (LSDIsFullWidthForLandScape) {
            ///直接铺满宽度 高度按照宽度的比率计算
            CGFloat ratio = frame.size.width / imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height * ratio;
            imageFrame.size.width  = frame.size.width;
            
        }else
        {
            ///scrollview的宽度小于高度
            if (frame.size.width <= frame.size.height) {
                
                ///宽度和scrollview等宽 高度按照宽度的比率计算
                CGFloat ratio = frame.size.width / imageFrame.size.width;
                imageFrame.size.height = imageFrame.size.height * ratio;
                imageFrame.size.width  = frame.size.width;
                
            }else
            {
                ///高度和scrollview等高 宽度按照高度的比率计算
                CGFloat ratio = frame.size.height/imageFrame.size.height;
                imageFrame.size.width = imageFrame.size.width*ratio;
                imageFrame.size.height = frame.size.height;
                
            }
        
        }
        self.imageview.frame = imageFrame;
        self.scrollview.contentSize = self.imageview.frame.size;
        ///调整imageview的中心点
        self.imageview.center = [self centerOfScrollViewContent:self.scrollview];
        
        CGFloat maxScale = frame.size.height / imageFrame.size.height;
        
        maxScale = (frame.size.width / imageFrame.size.width) > maxScale? (frame.size.width / imageFrame.size.width):maxScale;
        
        maxScale = maxScale >LSDMaxZoomScale? maxScale:LSDMaxZoomScale;
        ///设置缩放比
        self.scrollview.minimumZoomScale = LSDMinZoomScale;
        self.scrollview.maximumZoomScale = maxScale;
        self.scrollview.zoomScale = 1.0;
        
    }else
    {
    
        frame.origin = CGPointZero;
        self.imageview.frame = frame;
        self.scrollview.contentSize = self.imageview.frame.size;
    }

    self.scrollview.contentOffset = CGPointZero;

}

///放大后调整放大控件的center
- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView
{
    //目前contentsize的width是否大于原scrollview的contentsize，如果大于，设置imageview中心x点为contentsize的一半，以固定imageview在该contentsize中心。如果不大于说明图像的宽还没有超出屏幕范围，可继续让中心x点为屏幕中点，此种情况确保图像在屏幕中心。
    
    ///当scrollview的bounds的宽度大于contentSize的宽度时，x方向有偏移量
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    ///当scrollview的bounds的高度大于contentSize的高度时，y方向有偏移量
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    ///此时真实的中心点
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    
    return actualCenter;
}

#pragma mark -- UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.imageview.center = [self centerOfScrollViewContent:scrollView];
    
}

#pragma mark -- 懒加载
- (UIScrollView *)scrollview
{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] init];
        _scrollview.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        [_scrollview addSubview:self.imageview];
        _scrollview.delegate = self;
        _scrollview.clipsToBounds = YES;
    }
    return _scrollview;
}

- (UIImageView *)imageview
{
    if (!_imageview) {
        _imageview = [[UIImageView alloc] init];
        _imageview.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        _imageview.userInteractionEnabled = YES;
    }
    return _imageview;
}

- (UITapGestureRecognizer *)doubleTap
{
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTap.numberOfTapsRequired = 2;
        _doubleTap.numberOfTouchesRequired  =1;
    }
    return _doubleTap;
}

- (UITapGestureRecognizer *)singleTap
{
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        _singleTap.numberOfTapsRequired = 1;
        _singleTap.numberOfTouchesRequired = 1;
        _singleTap.delaysTouchesBegan = YES;
        [_singleTap requireGestureRecognizerToFail:self.doubleTap];
    }
    return _singleTap;
}

-(UILongPressGestureRecognizer *)longTap {
    if (!_longTap) {
        _longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
        _longTap.minimumPressDuration = 0.5;
    }
    return _longTap;
}

@end














