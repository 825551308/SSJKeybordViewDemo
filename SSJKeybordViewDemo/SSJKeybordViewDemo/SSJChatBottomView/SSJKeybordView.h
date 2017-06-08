//
//  SSJKeybordView.h
//  录音播放
//
//  Created by 金汕汕 on 16/9/11.
//  Copyright © 2016年 ccs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceholderTextView.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
//#import "PCRPlayMusicFile.h"//播放录音
#import "PCRRecordTool.h"

#import "SSGiftCollectionViewFlowLayout.h"

#import "ExpressionEvePageView.h"

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

@protocol SSJKeybordViewDelegate <NSObject>
/** 更新聊天tableview的bottom约束 */
- (void)updateChatTbBottom:(CGFloat)val;

/** 调用系统相册 */
- (void)chooseFromAlbum;

/** 调用系统相机 */
- (void)openCamera;

/** 发送文字 */
- (void)sendText:(NSString *)text;

/** 录音结束 */
- (void)recordEnd:(NSString *)recordPath recordTime:(NSString *)recordTime;

/** 当whetherRoomChat 为 YES,且一旦输入@就调用此代理 */
- (void)whriteAtChar;

/**
 *  当删除的字符是@字符串之间的 那就告诉vc  这个名字失效了
 *
 *  @param removedName <#removedName description#>
 */
- (void)atRemoved:(NSString *)removedName;

@end



@interface SSJKeybordView : UIView<UITextViewDelegate,PCRRecordToolDelegate,ExpressionEvePageViewDelegate,UIAlertViewDelegate>

#pragma mark -- Publick
/** 输入框 */
@property (weak, nonatomic) IBOutlet PlaceholderTextView *inputTextView;

/** 输入框默认提示文字 */
@property (strong, nonatomic) NSString *placeholderValue;

/** 是否群聊 默认NO ，群聊才有@功能*/
@property (assign, nonatomic) BOOL  whetherRoomChat;



#pragma mark -- Method
+ (SSJKeybordView *)instanceSSJKeybordView;

@property (nonatomic,weak) id<SSJKeybordViewDelegate>delegate;

/**
 *  收回高度
 */
- (void)recoverInputHeight;
/**
 *  将带"[]"格式的字符串替换成表情 并返回NSMutableAttributedString
 *
 *  @param text 带"[]"格式的字符串
 *
 *  @return NSMutableAttributedString
 */
+ (NSMutableAttributedString *)dealWithString:(NSString *)text;

+ (NSDictionary *)emojis;
@end

#pragma mark -- 文本信息类
@interface TextSegment : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign, getter=isSpecial) BOOL special;
@property (nonatomic, assign, getter=isEmotion) BOOL emotion;

@end


#pragma mark -- 使用方式
/*
- (void)viewDidAppear:(BOOL)animated{
    //添加底部栏
    if (!self.keybordView) {
        _keybordView = [SSJKeybordView instanceSSJKeybordView];
        _keybordView.frame = CGRectMake(0, self.view.frame.size.height-64-inputViewHeight, self.view.frame.size.width, inputViewHeight+100);
        _keybordView.delegate = self;
        _keybordView.whetherRoomChat = YES;
        _keybordView.placeholderValue = @"我要回复";
        [self.view addSubview:_keybordView];
    }
}
*/



