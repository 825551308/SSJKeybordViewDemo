//
//  HFPhotoPickerManager.h
//  HotFitness
//
//  Created by 周吾昆 on 15/10/31.
//  Copyright © 2015年 HeGuangTongChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface KKPhotoPickerManager : NSObject

+ (instancetype)shareInstace;

typedef void (^CompelitionBlock)(NSMutableArray *imageArray);

- (void)showActionSheetInView:(UIView *)inView
               fromController:(UIViewController *)fromController
              completionBlock:(CompelitionBlock)completionBlock;

- (void)getImagesfromController:(UIViewController *)fromController
              completionBlock:(CompelitionBlock)completionBlock;
//修改图片张数限制,全局搜kDNImageFlowMaxSeletedNumber修改即可.

@end
