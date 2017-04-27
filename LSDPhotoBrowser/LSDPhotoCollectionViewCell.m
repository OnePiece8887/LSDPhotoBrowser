//
//  LSDPhotoCollectionViewCell.m
//  CloodForSafeHomeSecurity
//
//  Created by ls on 16/6/27.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import "LSDPhotoCollectionViewCell.h"

@interface LSDPhotoCollectionViewCell ()

///
@property(strong,nonatomic)UIImageView *imageView;

///
@property(strong,nonatomic)UIImageView *addImageView;

@property(weak,nonatomic)UILabel *label;

@end



@implementation LSDPhotoCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{


    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupUI];
    }
    return self;
}

-(void)setupUI
{
    
    UIImageView *imageView = [[UIImageView alloc]init];
    
    [self addSubview:imageView];
    self.imageView = imageView;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
}

-(void)setIconImage:(NSString *)iconImage
{

    _iconImage = iconImage;
   
    if (!self.isLocalimage) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:iconImage]];
    }else
    {
        self.imageView.image = [UIImage imageNamed:iconImage];
    }
    
}


@end




















