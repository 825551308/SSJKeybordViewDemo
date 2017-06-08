//
//  ExpressionViewCell.h
//  自定义聊天键盘
//
//  Created by 金汕汕 on 16/9/20.
//  Copyright © 2016年 ccs. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString * const expressionViewCellIdentifier = @"ExpressionViewCellIdentifier";

@protocol ExpressionViewCellDelgate <NSObject>

- (void)expressionBtnClickDelagateMethod:(NSInteger )tag;

@end
@interface ExpressionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *expressionButton;
@property (weak,nonatomic) id<ExpressionViewCellDelgate> delegate;
@end
