//
//  LSDPhotoCollectionView.m
//  CloodForSafeHomeSecurity
//
//  Created by ls on 16/6/27.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import "LSDPhotoCollectionView.h"
#import "LSDPhotoCollectionViewCell.h"
#import "LSDPhotoBrowser.h"
CGFloat itemMargin = 10.0;

#define KPhotoCollectionViewItemW  (ScreenWidth - 20 - itemMargin*2) / 3

static NSString *LSDPhotoCollectionViewReuseIdentifier = @"LSDPhotoCollectionViewReuseIdentifier";
@interface LSDPhotoCollectionView ()<UICollectionViewDataSource,UICollectionViewDelegate,LSDPhotoBrowserDelegate>

///
@property(strong,nonatomic)UICollectionViewFlowLayout *flowLayout;

@end

@implementation LSDPhotoCollectionView

-(instancetype)initWithFrame:(CGRect)frame
{

    if (self = [super initWithFrame:frame]) {
    self = [self initWithFrame:frame collectionViewLayout:self.flowLayout];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    self.flowLayout = flowLayout;
    if (self = [super initWithFrame:frame collectionViewLayout:flowLayout]) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self setupCollectionView];
    }
    return self;
}

-(void)setupCollectionView
{
 
    _imageArray = [NSMutableArray array];
    
   
    self.dataSource = self;
    self.delegate = self;
    
    [self registerClass:[LSDPhotoCollectionViewCell class] forCellWithReuseIdentifier:LSDPhotoCollectionViewReuseIdentifier];
    self.showsVerticalScrollIndicator = NO;
    ///不能滚动
    self.scrollEnabled = NO;
}

-(void)layoutSubviews
{

    [super layoutSubviews];
    CGFloat itemWidth = (ScreenWidth - 20 - itemMargin*2) / 3;

    self.flowLayout.itemSize = CGSizeMake(itemWidth - 1, itemWidth - 1);
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;

  
}

#pragma mark -- dataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return self.imageArray.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    LSDPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LSDPhotoCollectionViewReuseIdentifier forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[LSDPhotoCollectionViewCell alloc]initWithFrame:CGRectZero];
    }
   
    cell.iconImage = self.imageArray[indexPath.row];
  
    return cell;
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    LSDPhotoBrowser *browser = [[LSDPhotoBrowser alloc]init];
    browser.sourceImagesContainerView = self;
    browser.imageCount = self.imageArray.count;
    browser.currentImageIndex = (NSInteger)indexPath.item;
    browser.delegate = self;
//    browser.isLocalImage = YES;
    [browser show];
    
}

-(CGSize)calculationCollectionViewHeight
{
    CGFloat height = 0;
    if (self.imageArray.count  <= 2) {
        height = KPhotoCollectionViewItemW + 1;
    }else
    {
        height = KPhotoCollectionViewItemW * (self.imageArray.count / 3 + 1) + itemMargin *(self.imageArray.count / 3);
    }
    
    return CGSizeMake(ScreenWidth - 20, height);
    
}



#pragma mark - photobrowser代理方法  提供图片数据源
- (UIImage *)photoBrowser:(LSDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {

    NSString *smallImageURL = self.imageArray[index];
    
    if (!browser.isLocalImage) {
        if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:smallImageURL] == nil) {
            return LSDPlaceholderImage;
        } else {
            return [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:smallImageURL];
        }
    }else
    {
        return [UIImage imageNamed:smallImageURL];
    }
 
}

#pragma mark -- 网络图片时提供高清图方法 本地图片时该方法不写
- (NSURL *)photoBrowser:(LSDPhotoBrowser *)browser highQualityImageUrlForIndex:(NSInteger)index {
    NSString *urlStr = self.imageArray[index];
    
    return [NSURL URLWithString:urlStr];
}

@end














