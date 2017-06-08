//
//  SSJKeybordViewConfig.h
//  MobileApplicationPlatform
//
//  Created by 金汕汕 on 17/6/8.
//  Copyright © 2017年 HCMAP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SSJKeybordViewConfig : NSObject
/** 表情图片名字数组 */
@property (nonatomic , strong) NSMutableArray *emojiFlagArr;
/** ios显示表情标示符  只用于iOS设置展示 */
@property (nonatomic, strong) NSArray *emojiFlagArrIOS;
/** 表情图片名字数组 */
@property (nonatomic , strong) NSMutableArray *emotionArr;

+ (SSJKeybordViewConfig *)shareManager;

//搜索指定的字符   并返回所搜到的所有位置集合
- (NSMutableArray *)searchCharFromString:(NSString *)searchStrSource  searChar:(NSString *)searChar;
/**
 *  将输入的内容转变成通用的    iOS显示的[得意]  转成  [smiley_1]
 */
- (NSString *)emojiFlagArrIOSToEmojiFlagArr:(NSString *)text;


////获取默认表情数组
+ (NSDictionary *)emojis;

//将带"[]"格式的字符串替换成表情 并返回NSMutableAttributedString
+ (NSMutableAttributedString *)dealWithString:(NSString *)text;
@end



#pragma mark -- 文本信息类
@interface TextSegment : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign, getter=isSpecial) BOOL special;
@property (nonatomic, assign, getter=isEmotion) BOOL emotion;

@end


#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height-64

#define recordAnimateViewWidth 130
#define recordAnimateViewHeight 130


/** 输入框高度 */
static CGFloat const inputViewHeight = 50;
static CGFloat const inputViewHeightMax = 80;

static CGFloat const keyBoardHeight = 216;

static CGFloat const expressionScrollerViewHeight = 176;
static CGFloat const expressionSendButtonWidth = 40;
static CGFloat const expressionSendButtonHeight = 30;

static CGFloat const expressionBtnWidth = 40;
static CGFloat const animateWithDurationVal = 0.25;

//屏幕大小尺寸
#define screen_width [UIScreen mainScreen].bounds.size.width
/**
 *  IM模块／聊天键盘     当用户输入@之后 选择了人员之后 调用此通知 告诉聊天键盘人员的name
 */
#define NoticeAppContainerSSJKeybordView_selectedName @"appContainerNoticeAppContainerSSJKeybordView_selectedName"

typedef NS_ENUM(NSUInteger, ShowMoreType) {
    /** 默认状态:键盘 表情等收回  输入框在底部 */
    ShowMoreTypeOfOff = 0,
    /** 模式一：键盘弹出 */
    ShowMoreTypeOfOne = 1,
    /** 模式二：键盘收回    选择界面出现 */
    ShowMoreTypeOfTwo = 2,
    /** 模式三：表情键盘弹出 */
    ShowMoreTypeOfKeyBoard = 3,
    /** 模式四：录音键盘弹出 */
    ShowMoreTypeOfRecord = 4
};

#define App_Height [[UIScreen mainScreen] bounds].size.height //主屏幕的高度
#define App_Width  [[UIScreen mainScreen] bounds].size.width  //主屏幕的宽度