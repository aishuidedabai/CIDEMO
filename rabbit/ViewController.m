//
//  ViewController.m
//  Yuanjin
//
//  Created by txb on 2018/1/10.
//  Copyright © 2018年 yicheng. All rights reserved.
//

#import "ViewController.h"
#import "YJ-Swift.h"
@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    btn.backgroundColor = [UIColor blackColor];
    [btn addTarget:self action:@selector(CliktVPN) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi:)name:@"YJinituserc5code" object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi1:)name:@"远近接口网络连接失败" object:nil];
    // Do any additional setup after loading the view.
     [[NSUserDefaults standardUserDefaults] setValue:@"c5_ios" forKey:@"YuanJinUsername"];
    //写入国外域名段
//    if([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"国外网站"]] isEqualToString:@"(null)"])
//    {
        NSString *textFileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"proxy"ofType:@"txt"]];
        NSArray *lines = [textFileContents componentsSeparatedByString:@"\n"];
        NSMutableArray *chinaiparr = [[NSMutableArray alloc]init];
        for (NSString *ip in lines) {
            NSArray *iparr = [ip componentsSeparatedByString:@"/"];
            NSString *ip1 = [NSString stringWithFormat:@"%@",iparr[0]];
            [chinaiparr addObject:ip1];
        }
        [[NSUserDefaults standardUserDefaults] setObject:chinaiparr forKey:@"国外网站"];
//    }
    
}

- (void)tongzhi1:(NSNotification *)text{
    
    NSLog(@"－－－－－接收到网络连接失败通知--%@----",text.userInfo[@"远近网络获取失败信息"]);
    
}


- (void)tongzhi:(NSNotification *)text{
    
    NSLog(@"－－－－－接收到通知--%@----",text.userInfo[@"YJinituserc5code"]);
    
}


-(void)CliktVPN
{
    [[NSUserDefaults standardUserDefaults] setValue:@{@"ss_address":@"47.52.102.114",@"ss_method":@"AES256CFB",@"ss_port": @7703,@"ss_password":@"elina"} forKey:@"线路参数"];
    [VPNmanagerAPI CliktVPN];
    
    //用户过期需要调用的接口
    //            VPNmanagerAPI.faild()
    
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
