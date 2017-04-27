//
//  LSDPhotoBrowser.h
//  LSDPhotoBrowser
//
//  Created by 神州锐达 on 2017/4/25.
//  Copyright © 2017年 OnePiece. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSDPhotoBrowser;
@protocol LSDPhotoBrowserDelegate<NSObject>

@required
///占位图片
-(UIImage *)photoBrowser:(LSDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index;

@optional
///提供高质量大图的url 网络图片时使用
-(NSURL *)photoBrowser:(LSDPhotoBrowser *)browser highQualityImageUrlForIndex:(NSInteger)index;


@end

///图片浏览器
@interface LSDPhotoBrowser : UIView<UIScrollViewDelegate>

///来源图片视图
@property(weak,nonatomic)UIView *sourceImagesContainerView;

///当前图片的index
@property(assign,nonatomic)NSInteger currentImageIndex;

///图片个数
@property(assign,nonatomic)NSInteger imageCount;

///代理
@property(weak,nonatomic)id<LSDPhotoBrowserDelegate> delegate;

///展示
-(void)show;

///本地还是网络图片  默认是网络图片
@property(assign,nonatomic)BOOL isLocalImage;


@end
