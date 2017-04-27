//
//  LSDWaitingView.m
//  LSDPhotoBrowser
//
//  Created by 神州锐达 on 2017/4/26.
//  Copyright © 2017年 OnePiece. All rights reserved.
//

#import "LSDWaitingView.h"

@implementation LSDWaitingView

-(instancetype)initWithFrame:(CGRect)frame
{

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = LSDWaitingViewBackgroundColor;
        self.clipsToBounds = YES;
        self.mode = LSDWaitingViewModeLoopDiagram;//默认用空心的 之后会覆盖用户选择的样式
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
    if (progress >= 1) {
        ///自动移除控件
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    }
}


- (void)setFrame:(CGRect)frame
{
    //设置背景图为圆
    frame.size.width = 50;
    frame.size.height = 50;
    self.layer.cornerRadius = 25;
    [super setFrame:frame];
}

-(void)drawRect:(CGRect)rect
{

    ///获取当前图形上下文
    CGContextRef ctx =  UIGraphicsGetCurrentContext();
    
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    ///绘制颜色
    [[UIColor whiteColor] set];
    
    switch (self.mode) {
        case LSDWaitingViewModePieDiagram:
        {
            CGFloat radius = MIN(rect.size.width * 0.5, rect.size.height * 0.5) - LSDWaitingViewItemMargin;

            CGFloat width = radius * 2 + LSDWaitingViewItemMargin;
            CGFloat height = width;
            CGFloat x = (rect.size.width - width) * 0.5;
            CGFloat y = (rect.size.height - height) * 0.5;
            
            ///绘制椭圆
            CGContextAddEllipseInRect(ctx, CGRectMake(x, y, width, height));
            CGContextFillPath(ctx);
            
            
            [LSDWaitingViewBackgroundColor set];
            
            CGContextMoveToPoint(ctx, xCenter, yCenter);
            CGContextAddLineToPoint(ctx, xCenter, 0);
            CGFloat endAngle = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.001; // 初始值
            CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, endAngle, 1);
            CGContextClosePath(ctx);
            
            CGContextFillPath(ctx);
            
        }
            break;
            
        default:
        {
        
            ///设置线宽
            CGContextSetLineWidth(ctx, 4);
            ///设置连接点类型
            CGContextSetLineCap(ctx, kCGLineCapRound);
            CGFloat endAngle = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.05; // 初始值0.05
            CGFloat radius = MIN(rect.size.width, rect.size.height) * 0.5 - LSDWaitingViewItemMargin;
            ///绘制圆形
            CGContextAddArc(ctx, xCenter, yCenter, radius, -M_PI * 0.5, endAngle, NO);
            
            ///空心填充圆形
            CGContextStrokePath(ctx);
            
        }
            break;
    }
    
}


@end













