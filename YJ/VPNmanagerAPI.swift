//当前版本1.5
import UIKit
import NetworkExtension
import SwiftyJSON

public var Xtoken = String() // header
public var username = String()
public var arrip: [JSON] = []
public var randomNumber = Int()
//public  var timer: Timer? = Timer()
//FIXME: 表示此处有bug 或者要优化 列如下
//MARK: 标记
//TODO: 此处需要完善

public class VPNmanagerAPI: NSObject {
    public class func CliktVPN() {

        UserDefaults.standard.set("1", forKey: "SetConnect")
        
        if(VpnManager.shared.vpnStatus == .off){
        }else{
            VpnManager.shared.disconnect()
            return;
        }
        //如果已存在则不需要再次获取
        if  UserDefaults.standard.string(forKey: "device_id") != nil {
            //初始化用户
            self.InitUser()
            return;
        }
        //获取用户设备码
        NetworkTools.requestData(.post, Header: "", URLString: "https://c5api.yuanjin.io/devices", parameters: ["device_serial_num":  UserDefaults.standard.string(forKey: "UserUIDevice") ?? "","device_os":"IOS","device_type":UIDevice.current.modelName]) { (result) in
            let json = JSON(result)
            //数据判断
            if let string = json.rawString() {
                let data = string.data(using: String.Encoding.utf8)
                if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
                   //400以上的code码全部是错误
                    if dict!["code"] != nil{
                        //发送获取设备码code码通知给c5game
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "YJgetdevicecode"),
                                                        object: self,
                                                        userInfo: ["YJgetdevicecode":NSString(format: "%@" , dict?["code"] as! CVarArg),
                                                                   "msg":NSString(format: "%@" , dict?["msg"] as! CVarArg)])
                    }
                    debugPrint("获取设备码",dict ?? "")
                    //能获取到id，400以下的正确的code
                    if dict!["_id"] != nil{
                        //存入device_id
                        let userdefaults =  UserDefaults.standard
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
        let userdefaults =  UserDefaults.standard
        let device_id = userdefaults.string(forKey: "device_id")
        let YuanJinUsername = userdefaults.string(forKey: "YuanJinUsername")
        //TODO: 此处需要传入YuanJinUsername
        //初始化用户
        NetworkTools.requestData(.post, Header: "", URLString: "https://c5api.yuanjin.io/users/init", parameters: ["username": YuanJinUsername ?? "","device_id":device_id ?? ""]) { (result) in
                //先转成data再用swiftJSON
                let data = NSString(format: "%@" , result as! CVarArg).data(using: String.Encoding.utf8.rawValue)
                do {
                        let json = try JSON(data:data!)
                        //获取节点配置
                        if json["x-token"] != JSON.null{
                            self.GETnodes(json["x-token"].stringValue, url: "https://c5api.yuanjin.io/users/nodes")
                        }
                        //获取失败发送错误
                        if json["c5code"] != JSON.null{
                            //发送初始化用户code码通知给c5game
                            NotificationCenter.default.post(name:
                                NSNotification.Name(rawValue:
                                    "YJinituserc5code"),object: self,
                                                         userInfo:
                                ["YJinituserc5code": json["c5code"].stringValue,
                                 "msg": json["msg"].stringValue])
                        }
                }
                catch{}//process error
            }
    }
    
    
    //MARK: 获取节点配置
    public class func GETnodes(_ str:String , url : String ) {
        let userdefaults =  UserDefaults.standard
        let YuanJinUsername = userdefaults.string(forKey: "YuanJinUsername")
         //TODO: 此处需要传入YuanJinUsername
        //获取头和username
        Xtoken = str;
        username = YuanJinUsername!;
        //MARK: 获取节点配置
        NetworkTools.requestData(.get, Header: str, URLString: url, parameters: ["username": YuanJinUsername ?? ""]) { (result) in
            //先转成data再用swiftJSON
            let data = NSString(format: "%@" , result as! CVarArg).data(using: String.Encoding.utf8.rawValue)
            do {
                let json = try JSON(data:data!)
                if json["nodes"] != JSON.null{
                    arrip = json["nodes"].array!
                    var dicip : [String : NSObject] = [String : NSObject]()
                    randomNumber = 0
                    //配置线路
                    dicip = ["ss_address": arrip[0]["address"].string! as NSObject ,
                             "ss_method": arrip[0]["method"].string! as NSObject,
                             "ss_port": arrip[0]["port"].int! as NSObject ,
                             "ss_password":arrip[0]["password"].string! as NSObject ]
                    let userdefaults =  UserDefaults.standard
                    userdefaults.set(dicip, forKey: "线路参数")
                    userdefaults.synchronize()
                    //均衡分配
                    if arrip.count.toUIntMax() > 1{
                        randomNumber = Int(arc4random() % 2) //随机数
                        dicip = ["ss_address": arrip[randomNumber]["address"].string! as NSObject ,
                                 "ss_method": arrip[randomNumber]["method"].string! as NSObject,
                                 "ss_port": arrip[randomNumber]["port"].int! as NSObject ,
                                 "ss_password":arrip[randomNumber]["password"].string! as NSObject ]
                        let userdefaults =  UserDefaults.standard
                        userdefaults.set(dicip, forKey: "线路参数")
                        userdefaults.synchronize()
                    }
                    //VPN操作判断
                    if(VpnManager.shared.vpnStatus == .off){
                        VpnManager.shared.connect()
                    }else{
                        VpnManager.shared.disconnect()
                    }
                }
            }
            catch{}//process error
        }
    }
    
    
    //MARK: vpn success
  public class  func success(_ name : String , userid : String) {
    //计时器诊断自动切点
    let md5user =  UserDefaults.standard.string(forKey: "YuanJinUsername")?.md5
    let decimalInt:Int = EncryptAndEcode.hexadecimal(toDecimal: md5user) //最后的时间
    //判断steam状态
//   Timer.scheduledTimer(timeInterval:1800, target: self, selector:#selector(SteamStatusTimer), userInfo: nil, repeats: true)
    // 定义需要计时的时间
    var timeCount: Int64  = 10000000000000000
    let codeTimer = DispatchSource.makeTimerSource(queue:      DispatchQueue.global())
    codeTimer.scheduleRepeating(deadline: .now(), interval: .seconds(1))
    codeTimer.setEventHandler(handler: {
        timeCount = timeCount - 1
        if timeCount % 600 == 0 {
            DispatchQueue.main.async {
                self.SteamStatusTimer()
            }
        }
        if timeCount == 0 {
            codeTimer.cancel()
        }
    })
    codeTimer.resume()
    
