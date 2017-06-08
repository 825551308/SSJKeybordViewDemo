//
//  MainTableViewCell.m
//  SSJKeybordViewDemo
//
//  Created by jssName on 2017/6/7.
//  Copyright © 2017年 ccs. All rights reserved.
//

#import "MainTableViewCell.h"
#import "SSJKeybordView.h"
@implementation MainTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCell:(NSString *)message{
//    self.titleLabel.text = message;
    
    self.titleLabel.attributedText = [SSJKeybordView dealWithString:message];
}
@end
