//
//  PCRRecordTool.m
//  PersonalCR
//
//  Created by jssName on 16/4/14.
//  Copyright © 2016年 jssName. All rights reserved.
//
/**
 *                                  录音工具
 1、设置音频会话类型为AVAudioSessionCategoryPlayAndRecord，因为程序中牵扯到录音和播放操作。
 2、创建录音机AVAudioRecorder，指定录音保存的路径并且设置录音属性，注意对于一般的录音文件要求的采样率、位数并不高，需要适当设置以保证录音文件的大小和效果。
 3、 设置录音机代理以便在录音完成后播放录音，打开录音测量保证能够实时获得录音时的声音强度。（注意声音强度范围-160到0,0代表最大输入）
 4、 创建音频播放器AVAudioPlayer，用于在录音完成之后播放录音。
 5、创建一个定时器以便实时刷新录音测量值并更新录音强度到UIProgressView中显示。
 6、添加录音、暂停、恢复、停止操作，需要注意录音的恢复操作其实是有音频会话管理的，恢复时只要再次调用record方法即可，无需手动管理恢复时间等。
 */

/**
 *  总结：
    录音步骤：
 1、设置绘话 setAudioSession
 2、创建   AVAudioRecorder 对象
 3、
 */

#import "PCRRecordTool.h"



@implementation PCRRecordTool
static AVAudioRecorder *ad;

- (NSString *)secondTime{
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970]*1000;
    NSString *timeStr = [NSString stringWithFormat:@"%.0f",time];
    return timeStr;
}

+ (PCRRecordTool *)shareManager{
    static  PCRRecordTool *recordTool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recordTool = [PCRRecordTool new];
    });
    return recordTool;
}

//获取一个随机整数，范围在[from,to），包括from，不包括to
-(NSInteger)getRandomNumber:(int)from to:(int)to
{
    return (NSInteger)(from + (arc4random() % (to - from + 1)));
}

- (void) kBuildFirst{
    NSString *fileName = [NSString stringWithFormat:@"/%@.aac",[self secondTime]];
     NSString *str = [recordPathHead stringByAppendingString:fileName];
    
    self.urlStr = str;
    NSURL *url = [NSURL URLWithString:self.urlStr];
    NSLog(@"录音路径-%@",self.urlStr);
   
    //创建录音格式设置
    NSDictionary *setting=[self getAudioSetting];
    
    NSError *error;
    ad = [[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
    ad.delegate = self;
    ad.meteringEnabled =YES;//启动录音测量
    [ad prepareToRecord];
    if(error){
        NSLog(@"创建录音器过程中出现异常:%@",error.localizedDescription);
    }
    [self setAudioSession];
}

/**
 *  设置录音的格式
 *
 *  @return 返回格式字典
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
//    //设置录音格式
//    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
//    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
//    [dicM setObject:@(8000) forKey:AVSampleRateKey];
//    //设置通道,这里采用单声道
//    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
//    //是否使用浮点数采样
//    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
//    //音频质量,采样质量
//    [dicM setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    
    //录音格式 无法使用
    [dicM setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey: AVFormatIDKey];
    //采样率
    [dicM setValue :[NSNumber numberWithFloat:8000.0] forKey: AVSampleRateKey];//44100.0
    //通道数
    [dicM setValue :[NSNumber numberWithInt:1] forKey: AVNumberOfChannelsKey];
    //音频质量,采样质量
    [dicM setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    
    return dicM;
}
/** 开始录音 */
- (void)startRecord{
    _countDown = countDownMaxFloat;//重置countDownMaxFloat秒倒计时
    if (ad.isRecording == NO) {
        [self kBuildFirst];
    }
    if(![ad isRecording]){
        [ad record];
        self.timer.fireDate=[NSDate distantPast];
    }
}
/** 结束录音 */
- (void)stopRecord{
    if([ad isRecording]){
        [ad stop];
        self.timer.fireDate=[NSDate distantFuture];
    }
}

/** 结束录音 */
- (void)stopRecordWithBlock:(PCRRecordToolBlock)_backBlock{
    self.pCRRecordToolBlock=_backBlock;
    
    if([ad isRecording]){
        [ad stop];
        self.timer.fireDate=[NSDate distantFuture];
    }
}


#pragma mark-AVAudioRecorderDelegate-录音完成
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"完成录音");
    if (self.pCRRecordToolBlock != nil) {
        /**< 如果小于1秒 给予提示 不调用代理方法 */
        if (_countDown > (countDownMaxFloat - countDownMinFloat)) {
         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"说话时间太短" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            [self stopRecord];
            return;
        }
        self.pCRRecordToolBlock();
    }
    
}
#pragma mark-AVAudioRecorderDelegate-编码错误
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"编码错误--%@",error.localizedDescription);
}

/** 设置音频会话 */
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setActive:YES error:nil];
}
//懒加载
- (NSTimer *)timer{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

/** 定时获取录音测量 */
- (void)timerChange{
    _countDown = _countDown - 0.1 ;//定时器时0.1秒执行一次
    if (_countDown <= 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"最多允许录音60秒" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        [self stopRecord];
        [self.delegate recordTimeOut:self.urlStr];
        return;
    }
    
    [ad updateMeters];
    CGFloat power= [ad averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    CGFloat progress=(1.0/160.0)*(power+160.0);
    [self.delegate updateMetersMethod:progress];
}


/** 获取Documents目录 */
- (NSString *)dirDoc{
    //[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"app_home_doc: %@",documentsDirectory);
    return documentsDirectory;
}

@end
