
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

@implementation EncryptAndEcode

//解密
+(void)httpUrl:(NSString *)url AndPOSTparameters:(NSDictionary *)parameters andheader:(NSString *)Header block:(void(^)(NSDictionary* responseObject))block errorblock:(void(^)(NSError * error))block1{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//设置相应内容类型
    manager.requestSerializer.timeoutInterval = 8;//超时时间
    manager.responseSerializer.acceptableContentTypes = nil;//[NSSet setWithObject:@"text/ plain"];
    manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    manager.securityPolicy.allowInvalidCertificates = YES;//忽略https证书
    manager.securityPolicy.validatesDomainName = NO;//是否验证域名
    [manager.requestSerializer setValue:Header forHTTPHeaderField:@"X-TOKEN"];// ["X-TOKEN":Header]
    
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject1) {
        
        NSString *str1=[[NSString alloc]initWithData:responseObject1 encoding:NSUTF8StringEncoding];
        NSDictionary *responseObject =[self dictionaryWithJsonString:str1];
        block(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         block1(error);
    }];
}


+(void)httpUrl:(NSString *)url AndGETparameters:(NSDictionary *)parameters andheader:(NSString *)Header block:(void(^)(NSDictionary* responseObject))block errorblock:(void(^)(NSError * error))block1{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 8;
    manager.responseSerializer.acceptableContentTypes = nil;//[NSSet setWithObject:@"text/ plain"];
    manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject1) {
        
        NSString *str1=[[NSString alloc]initWithData:responseObject1 encoding:NSUTF8StringEncoding];
        NSDictionary *responseObject =[self dictionaryWithJsonString:str1];
        block(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(error == nil) {
            return ;
        }
        block1(error);
        //获取错误信息
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData != nil){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            if([NSString stringWithFormat:@"%@",serializedData].length>10)
            {
                if (![[NSString stringWithFormat:@"%@",[serializedData valueForKey:@"code"]] isEqualToString:@"200"]) {
                    
                }
            }
        }
        
        
    }];
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
