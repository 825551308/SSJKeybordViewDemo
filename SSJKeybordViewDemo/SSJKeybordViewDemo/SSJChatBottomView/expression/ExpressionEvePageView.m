//
//  ExpressionEvePageView.m
//  自定义聊天键盘
//
//  Created by 金汕汕 on 16/9/21.
//  Copyright © 2016年 ccs. All rights reserved.
//

#import "ExpressionEvePageView.h"

@implementation ExpressionEvePageView
#define App_Height [[UIScreen mainScreen] bounds].size.height //主屏幕的高度
#define App_Width  [[UIScreen mainScreen] bounds].size.width  //主屏幕的宽度
#define expressionScrollerViewHeight 176
#define expressionBtnWidth  40

- (void)initWithData{
    self.expressionBtnR = expressionBtnWidth;
    int widNum = (int) App_Width / (self.expressionBtnR);//一行表情个数
    
    if (widNum *(self.expressionBtnR)  == App_Width) {
        
    }else{
        self.expressionBtnR = (App_Width - widNum *(self.expressionBtnR) ) / widNum  + self.expressionBtnR;
    }
    
}
/**
 *  创建表情栏数据
 *
 *  @param arrEmotion 表情栏表情名数据源（所有的）
 *  @param pageVal    页数
 */
- (void)createView :(NSArray *)arrEmotion page:(NSInteger)pageVal{
    [self initWithData];

    //先清空之前添加的表情按钮  然后再重新添加
    for (UIView *childView in self.subviews) {
        if ([childView isKindOfClass:[UIButton class]]) {
            [childView removeFromSuperview];
        }
    }
    
    
    CGFloat X;
    CGFloat Y;
    
    int widNum = (int) App_Width / (self.expressionBtnR);//一行表情个数
    int heightNum = expressionScrollerViewHeight / (self.expressionBtnR);//一列表情行数
    
    int currCount  ;
    if (widNum * heightNum * (pageVal+1) > arrEmotion.count) {
        currCount = (int)arrEmotion.count;
    }else{
        currCount = (int) (widNum * heightNum * (pageVal+1));
    }
    int dataIndex = (int)(widNum * heightNum * pageVal);
    for (int i = 0; i < widNum * heightNum; i ++) {
        
        UIButton *biaoqing =[[UIButton alloc] init];
        
        X = self.expressionBtnR * ((i)%widNum) ;
        int a = (i)/widNum ;
        Y = 0 + a * self.expressionBtnR ;
        biaoqing.frame = CGRectMake(X, Y, self.expressionBtnR, self.expressionBtnR);
        
        //索引等于当前 （页数－1）＊一页的表情个数 ＋ 当前i值
        if(pageVal - 1 >= 0){
            dataIndex = (int) (i + (widNum * heightNum) * pageVal);
        }else{
            dataIndex = i;
        }
        if (dataIndex >= arrEmotion.count) {
            //此时 超出表情数据源个数
            return;
        }
//        if (pageVal==3) {
//            NSLog(@"arrEmotion[dataIndex] %@",arrEmotion[dataIndex]);
//        }
//        NSString *Str = arrEmotion[dataIndex];
//        [biaoqing setTitle:Str forState:UIControlStateNormal];
        NSString *btnExpressionImgName = arrEmotion[dataIndex];
        [biaoqing setImage:[UIImage imageNamed:btnExpressionImgName] forState:UIControlStateNormal];
         biaoqing.imageEdgeInsets = UIEdgeInsetsMake(5,5,5,5);
        [biaoqing setTitleColor:[UIColor blackColor]  forState:UIControlStateNormal];
        biaoqing.tag = dataIndex;
        [biaoqing addTarget:self action:@selector(biaoqingClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:biaoqing];
        
        
    }
    
}

//表情按钮点击
- (void)biaoqingClick:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    if ([self.delegate respondsToSelector:@selector(biaoqingClickDelagateMethod:)]) {
        [self.delegate biaoqingClickDelagateMethod:btn.tag];
    }
}

@end
