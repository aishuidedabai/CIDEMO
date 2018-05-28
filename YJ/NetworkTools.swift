//
//  NetworkTools.swift
//  Yuanjin
//
//  Created by txb on 2018/1/12.
//  Copyright © 2018年 yicheng. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum MethodType {
    case get
    case post
}
//http://steamcommunity.com/#scrollTop=0

//let Header  = ["a":"b","c":"d", "e":"f"]  //设置请求头
class NetworkTools {
     class func requestData(_ type : MethodType, Header :  String, URLString : String, parameters : [String : Any]? = nil, finishedCallback :  @escaping (_ result : Any) -> ()) {
        
        // 1.获取类型
        let method = type == .get ? HTTPMethod.get : HTTPMethod.post
        
        // 2.发送网络请求
         Alamofire.request(URLString, method:method, parameters: parameters,headers: ["X-TOKEN":Header])//TODO 请求数据json格式
            //HandyJSON需要序列化的是字符串这里是responseString
            .responseString { (response) in
                
                switch response.result {
                    
                case .success:
//                    let statusCode = response.response?.statusCode // 状态码
                    if let value = response.result.value {
                        finishedCallback(NSString(format: "%@" , value as CVarArg))
                    }
                    debugPrint("成功:\(String(describing: response.result.value))")
                case .failure(let error):
                      debugPrint("GetError:\(error)")
                    debugPrint("GetErrorUrl:\(String(describing: response.request))")
        
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "远近接口网络连接失败"),
                                                    object: self,
                                                    userInfo: ["远近网络获取失败信息":"\(String(describing: error))"])
                    debugPrint("GetError:\(error)")
                }
                
        }
    }
   
    
    //备份
    class func requestData1(_ type : MethodType, Header1 : [String : Any]? = nil,URLString : String, parameters : [String : Any]? = nil, finishedCallback :  @escaping (_ result : Any) -> ()) {
        
        // 1.获取类型
        let method = type == .get ? HTTPMethod.get : HTTPMethod.post
        
        // 2.发送网络请求
        Alamofire.request(URLString, method: method, parameters: parameters , headers:nil).responseJSON { (response) in
            
            // 3.获取结果
            guard let result = response.result.value else {
                print(response.result.error!)
                return
            }
            
            // 4.将结果回调出去
            finishedCallback(result)
        }
    }
    
}

