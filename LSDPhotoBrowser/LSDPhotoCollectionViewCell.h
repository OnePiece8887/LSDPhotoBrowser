//
//  LSDPhotoCollectionViewCell.h
//  CloodForSafeHomeSecurity
//
//  Created by ls on 16/6/27.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSDPhotoCollectionViewCell : UICollectionViewCell


///图片
@property(copy,nonatomic)NSString *iconImage;

///本地或者网络图片  默认网络图片
@property(assign,nonatomic)BOOL isLocalimage;

@end
