//
//  ExpressionEvePageView.h
//  自定义聊天键盘
//
//  Created by 金汕汕 on 16/9/21.
//  Copyright © 2016年 ccs. All rights reserved.
//
#import <UIKit/UIKit.h>
@protocol ExpressionEvePageViewDelegate <NSObject>

- (void)biaoqingClickDelagateMethod:(NSInteger )tag;

@end

@interface ExpressionEvePageView : UIView
@property (nonatomic , assign) float  expressionBtnR;
@property (nonatomic , weak) id<ExpressionEvePageViewDelegate>delegate;

- (void)createView :(NSArray *)arrEmotion page:(NSInteger)pageVal;
@end
