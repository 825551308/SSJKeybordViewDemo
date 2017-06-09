//
//  SSJKeybordViewConfig.m
//  MobileApplicationPlatform
//
//  Created by 金汕汕 on 17/6/8.
//  Copyright © 2017年 HCMAP. All rights reserved.
//

#import "SSJKeybordViewConfig.h"
#import "RegexKitLite.h"

@implementation TextSegment

@end

@implementation SSJKeybordViewConfig
+ (SSJKeybordViewConfig *)shareManager{
    static SSJKeybordViewConfig *emailSingleClass = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        emailSingleClass = [[SSJKeybordViewConfig alloc] init];
        [emailSingleClass initData];
    });
    return emailSingleClass;
}


- (NSDictionary *)emojis{
    static NSDictionary *__emojis = nil;
    if (!__emojis){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"json"];
        NSData *emojiData = [[NSData alloc] initWithContentsOfFile:path];
        __emojis = [NSJSONSerialization JSONObjectWithData:emojiData options:NSJSONReadingAllowFragments error:nil];
    }
    return __emojis;
}
////获取默认表情数组
+ (NSDictionary *)emojis{
    static NSDictionary *__emojis = nil;
    if (!__emojis){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"json"];
        NSData *emojiData = [[NSData alloc] initWithContentsOfFile:path];
        __emojis = [NSJSONSerialization JSONObjectWithData:emojiData options:NSJSONReadingAllowFragments error:nil];
    }
    return __emojis;
}

// 初始化表情标识符－－描述文字
- (void)initData{
    if (!_emojiFlagArr) {
        _emojiFlagArr = self.emojis[@"emojiFlagArr"];
    }
    if (!_emojiFlagArrIOS) {
        _emojiFlagArrIOS = self.emojis[@"emojiFlagArrIOS"];
    }
    if (!_emotionArr) {
        _emotionArr = self.emojis[@"emojiImgNameArr"];
    }
}


//搜索指定的字符   并返回所搜到的所有位置集合
- (NSMutableArray *)searchCharFromString:(NSString *)searchStrSource  searChar:(NSString *)searChar{
    NSMutableArray *searIndexMuArray = [NSMutableArray new];
    NSString *temp = nil;
    for(int i =0; i < [searchStrSource length]; i++)
    {
        temp = [searchStrSource substringWithRange:NSMakeRange(i, 1)];
        if ([temp isEqualToString:searChar]) {
            NSLog(@"第%d个字是:%@", i, temp);
            [searIndexMuArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return searIndexMuArray;
}

/**
 *  将输入的内容转变成通用的    iOS显示的[得意]  转成  [smiley_1]
 */
- (NSString *)emojiFlagArrIOSToEmojiFlagArr:(NSString *)text{
    NSString *cStr= text;
    
    NSString *emotionPattern = @"\\[[a-zA-Z\\u4e00-\\u9fa5]+\\]";
    //    NSString *topicPattern = @"#[0-9a-zA-Z\\u4e00-\\u9fa5]+#";
    NSString *topicPattern = @"\\[\\w+\\]";//自定义
    NSString *urlPattern = @"[a-zA-z]+://[^\\s]*";
    NSString *pattern = [NSString stringWithFormat:@"%@|%@|%@",emotionPattern,topicPattern,urlPattern];
    
    // 把[表情]替换成attachment图片，不能用replace和insert，因为会改变后面的相对位置，应该先拿到所有位置，最后再统一修改。
    // 应该打散特殊部分和非特殊部分，然后拼接。
    NSMutableArray *parts = [NSMutableArray array];
    
    
    [text enumerateStringsMatchedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        if ((*capturedRanges).length == 0) return;
        
        TextSegment *seg = [[TextSegment alloc] init];
        seg.text = *capturedStrings;
        seg.range = *capturedRanges;
        seg.special = YES;
        
        seg.emotion = [seg.text hasPrefix:@"["] && [seg.text hasSuffix:@"]"];
        
        [parts addObject:seg];
        
    }];
    
    [text enumerateStringsSeparatedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        if ((*capturedRanges).length == 0) return;
        
        TextSegment *seg = [[TextSegment alloc] init];
        seg.text = *capturedStrings;
        seg.range = *capturedRanges;
        seg.special = NO;
        [parts addObject:seg];
        
    }];
    
    
    /**
     *
     */
    [parts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        TextSegment *ts1 = obj1;
        TextSegment *ts2 = obj2;
        
        // Descending指的是obj1>obj2
        // Ascending指的是obj1<obj2
        // 要实现升序，按照上面的规则返回。
        
        // 系统默认按照升序排列。
        if (ts1.range.location < ts2.range.location) {
            return NSOrderedAscending;
        }
        
        return NSOrderedDescending;
        
    }];
    
    /**
     *  从前到后拼接一个新创建的NSAttributedString，根据内容的不同拼接不同的内容
     */
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    NSInteger cnt = parts.count;
    for (NSInteger i = 0; i < cnt; i++) {
        TextSegment *ts = parts[i];
        if (ts.isEmotion) {
            /** 判断是哪一个表情描述字段  从而匹配相应的表情*/
            for (int i=0; i<_emojiFlagArrIOS.count; i++) {
                if ([ts.text isEqualToString:_emojiFlagArrIOS[i]]) {
                    NSString *strName = [NSString stringWithFormat:@"[smiley_%d]",i];
                    cStr =  [cStr stringByReplacingOccurrencesOfString:ts.text withString:strName];
                    break;
                }
            }
        }else if(ts.isSpecial){
            NSAttributedString *special = [[NSAttributedString alloc] initWithString:ts.text attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
            [attributedText appendAttributedString:special];
        }else{
            [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:ts.text]];
        }
    }
    
    return cStr;
}