    self.SteamStatusTimer()
        NetworkTools.requestData(.post , Header: Xtoken, URLString: "https://c5api.yuanjin.io/users/start", parameters: ["username": username]) { (result) in
            let data = NSString(format: "%@" , result as! CVarArg).data(using: String.Encoding.utf8.rawValue)
            do {
                    let json = try JSON(data:data!)
                    //用户开启失败发送错误并且关闭vpn
                    if json["c5code"] != JSON.null{
                        //VPN操作判断
                        if(VpnManager.shared.vpnStatus == .off){}else{
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
            catch{}//process error
    }
    }

    
    //MARK: vpn faild (证明此用户过期了)
   public class func faild() {
//    if (timer != nil) {
//       timer?.invalidate()
//       timer = nil
//    }
        NetworkTools.requestData(.post , Header: Xtoken, URLString: "https://c5api.yuanjin.io/users/stop", parameters: ["username": username]) { (result) in
            VpnManager.shared.disconnect()
        }
    }
    
    
    //MARK:计时器判断steam
     public class func SteamStatusTimer() {
        if randomNumber - 1 > arrip.count{
            return;
        }
        //检测steam状态
        EncryptAndEcode.httpUrl(nil, andGETparameters: nil, block: { (result) in
            self.VpsFaildAndSucess(arrip[randomNumber]["address"].string!, status: "0", port: arrip[randomNumber]["port"].int!)
            //正常
            debugPrint("Steam正常访问")
        }) { (result) in
            if result == "超时"{
                debugPrint("Steam不正常")
                 self.changevps()
                 self.VpsFaildAndSucess(arrip[randomNumber]["address"].string!, status: "1", port: arrip[randomNumber]["port"].int!)
            }
        }
    }
    
    
    //MARK: Steam状态失败改变vps
     public class func changevps() {
        if(VpnManager.shared.vpnStatus == .off){
        }else{
            VpnManager.shared.disconnect()
        }
        //延迟执行
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { //获取新节点
            self.GETnodes(Xtoken, url: "https://c5api.yuanjin.io/users/change_nodes")
        }
    }
    
    
    ///MARK:
    public class func VpsFaildAndSucess(_ IPname : String , status : String ,  port : Int) {
        let headers = [
            "content-type": "text/plain",
            "cache-control": "no-cache"
        ]
        let string = NSString(format: "# TYPE status counter\nstatus{label=\"%@\", port=\"%d\"} %@\n" , IPname,port,status)
        let postData = NSData(data: string.data(using: String.Encoding.utf8.rawValue)!)
        let request = NSMutableURLRequest(url: NSURL(string: "http://c5prom.yuanjin.io:9091/metrics/jobs/mon/instances/" + IPname)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
        })
        dataTask.resume()
    }
}

// MARK:
// MARK: 十六进制String 转 十进制Int
/// 十六进制String 转 十进制Int
public func stringSixteenChangeToInt(stringSixteen:String) -> Int {
    let str = stringSixteen.uppercased()

    var numbrInt = 0
    
    for i in str.utf8 {
        
        numbrInt = numbrInt * 16 + Int(i) - 48
        
        // 0-9 从48开始
        if i >= 65 {
            
            // A-Z 从65开始，但有初始值10，所以应该是减去55
            numbrInt -= 7
        }
    }
    return numbrInt
}


//MAKE： MD5加密
public extension String {
    var md5 : String{
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        
        return String(format: hash as String)
    }
}


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
