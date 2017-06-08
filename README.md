# SSJKeybordViewDemo
![](https://github.com/825551308/SSJKeybordViewDemo/blob/master/SSJKeybordViewGif2.gif)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
## 地址: https://github.com/825551308/SSJKeybordViewDemo
## 使用方式
```
- (void)viewDidAppear:(BOOL)animated{<br/>
    //添加底部栏
    if (!self.keybordView) {
        _keybordView = [SSJKeybordView instanceSSJKeybordView];
        _keybordView.frame = CGRectMake(0, self.view.frame.size.height-64-inputViewHeight, self.view.frame.size.width, inputViewHeight+100);
        _keybordView.delegate = self;
        _keybordView.whetherRoomChat = YES;
        _keybordView.placeholderValue = @"我要回复";<br/> 
        [self.view addSubview:_keybordView ]; 
    }
}
ps:
1、所有表情匹配文字以及匹配的图片名字都在emoji.json这个文件里；
2、一般我们存在服务端的消息格式“今天天气真好啊[微笑]”，当客户端接收到“今天天气真好啊[微笑]”的时候，可以调用
[SSJKeybordViewConfig dealWithString:”今天天气真好啊[微笑]”] 来转化成NSMutableAttributedString，然后再把这个NSMutableAttributedString传给需要显示的label
