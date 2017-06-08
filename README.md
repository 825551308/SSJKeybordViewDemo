# SSJKeybordViewDemo
由于是在xcode8上创建的，在低版本的Xcode上可能运行不了，需要找到对应的xib文件，然后右键－－用文本编辑器打开，并搜索找到 “<capability name="documents saved in the Xcode 8 format" minToolsVersion=“8.0”/>”这段内容，将这行删掉。以此类推，所有运行不了的xib都要如此。
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

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