//将带"[]"格式的字符串替换成表情 并返回NSMutableAttributedString
+ (NSMutableAttributedString *)dealWithString:(NSString *)text{
    if (text.length >2) {
        if ([[text substringToIndex:3] isEqualToString:@"ssj"]) {
            NSLog(@"test:%@",text);
        }
    }
    
    NSString *emotionPattern = @"\\[[a-zA-Z\\u4e00-\\u9fa5]+\\]";
    //    NSString *topicPattern = @"#[0-9a-zA-Z\\u4e00-\\u9fa5]+#";
    NSString *topicPattern = @"\\[\\w+\\]";//自定义
    NSString *urlPattern = @"[a-zA-z]+://[^\\s]*";
    NSString *pattern = [NSString stringWithFormat:@"%@|%@|%@",emotionPattern,topicPattern,urlPattern];
    
    // 把[表情]替换成attachment图片，不能用replace和insert，因为会改变后面的相对位置，应该先拿到所有位置，最后再统一修改。
    // 应该打散特殊部分和非特殊部分，然后拼接。
    NSMutableArray *parts = [NSMutableArray array];
    
    
    [text enumerateStringsMatchedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        if ((*capturedRanges).length == 0) return;
        
        TextSegment *seg = [[TextSegment alloc] init];
        seg.text = *capturedStrings;
        seg.range = *capturedRanges;
        seg.special = YES;
        
        seg.emotion = [seg.text hasPrefix:@"["] && [seg.text hasSuffix:@"]"];
        
        [parts addObject:seg];
        
    }];
    
    [text enumerateStringsSeparatedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        if ((*capturedRanges).length == 0) return;
        
        TextSegment *seg = [[TextSegment alloc] init];
        seg.text = *capturedStrings;
        seg.range = *capturedRanges;
        seg.special = NO;
        [parts addObject:seg];
        
    }];
    
    
    /**
     *
     */
    [parts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        TextSegment *ts1 = obj1;
        TextSegment *ts2 = obj2;
        
        // Descending指的是obj1>obj2
        // Ascending指的是obj1<obj2
        // 要实现升序，按照上面的规则返回。
        
        // 系统默认按照升序排列。
        if (ts1.range.location < ts2.range.location) {
            return NSOrderedAscending;
        }
        
        return NSOrderedDescending;
        
    }];
    
    /**
     *  从前到后拼接一个新创建的NSAttributedString，根据内容的不同拼接不同的内容
     */
    /**
     *  从前到后拼接一个新创建的NSAttributedString，根据内容的不同拼接不同的内容
     */
    NSArray *emojiFlagArr = [SSJKeybordViewConfig emojis][@"emojiFlagArr"];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    NSInteger cnt = parts.count;
    for (NSInteger i = 0; i < cnt; i++) {
        TextSegment *ts = parts[i];
        if (ts.isEmotion) {
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            //            attach.image = [UIImage imageNamed:@"camera_edit_cut_cancel_highlighted"];
            /** 判断是哪一个表情描述字段  从而匹配相应的表情*/
            
            
            for (int i=0; i<emojiFlagArr.count; i++) {
                if ([ts.text isEqualToString:emojiFlagArr[i]]) {
                    NSString *imgName = [NSString stringWithFormat:@"smiley_%d",i];
                    attach.image = [UIImage imageNamed:imgName];
                    NSLog(@"图片名字:%@  要比较的:%@",imgName,ts.text);
                    break;
                }
            }
            
            attach.bounds = CGRectMake(0, -3, 19, 19);
            NSAttributedString *emotionStr = [NSAttributedString attributedStringWithAttachment:attach];
            [attributedText appendAttributedString:emotionStr];
        }else if(ts.isSpecial){
            NSAttributedString *special = [[NSAttributedString alloc] initWithString:ts.text attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
            [attributedText appendAttributedString:special];
        }else{
            [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:ts.text]];
        }
    }
    //    self.inputTextView.attributedText = attributedText;
    return attributedText;
}


@end
