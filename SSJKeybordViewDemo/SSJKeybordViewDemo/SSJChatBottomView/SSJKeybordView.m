//
//  SSJKeybordView.m
//  录音播放
//
//  Created by 金汕汕 on 16/9/11.
//  Copyright © 2016年 ccs. All rights reserved.
//


/**
 *  表情选择栏采用自定义的90张图片 图片名字分别是smiley_0 ~  smiley_90   对应的描述文字是[smiley_0] ~  [smiley_90]
 *  所以用了两个数组      arrEmotion：表情图片名字数组                  emojiFlagArr：表情描述文字数组
 *  每一个表情都是ExpressionEvePageView上的一个button按钮
 */


#import "SSJKeybordView.h"
#import "JZMTBtnView.h"
#import "SSJRecordAnimateView.h"
#import "RegexKitLite.h"
#import "UIButton+EnlargeTouchArea.h"
#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height-64

#define recordAnimateViewWidth 130
#define recordAnimateViewHeight 130

@implementation TextSegment

@end

@interface SSJKeybordView()

#pragma mark -- UI
/** 表情scroll区域视图 */
@property (nonatomic , strong) UIScrollView *expressionScrollerView;
/** 表情滚动 */
@property (nonatomic , strong) ExpressionEvePageView *leftPageView;
@property (nonatomic , strong) ExpressionEvePageView *centerPageView;
@property (nonatomic , strong) ExpressionEvePageView *rightPageView;

@property (nonatomic, strong) UIView *backView1;
@property (nonatomic, strong) UIView *backView2;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputTextViewHeight_LayoutConstraint;
/** 底部线条 */
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
/** 相册、视频 选择view */
@property (weak, nonatomic) IBOutlet UIView *listView;
/** 录音切换按钮 */
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
/** 表情切换按钮 */
@property (weak, nonatomic) IBOutlet UIButton *expressionButton;
/** 选择更多切换按钮（加号） */
@property (weak, nonatomic) IBOutlet UIButton *selectMoreButton;
/** 开始录音按钮 */
@property (weak, nonatomic) IBOutlet UIButton *recordActionButton;
/** 表情视图 */
@property (weak, nonatomic) IBOutlet UIView *expressionView;
/** 翻页控件 */
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
/** 工具view */
@property (weak, nonatomic) IBOutlet UIView *keyBoardUIView;
/** 工具view高度约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyBoardUIViewLayoutHeight;


#pragma mark -- Paramert
/** 记录结束编辑之前的NSRange */
@property (nonatomic , assign)  NSRange range;

/** 总页数 */
@property (nonatomic , assign) NSInteger pageSum;
/** 录音地址 */
@property (nonatomic , assign) NSString *recordPath;
/** ios显示表情标示符  只用于iOS设置展示 */
@property (nonatomic, strong) NSArray *emojiFlagArrIOS;
/** 是否编辑状态 默认NO:非编辑状态(键盘收回) */
@property (assign, nonatomic) BOOL isEditing;
/** 记录当前的状态，具体看类型注释 */
@property (assign, nonatomic) ShowMoreType isShowMoreEditing;
/** 记录键盘的高度 */
@property (assign, nonatomic) CGFloat keyboardHeight;

/** 表情按钮宽度 */
@property (nonatomic , assign) float  expressionBtnR;
/** 表情图片名字数组 */
@property (nonatomic , strong) NSMutableArray *arrEmotion;
/** 表情标示符  请求交互时用到 */
@property (nonatomic, strong) NSArray *emojiFlagArr;

/** 记录表情scrollView起始x位置 */
@property (nonatomic, assign)  float historyX;
/** 记录当前页数 */
@property (nonatomic, assign)  float currentPage;
/** 记录之前文字的size */
@property (nonatomic, assign)  CGSize lastSize;
/******************@处理**************** Head ****/
/**
 *  记录每一个@的位置  ／ 可被覆盖
 */
@property (nonatomic,assign) NSUInteger contentAtLocation;

/**
 *  存储@字符串的位置数组 （	结构： [ @{“张三”:[3,6]} , @{“李四”:[8,11]}  ]  	 	）
 */
@property (nonatomic,strong) NSMutableArray *atMuArray;
/******************@处理*************** End *****/
/** 记录当前keyBoardUIView的高度 */
@property (nonatomic,assign) CGFloat currentFrameHeight;

@property (nonatomic,strong) NSDictionary *emojis;
@end

@implementation SSJKeybordView
static SSJRecordAnimateView *recordAnimateView;
static UIView *recordAnimateBackgroundWindowView;//recordAnimateView的背景view
#pragma mark -- 界面初始化

+ (SSJKeybordView *)instanceSSJKeybordView
{
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"SSJKeybordView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}


- (void)kCreatView{
    /**设置 开始录音 的边框*/
    self.recordActionButton.layer.borderWidth = 1;
    self.recordActionButton.layer.borderColor = [[UIColor groupTableViewBackgroundColor] CGColor];
    self.recordActionButton.hidden = TRUE;//默认是隐藏的
    
    NSMutableArray *titleArray = [[NSMutableArray alloc]initWithArray:@[@"相册",@"相机"]];
    NSMutableArray *imgArray = [[NSMutableArray alloc]initWithArray:@[@"IM_PIC",@"IM_Photograph"]];
    
    [self buidliew:titleArray imgArray:imgArray numberOfEveLine:4 senderVC:self];
    
    [self initData];
    /**增加监听，当键盘改变时收出消息*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self.recordActionButton setEnlargeEdgeWithTop:0 right:0 bottom:0 left:0];
}



- (void)awakeFromNib{
    /**增加监听，当键盘出现时收出消息*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
    
    [self kCreatView];
    
    self.currentFrameHeight = inputViewHeight;
    self.arrEmotion = [[NSMutableArray alloc]initWithArray:[self customEmojiDescribeArr]];
    /**< 创建每个表情按钮的宽度 */
    self.expressionBtnR = expressionBtnWidth;
    [self createExpressionBtnR];//默认表情宽度是宏定义expressionBtnWidth，但如果（默认表情宽度 * 一行的表情个数）不等于屏幕宽度 那就均分屏幕表情宽度
    
    self.inputTextView.layoutManager.allowsNonContiguousLayout=NO;
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**
 *  创建功能view
 *
 *  @param titleArray           名字数组
 *  @param imgArray             图片名字数组
 *  @param numberOfEveLineValue 每一行的个数
 *  @param senderVC             代理
 */
- (void)buidliew:(NSMutableArray *)titleArray imgArray:(NSMutableArray *)imgArray numberOfEveLine:(int)numberOfEveLineValue  senderVC:(id)senderVC{
    
    _backView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Width, 160)];
    _backView2 = [[UIView alloc] initWithFrame:CGRectMake(App_Width, 0, App_Width, 160)];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, App_Width, 180)];
    scrollView.contentSize = CGSizeMake(2*App_Width, 180);
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    [scrollView addSubview:_backView1];
    [scrollView addSubview:_backView2];
    
    [self.listView addSubview:scrollView];
    
    //创建
    for (int i = 0; i < titleArray.count; i++) {
        CGRect frame = CGRectMake(i*App_Width/numberOfEveLineValue, 0, App_Width/numberOfEveLineValue, 80);
        NSString *title = titleArray[i];
        NSString *imageStr = imgArray[i];
        JZMTBtnView *btnView = [[JZMTBtnView alloc] initWithFrame:frame title:title imageStr:imageStr];
        btnView.tag = 10+i;
        
        [_backView1 addSubview:btnView];
        
        //添加触摸事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnTapBtnView:)];
        [btnView addGestureRecognizer:tap];
        
    }
    
    
    if (titleArray.count <= numberOfEveLineValue) {
        
        scrollView.scrollEnabled = FALSE;
    }
}


