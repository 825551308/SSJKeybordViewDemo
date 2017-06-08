//
//  SSJRecordAnimateView.h
//  自定义聊天键盘
//
//  Created by 金汕汕 on 16/9/19.
//  Copyright © 2016年 ccs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJRecordAnimateView : UIView
@property (strong, nonatomic) UIImageView *animateImgView;//录音动画展现imageView
@property (strong, nonatomic) UIImageView *recordLocgImgView;//录音话筒logo

- (void)createView:(float)selfWidth selfHeight:(float)selfHeight;
/*
 * 更新 录音动画图片
 */
- (void)updateRecordAnimateViewBcgImg:(NSString *)backgroundImgName;

/*
 * 录音结束
 */
- (void)updateRecordAnimateViewEnd;
@end
