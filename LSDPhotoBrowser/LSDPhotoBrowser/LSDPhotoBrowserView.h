//
//  LSDPhotoBrowserView.h
//  LSDPhotoBrowser
//
//  Created by 神州锐达 on 2017/4/26.
//  Copyright © 2017年 OnePiece. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SingleTapBlock)(UITapGestureRecognizer *recognizer);

typedef void(^LongTapBlock)(UILongPressGestureRecognizer *recognizer);

@interface LSDPhotoBrowserView : UIView

///scrollview
@property(strong,nonatomic)UIScrollView *scrollview;

///图片
@property(strong,nonatomic)UIImageView *imageview;

///加载进度
@property(assign,nonatomic)CGFloat progress;

///开始加载图片
@property(assign,nonatomic)BOOL beginLoadingImage;

///单击block
@property(copy,nonatomic)SingleTapBlock singleTapBlock;

///长按block
@property(copy,nonatomic)LongTapBlock longTapBlock;

///本地还是网络图片
@property(assign,nonatomic)BOOL isLocalImage;

///加载图片
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

@end
