//
//  main.m
//  XiongMaoVPNPro
//
//  Created by ISOYasser on 16/6/17.
//  Copyright © 2016年 ISOYasser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <OneAPM/OneAPM.h>
int main(int argc, char * argv[]) {
    @autoreleasepool {
        [OneAPM startWithApplicationToken: @ "0ECEB84844CE0196070A79CB853C360A25"];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
