//
//  PCRPlayMusicFile.m
//  PersonalCR
//
//  Created by jssName on 16/4/12.
//  Copyright © 2016年 jssName. All rights reserved.
//

#import "PCRPlayMusicFile.h"
#import <AudioToolbox/AudioToolbox.h>



@implementation PCRPlayMusicFile
{
    AVAudioPlayer *player;
    NSString *playingEndStr;//如果播放结束标记为1 就不执行代理方法
}
+ (PCRPlayMusicFile *)shareManager{
    static    PCRPlayMusicFile *pcrPlay=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pcrPlay = [PCRPlayMusicFile new];
    });
    return pcrPlay;
}

- (NSTimer *)timer{
    if(!_timer){
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateMusicProgressView) userInfo:nil repeats:YES];
    }
    return  _timer;
}

/**
 *  创建播放器
 */
- (void)buildAudioPlayer:(NSString *)_pathStr{
    //     NSString *str = [[NSBundle mainBundle]pathForResource:@"voice1" ofType:@"mp3"];
    
    NSURL *fileUrl=[NSURL fileURLWithPath:_pathStr];
    NSError *error = nil;
    player = [[AVAudioPlayer new]initWithContentsOfURL:fileUrl error:&error];
    player.numberOfLoops=0;
    player.delegate=self;

    [player prepareToPlay];
    if (error) {
        NSLog(@"播放器初始化发生错误，错误信息如下:%@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(buildAudioPlayerError:)]) {
            [self.delegate buildAudioPlayerError:error.localizedDescription];
        }
        
    }
//    [self play];
    //    AudioServicesPlayAlertSound(soundID);//播放音效并震动
    
}

- (void)buildAudioPlayerWithData:(NSData *)voiceData{
    NSError *error = nil;
    player = [[AVAudioPlayer new] initWithData:voiceData error:&error];
    player.numberOfLoops=0;
    player.delegate=self;
    
    [player prepareToPlay];
    if (error) {
        NSLog(@"播放器初始化发生错误，错误信息如下:%@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(buildAudioPlayerError:)]) {
            [self.delegate buildAudioPlayerError:error.localizedDescription];
        }
    }
}
- (BOOL)isplaying
{
    if ([player isPlaying]) {
        return YES;
    }
    return NO;
}
- (void)stopplaying
{
    if ([player isPlaying]) {
        [player stop];
        self.timer.fireDate=[NSDate distantPast];
    }
}
/**
 *  暂停
 */
- (void)pausePlaying{
    if ([player isPlaying]) {
        [player pause];
        self.timer.fireDate=[NSDate distantFuture];//暂停定时器
    }
}
/**
 *  播放
 */
- (void)play{
    [self setAudioSession];
    [self handleNotification:YES];
    if (![player isPlaying]) {
        [player play];
        playingEndStr = @"0";//初始化播放标记
        self.timer.fireDate=[NSDate distantPast];//恢复定时器
    }
}
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];//AVAudioSessionCategorySoloAmbient
//    [audioSession setActive:YES error:nil];//此方法会导致只能播放一次
    //正确应当如下:
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
}

#pragma mark- 播放结束
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"播放结束");
    playingEndStr = @"1";
    [self handleNotification:NO];
    if ([self.delegate respondsToSelector:@selector(updateProgressEnd)]) {
        [self.delegate updateProgressEnd];
    }
    
}
//更新进度
- (void)updateMusicProgressView{
    float progress = player.currentTime/player.duration;
    //如果播放结束标记为1 就不执行代理方法
    if (![playingEndStr isEqualToString:@"1"]) {
        if ([self.delegate respondsToSelector:@selector(updateProgress:)]){
            [self.delegate updateProgress:progress];
        }
    }
    
}
#pragma mark - 监听听筒or扬声器
- (void) handleNotification:(BOOL)state
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:state]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    if(state)//添加监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification"
                                                   object:nil];
    else//移除监听
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

//+ (void)play{
////     NSString *str = [[NSBundle mainBundle]pathForResource:@"voice1" ofType:@"mp3"];
//    NSString *audioFile=[[NSBundle mainBundle] pathForResource:@"voice1" ofType:@"mp3"];
//    NSURL *fileUrl=[NSURL fileURLWithPath:audioFile];
//    //1.获得系统声音ID
//    SystemSoundID soundID=0;
//    /**
//     * inFileUrl:音频文件url
//     * outSystemSoundID:声音id（此函数会将音效文件加入到系统音频服务中并返回一个长整形ID）
//     */
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
//    //如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
//    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
//    //2.播放音频
//    AudioServicesPlaySystemSound(soundID);//播放音效
//    //    AudioServicesPlayAlertSound(soundID);//播放音效并震动
//
//
//
//
////    NSString *str = [[NSBundle mainBundle]pathForResource:@"voice1" ofType:@"mp3"];
////    NSURL *url=[NSURL URLWithString:str];
////    SystemSoundID sdID = 0;
////    AudioServicesCreateSystemSoundID((__bridge CFURLRef  _Nonnull) url, &sdID);
//////     AudioServicesAddSystemSoundCompletion(sdID, NULL, NULL, soundCompleteCallback, NULL);
////    AudioServicesAddSystemSoundCompletion(sdID, NULL, NULL, soundCompleteCallback,NULL);
////    AudioServicesPlaySystemSound(sdID);
//
//
//}
//void soundCompleteCallback(SystemSoundID soundID,void * clientData){
//    NSLog(@"播放完成...");
//}
@end