#pragma mark -- set方法
- (void)setFrame:(CGRect)frame{
    NSLog(@"%f",App_Height);
    if (_isShowMoreEditing > 0) {//如果是加号操作 不需要改变输入框的frame
        frame.origin.y = (App_Height-64)-self.keyboardHeight-self.currentFrameHeight;
    }else{
        
        frame.origin.y = (App_Height-64)-self.keyboardHeight-self.currentFrameHeight;
    }
    [UIView animateWithDuration:animateWithDurationVal animations:^{
        [super setFrame:frame];
    } completion:^(BOOL finished) {
        if (self.keyboardHeight == 0) {
            self.listView.hidden = TRUE;//先隐藏相册 视频 视图
            self.expressionView.hidden = TRUE;//将表情视图隐藏
        }
    }];
    
}

- (void)setPlaceholderValue:(NSString *)placeholderValue{
    _inputTextView.placeholder = placeholderValue;
}

- (void)setWhetherRoomChat:(BOOL)whetherRoomChat{
    _whetherRoomChat = whetherRoomChat;
    /* 注册通知 由键盘调用的viewcontroller 告诉当前view @之后输入的人员名字 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAtName:) name:NoticeAppContainerSSJKeybordView_selectedName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ssjTextDidChangeNotification:) name:UITextViewTextDidChangeNotification object:nil];
    
}

- (NSMutableArray *)atMuArray{
    if (!_atMuArray) {
        _atMuArray = [[NSMutableArray alloc]init];
    }
    return _atMuArray;
}

/** 创建表情宽度 */
- (void)createExpressionBtnR{
    int widNum = (int) App_Width / (self.expressionBtnR);//一行表情个数
    if (widNum *(self.expressionBtnR)  == App_Width) {
        
    }else{
        self.expressionBtnR = (App_Width - widNum *(self.expressionBtnR) ) / widNum  + self.expressionBtnR;
    }
    
}


#pragma mark -- 重置按钮状态
- (void)resetAllButtonState{
    if (!self.listView.hidden) {
        self.listView.hidden = TRUE;//先隐藏相册 视频 视图
        [self.selectMoreButton setBackgroundImage:[UIImage imageNamed:@"+"] forState:UIControlStateNormal];//将选择更多按钮图片重置
    }
    /**录音按钮  开始录音按钮 重置*/
    [self.recordButton setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
    self.inputTextView.hidden = FALSE;//取消隐藏 输入框
    self.bottomLine.hidden = FALSE;//取消隐藏 底部线条
    self.recordActionButton.hidden = TRUE;//显示 开始录音按钮
    
    if (!self.expressionView.hidden) {
        self.expressionView.hidden = TRUE;//先隐藏表情视图
        [self.expressionButton setBackgroundImage:[UIImage imageNamed:@"expression"] forState:UIControlStateNormal];//将表情按钮图片重置
    }
    
    _isShowMoreEditing = ShowMoreTypeOfOff;
}


#pragma mark -- 键盘通知
//当键盘出现 －－ 通知
- (void)keyboardWillShow:(NSNotification *)aNotification{
    /**获取键盘的高度*/
    NSValue *aValue = [[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    if (keyboardRect.size.height > self.keyboardHeight) {
        self.keyboardHeight = keyboardRect.size.height;
    }
    
    _isEditing = YES;
    if (self.currentFrameHeight != 0 ) {
        self.frame = CGRectMake(0, App_Height-64-self.currentFrameHeight-64, App_Width, self.currentFrameHeight);
    }else{
        self.frame = CGRectMake(0, App_Height-64-self.keyboardHeight-64, App_Width, inputViewHeight);
    }
    if ([self.delegate respondsToSelector:@selector(updateChatTbBottom:)]) {
        [self.delegate updateChatTbBottom:self.keyboardHeight+self.currentFrameHeight];
    }else{
        NSLog(@"未实现代理方法:updateChatTbBottom");
    }
    
    
}

//当键盘改变 －－ 通知
- (void)keyboardWillChangeFrame:(NSNotification *)aNotification{
    NSValue *aValue = [[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    self.keyboardHeight = keyboardRect.origin.y;
    self.keyboardHeight = App_Height-64 - (keyboardRect.origin.y-64);
    
    if (self.keyboardHeight > 0) {
        _isEditing = YES;
    }else{
        _isEditing = NO;
    }
    
    self.frame = CGRectMake(0, keyboardRect.origin.y - self.currentFrameHeight, App_Width, self.currentFrameHeight);
    
    if ([self.delegate respondsToSelector:@selector(updateChatTbBottom:)]) {
        [self.delegate updateChatTbBottom:self.keyboardHeight + inputViewHeight];
    }else{
        NSLog(@"未实现代理方法:updateChatTbBottom");
    }
}

- (void)ssjTextDidChangeNotification:(NSNotification *)aNotification{
    /* 检查删除self.atMuArray */
    [self removeFromAtMuArray];
}

#pragma mark -- 遍历self.atMuArray    搜索每个元素在self.inputTextView.text内是否存在 如果不存在就删除 并通知delegate
- (void)removeFromAtMuArray{
    for (int i = 0 ; i < self.atMuArray.count; i++) {
        NSString *eveName = self.atMuArray[i];
        if ([self.inputTextView.text rangeOfString:eveName].location == NSNotFound) {
            //如果找不到就移除
            [self.atMuArray removeObjectAtIndex:i];
            if ([self.delegate respondsToSelector:@selector(atRemoved:)]) {
                NSString *nameStr = [eveName substringWithRange:NSMakeRange(1, eveName.length-2)];
                [self.delegate atRemoved:nameStr];
            }
            break;
        }
    }
}

#pragma mark -- 点击事件
/**
 *  点击录音
 */
- (IBAction)showRecordVoiceClick:(id)sender{
    
    if (!self.listView.hidden) {
        self.listView.hidden = TRUE;//先隐藏相册 视频 视图
        [self.selectMoreButton setBackgroundImage:[UIImage imageNamed:@"+"] forState:UIControlStateNormal];//将选择更多按钮图片重置
    }
    if (!self.expressionView.hidden) {
        self.expressionView.hidden = TRUE;//先隐藏表情视图
        [self.expressionButton setBackgroundImage:[UIImage imageNamed:@"expression"] forState:UIControlStateNormal];//将表情按钮图片重置
    }
    
    if (_isShowMoreEditing == ShowMoreTypeOfRecord) {//如果录音视图已经出现
        [self.recordButton setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
        [self.inputTextView becomeFirstResponder];//弹出键盘
        _isShowMoreEditing = ShowMoreTypeOfOne;
        self.inputTextView.hidden = FALSE;//取消隐藏 输入框
        self.bottomLine.hidden = FALSE;//取消隐藏 底部线条
        self.recordActionButton.hidden = TRUE;//显示 开始录音按钮
    }else{
        /**弹出录音视图*/
        [self.recordButton setBackgroundImage:[UIImage imageNamed:@"keyBoard"] forState:UIControlStateNormal];
        _isShowMoreEditing = ShowMoreTypeOfRecord;
        self.range = [self.inputTextView selectedRange];//记录光标位置
        [self endEditing:YES];
        self.inputTextView.hidden = TRUE;//隐藏 输入框
        self.bottomLine.hidden = TRUE;//隐藏 底部线条
        self.recordActionButton.hidden = FALSE;//显示 开始录音按钮
        self.keyboardHeight = 0;//录音的时候 应该在底部
        self.frame = CGRectMake(0, App_Height-64-self.keyboardHeight-64, App_Width, self.currentFrameHeight);
        if ([self.delegate respondsToSelector:@selector(updateChatTbBottom:)]) {
            [self.delegate updateChatTbBottom:self.keyboardHeight+inputViewHeight];
        }else{
            NSLog(@"未实现代理方法:updateChatTbBottom");
        }
    }
}

/**
 *  点击表情
 */
- (IBAction)showExpressionClick:(id)sender {
    if (!self.listView.hidden) {
        self.listView.hidden = TRUE;//先隐藏相册 视频 视图
        [self.selectMoreButton setBackgroundImage:[UIImage imageNamed:@"+"] forState:UIControlStateNormal];//将选择更多按钮图片重置
    }
    //录音按钮  开始录音按钮 重置
    [self.recordButton setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
    self.inputTextView.hidden = FALSE;//取消隐藏 输入框
    self.bottomLine.hidden = FALSE;//取消隐藏 底部线条
    self.recordActionButton.hidden = TRUE;//显示 开始录音按钮
    
    
    if (_isShowMoreEditing == ShowMoreTypeOfKeyBoard) {//如果表情键盘已经出现
        [self.inputTextView becomeFirstResponder];//弹出键盘
        _isShowMoreEditing = ShowMoreTypeOfOne;//将zhuangtai 改为键盘弹出
        self.expressionView.hidden = TRUE;//将表情视图隐藏
        [self.expressionButton setBackgroundImage:[UIImage imageNamed:@"expression"] forState:UIControlStateNormal];
        return;
    }else{
        //如果表情键盘未出现
        [self endEditing:YES];
        _isShowMoreEditing = ShowMoreTypeOfKeyBoard;//将zhuangtai 改为键盘弹出
        [self.expressionButton setBackgroundImage:[UIImage imageNamed:@"keyBoard"] forState:UIControlStateNormal];
        self.expressionView.hidden = FALSE;
        if(self.keyboardHeight == 0){
            self.keyboardHeight = keyBoardHeight;
        }
        //创建表情
        [self createExpressionScrollerView];
    }
    
    self.frame = CGRectMake(0, App_Height-64-(self.keyboardHeight-64), App_Width, inputViewHeight+self.keyboardHeight);
    
    if ([self.delegate respondsToSelector:@selector(updateChatTbBottom:)]) {
        [self.delegate updateChatTbBottom:self.keyboardHeight+inputViewHeight];
    }else{
        NSLog(@"未实现代理方法:updateChatTbBottom");
    }
    
}

#pragma mark -- 编辑结束后
- (void)textViewDidEndEditing:(UITextView *)textView{
    self.range = [self.inputTextView selectedRange];//记录光标位置 编辑结束后
}

/**
 *  点击加号
 */
- (IBAction)showMoreSelectClick:(id)sender {
    if (!self.expressionView.hidden) {
        self.expressionView.hidden = TRUE;//先隐藏表情视图
        [self.expressionButton setBackgroundImage:[UIImage imageNamed:@"expression"] forState:UIControlStateNormal];//将表情按钮图片重置
    }
    //录音按钮  开始录音按钮 重置
    [self.recordButton setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
    self.inputTextView.hidden = FALSE;//取消隐藏 输入框
    self.bottomLine.hidden = FALSE;//取消隐藏 底部线条
    self.recordActionButton.hidden = TRUE;//显示 开始录音按钮
    
    if (_isShowMoreEditing == ShowMoreTypeOfTwo) {//如果表情键盘已经出现
        //键盘出现
        _isShowMoreEditing = ShowMoreTypeOfOne;
        self.listView.hidden = TRUE;//将相册、视频 视图显示
        [self.inputTextView becomeFirstResponder];
    }else{
        //选择界面出现    此时应该收回键盘 并且显示图片、视频等选择视图
        _isShowMoreEditing = ShowMoreTypeOfTwo;
        self.listView.hidden = FALSE;//将相册、视频 视图显示
        self.range = [self.inputTextView selectedRange];//记录光标位置
        [self.inputTextView endEditing:YES];
        if(self.keyboardHeight == 0){
            self.keyboardHeight = keyBoardHeight;
        }
        self.frame = CGRectMake(0, App_Height-64-self.keyboardHeight-64, App_Width, inputViewHeight+self.keyboardHeight);
    }
    
    if ([self.delegate respondsToSelector:@selector(updateChatTbBottom:)]) {
        [self.delegate updateChatTbBottom:self.keyboardHeight+inputViewHeight];
    }else{
        NSLog(@"未实现代理方法:updateChatTbBottom");
    }
    
}

/**
 *  每一个功能点击（相册、相机、小视频）
 */
-(void)OnTapBtnView:(UITapGestureRecognizer *)sender{
    NSString *msg=[NSString stringWithFormat:@"%ld",(long)sender.view.tag];
    
    NSLog(@"tag:%d",(int)sender.view.tag);
    
    switch ([msg integerValue]-10) {
        case 0:
        {
            NSLog(@"调用相册");
            if ([self.delegate respondsToSelector:@selector(chooseFromAlbum)]) {
                [self.delegate chooseFromAlbum];
            }else{
                NSLog(@"未实现代理方法:chooseFromAlbum");
            }
            
        }
            break;
            
        default:
        {
            NSLog(@"调用相机");
            if ([self.delegate respondsToSelector:@selector(openCamera)]) {
                [self.delegate openCamera];
            }else{
                NSLog(@"未实现代理方法:openCamera");
            }
        }
            break;
    }
}

#pragma mark -- 表情栏发送按钮
- (void)senBtnTouchUpInSide:(id)sender{
    if ([self.delegate respondsToSelector:@selector(sendText:)]) {
        [self.delegate sendText:[self emojiFlagArrIOSToEmojiFlagArr:self.inputTextView.text]];
    }else{
        NSLog(@"未实现代理方法:sendText");
    }
    
    /**< 恢复self高度 */
    self.currentFrameHeight = inputViewHeight;
    [self recoverInputHeight];
    [self endEditing:YES];
    self.keyBoardUIViewLayoutHeight.constant = inputViewHeight;
    [self.keyBoardUIView layoutIfNeeded];
    
    self.inputTextView.text = @"";
    self.inputTextView.PlaceholderLabel.hidden = FALSE;
    _range = NSMakeRange(self.inputTextView.text.length,0);
    self.inputTextViewHeight_LayoutConstraint.constant = 28.0;
    [self.inputTextView layoutIfNeeded];
    /*当点击发送的时候 不需要收回下面的高度*/
    //    [self resetAllButtonState];
    //    self.keyboardHeight = 0;
    //    self.frame = CGRectMake(0, App_Height-64-self.keyboardHeight-64, App_Width, inputViewHeight);
    
    [self.atMuArray removeAllObjects];
}

#pragma mark - ******************** 录音方法
- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    return bCanRecord;
}
- (IBAction)startRecord:(id)sender {
    if (![self canRecord]) {
        //[UIAlertView alert:@"提示" msg:@"麦克风权限受限" ];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"麦克风权限受限" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    NSLog(@"开始录音");
    [self buildRecordAnimateView];//创建录音动画view 并将它加到window上
    [self recordButtonHandel:sender];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 1://确定按钮点击
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
            break;
            
        default:
            break;
    }
}

/** 按下之后再抬起 */
- (IBAction)inside:(id)sender {
    [self stopRecord:sender];
}

/** 所有触摸取消事件，即一次触摸因为放上了太多手指而被取消，或者被上锁或者电话呼叫打断。 */
- (IBAction)touchCancel:(id)sender {
    [self stopRecord:sender];
}

/** 移动出去 */
- (IBAction)touchDragExit:(id)sender {
    [self stopRecord:sender];
}


/** 当文本控件内通过按下回车键（或等价行为）结束编辑时，发送通知。 */
- (IBAction)disEndOnExit:(id)sender {
    [self stopRecord:sender];
}

/** 所有在控件之外触摸抬起事件(点触必须开始与控件内部才会发送通知)。 以及所有的取消*/
- (IBAction)stopRecord:(id)sender {
    [recordAnimateView updateRecordAnimateViewEnd];//结束动画
    [recordAnimateBackgroundWindowView removeFromSuperview];//从window上移除
    [self resetAllButtonState];//重置按钮状态
    
    NSLog(@"获得录音文件路径:%@",[PCRRecordTool shareManager].urlStr);
    self.recordPath = [PCRRecordTool shareManager].urlStr;
    //    [UIAlertView alert:@"录音地址" msg:self.recordPath];
    
    //关闭录音
    [[PCRRecordTool shareManager] stopRecordWithBlock:^{
        //如果录音时长大于1秒
        if ([PCRRecordTool shareManager].countDown <= (countDownMaxFloat - countDownMinFloat)) {
            if([self.delegate respondsToSelector:@selector(recordEnd:recordTime:)]){
                [self.delegate recordEnd:[self.recordPath componentsSeparatedByString:@"/"].lastObject recordTime:[NSString stringWithFormat:@"%f",roundf((countDownMaxFloat - [PCRRecordTool shareManager].countDown))] ];
                //                            [UIAlertView alert:@"stopRecord得到的录音time" msg:[NSString stringWithFormat:@"%f",roundf((60 - [PCRRecordTool shareManager].countDown))] ];
            }else{
                NSLog(@"没有实现recordEnd代理");
            }
            
        }
    }];
    
}

//录音超时时调用
- (void)recordTimeOut:(NSString *)pathStr{
    [recordAnimateView updateRecordAnimateViewEnd];//结束动画
    [recordAnimateBackgroundWindowView removeFromSuperview];//从window上移除
    [self resetAllButtonState];//重置按钮状态
    
    self.recordPath = pathStr;
    if([self.delegate respondsToSelector:@selector(recordEnd:recordTime:)]){
        float timeF = roundf((countDownMaxFloat - [PCRRecordTool shareManager].countDown));
        timeF = timeF > countDownMaxFloat ?(countDownMaxFloat):(timeF);
        [self.delegate recordEnd:[self.recordPath componentsSeparatedByString:@"/"].lastObject recordTime:[NSString stringWithFormat:@"%f",timeF] ];
    }else{
        NSLog(@"没有实现recordEnd代理");
    }
    //关闭录音
    [[PCRRecordTool shareManager] stopRecordWithBlock:^{
        
    }];
    
    //    [self.pCRPlayMusicFile buildAudioPlayer:[PCRRecordTool shareManager].urlStr];
    //    [self.pCRPlayMusicFile play];
}

#pragma mark - 创建录音动画view 并将它加到window上
- (void)buildRecordAnimateView{
    if (!recordAnimateBackgroundWindowView) {
        recordAnimateBackgroundWindowView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screen_width, [UIScreen mainScreen].bounds.size.height) ];
        recordAnimateBackgroundWindowView.backgroundColor = [UIColor clearColor];
    }
    if (recordAnimateView == nil) {
        recordAnimateView = [SSJRecordAnimateView new];
        [recordAnimateView createView:recordAnimateViewWidth selfHeight:recordAnimateViewHeight];
        recordAnimateView.frame = CGRectMake( (screenWidth-recordAnimateViewWidth)/2, (screenHeight-recordAnimateViewWidth)/2, recordAnimateViewWidth, recordAnimateViewHeight);
        recordAnimateView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5 ];
        recordAnimateView.layer.cornerRadius = 6.0;
    }
    //添加到window
    [recordAnimateBackgroundWindowView addSubview:recordAnimateView];
    [[UIApplication sharedApplication].keyWindow addSubview:recordAnimateBackgroundWindowView];
}

/******************************************************************************************************************************/


/**
 *  设置音频会话
 */
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}
//录音
- (void)recordButtonHandel:(id)sender {
    [PCRRecordTool shareManager].delegate=self;
    [[PCRRecordTool shareManager] startRecord];
}

/*******End************************录音*****************************/


#pragma mark-PCRRecordToolDelegate   时时获取录音测量值
- (void)updateMetersMethod:(CGFloat)floatValue{
    NSLog(@"录音测量：%f",floatValue);
    //    [self.progressView setProgress:floatValue animated:YES];
    //7张图片
    float eveVal = 1.00 / 7;
    
    NSString *imgNameStr = @"";
    if (floatValue > 7 * eveVal) {
        imgNameStr = @"tq";
    }else if (floatValue > 6 * eveVal) {
        imgNameStr = @"tp";
    }else if (floatValue > 5 * eveVal) {
        imgNameStr = @"to";
    }else if (floatValue > 4 * eveVal) {
        imgNameStr = @"tn";
    }else if (floatValue > 3 * eveVal) {
        imgNameStr = @"tm";
    }else if (floatValue > 2 * eveVal) {
        imgNameStr = @"tl";
    }else if (floatValue > 1 * eveVal) {
        imgNameStr = @"tk";
    }else{
        imgNameStr = @"";
    }
    
    [recordAnimateView updateRecordAnimateViewBcgImg:imgNameStr];
}



//#pragma mark-PCRPlayMusicFileDelegate   更新进度条
//- (void)updateProgress:(float)progressFloat{
//    NSLog(@"播放进度：%f",progressFloat);
//    //    [self.progressView setProgress:progressFloat animated:YES];
//}
//- (void)updateProgressEnd{
//    [_recordActionButton setTitle:@"按住  说话" forState:UIControlStateNormal];
//    //    [recordAnimateView updateRecordAnimateViewEnd];
//    //    [self.progressView setProgress:0.0 animated:YES];
//}

/******************************************************************************************************************************/



/*******************************/
// 初始化表情标识符－－描述文字
- (void)initData{
    if (!_emojiFlagArr) {
        _emojiFlagArr = self.emojis[@"emojiFlagArr"];
    }
    if (!_emojiFlagArrIOS) {
        _emojiFlagArrIOS = self.emojis[@"emojiFlagArrIOS"];
    }
}
//将数字转为
#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);
////获取默认表情数组
- (NSDictionary *)emojis{
    static NSDictionary *__emojis = nil;
    if (!__emojis){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"json"];
        NSData *emojiData = [[NSData alloc] initWithContentsOfFile:path];
        __emojis = [NSJSONSerialization JSONObjectWithData:emojiData options:NSJSONReadingAllowFragments error:nil];
    }
    return __emojis;
}
////获取默认表情数组
+ (NSDictionary *)emojis{
    static NSDictionary *__emojis = nil;
    if (!__emojis){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"json"];
        NSData *emojiData = [[NSData alloc] initWithContentsOfFile:path];
        __emojis = [NSJSONSerialization JSONObjectWithData:emojiData options:NSJSONReadingAllowFragments error:nil];
    }
    return __emojis;
}

//创建数组－－自定义表情图片名
- (NSArray *)customEmojiDescribeArr{
    NSArray *emojiImgNameArr = @[@"smiley_0",@"smiley_1",@"smiley_2",@"smiley_3",@"smiley_4",@"smiley_5",@"smiley_6",@"smiley_7",@"smiley_8",@"smiley_9",@"smiley_10",@"smiley_11",@"smiley_12",@"smiley_13",@"smiley_14",@"smiley_15",@"smiley_16",@"smiley_17",@"smiley_18",@"smiley_19",@"smiley_20",@"smiley_21",@"smiley_22",@"smiley_23",@"smiley_24",@"smiley_25",@"smiley_26",@"smiley_27",@"smiley_28",@"smiley_29",@"smiley_30",@"smiley_31",@"smiley_32",@"smiley_33",@"smiley_34",@"smiley_35",@"smiley_36",@"smiley_37",@"smiley_38",@"smiley_39",@"smiley_40",@"smiley_41",@"smiley_42",@"smiley_43",@"smiley_44",@"smiley_45",@"smiley_46",@"smiley_47",@"smiley_48",@"smiley_49",@"smiley_50",@"smiley_51",@"smiley_52",@"smiley_53",@"smiley_54",@"smiley_55",@"smiley_56",@"smiley_57",@"smiley_58",@"smiley_59",@"smiley_60",@"smiley_61",@"smiley_62",@"smiley_63",@"smiley_64",@"smiley_65",@"smiley_66",@"smiley_67",@"smiley_68",@"smiley_69",@"smiley_70",@"smiley_71",@"smiley_72",@"smiley_73",@"smiley_74",@"smiley_75",@"smiley_76",@"smiley_77",@"smiley_78",@"smiley_79",@"smiley_80",@"smiley_81",@"smiley_82",@"smiley_83",@"smiley_84",@"smiley_85",@"smiley_86",@"smiley_87",@"smiley_88",@"smiley_89"];
    return emojiImgNameArr;
}

/********************************************/

- (void)createExpressionScrollerView{
    if (_expressionScrollerView == nil) {
        /**在将对应数组里的表情依次存放到UIButton里，贴出部分代码：*/
        UIView *backView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Width, 160)];
        UIView *backView4 = [[UIView alloc] initWithFrame:CGRectMake(App_Width, 0, App_Width, 160)];
        _expressionScrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, App_Width, expressionScrollerViewHeight)];
        
        _expressionScrollerView.pagingEnabled = YES;
        _expressionScrollerView.delegate = self;
        _expressionScrollerView.showsHorizontalScrollIndicator = NO;
        
        [_expressionScrollerView addSubview:backView3];
        [_expressionScrollerView addSubview:backView4];
        
        //将表情放到UIButton里
        
        //获取数组
        
        int widNum = (int) App_Width / (self.expressionBtnR);//一行表情个数
        int heightNum = expressionScrollerViewHeight / (self.expressionBtnR);//一列表情行数
        float heightTop ;
        if (heightNum *self.expressionBtnR  == expressionScrollerViewHeight) {
            
            heightTop = 0;
        }else{
            heightTop = (expressionScrollerViewHeight - heightNum *self.expressionBtnR)*1.0/2;
        }
        
        _pageSum = self.emojiFlagArr.count % (widNum*4) == 0 ? (self.emojiFlagArr.count / (widNum*4) ) : ( self.emojiFlagArr.count / (widNum*4) + 1 ) ;
        _expressionScrollerView.contentSize = CGSizeMake(App_Width * _pageSum, expressionScrollerViewHeight);
        _pageControl.numberOfPages  = _pageSum;
        if (_pageSum > 2) {
            _leftPageView = [ExpressionEvePageView new];
            [_leftPageView createView:self.arrEmotion page:0];
            _leftPageView.frame = CGRectMake(0, 0, App_Width, expressionScrollerViewHeight) ;
            _leftPageView.delegate = self;
            [_expressionScrollerView addSubview:_leftPageView];
            
            _centerPageView = [ExpressionEvePageView new];
            [_centerPageView createView:self.arrEmotion page:1];
            _centerPageView.frame = CGRectMake(App_Width, 0, App_Width, expressionScrollerViewHeight) ;
            _centerPageView.delegate = self;
            [_expressionScrollerView addSubview:_centerPageView];
            
            _rightPageView = [ExpressionEvePageView new];
            [_rightPageView createView:self.arrEmotion page:2];
            _rightPageView.frame = CGRectMake(App_Width*2, 0, App_Width, expressionScrollerViewHeight) ;
            _rightPageView.delegate = self;
            [_expressionScrollerView addSubview:_rightPageView];
        }else  if (_pageSum > 1) {
            _leftPageView = [ExpressionEvePageView new];
            [_leftPageView createView:self.arrEmotion page:0];
            _leftPageView.frame = CGRectMake( 0 , 0, App_Width, expressionScrollerViewHeight) ;
            _leftPageView.delegate = self;
            [_expressionScrollerView addSubview:_leftPageView];
            
            _centerPageView = [ExpressionEvePageView new];
            [_centerPageView createView:self.arrEmotion page:1];
            _centerPageView.frame = CGRectMake( App_Width, 0, App_Width, expressionScrollerViewHeight) ;
            _centerPageView.delegate = self;
            [_expressionScrollerView addSubview:_centerPageView];
        }else{
            _leftPageView = [ExpressionEvePageView new];
            [_leftPageView createView:self.arrEmotion page:0];
            _leftPageView.frame = CGRectMake(0, 0, App_Width, expressionScrollerViewHeight) ;
            _leftPageView.delegate = self;
            [_expressionScrollerView addSubview:_leftPageView];
        }
        
        
        
        [self.expressionView addSubview:_expressionScrollerView];
        /**添加底部操作view**/
        UIView *expressionActionView = [[UIView alloc]initWithFrame:CGRectMake(0, expressionScrollerViewHeight, App_Width, keyBoardHeight-expressionScrollerViewHeight)];
        [self.expressionView setBackgroundColor:[UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:0.5]];
        [expressionActionView setBackgroundColor:[UIColor whiteColor]];
        [self.expressionView addSubview:expressionActionView];
        UIButton *sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(App_Width-expressionSendButtonWidth-5, 5, expressionSendButtonWidth, expressionSendButtonHeight)];
        [expressionActionView addSubview:sendBtn];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        [sendBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        sendBtn.layer.borderColor = [[UIColor blackColor] CGColor];
        
        [sendBtn addTarget:self action:@selector(senBtnTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside];
    }
}
#pragma mark -- scrollViewDelegate
//记录滑动起始X轴坐标
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if(scrollView == self.inputTextView){
        [self.inputTextView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];//设置UITextView的内边距
        [self.inputTextView setTextAlignment:NSTextAlignmentLeft];//并设置左对齐
        return;
    }
    _historyX = scrollView.contentOffset.x;
    
}


