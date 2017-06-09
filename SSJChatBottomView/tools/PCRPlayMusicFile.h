//
//  PCRPlayMusicFile.h
//  PersonalCR
//
//  Created by jssName on 16/4/12.
//  Copyright © 2016年 jssName. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@protocol PCRPlayMusicFileDelegate <NSObject>
@optional
- (void)updateProgress:(float)progressFloat;
/*播放结束*/
- (void)updateProgressEnd;
/*创建播放器异常*/
- (void)buildAudioPlayerError:(NSString *)errorMessage;
@end



@interface PCRPlayMusicFile : NSObject<AVAudioPlayerDelegate>


@property (nonatomic , weak) NSTimer *timer;

+ (PCRPlayMusicFile *)shareManager;
//+ (void)play;

/**
 *  创建播放器
 *
 *  @param _pathStr 文件路径
 */
- (void)buildAudioPlayer:(NSString *)_pathStr;

- (void)buildAudioPlayerWithData:(NSData *)voiceData;
/**
 *  播放
 */
- (void)play;
/**
 *  暂停
 */
- (void)pausePlaying;
- (BOOL)isplaying;
- (void)stopplaying;

@property (nonatomic , weak) id<PCRPlayMusicFileDelegate>delegate;
@end
