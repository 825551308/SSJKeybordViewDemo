//
//  SSJRecordAnimateView.m
//  自定义聊天键盘
//
//  Created by 金汕汕 on 16/9/19.
//  Copyright © 2016年 ccs. All rights reserved.
//

#import "SSJRecordAnimateView.h"

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height-64

//#define recordAnimateViewWidth 150
//#define recordAnimateViewHeight 150

@implementation SSJRecordAnimateView

- (void)createView:(float)selfWidth selfHeight:(float)selfHeight{
    //两个图片宽度 2:1  两边各留10 图片之际间距5    图片本身左右有留白  此处不需要考虑左右边距和图片间距
    float lR = selfWidth*1.0/3 ;
    //增加说话的logo 话筒样式
    _recordLocgImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, (selfHeight - lR*2 ) * 1.0 /2, lR*2 - 10, lR*2 + 10)];
    _recordLocgImgView.image = [UIImage imageNamed:@"voice_to_speek"];
    [self addSubview:_recordLocgImgView];
    //增加说话音波强度图片    原图宽：高 ＝ 2 : 3
    _animateImgView = [[UIImageView alloc]initWithFrame:CGRectMake( lR * 2 - 20, ( selfHeight - (lR * 1.0)/2*3 ) / 2 + 5, lR - 10, (lR * 1.0)/2*3)];
    [self addSubview:_animateImgView];
}

#pragma mark -- 更新 录音动画图片
- (void)updateRecordAnimateViewBcgImg:(NSString *)backgroundImgName{
    _animateImgView.image = [UIImage imageNamed:backgroundImgName];
    if (self.hidden) {
        self.hidden = FALSE;
    }
}

#pragma mark -- 录音结束代理
- (void)updateRecordAnimateViewEnd{
    //清空动画图片
    self.animateImgView.image = [UIImage imageNamed:@""];
    //隐藏动画view
    if (!self.hidden) {
        self.hidden = TRUE;
    }
}
@end