/** 只要滚动了就会触发 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //    CGFloat pageWidth = self.expressionScrollerView.frame.size.width;
    //    int page = floor((self.expressionScrollerView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (scrollView.contentOffset.x<_historyX) {
        if (self.currentPage > 0) {
            --self.currentPage;
        }
        NSLog(@"右滑动 %f",self.currentPage);
        self.pageControl.currentPage = self.currentPage; // 分页控制器当前显示的页数;
    } else if (scrollView.contentOffset.x>_historyX) {
        if (self.currentPage < _pageSum-1) {
            ++self.currentPage;
        }
        
        NSLog(@"左滑动 %f",self.currentPage);
        self.pageControl.currentPage = self.currentPage; // 分页控制器当前显示的页数;
    }
    
    if ((int)self.currentPage == 0) {
        [_leftPageView createView:self.arrEmotion page:0];
        [_centerPageView createView:self.arrEmotion page:1];
        [_rightPageView createView:self.arrEmotion page:2];
        [_expressionScrollerView setContentOffset:CGPointMake(0,0) animated:NO];
    }else
        
        if ((int)self.currentPage == _pageSum-1) {
            [_leftPageView createView:self.arrEmotion page:_pageSum-3];
            [_centerPageView createView:self.arrEmotion page:_pageSum-2];
            [_rightPageView createView:self.arrEmotion page:_pageSum-1];
            [_expressionScrollerView setContentOffset:CGPointMake(2*App_Width,0) animated:NO];
            
        }else{
            
            [_leftPageView createView:self.arrEmotion page:(int)self.currentPage-1];
            [_centerPageView createView:self.arrEmotion page:(int)self.currentPage];
            [_rightPageView createView:self.arrEmotion page:(int)self.currentPage+1];
            [_expressionScrollerView setContentOffset:CGPointMake(App_Width,0) animated:NO];
        }
}

#pragma mark -- UITextViewDelegate
#pragma mark -- 点击键盘－－发送
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (self.whetherRoomChat) {
        if ([text isEqualToString:@"@"]) {
            NSLog(@"输入了@");
            self.contentAtLocation = range.location;//记录@的位置
            if ([self.delegate respondsToSelector:@selector(whriteAtChar)]) {
                //调用代理
                [self.delegate whriteAtChar];
            }
        }
    }
    /**
     *  如果删除了@" "
     */
    if ([[textView.text substringWithRange:range] isEqualToString:@" "]) {
        NSRange range = self.inputTextView.selectedRange;
        NSString *searStr = [textView.text substringToIndex:range.location];
        //查找紧挨着的上一个"@"
        NSString *lastIndexStr = [self searchCharFromString:searStr searChar:@"@"].lastObject;
        NSString *headStr = [self.inputTextView.text substringToIndex:[lastIndexStr integerValue]];
        NSString *endStr = [self.inputTextView.text substringFromIndex:range.location];
        self.inputTextView.text = [NSString stringWithFormat:@"%@%@",headStr,endStr];
        //删除表情后 将光标位置往前挪一个 @字符串 的单位
        self.inputTextView.selectedRange = NSMakeRange([lastIndexStr integerValue],0);
        _range = NSMakeRange([lastIndexStr integerValue],0);
        /* 检查删除self.atMuArray */
        [self removeFromAtMuArray];
        return NO;
    }
    
    if ([[textView.text substringWithRange:range] isEqualToString:@"]"]) {
        NSRange range = self.inputTextView.selectedRange;
        NSString *searStr = [textView.text substringToIndex:range.location];
        //查找紧挨着的上一个"["
        NSString *lastIndexStr = [self searchCharFromString:searStr searChar:@"["].lastObject;
        NSString *headStr = [self.inputTextView.text substringToIndex:[lastIndexStr integerValue]];
        NSString *endStr = [self.inputTextView.text substringFromIndex:range.location];
        self.inputTextView.text = [NSString stringWithFormat:@"%@%@",headStr,endStr];
        //删除表情后 将光标位置往前挪一个表情的单位
        self.inputTextView.selectedRange = NSMakeRange([lastIndexStr integerValue],0);
        _range = NSMakeRange([lastIndexStr integerValue],0);
        return NO;
    }
    /**< 如果点击了键盘上的“回车”按钮 */
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(sendText:)]) {
            [self.delegate sendText:[self emojiFlagArrIOSToEmojiFlagArr:self.inputTextView.text]];
            [textView setContentInset:UIEdgeInsetsMake(4, -5, -15, 4)];//设置UITextView的内边距
        }else{
            NSLog(@"未实现代理方法:sendText");
        }
        /**< 恢复selfmoren高度 */
        self.currentFrameHeight = inputViewHeight;
        [self recoverInputHeight];
        [self endEditing:YES];
        self.keyBoardUIViewLayoutHeight.constant = inputViewHeight;
        [self.keyBoardUIView layoutIfNeeded];
        
        self.inputTextView.text = @"";
        self.inputTextView.PlaceholderLabel.hidden = FALSE;
        _range = NSMakeRange(self.inputTextView.text.length,0);
        self.inputTextViewHeight_LayoutConstraint.constant = 28.0;
        
        for (UIView *childView in self.keyBoardUIView.subviews) {
            [childView layoutIfNeeded];
        }
        
        [self.inputTextView layoutIfNeeded];
        /*当点击发送的时候 不需要收回下面的高度*/
        /*    [self resetAllButtonState];
            self.keyboardHeight = 0;
            self.frame = CGRectMake(0, App_Height-64-self.keyboardHeight-64, App_Width, inputViewHeight);
                [self endEditing:YES];
                [self resetAllButtonState];
        */
        [self.atMuArray removeAllObjects];
        return NO;
    }
