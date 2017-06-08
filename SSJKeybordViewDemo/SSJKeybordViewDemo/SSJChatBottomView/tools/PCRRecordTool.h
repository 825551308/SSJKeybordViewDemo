//
//  PCRRecordTool.h
//  PersonalCR
//
//  Created by jssName on 16/4/14.
//  Copyright © 2016年 jssName. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#define recordPathHead  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
static float const countDownMaxFloat = 60;//倒计时开始
static float const countDownMinFloat = 1;
//static float countDown = 60;//倒计时

@protocol PCRRecordToolDelegate <NSObject>

- (void)updateMetersMethod:(CGFloat)floatValue;
- (void)recordTimeOut:(NSString *)pathStr;
@end



@interface PCRRecordTool : NSObject<AVAudioRecorderDelegate>
@property (nonatomic , weak)  NSString *urlStr;

typedef void(^PCRRecordToolBlock)();
@property (nonatomic , copy) PCRRecordToolBlock pCRRecordToolBlock;
@property (nonatomic , strong)    NSTimer *timer;//定时器 监控录音测量值
@property (nonatomic , assign)  float countDown ;//倒计时
+ (PCRRecordTool *)shareManager;
- (void)startRecord;
- (void)stopRecord;
//结束录音
- (void)stopRecordWithBlock:(PCRRecordToolBlock)_backBlock;

@property (nonatomic , weak) id<PCRRecordToolDelegate>delegate;


@end
