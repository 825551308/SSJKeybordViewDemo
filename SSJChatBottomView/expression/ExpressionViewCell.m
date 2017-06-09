//
//  ExpressionViewCell.m
//  自定义聊天键盘
//
//  Created by 金汕汕 on 16/9/20.
//  Copyright © 2016年 ccs. All rights reserved.
//

#import "ExpressionViewCell.h"

@implementation ExpressionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (IBAction)expressionClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if ([self.delegate respondsToSelector:@selector(expressionBtnClickDelagateMethod:)]) {
        [self.delegate expressionBtnClickDelagateMethod:btn.tag];
    }
    
}

@end
