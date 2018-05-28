//
//  GetMiYao.m
//  VPN
//
//  Created by Apple on 16/9/26.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "GetMiYao.h"
#import "SAMKeychain.h"
@implementation GetMiYao

+ (NSString *)getDeviceId {
    // 读取设备号
    NSString *localDeviceId = [[NSUserDefaults standardUserDefaults] valueForKey:@"用户名"];
    if (!localDeviceId) {
        // 保存设备号
        CFUUIDRef deviceId = CFUUIDCreate(NULL);
        assert(deviceId != NULL);
        CFStringRef deviceIdStr = CFUUIDCreateString(NULL, deviceId);
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@", deviceIdStr] forKey:@"用户名"];
        localDeviceId = [NSString stringWithFormat:@"%@", deviceIdStr];
    }
    return localDeviceId;
}

@end