//    if (text.length == 0) {
//        /**< 执行了删除 */
//        [self textViewDeleteAction];
//    }
    return YES;
}



-(void)textViewDidChange:(UITextView *)textView{
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length, 1)];
    //获取文本中字体的size
    CGSize size = [self.inputTextView sizeThatFits:CGSizeMake(self.inputTextView.frame.size.width, MAXFLOAT)];
    __weak SSJKeybordView *weakSelf = self;
    if (size.height > (inputViewHeightMax-18)) {//因为默认高度是32 而文字一行占用高度是16    所以要预留18的高度
        _lastSize = size;
        [UIView animateWithDuration:0.1 animations:^{
            weakSelf.keyBoardUIViewLayoutHeight.constant = inputViewHeightMax;
            [weakSelf.keyBoardUIView layoutIfNeeded];
            CGRect fr = weakSelf.frame;
            fr.origin.y = fr.origin.y - (size.height - 32);
            
            if (self.isShowMoreEditing == ShowMoreTypeOfKeyBoard || self.isShowMoreEditing == ShowMoreTypeOfRecord) {
                fr.size.height = inputViewHeightMax + self.keyboardHeight;
            }else{
                fr.size.height = inputViewHeightMax;
                
            }
            if (weakSelf.currentFrameHeight != inputViewHeightMax) {
                if ([self.delegate respondsToSelector:@selector(updateChatTbBottom:)]) {
                    [self.delegate updateChatTbBottom:inputViewHeightMax + self.keyboardHeight];
                }else{
                    NSLog(@"没有实现updateChatTbBottom代理");
                }
            }
            weakSelf.currentFrameHeight = inputViewHeightMax;
            weakSelf.frame = fr;
            weakSelf.inputTextViewHeight_LayoutConstraint.constant = inputViewHeightMax - 18;
            for (UIView *childView in weakSelf.keyBoardUIView.subviews) {
                [childView layoutIfNeeded];
            }
        } completion:^(BOOL finished) {
            /**< 防止粘贴文字后 内容显示不全（文字整体上移了） */
            [textView setContentInset:UIEdgeInsetsMake(5, -5, -15, 5)];//设置UITextView的内边距
            [textView scrollRangeToVisible:NSMakeRange(textView.text.length, 1)];
        }];
        
        return;
    }
    if (size.height > (inputViewHeight-18) && size.height < (inputViewHeightMax-18)) {
        [UIView animateWithDuration:0.1 animations:^{
            self.keyBoardUIViewLayoutHeight.constant = inputViewHeight + (size.height - 32);
            [self.keyBoardUIView layoutIfNeeded];
            CGRect fr = self.frame;
            fr.origin.y = fr.origin.y - (size.height - 32);
            if (self.isShowMoreEditing == ShowMoreTypeOfKeyBoard || self.isShowMoreEditing == ShowMoreTypeOfRecord) {
                fr.size.height = inputViewHeight + (size.height - 32) + self.keyboardHeight;
            }else{
                fr.size.height = inputViewHeight + (size.height - 32);
            }
            if (weakSelf.currentFrameHeight != inputViewHeight + (size.height - 32)) {
                if ([self.delegate respondsToSelector:@selector(updateChatTbBottom:)]) {
                    [self.delegate updateChatTbBottom:inputViewHeight + (size.height - 32) + self.keyboardHeight];
                }else{
                    NSLog(@"没有实现updateChatTbBottom代理");
                }
            }
            self.currentFrameHeight = inputViewHeight + (size.height - 32);
            self.frame = fr;
            for (UIView *childView in self.keyBoardUIView.subviews) {
                [childView layoutIfNeeded];
            }
            NSLog(@"2---%f",self.currentFrameHeight);
        } ];
    }
    if (size.height != _lastSize.height && _lastSize.height !=0) {
        [UIView animateWithDuration:0.1 animations:^{
            /*inputTextView最低高度32*/
            if (size.height >32) {
                self.inputTextViewHeight_LayoutConstraint.constant = size.height;
            }else{
                self.inputTextViewHeight_LayoutConstraint.constant = 32;
            }
            [textView layoutIfNeeded];
            NSLog(@"3---%f",self.currentFrameHeight);
        } completion:^(BOOL finished) {
            /**< 防止粘贴文字后 内容显示不全（文字整体上移了） */
            [textView setContentInset:UIEdgeInsetsMake(5, -5, -15, 5)];//设置UITextView的内边距
            [textView setTextAlignment:NSTextAlignmentLeft];//并设置左对齐
            [textView scrollRangeToVisible:NSMakeRange(textView.text.length, 1)];
        }];
    }
    _lastSize = size;
}

