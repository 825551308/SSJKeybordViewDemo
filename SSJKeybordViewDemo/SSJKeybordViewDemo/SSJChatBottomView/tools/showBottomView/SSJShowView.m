//
//  SSJShowView.m
//  获得系统相册路径沙盒机制
//
//  Created by 金汕汕 on 16/6/30.
//  Copyright © 2016年 ccs. All rights reserved.
//


#define screen_width [UIScreen mainScreen].bounds.size.width

#import "SSJShowView.h"
#import "JZMTBtnView.h"
@implementation SSJShowView
{
//    UIView *_backView1;
//    UIView *_backView2;
//    UIPageControl *_pageControl;
}


+ (SSJShowView *)instanceSSJShowView{
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"SSJShowView" owner:nil options:nil];
    //    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"UserPayDetailView" owner:nil options:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(qiehuan:)
//                                                 name:KNOTIFICATION_NOLOGIN
//                                               object:nil];
    return [nibView objectAtIndex:0];
}


- (void)buidliew:(NSMutableArray *)titleArray imgArray:(NSMutableArray *)imgArray numberOfEveLine:(int)numberOfEveLineValue  senderVC:(id)senderVC{

    _backView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 160)];
    _backView2 = [[UIView alloc] initWithFrame:CGRectMake(screen_width, 0, screen_width, 160)];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 180)];
    float scrollViewPageCount = titleArray.count%numberOfEveLineValue == 0?(titleArray.count/numberOfEveLineValue):(titleArray.count/numberOfEveLineValue+1);
    scrollView.contentSize = CGSizeMake(scrollViewPageCount*screen_width, 180);
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    [scrollView addSubview:_backView1];
    [scrollView addSubview:_backView2];
    [self.actionView addSubview:scrollView];
    
    //创建8个
    for (int i = 0; i < titleArray.count; i++) {
        CGRect frame = CGRectMake(i*screen_width/numberOfEveLineValue, 0, screen_width/numberOfEveLineValue, 80);
        NSString *title = titleArray[i];
        NSString *imageStr = imgArray[i];
        JZMTBtnView *btnView = [[JZMTBtnView alloc] initWithFrame:frame title:title imageStr:imageStr];
        btnView.tag = 10+i;
        [_backView1 addSubview:btnView];
       
        //添加触摸事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnTapBtnView:)];
        [btnView addGestureRecognizer:tap];
    }
    self.senderViewController = senderVC;
    if (titleArray.count == numberOfEveLineValue) {
        scrollView.scrollEnabled = FALSE;
    }
}


-(void)OnTapBtnView:(UITapGestureRecognizer *)sender{
//    JZMTBtnView *jz=(JZMTBtnView *)sender;
    NSString *msg=[NSString stringWithFormat:@"%ld",(long)sender.view.tag];
    
    NSLog(@"tag:%d",(int)sender.view.tag);
    
    if ([self.senderViewController respondsToSelector:@selector(menuHandelPush:)]) {
        [self.delegate menuHandelPush:[msg integerValue]-10];
    }
}



#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollViewW = scrollView.frame.size.width;
    CGFloat x = scrollView.contentOffset.x;
    int page = (x + scrollViewW/2)/scrollViewW;
    _pageControl.currentPage = page;
}



//取消上传
- (IBAction)cancelBtnClick:(id)sender {
    if ([self.senderViewController respondsToSelector:@selector(cancelBtnClickDelegateMethod:)]) {
        [self.delegate cancelBtnClickDelegateMethod:sender];
    }
}


@end
