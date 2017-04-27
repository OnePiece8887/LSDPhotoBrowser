//
//  ViewController.m
//  LSDPhotoBrowser
//
//  Created by 神州锐达 on 2017/4/25.
//  Copyright © 2017年 OnePiece. All rights reserved.
//

#import "ViewController.h"
#import "LSDPhotoCollectionView.h"
@interface ViewController ()

///
@property(strong,nonatomic)NSArray *imageArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    NSMutableArray *muarray = @[].mutableCopy;
//    
//    for (int i = 1; i < 11 ; i ++) {
//        NSString *imageName = [NSString stringWithFormat:@"%02d",i];
//
//        [muarray addObject:imageName];
//        
//    }
//    self.imageArray = muarray.copy;
    
    self.imageArray = @[@"http://ww2.sinaimg.cn/bmiddle/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg",@"http://ww4.sinaimg.cn/bmiddle/9e9cb0c9jw1ep7nlyu8waj20c80kptae.jpg",@"http://ww2.sinaimg.cn/bmiddle/642beb18gw1ep3629gfm0g206o050b2a.gif",@"http://ww3.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg",@"http://ww2.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg",@"http://ww4.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",@"http://ww3.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg",@"http://ww2.sinaimg.cn/bmiddle/677febf5gw1erma104rhyj20k03dz16y.jpg",@"http://ww4.sinaimg.cn/bmiddle/677febf5gw1erma1g5xd0j20k0esa7wj.jpg"];
    
    
    LSDPhotoCollectionView *collectView = [[LSDPhotoCollectionView alloc]initWithFrame:CGRectZero];
    
    [self.view addSubview:collectView];
    
    collectView.imageArray = self.imageArray.copy;
    
    CGSize size = [collectView calculationCollectionViewHeight];
    
    [collectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.mas_equalTo(size.height);
    }];
    
    
    [collectView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
