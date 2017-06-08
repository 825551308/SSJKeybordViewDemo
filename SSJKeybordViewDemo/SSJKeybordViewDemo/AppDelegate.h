//
//  AppDelegate.h
//  SSJKeybordViewDemo
//
//  Created by jssName on 2017/6/7.
//  Copyright © 2017年 jssName. All rights reserved.
//

#import <UIKit/UIKit.h>
#define App_Delegate      ((AppDelegate*)[[UIApplication sharedApplication]delegate])
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) NSInteger maxPicNum; //发布跟帖可选最大图片张数
@property (assign, nonatomic) NSInteger selectedPicNum; //已选择张数


@end

