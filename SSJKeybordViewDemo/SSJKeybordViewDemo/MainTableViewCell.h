//
//  MainTableViewCell.h
//  SSJKeybordViewDemo
//
//  Created by jssName on 2017/6/7.
//  Copyright © 2017年 ccs. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString  * const mainTableViewCellIdent = @"MainTableViewCellIdent";
@interface MainTableViewCell : UITableViewCell

/** 新cell内容 */
- (void)updateCell:(NSString *)message;
@end