//当点击textView的时候 重置状态为键盘弹出
- (void)textViewDidBeginEditing:(UITextView *)textView{
    /**重置按钮状态    录音  表情  更多选择*/
    [self resetAllButtonState];
    _isShowMoreEditing = ShowMoreTypeOfOne;
    return;
    
}

#pragma mark -- 废弃方法
/** 输入框删除了字符 */
- (void)textViewDeleteAction{
    [self.inputTextView scrollRangeToVisible:NSMakeRange(self.inputTextView.text.length, 1)];
    //获取文本中字体的size
    CGSize size = [self kSizeWithString:self.inputTextView.text font:[UIFont systemFontOfSize:14.0] width:self.inputTextView.frame.size.width];
    
    if (size.height > (inputViewHeight-18) && size.height <= (inputViewHeightMax-18)) {
        self.keyBoardUIViewLayoutHeight.constant = inputViewHeight + (size.height - 32);
        [self.keyBoardUIView layoutIfNeeded];
        CGRect fr = self.frame;
        fr.size.height = inputViewHeight + (size.height - 32);
        self.currentFrameHeight = fr.size.height;
        self.frame = fr;
        if (size.height != _lastSize.height && _lastSize.height !=0) {
            /**< inputTextView最低高度32 */
            if (size.height >28) {
                self.inputTextViewHeight_LayoutConstraint.constant = size.height + 18;
            }else{
                self.inputTextViewHeight_LayoutConstraint.constant = 28;
            }
            [self.inputTextView layoutIfNeeded];
        }
        _lastSize = size;
    }else if (size.height > (inputViewHeightMax-18)) {
        self.keyBoardUIViewLayoutHeight.constant = inputViewHeightMax;
        [self.keyBoardUIView layoutIfNeeded];
        CGRect fr = self.frame;
        fr.size.height = inputViewHeightMax;
        self.currentFrameHeight = fr.size.height;
        self.frame = fr;
    }
    else{
        self.keyBoardUIViewLayoutHeight.constant = inputViewHeight;
        [self.keyBoardUIView layoutIfNeeded];
        CGRect fr = self.frame;
        fr.size.height = inputViewHeight;
        self.currentFrameHeight = fr.size.height;
        self.frame = fr;
        self.inputTextViewHeight_LayoutConstraint.constant = 32;
        [self.inputTextView layoutIfNeeded];
    }
}

