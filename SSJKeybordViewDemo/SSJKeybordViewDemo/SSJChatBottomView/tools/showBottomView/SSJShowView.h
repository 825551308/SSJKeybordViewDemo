//
//  SSJShowView.h
//  获得系统相册路径沙盒机制
//
//  Created by 金汕汕 on 16/6/30.
//  Copyright © 2016年 ccs. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SSJShowViewDelegate<NSObject>
- (void)menuHandelPush:(NSInteger)indexValue;
- (void)cancelBtnClickDelegateMethod:(id)sender;
@end

@interface SSJShowView : UIView<UIScrollViewDelegate>


@property (weak, nonatomic) IBOutlet UIView *actionView;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) UIView *backView1;
@property (nonatomic, strong) UIView *backView2;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) id senderViewController;
@property (nonatomic, assign) id<SSJShowViewDelegate>delegate;

+ (SSJShowView *)instanceSSJShowView;
- (void)buidliew:(NSMutableArray *)titleArray imgArray:(NSMutableArray *)imgArray numberOfEveLine:(int)numberOfEveLineValue  senderVC:(id)senderVC;
@end
