//let jsonObject = json.object as AnyObject
//
//let jsonObject = json.rawValue  as AnyObject
//
////JSON转化为Data
//let data = json.rawData()
//
////JSON转化为String字符串
//if let string = json.rawString() {
//    //Do something you want
//}
//
////JSON转化为Dictionary字典（[String: AnyObject]?）
//if let dic = json.dictionaryObject {
//    //Do something you want
//}
//
////JSON转化为Array数组（[AnyObject]?）
//if let arr = json.arrayObject {
//    //Do something you want
//}


import UIKit
import NetworkExtension
import SwiftyJSON

public var Xtoken = String() // header
public var username = String()

//FIXME: 表示此处有bug 或者要优化 列如下
//MARK: 标记
//TODO: 此处需要完善

//逻辑是 ：先初始化设备，然后初始化用户，然后获取节点配置，然后开始连接（先调用接口，接口返回成功才开启成功）备注：这三个流程接口，如果任何一个网络不好获取配置信息失败都会导致无法连接成功。通知名：远近接口网络连接失败 ，参数：远近网络获取失败信息

//TODO: 要把所有的传给C5GAME的信息写下来（都是字符串）

//初始化设备时候，通知的名称：YJgetdevicecode。接收到的参数YJgetdevicecode:获取设备信息时候返回的code码（400以上都是错误的），msg:返回的错误信息

//初始化用户和开始连接的通知名称：YJinituserc5code。接收到的参数YJinituserc5code:获取设备信息时候返回的c5code码（这个是自定义的），msg:返回的错误信息

// YuanJinUsername ： 需要传过来的用户名，存在UserDefaults里面

/*
 开启和关闭VPN只需要调用CliktVPN() 方法。连接状态：UserDefaults 存进去键值对,同时发送一个通知 (我个人认为不需要添加连接中和断开中的状态，因为只要配置正确，连接时间是毫秒，即：用户的等待时间应该是我们配置的网络请求时间，获取到配置，vpn断开和连接都应该是按下按钮的一瞬间，可以参考远近商用专线)
 {YJ判断连接：连接成功ON} 通知 NotificationCenter.default.post(name: Notification.Name(rawValue: "YJon"),object: nil, userInfo: nil)
 
 {YJ判断连接：连接中Connecting} 通知  NotificationCenter.default.post(name: Notification.Name(rawValue: "YJConnecting"),object: nil, userInfo: nil)
 
 {YJ判断连接：断开连接中Disconnecting} 通知  NotificationCenter.default.post(name: Notification.Name(rawValue: "YJDisconnecting"),object: nil, userInfo: nil)
 
 {YJ判断连接：断开连接or连接失败off} 通知  NotificationCenter.default.post(name: Notification.Name(rawValue: "YJoff"),object: nil, userInfo: nil)
*/

public class VPNmanagerAPI: NSObject {
    public class func CliktVPN() {
        
//        if(VpnManager.shared.vpnStatus == .off){
//            VpnManager.shared.connect()
//        }else{
//            VpnManager.shared.disconnect()
//        }
//        return;
        
        
        //MARK: 获取设备号
        let deviceUUID = UIDevice.current.identifierForVendor?.uuidString
        
        //如果已存在则不需要再次获取
        if UserDefaults.standard.value(forKey: "device_id") != nil {
            //初始化用户
            self.InitUser()
            return;
        }
        
        NetworkTools.requestData(.post, Header: "", URLString: "https://c5api.yuanjin.io/devices", parameters: ["device_serial_num": deviceUUID ?? "","device_os":"IOS","device_type":UIDevice.current.modelName]) { (result) in
            let json = JSON(result)
             print("--获取设备号------------%@-",json)
            
            
            //数据判断
            if let string = json.rawString() {
                let data = string.data(using: String.Encoding.utf8)
                if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
                    
                    print("--获取设备ID-------------",dict?["_id"] ?? "")
                    
                    //400以上的code码全部是错误
                    if dict!["code"] != nil{
                        
                        //发送获取设备码code码通知给c5game
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "YJgetdevicecode"),
                                                        object: self,
                                                        userInfo: ["YJgetdevicecode":NSString(format: "%@" , dict?["code"] as! CVarArg),
                                                                   "msg":NSString(format: "%@" , dict?["msg"] as! CVarArg)])
                    }
                    