//搜索指定的字符   并返回所搜到的所有位置集合
- (NSMutableArray *)searchCharFromString:(NSString *)searchStrSource  searChar:(NSString *)searChar{
    NSMutableArray *searIndexMuArray = [NSMutableArray new];
    NSString *temp = nil;
    for(int i =0; i < [searchStrSource length]; i++)
    {
        temp = [searchStrSource substringWithRange:NSMakeRange(i, 1)];
        if ([temp isEqualToString:searChar]) {
            NSLog(@"第%d个字是:%@", i, temp);
            [searIndexMuArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return searIndexMuArray;
}



/** 检索字符串中的表情，显示到label上 */
- (NSString *)showEmoji:(NSString *)content{
    
    __block NSString *showStr;
    __weak typeof(self)  weakself = self;
    
    showStr = content;
    
    // 表情文字左右方括号标示
    NSString *leftParenthesis   =  @"[";
    NSString *rightparenthesis  =  @"]";
    // 枚举出所有该字符串中所有表情
    [showStr enumerateSubstringsInRange:NSMakeRange(0, showStr.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        
        if ([showStr containsString:leftParenthesis] && [showStr containsString:rightparenthesis]) {
            NSRange leftRange  = [showStr rangeOfString:leftParenthesis options:NSCaseInsensitiveSearch];
            NSRange rightRange = [showStr rangeOfString:rightparenthesis options:NSCaseInsensitiveSearch];
            if (rightRange.location>leftRange.location) {
                NSString *emojiStr = [showStr substringWithRange:NSMakeRange(leftRange.location, rightRange.location-leftRange.location+1)];
                /** 判断是哪一个表情字段  从而匹配相应的表情*/
                NSArray *emojiFlagArr = weakself.emojiFlagArr;
                NSArray *emojiArr     = self.arrEmotion;
                for (int i=0; i<emojiFlagArr.count; i++) {
                    if ([emojiStr isEqualToString:emojiFlagArr[i]]) {
                        showStr =[showStr stringByReplacingOccurrencesOfString:emojiStr withString:emojiArr[i]];
                        break;
                    }
                }
            }
        }
    }];
    
    return showStr;
}


/** 将带"[]"格式的字符串替换成表情 并返回NSMutableAttributedString */
+ (NSMutableAttributedString *)dealWithString:(NSString *)text{
    if (text.length >2) {
        if ([[text substringToIndex:3] isEqualToString:@"ssj"]) {
            NSLog(@"test:%@",text);
        }
    }
    
    NSString *emotionPattern = @"\\[[a-zA-Z\\u4e00-\\u9fa5]+\\]";
    //    NSString *topicPattern = @"#[0-9a-zA-Z\\u4e00-\\u9fa5]+#";
    NSString *topicPattern = @"\\[\\w+\\]";//自定义
    NSString *urlPattern = @"[a-zA-z]+://[^\\s]*";
    NSString *pattern = [NSString stringWithFormat:@"%@|%@|%@",emotionPattern,topicPattern,urlPattern];
    
    /**< 把[表情]替换成attachment图片，不能用replace和insert，因为会改变后面的相对位置，应该先拿到所有位置，最后再统一修改。*/
    /**< 应该打散特殊部分和非特殊部分，然后拼接。*/
    NSMutableArray *parts = [NSMutableArray array];
    
    
    [text enumerateStringsMatchedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        if ((*capturedRanges).length == 0) return;
        
        TextSegment *seg = [[TextSegment alloc] init];
        seg.text = *capturedStrings;
        seg.range = *capturedRanges;
        seg.special = YES;
        
        seg.emotion = [seg.text hasPrefix:@"["] && [seg.text hasSuffix:@"]"];
        
        [parts addObject:seg];
        
    }];
    
    [text enumerateStringsSeparatedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        if ((*capturedRanges).length == 0) return;
        
        TextSegment *seg = [[TextSegment alloc] init];
        seg.text = *capturedStrings;
        seg.range = *capturedRanges;
        seg.special = NO;
        [parts addObject:seg];
        
    }];
    
    
    /**
     *
     */
    [parts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        TextSegment *ts1 = obj1;
        TextSegment *ts2 = obj2;
        
        // Descending指的是obj1>obj2
        // Ascending指的是obj1<obj2
        // 要实现升序，按照上面的规则返回。
        
        // 系统默认按照升序排列。
        if (ts1.range.location < ts2.range.location) {
            return NSOrderedAscending;
        }
        
        return NSOrderedDescending;
        
    }];
    
    /**
     *  从前到后拼接一个新创建的NSAttributedString，根据内容的不同拼接不同的内容
     */
    NSArray *emojiFlagArr = [SSJKeybordView emojis][@"emojiFlagArr"];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    NSInteger cnt = parts.count;
    for (NSInteger i = 0; i < cnt; i++) {
        TextSegment *ts = parts[i];
        if (ts.isEmotion) {
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            //            attach.image = [UIImage imageNamed:@"camera_edit_cut_cancel_highlighted"];
            /** 判断是哪一个表情描述字段  从而匹配相应的表情*/
            
            
            for (int i=0; i<emojiFlagArr.count; i++) {
                if ([ts.text isEqualToString:emojiFlagArr[i]]) {
                    NSString *imgName = [NSString stringWithFormat:@"smiley_%d",i];
                    attach.image = [UIImage imageNamed:imgName];
                    NSLog(@"图片名字:%@  要比较的:%@",imgName,ts.text);
                    break;
                }
            }
            
            attach.bounds = CGRectMake(0, -3, 19, 19);
            NSAttributedString *emotionStr = [NSAttributedString attributedStringWithAttachment:attach];
            [attributedText appendAttributedString:emotionStr];
        }else if(ts.isSpecial){
            NSAttributedString *special = [[NSAttributedString alloc] initWithString:ts.text attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
            [attributedText appendAttributedString:special];
        }else{
            [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:ts.text]];
        }
    }
    return attributedText;
}


