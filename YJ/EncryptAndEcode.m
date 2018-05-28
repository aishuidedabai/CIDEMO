
//
//  EncryptAndEcode.m
//  XiongMaoJiaSu
//
//  Created by 唐晓波的电脑 on 16/6/7.
//  Copyright © 2016年 ISOYasser. All rights reserved.
//

//加密解密
#import "EncryptAndEcode.h"
#import "AFNetworking.h"
#import "ClearCacheTool.h"
@implementation EncryptAndEcode


+(long int )hexadecimalToDecimal:(NSString *)hex{ //用户名的md5 16 进制
    //unsigned long deci =strtoul([hex UTF8String],0,16); 返回的是一个无符号的long类型
//    NSString * dec = [NSString stringWithFormat:@"%lu",strtoul([hex UTF8String],0,16)];
    if (hex == nil) {
         return 1000;
    }
    unsigned long int m = strtoul([hex UTF8String],0,16);
    long int mm = m % 300;
    
    //当前时间戳
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970];// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    long int timeint = [timeString integerValue];
    timeint = timeint%300 + 1;
    timeint = timeint * 300;
    mm = mm + timeint;
    
    return mm;
}


+(void)httpUrl:(NSString *)url AndGETparameters:(NSDictionary *)parameters block:(void(^)(NSString* responseObject))block errorblock:(void(^)(NSString * error))block1
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;//超时时间
    [manager GET:@"http://steamcommunity.com/#scrollTop=0" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject1) {
        block(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([[NSString stringWithFormat:@"%@",error] containsString:@"The request timed out."]) {
            block1(@"超时");
        }
    }]; 
}
//获取配置github
 static NSURLSessionDownloadTask *_downloadTask;
+(void)httpGithubUrl
{
    [self httpGithubUrldirect];
    
     [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"httpgithub"];
    // 1. 创建url
    NSString *urlStr = @"https://raw.githubusercontent.com/VimSakura/steam_proxy_url/master/proxy_ios";
    //    urlStr = @"https://xubiji.com/tools/potatso.conf";
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *Url = [NSURL URLWithString:urlStr];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:Url];
    
    // 创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask *downLoadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            // 下载成功
            // 注意 location是下载后的临时保存路径, 需要将它移动到需要保存的位置
            NSError *saveError;
            // 创建一个自定义存储路径
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *savePath = [cachePath stringByAppendingPathComponent:@"filenameiplist"];
            NSURL *saveURL = [NSURL fileURLWithPath:savePath];
            //检查文件是否存在
            // 做存在的事情
            BOOL isClearSuccess = [ClearCacheTool clearCache];;
            if (isClearSuccess) {
                NSLog(@"清除成功");
            }else{
                NSLog(@"清除失败");
            }
            // 文件复制到cache路径中
            [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveURL error:&saveError];
            
            if (!saveError) {
                NSString *textFileContents = [NSString stringWithContentsOfFile:savePath encoding:NSUTF8StringEncoding error:nil];
                NSArray *lines = [[self removeSpaceAndNewline:textFileContents] componentsSeparatedByString:@"\n"];
                if (lines.count == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self httpGithubUrl];
                    });
                    return;
                }
                [[NSUserDefaults standardUserDefaults] setObject:lines forKey:@"httpgithub"];

            } else {
            }
        } else {
        }
    }];
    // 恢复线程, 启动任务
    [downLoadTask resume];
}

+(void)httpGithubUrldirect
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"httpgithubdirect"];
    
    // 1. 创建url
    NSString *urlStr = @"https://raw.githubusercontent.com/aishuidedabai/Pro-x-ylist/master/IPlistDirect.txt";
    //    urlStr = @"https://xubiji.com/tools/potatso.conf";
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *Url = [NSURL URLWithString:urlStr];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:Url];
    
    // 创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask *downLoadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            // 下载成功
            // 注意 location是下载后的临时保存路径, 需要将它移动到需要保存的位置
            NSError *saveError;
            // 创建一个自定义存储路径
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *savePath = [cachePath stringByAppendingPathComponent:@"httpgithubdirectplist"];
            NSURL *saveURL = [NSURL fileURLWithPath:savePath];
            //检查文件是否存在
            // 做存在的事情
            BOOL isClearSuccess = [ClearCacheTool clearCache];;
            if (isClearSuccess) {
                NSLog(@"清除成功");
            }else{
                NSLog(@"清除失败");
            }
            // 文件复制到cache路径中
            [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveURL error:&saveError];
            
            if (!saveError) {
                NSString *textFileContents = [NSString stringWithContentsOfFile:savePath encoding:NSUTF8StringEncoding error:nil];
                NSArray *lines = [[self removeSpaceAndNewline:textFileContents] componentsSeparatedByString:@"\n"];
                if (lines.count == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self httpGithubUrl];
                    });
                    return;
                }
                NSLog(@"------httpgithubdirect---%@",lines[11]);
                [[NSUserDefaults standardUserDefaults] setObject:lines forKey:@"httpgithubdirect"];
                
            } else {
            }
        } else {
        }
    }];
    // 恢复线程, 启动任务
    [downLoadTask resume];
}



+ (NSString *)removeSpaceAndNewline:(NSString *)str{
    
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"(" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return temp;
}


+ (NSString*)dictionaryToJson:(NSDictionary *)dic{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end
