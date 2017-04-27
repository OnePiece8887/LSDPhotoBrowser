//
//  LSDPhotoCollectionView.h
//  CloodForSafeHomeSecurity
//
//  Created by ls on 16/6/27.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSDPhotoCollectionView : UICollectionView

///
@property(strong,nonatomic)NSMutableArray *imageArray;

-(CGSize)calculationCollectionViewHeight;
@end