#pragma mark -- ExpressionEvePageViewDelegate   添加表情描述文字
- (void)biaoqingClickDelagateMethod:(NSInteger)tag{
    //获取要插入的表情描述文字
    NSString *str = self.emojiFlagArrIOS[tag];
    //获取之前记录的光标位置
    NSMutableString *top = [[NSMutableString alloc] initWithString:[self.inputTextView text]];
    NSString *addName = [NSString stringWithFormat:@"%@",str];
    [top insertString:addName atIndex:_range.location];
    self.inputTextView.text = top;
    //将光标位置往后挪一个表情的单位
    NSUInteger length = _range.location + [str length];
    _range = NSMakeRange(length,0);
    //进行位置调整
    [self textViewDidChange:self.inputTextView];
    //    [self.inputTextView scrollRectToVisible:CGRectMake(0, self.inputTextView.contentSize.height-15, self.inputTextView.contentSize.width, 10) animated:YES];
    [self.inputTextView scrollRangeToVisible:NSMakeRange(self.inputTextView.text.length, 1)];
}
/**
 *  将输入的内容转变成通用的    iOS显示的[得意]  转成  [smiley_1]
 */
- (NSString *)emojiFlagArrIOSToEmojiFlagArr:(NSString *)text{
    NSString *cStr=self.inputTextView.text;
    
    NSString *emotionPattern = @"\\[[a-zA-Z\\u4e00-\\u9fa5]+\\]";
    //    NSString *topicPattern = @"#[0-9a-zA-Z\\u4e00-\\u9fa5]+#";
    NSString *topicPattern = @"\\[\\w+\\]";//自定义
    NSString *urlPattern = @"[a-zA-z]+://[^\\s]*";
    NSString *pattern = [NSString stringWithFormat:@"%@|%@|%@",emotionPattern,topicPattern,urlPattern];
    
    // 把[表情]替换成attachment图片，不能用replace和insert，因为会改变后面的相对位置，应该先拿到所有位置，最后再统一修改。
    // 应该打散特殊部分和非特殊部分，然后拼接。
    NSMutableArray *parts = [NSMutableArray array];
    
    
    [text enumerateStringsMatchedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        if ((*capturedRanges).length == 0) return;
        
        TextSegment *seg = [[TextSegment alloc] init];
        seg.text = *capturedStrings;
        seg.range = *capturedRanges;
        seg.special = YES;
        
        seg.emotion = [seg.text hasPrefix:@"["] && [seg.text hasSuffix:@"]"];
        
        [parts addObject:seg];
        
    }];
    
    [text enumerateStringsSeparatedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        if ((*capturedRanges).length == 0) return;
        
        TextSegment *seg = [[TextSegment alloc] init];
        seg.text = *capturedStrings;
        seg.range = *capturedRanges;
        seg.special = NO;
        [parts addObject:seg];
        
    }];
    
    
    /**
     *
     */
    [parts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        TextSegment *ts1 = obj1;
        TextSegment *ts2 = obj2;
        
        // Descending指的是obj1>obj2
        // Ascending指的是obj1<obj2
        // 要实现升序，按照上面的规则返回。
        
        // 系统默认按照升序排列。
        if (ts1.range.location < ts2.range.location) {
            return NSOrderedAscending;
        }
        
        return NSOrderedDescending;
        
    }];
    
    /**
     *  从前到后拼接一个新创建的NSAttributedString，根据内容的不同拼接不同的内容
     */
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    NSInteger cnt = parts.count;
    for (NSInteger i = 0; i < cnt; i++) {
        TextSegment *ts = parts[i];
        if (ts.isEmotion) {
            /** 判断是哪一个表情描述字段  从而匹配相应的表情*/
            for (int i=0; i<_emojiFlagArrIOS.count; i++) {
                if ([ts.text isEqualToString:_emojiFlagArrIOS[i]]) {
                    NSString *strName = [NSString stringWithFormat:@"[smiley_%d]",i];
                    cStr =  [cStr stringByReplacingOccurrencesOfString:ts.text withString:strName];
                    break;
                }
            }
        }else if(ts.isSpecial){
            NSAttributedString *special = [[NSAttributedString alloc] initWithString:ts.text attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
            [attributedText appendAttributedString:special];
        }else{
            [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:ts.text]];
        }
    }
    
    return cStr;
}


