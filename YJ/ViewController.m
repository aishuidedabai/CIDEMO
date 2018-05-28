//
//  ViewController.m
//  Yuanjin
//
//  Created by txb on 2018/1/10.
//  Copyright © 2018年 yicheng. All rights reserved.
//

#import "ViewController.h"
#import "YJ-Swift.h"
#import "ViewController.h"
#import "YJ-Swift.h"
#import "YYText.h"
#import "YYWebImage.h"
#import "MJRefresh.h"
#import "YYWebImage.h"
#import "UMMobClick/MobClick.h"
#import "IQKeyboardManager.h"
#import <UserNotifications/UserNotifications.h>
#import <GTSDK/GeTuiSdk.h>
#import <UMSocialCore/UMSocialCore.h>
#import "GetMiYao.h"
#include <stdio.h>
//#import <OneAPM/OneAPM.h>
#import "AFNetworking.h"
#import "EncryptAndEcode.h"
@interface ViewController ()

@end

//0ECEB84844CE0196070A79CB853C360A25

@implementation ViewController



- (void)googlehttp{
    //创建配置信息
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //设置请求超时时间：5秒
    configuration.timeoutIntervalForRequest = 8;
    //创建会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration: configuration delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com"]];
    //设置请求方式：POST
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-Type"];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Accept"];
    //data的字典形式转化为data
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@"" options:NSJSONWritingPrettyPrinted error:nil];
//    //设置请求体
//    [request setHTTPBody:@""];
    
    NSURLSessionDataTask * dataTask =[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([[NSString stringWithFormat:@"%@",error] containsString:@"The request timed out."]) {
            NSLog(@"超时");
        }
    }];
    [dataTask resume];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self googlehttp];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 300, 100, 100)];
    btn.backgroundColor = [UIColor blackColor];
    [btn setTitle:@"点击切换" forState:0];
    [btn setTitleColor:[UIColor whiteColor] forState:0];
    [btn addTarget:self action:@selector(CliktVPN) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi:)name:@"YJon" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi1:)name:@"远近接口网络连接失败" object:nil];
    // Do any additional setup after loading the view.
     [[NSUserDefaults standardUserDefaults] setValue:@"c5_ios" forKey:@"YuanJinUsername"];
    //获取的用户名，永远不为空
     [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[GetMiYao getDeviceId]] forKey:@"UserUIDevice"];
     [[NSUserDefaults standardUserDefaults] synchronize];
    
     [EncryptAndEcode httpGithubUrl];
    NSLog(@"－－－－－接收到网络连接失败通知--%@----",[[NSUserDefaults standardUserDefaults] valueForKey:@"YuanJinUsername"]);
    
//    [EncryptAndEcode httpUrl:nil AndGETparameters:nil block:^(NSString *responseObject) {
//    } errorblock:^(NSString *error) {
//    }];
}

- (void)tongzhi1:(NSNotification *)text{
    
    NSLog(@"－－－－－接收到网络连接失败通知--%@----",text.userInfo[@"远近网络获取失败信息"]);
}


- (void)tongzhi:(NSNotification *)text{
    
    NSLog(@"－－－－－接收到通知--%@----",text.userInfo[@"YJinituserc5code"]);
}

//static void writeFile(int str) {
//    NSMutableString *documentsPath = [NSMutableString stringWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
//    [documentsPath appendFormat:@"StautsSS.txt"];
//
//   char strarr[18000];
//    strcpy (strarr,[documentsPath UTF8String]);
//    FILE *p_file = fopen(strarr, "w+");
//    if(p_file) {
//        fprintf(p_file, "%d", str);
//        fclose(p_file);
//        p_file = NULL;
//    }else{
//        NSLog(@"文件打开失败");
//    }
//}
//
//int
//StautsSSrecever(){
//    NSMutableString *documentsPath = [NSMutableString stringWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
//    [documentsPath appendFormat:@"StautsSS.txt"];
//
//    FILE *p_file = fopen([documentsPath UTF8String], "r");
//    int strint = 0;
//    if(p_file) {
//        fscanf(p_file, "%d", &strint);
//        fclose(p_file);
//        p_file = NULL;
//    }
//    return strint;
//}

-(void)CliktVPN{
//     [[NSUserDefaults standardUserDefaults] setValue:@{@"ss_address":@"47.52.203.194",@"ss_method":@"AES256CFB",@"ss_port": @10702,@"ss_password":@"3Ap)344~"} forKey:@"线路参数"];
//    [[[NSUserDefaults standardUserDefaults]initWithSuiteName:@"group.com.lightningCat"] setValue:@"1" forKey:@"SetConnect"];
    //测试
    [VPNmanagerAPI CliktVPN];
    
//    [VPNmanagerAPI changevps];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