                    //能获取到id，400以下的正确的code
                    if dict!["_id"] != nil{
                        //存入device_id
                        let userdefaults = UserDefaults.standard
                        userdefaults.set(dict?["_id"] ?? "" , forKey: "device_id")
                        userdefaults.synchronize()
                        //初始化用户
                        self.InitUser()
                    }
                }
            }
        }
    }
    
    
    //MARK: 初始化用户
    public class func InitUser() {
        
        let userdefaults = UserDefaults.standard
        let device_id = userdefaults.string(forKey: "device_id")
        let YuanJinUsername = userdefaults.string(forKey: "YuanJinUsername")
        //TODO: 此处需要传入YuanJinUsername
//        YuanJinUsername = "c5_ios"
        debugPrint("--------用户名-----",YuanJinUsername ?? "")
        //初始化用户
        NetworkTools.requestData(.post, Header: "", URLString: "https://c5api.yuanjin.io/users/init", parameters: ["username": YuanJinUsername ?? "","device_id":device_id ?? ""]) { (result) in
            
                print("--获取初始化用户数据-------------",result)
            
                //先转成data再用swiftJSON
                let data = NSString(format: "%@" , result as! CVarArg).data(using: String.Encoding.utf8.rawValue)
                do {
                        let json = try JSON(data:data!)
                    
                        //获取节点配置
                        if json["x-token"] != JSON.null{
                            self.GETnodes(str: json["x-token"].stringValue)
                        }
                    
                        //获取失败发送错误
                        if json["c5code"] != JSON.null{
                            
                            //发送初始化用户code码通知给c5game
                            NotificationCenter.default.post(name:
                                NSNotification.Name(rawValue:
                                    "YJinituserc5code"),object: self,
                                                         userInfo: ["YJinituserc5code": json["c5code"].stringValue,"msg": json["msg"].stringValue])
                        }
                }
                catch{
                    //process error
                }
            }
    }
    
    
    //MARK: 获取节点配置
    public class func GETnodes(str:String) {
        
        let userdefaults = UserDefaults.standard
        let YuanJinUsername = userdefaults.string(forKey: "YuanJinUsername")
         //TODO: 此处需要传入YuanJinUsername
//        YuanJinUsername = "c5_ios"
        //获取头和username
        Xtoken = str;
        username = YuanJinUsername!;
        
        
        //MARK: 获取节点配置
        NetworkTools.requestData(.get, Header: str, URLString: "https://c5api.yuanjin.io/users/nodes", parameters: ["username": YuanJinUsername ?? ""]) { (result) in
            //先转成data再用swiftJSON
            let data = NSString(format: "%@" , result as! CVarArg).data(using: String.Encoding.utf8.rawValue)
            do {
                
                let json = try JSON(data:data!)
                if json["nodes"] != JSON.null{
                    let randomNumber:Int = Int(arc4random() % 3) //随机数
                    let arrip = json["nodes"].array
                    
                    var dicip : [String : NSObject] = [String : NSObject]()
                    
                    //配置线路
                    dicip = ["ss_address": arrip![0]["address"].string! as NSObject ,
                             "ss_method": arrip![0]["method"].string! as NSObject,
                             "ss_port": arrip![0]["port"].int! as NSObject ,
                             "ss_password":arrip![0]["password"].string! as NSObject ]
                    
                    let userdefaults = UserDefaults.standard
                     userdefaults.synchronize()
                    userdefaults.set(dicip, forKey: "线路参数")

                    //均衡分配
                    if json.count >= 3{
                        debugPrint("--//获取节点配置--------%@----%@-",arrip![randomNumber])
                        dicip = ["ss_address": arrip![randomNumber]["address"].string! as NSObject ,
                                 "ss_method": arrip![randomNumber]["method"].string! as NSObject,
                                 "ss_port": arrip![randomNumber]["port"].int! as NSObject ,
                                 "ss_password":arrip![randomNumber]["password"].string! as NSObject ]
                        
                        let userdefaults = UserDefaults.standard
                        userdefaults.synchronize()
                        userdefaults.set(dicip, forKey: "线路参数")
                    }
                    
                    
                    //VPN操作判断
                    if(VpnManager.shared.vpnStatus == .off){
                        VpnManager.shared.connect()
                    }else{
                        VpnManager.shared.disconnect()
                    }
                }
            }
            catch{
                //process error
            }
        }
    }
    
    
    //MARK: vpn success
  public class  func success(_ name : String , userid : String) {
        NetworkTools.requestData(.post , Header: Xtoken, URLString: "https://c5api.yuanjin.io/users/start", parameters: ["username": username]) { (result) in
              debugPrint("开启成功的返回------",result)
            
            let data = NSString(format: "%@" , result as! CVarArg).data(using: String.Encoding.utf8.rawValue)
            do {
                    let json = try JSON(data:data!)

                    //用户开启失败发送错误并且关闭vpn
                    if json["c5code"] != JSON.null{
                        
                        //VPN操作判断
                        if(VpnManager.shared.vpnStatus == .off){
                            VpnManager.shared.connect()
                        }else{
                            VpnManager.shared.disconnect()
                        }
                        
                        //发送初始化用户code码通知给C5GAME
                        NotificationCenter.default.post(name:
                            NSNotification.Name(rawValue:
                                "YJinituserc5code"),object: self,
                                                    userInfo: ["YJinituserc5code": json["c5code"].stringValue,
                                                           "msg": json["msg"].stringValue])
                }
                }
            catch{
                //process error
            }
    }
    }
    
    
    //MARK: vpn faild (证明此用户过期了)
   public class func faild() {
        NetworkTools.requestData(.post , Header: Xtoken, URLString: "https://c5api.yuanjin.io/users/stop", parameters: ["username": username]) { (result) in
            debugPrint("开启失败的返回------",result)
        }
    }
}



