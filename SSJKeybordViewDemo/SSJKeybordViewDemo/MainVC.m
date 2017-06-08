//
//  MainVC.m
//  SSJKeybordViewDemo
//
//  Created by 金汕汕 on 17/2/28.
//  Copyright © 2017年 ccs. All rights reserved.
//

#import "MainVC.h"
#import "SSJKeybordView.h"
#import "PCRPlayMusicFile.h"
#import "MainTableViewVC.h"
@interface MainVC ()<SSJKeybordViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic,strong) SSJKeybordView *keybordView;
@property (nonatomic,strong) MainTableViewVC*chatTabeleViewVC;
@property (nonatomic,strong) UITableView*chatTabeleView;
@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    __weak MainVC*weakSelf = self;
    self.chatTabeleViewVC = [MainTableViewVC new];
    self.chatTabeleView = self.chatTabeleViewVC.tableView;
    self.chatTabeleViewVC.scrollViewWillBeginDraggingBlock = ^(UIScrollView *scrollView) {
        [weakSelf.view endEditing:YES];
        [weakSelf.keybordView recoverInputHeight];
    };
}

- (void)viewDidAppear:(BOOL)animated{
    /**< 添加聊天tableView */
    self.chatTabeleView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-inputViewHeight);
    self.chatTabeleView.delegate = self.chatTabeleViewVC;
    [self.view addSubview:self.chatTabeleView];
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - keyboard delegate
// @某人回调
- (void)whriteAtChar{
    /**< @"isPress"：@"1"代表长按   @"0" 代表输入@ */
    NSMutableDictionary *dic = [NSMutableDictionary new];
    dic[@"name"] = @"张三";/**< 此处可以输入你需要@的人的名字 */
    dic[@"isPress"] = @"0";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NoticeAppContainerSSJKeybordView_selectedName object:nil userInfo:dic];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.keybordView.inputTextView becomeFirstResponder];
        });
    });
    
    
}

// 取消@某人
- (void)atRemoved:(NSString *)removedName{
    NSLog(@"取消@%@",removedName);
}
//图库
- (void)chooseFromAlbum {
    
    [self.keybordView recoverInputHeight];
}

- (UIImage *)compressImage:(UIImage *)sourceImage toTargetWidth:(CGFloat)targetWidth {
    CGSize imageSize = sourceImage.size;
    
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetHeight = (targetWidth / width) * height;
    
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

//拍照
- (void)openCamera {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        NSLog(@"相机权限受限");
        //        [UIAlertView alert:@"提示" msg:@"相机权限受限"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"相机权限受限" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark --  相机回调
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo{
    [picker dismissViewControllerAnimated:YES completion:nil];
    /** 点击相机按钮后 添加您的处理方式 */
    
    
    
    
    
    /**< 收回高度 */
    [self.keybordView recoverInputHeight];
}



// 语音回调
- (void)recordEnd:(NSString *)recordPath recordTime:(NSString *)recordTime{
    NSFileManager *manage = [[NSFileManager alloc] init];
    NSString *playPath = [recordPathHead stringByAppendingPathComponent:recordPath];
    if([manage fileExistsAtPath:playPath]){
        
        /**< 播放方式1 */
        NSData *data = [NSData dataWithContentsOfFile:playPath];
        [[PCRPlayMusicFile shareManager] buildAudioPlayerWithData:data];
        [[PCRPlayMusicFile shareManager] play];
        
    //        /**< 播放方式2 */
    //        [[PCRPlayMusicFile shareManager] buildAudioPlayer:playPath];
    //        [PCRPlayMusicFile shareManager].delegate = self;
    //        [[PCRPlayMusicFile shareManager] play];
    }
}

/*
 *  更新聊天tableview 底部约束
 */
- (void)updateChatTbBottom:(CGFloat)val{
    self.chatTabeleView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-val);
//        self.bottomConstraint.constant = val;
//        [self.chatTab layoutIfNeeded];
        [self.chatTabeleViewVC scrollToBottom];
    
}

- (void)sendText:(NSString *)text{
    NSLog(@"发送了:%@",text);
    [self.chatTabeleViewVC joinToList:text];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
@end
