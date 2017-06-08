# SSJKeybordViewDemo
![](https://github.com/825551308/SSJKeybordViewDemo/blob/master/SSJKeybordViewGif.gif)
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