//转成data类型存入数组
//let data = try? JSONSerialization.data(withJSONObject: dicip, options: [])
////Data转换成String打印输出
//let str = String(data:data!, encoding: String.Encoding.utf8)
////输出json字符串
//print("Json Str:\(str!)")
// userdefaults.saveCustomObject(customObject: dicip as NSData, key: "线路参数") //存
//extension UserDefaults { //1
//    func saveCustomObject(customObject object: NSData, key: String) { //2
//        let encodedObject = NSKeyedArchiver.archivedData(withRootObject: object)
//        self.set(encodedObject, forKey: key)
//        self.synchronize()
//    }
//
//    func getCustomObject(forKey key: String) -> AnyObject? { //3
//        let decodedObject = self.object(forKey: key) as? NSData
//
//        if let decoded = decodedObject {
//            let object = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data as Data)
//            return object as AnyObject
//        }
//
//        return nil
//    }
//}




//MARK: - UIDevice延展
public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1":                               return "iPhone 7 (CDMA)"
        case "iPhone9,3":                               return "iPhone 7 (GSM)"
        case "iPhone9,2":                               return "iPhone 7 Plus (CDMA)"
        case "iPhone9,4":                               return "iPhone 7 Plus (GSM)"
        case "iPhone10,1":                               return "iPhone 8"
        case "iPhone10,4":                               return "iPhone 8"
        case "iPhone10,2":                               return "iPhone 8 Plus"
        case "iPhone10,5":                               return "iPhone 8 Plus"
        case "iPhone10,3":                               return "iPhone X"
        case "iPhone10,6":                               return "iPhone X"
            
            
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
