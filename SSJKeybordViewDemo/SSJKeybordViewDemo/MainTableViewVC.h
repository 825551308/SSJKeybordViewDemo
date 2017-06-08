//
//  MainTableViewVC.h
//  SSJKeybordViewDemo
//
//  Created by jssName on 2017/6/7.
//  Copyright © 2017年 ccs. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ScrollViewWillBeginDraggingBlock)(UIScrollView *scrollView);
@interface MainTableViewVC : UITableViewController
- (void)joinToList:(NSString *)str;
/** 滚动后告诉调用者收回键盘 */
@property (nonatomic,copy) ScrollViewWillBeginDraggingBlock scrollViewWillBeginDraggingBlock;
// 滚到底部
- (void)scrollToBottom;
@end
