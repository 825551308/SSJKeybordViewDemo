# SSJKeybordViewDemo
![](https://github.com/825551308/SSJKeybordViewDemo/blob/master/SSJKeybordViewGif2.gif)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
## 地址: https://github.com/825551308/SSJKeybordViewDemo
## 使用方式

    - (void)viewDidAppear:(BOOL)animated{
        //添加底部栏
        if (!self.keybordView) {
            _keybordView = [SSJKeybordView instanceSSJKeybordView];
            _keybordView.frame = CGRectMake(0, self.view.frame.size.height-64-inputViewHeight, self.view.frame.size.width, inputViewHeight+100);
            _keybordView.delegate = self;
            _keybordView.whetherRoomChat = YES;
            _keybordView.placeholderValue = @"我要回复";
            [self.view addSubview:_keybordView ]; 
        }
    }

    #pragma mark - keyboard delegate
    // @某人回调
    - (void)whriteAtChar{

    }

    // 取消@某人
    - (void)atRemoved:(NSString *)removedName{

    }
    //图库
    - (void)chooseFromAlbum {
        [self.keybordView recoverInputHeight];
    }

    //拍照
    - (void)openCamera {
    }

    #pragma mark --  相机回调
    - (void)imagePickerController:(UIImagePickerController *)picker
            didFinishPickingImage:(UIImage *)image
                      editingInfo:(NSDictionary *)editingInfo{
    }

    // 语音回调
    - (void)recordEnd:(NSString *)recordPath recordTime:(NSString *)recordTime{
    }

    /* 更新聊天tableview 底部约束 */
    - (void)updateChatTbBottom:(CGFloat)val{

    }

    /* 点击发送按钮 */
    - (void)sendText:(NSString *)text{

    }
## .针对错误：“_u_errorNmae”,referenced from:
### . 解决方案：Build Settings 搜索 other Linker Flags 添加 -licucore即可

## PS:
1、所有表情匹配文字以及匹配的图片名字都在emoji.json这个文件里；
2、一般我们存在服务端的消息格式“今天天气真好啊[微笑]”，当客户端接收到“今天天气真好啊[微笑]”的时候，可以调用
[SSJKeybordViewConfig dealWithString:”今天天气真好啊[微笑]”] 来转化成NSMutableAttributedString，然后再把这个NSMutableAttributedString传给需要显示的label
