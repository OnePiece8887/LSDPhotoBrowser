//
//  LSDPhotoBrowserConfigure.h
//  LSDPhotoBrowser
//
//  Created by 神州锐达 on 2017/4/26.
//  Copyright © 2017年 OnePiece. All rights reserved.
//

#ifndef LSDPhotoBrowserConfigure_h
#define LSDPhotoBrowserConfigure_h

typedef enum : NSUInteger {
    LSDNumPageType,     //数字展示图片数量
    LSDPageControlType  //系统默认 分页条UIPageControl
} LSDPageTypeMode;

typedef enum : NSUInteger {
    LSDWaitingViewModeLoopDiagram, // 原型空心
    LSDWaitingViewModePieDiagram // 原型实心
} LSDWaitingViewMode;


///是否支持横屏  默认支持横屏
#define LSDISShouldLandscape YES

///使用哪种样式显示 图片总数量与当前查看的图片
#define LSDPageType LSDNumPageType

//占位图
#define LSDPlaceholderImage [UIImage imageNamed:@"placeholderImage"]

///照片浏览器的背景颜色
#define LSDPhotoBrowserBackgroundColor [UIColor blackColor]

///照片浏览器中 图片之间的margin
#define LSDPhotoBrowserImageViewMargin 10

///照片浏览器中 显示图片动画时长
#define LSDPhotoBrowserShowImageAnimationDuration 0.35f

///照片浏览器中 隐藏图片动画时长
#define LSDPhotoBrowserHideImageAnimationDuration 0.35f

// 图片保存成功提示文字
#define LSDPhotoBrowserSaveImageSuccessText @" 保存成功 ";

// 图片保存失败提示文字
#define LSDPhotoBrowserSaveImageFailText @" 保存失败 ";

// 照片浏览器中 屏幕旋转时 使用这个时间 来做动画修改图片的展示
#define LSDAnimationDuration 0.35f



#pragma mark -- LSDPhotoBrowserView使用的宏定义
#define LSDIsFullWidthForLandScape NO //是否在横屏的时候直接满宽度，而不是满高度，一般是在有长图需求的时候设置为YES

///缩放scale
#define LSDMinZoomScale 0.6f
#define LSDMaxZoomScale 2.0f


#pragma mark -- LSDWaitingView使用的宏定义
///图片下载进度指示器背景色
#define LSDWaitingViewBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]

///图片下载进度指示进度显示样式（LSDWaitingViewModeLoopDiagram 圆形空心，LSDWaitingViewModePieDiagram 圆形实心） 默认空心
#define LSDWaitingViewProgressMode LSDWaitingViewModeLoopDiagram

// 图片下载进度指示器内部控件间的间距
#define LSDWaitingViewItemMargin 10

#endif /* LSDPhotoBrowserConfigure_h */
