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
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;

- (void)updateCell:(NSString *)message;
@end