#pragma mark -- recoverInputHeight
//收回高度  chatTB_LayoutConstraintBottom为聊天内容展示tableView的底部高度约束
- (void)recoverInputHeight{
    if (!self.listView.hidden) {
        self.listView.hidden = TRUE;//先隐藏相册 视频 视图
        [self.selectMoreButton setBackgroundImage:[UIImage imageNamed:@"+"] forState:UIControlStateNormal];//将选择更多按钮图片重置
    }
    
    self.expressionView.hidden = TRUE;//将表情视图隐藏
    [self.expressionButton setBackgroundImage:[UIImage imageNamed:@"expression"] forState:UIControlStateNormal];
    self.keyboardHeight = 0;
    
    self.isEditing = NO;
    if (_isShowMoreEditing != ShowMoreTypeOfOff) {
        [UIView animateWithDuration:0 animations:^{
            self.frame = CGRectMake(0, App_Height-64-self.currentFrameHeight, App_Width, self.currentFrameHeight+100);
            if ([self.delegate respondsToSelector:@selector(updateChatTbBottom:)]) {
                [self.delegate updateChatTbBottom:self.currentFrameHeight];
            }else{
                NSLog(@"没有实现updateChatTbBottom代理");
            }
            
            _isShowMoreEditing = ShowMoreTypeOfOff;
        }];
    }
}


#pragma mark -- NoticeAppContainerSSJKeybordView_selectedName 通知
- (void)notificationAtName:(NSNotification *)sender{
    //获取要插入的人员名字
    NSDictionary *userInfoDic = sender.userInfo;
    NSString *nameStr = userInfoDic[@"name"];
    NSString *isPressStr = userInfoDic[@"isPress"];
    /**
     userInfoDic[@"isPress"]：@"1"代表长按   @"0" 代表输入@
     */
    if (self.inputTextView.text.length == 0) {
        NSLog(@"@符号丢失");
        return;
    }
    if ([isPressStr isEqualToString:@"0"]) {
        NSMutableString *top = [[NSMutableString alloc] initWithString:[self.inputTextView text]];
        NSString *addName = [NSString stringWithFormat:@"%@ ",nameStr];
        [top insertString:addName atIndex:self.contentAtLocation+1];
        self.inputTextView.text = top;
        
        //进行位置调整
        [self textViewDidChange:self.inputTextView];
        [self.inputTextView scrollRangeToVisible:NSMakeRange(self.inputTextView.text.length, 1)];
        
        //数据结构2
        [self.atMuArray addObject:[NSString stringWithFormat:@"@%@ ",nameStr]];
        
        //将光标位置往前挪一个 @字符串 的单位
        self.inputTextView.selectedRange = NSMakeRange(self.contentAtLocation+(nameStr.length + 2),0);
        _range = NSMakeRange(self.contentAtLocation+(nameStr.length + 2) ,0);
        
    }else{
        /**< 先获取光标位置 */
        NSRange currentRang = [self.inputTextView selectedRange];
        
        NSMutableString *top = [[NSMutableString alloc] initWithString:[self.inputTextView text]];
        NSString *addName = [NSString stringWithFormat:@"@%@ ",nameStr];
        [top insertString:addName atIndex:currentRang.location];
        self.inputTextView.text = top;
        
        //进行位置调整
        [self textViewDidChange:self.inputTextView];
        [self.inputTextView scrollRangeToVisible:NSMakeRange(self.inputTextView.text.length, 1)];
        
        //数据结构2
        [self.atMuArray addObject:[NSString stringWithFormat:@"@%@ ",nameStr]];
        
        //将光标位置往前挪一个 @字符串 的单位
        self.inputTextView.selectedRange = NSMakeRange(currentRang.location+(nameStr.length + 2),0);
        _range = NSMakeRange(currentRang.location+(nameStr.length + 2) ,0);
    }
    
    
    
}


/** 计算字体size */
-(CGSize)kSizeWithString:(NSString*)string font:(UIFont*)font     width:(float)width {
    CGRect rect = [string boundingRectWithSize:CGSizeMake(width,   80000) options:NSStringDrawingTruncatesLastVisibleLine |   NSStringDrawingUsesFontLeading    |NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return rect.size;
}

@end
