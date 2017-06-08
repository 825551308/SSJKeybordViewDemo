//
//  MainTableViewCell.m
//  SSJKeybordViewDemo
//
//  Created by jssName on 2017/6/7.
//  Copyright © 2017年 ccs. All rights reserved.
//

#import "MainTableViewCell.h"
#import "SSJKeybordView.h"

@interface MainTableViewCell()
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@end
@implementation MainTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/** 新cell内容 */
- (void)updateCell:(NSString *)message{
    /**< 此处需要将要显示的"今天天气不错嘛[微笑]！"等字符串 转换成NSAttributedString进行显示，转换不可逆 */
    self.titleLabel.attributedText = [SSJKeybordView dealWithString:message];
}
@end
