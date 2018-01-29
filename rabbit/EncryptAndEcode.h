//
//  EncryptAndEcode.h
//  XiongMaoJiaSu
//
//  Created by 唐晓波的电脑 on 16/6/7.
//  Copyright © 2016年 ISOYasser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EncryptAndEcode : NSObject

+(void)httpUrl:(NSString *)url AndPOSTparameters:(NSDictionary *)parameters andheader:(NSString *)Header block:(void(^)(NSDictionary* responseObject))block errorblock:(void(^)(NSError * error))block1;
+(void)httpUrl:(NSString *)url AndGETparameters:(NSDictionary *)parameters andheader:(NSString *)Header block:(void(^)(NSDictionary* responseObject))block errorblock:(void(^)(NSError * error))block1;
@end
