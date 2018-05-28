//
//  AppDelegate.m
//  VPN
//
//  Created by Apple on 16/9/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
#define Wscreen [UIScreen mainScreen].bounds.size.width
#define Hscreen [UIScreen mainScreen].bounds.size.height
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 
    
    ViewController *loginVC = [[ViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];//创建了window
    
     [UINavigationBar appearance].tintColor = [UIColor blackColor];
    //设置NavigationBar背景颜色
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    [[[NSUserDefaults standardUserDefaults]initWithSuiteName:@"group.com.lightningCat"] setValue:@"0" forKey:@"SetConnect"];
}
- (void)applicationDidEnterBackground:(UIApplication *)application{
    [[[NSUserDefaults standardUserDefaults]initWithSuiteName:@"group.com.lightningCat"] setValue:@"0" forKey:@"SetConnect"];
}
- (void)applicationWillTerminate:(UIApplication *)application {
    [[[NSUserDefaults standardUserDefaults]initWithSuiteName:@"group.com.lightningCat"] setValue:@"0" forKey:@"SetConnect"];
}
@end
