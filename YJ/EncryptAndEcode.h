//
//  EncryptAndEcode.h
//  XiongMaoJiaSu
//
//  Created by 唐晓波的电脑 on 16/6/7.
//  Copyright © 2016年 ISOYasser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EncryptAndEcode : NSObject
+(void)httpGithubUrl;
+(long int )hexadecimalToDecimal:(NSString *)hex;
+(void)httpUrl:(NSString *)url AndGETparameters:(NSDictionary *)parameters block:(void(^)(NSString* responseObject))block errorblock:(void(^)(NSString * error))block1;
@end
