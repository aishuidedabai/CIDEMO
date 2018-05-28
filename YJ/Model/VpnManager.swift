
//  Created by TXB on 2018/01/22.
//

import Foundation
import NetworkExtension


enum VPNStatus {
    case off
    case connecting
    case on
    case disconnecting
}


class VpnManager{
    static let shared = VpnManager()
    var observerAdded: Bool = false
    
    
    fileprivate(set) var vpnStatus = VPNStatus.off {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "kProxyServiceVPNStatusNotification"), object: nil)
        }
    }
    
    init() {
        loadProviderManager{
            guard let manager = $0 else{return}
            self.updateVPNStatus(manager)
        }
        addVPNStatusObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addVPNStatusObserver() {
        guard !observerAdded else{
            return
        }
        loadProviderManager { [unowned self] (manager) -> Void in
            if let manager = manager {
                self.observerAdded = true
                NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: manager.connection, queue: OperationQueue.main, using: { [unowned self] (notification) -> Void in
                    self.updateVPNStatus(manager)
                })
            }
        }
    }
    
    
    func updateVPNStatus(_ manager: NEVPNManager) {
        switch manager.connection.status {
        case .connected:
            self.vpnStatus = .on
            NotificationCenter.default.post(name: Notification.Name(rawValue: "YJon"),
                                            object: nil, userInfo: nil)
            let userdefaults =  UserDefaults.standard
            userdefaults.set("1", forKey:"vpnStatus");
            userdefaults.synchronize()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                VPNmanagerAPI.success("vpnStatus" , userid: "1")
            }

        case .connecting, .reasserting:
            self.vpnStatus = .connecting
            NotificationCenter.default.post(name: Notification.Name(rawValue: "YJConnecting"),
                                            object: nil, userInfo: nil)
            let userdefaults =  UserDefaults.standard
            userdefaults.set("2", forKey:"vpnStatus");
            userdefaults.synchronize()
            
        case .disconnecting:
            self.vpnStatus = .disconnecting
            NotificationCenter.default.post(name: Notification.Name(rawValue: "YJDisconnecting"),
                                            object: nil, userInfo: nil)
            let userdefaults =  UserDefaults.standard
            userdefaults.set("3", forKey:"vpnStatus");
            userdefaults.synchronize()
            
        case .disconnected, .invalid:
            self.vpnStatus = .off
            NotificationCenter.default.post(name: Notification.Name(rawValue: "YJoff"),
                                            object: nil, userInfo: nil)
            let userdefaults =  UserDefaults.standard
            userdefaults.set("4", forKey:"vpnStatus");
            userdefaults.synchronize()
        }
        debugPrint(self.vpnStatus)
    }
}

// load VPN Profiles
extension VpnManager{
    
    fileprivate func createProviderManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        let conf = NETunnelProviderProtocol()
        conf.serverAddress = "C5GAME"
        manager.protocolConfiguration = conf
        manager.localizedDescription = "C5GAME"
        return manager
    }
    
    
    func loadAndCreatePrividerManager(_ complete: @escaping (NETunnelProviderManager?) -> Void ){
        NETunnelProviderManager.loadAllFromPreferences{ (managers, error) in
            guard let managers = managers else{return}
            let manager: NETunnelProviderManager
            if managers.count > 0 {
                manager = managers[0]
                self.delDupConfig(managers)
            }else{
                manager = self.createProviderManager()
            }
            
            manager.isEnabled = true
            self.setRulerConfig(manager)
            manager.saveToPreferences{
                if $0 != nil{complete(nil);return;}
                manager.loadFromPreferences{
                    if $0 != nil{
                        print($0.debugDescription)
                        complete(nil);return;
                    }
                    self.addVPNStatusObserver()
                    complete(manager)
                }
            }
            
        }
    }
    
    func loadProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void){
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let managers = managers {
                if managers.count > 0 {
                    let manager = managers[0]
                    complete(manager)
                    return
                }
            }
            complete(nil)
        }
    }
    
    
    func delDupConfig(_ arrays:[NETunnelProviderManager]){
        if (arrays.count)>1{
            for i in 0 ..< arrays.count{
                print("Del DUP Profiles")
                arrays[i].removeFromPreferences(completionHandler: { (error) in
                    if(error != nil){print(error.debugDescription)}
                })
            }
        }
    }
}

// Actions
extension VpnManager{
    func connect(){
        self.loadAndCreatePrividerManager { (manager) in
            guard let manager = manager else{return}
            do{
                try manager.connection.startVPNTunnel(options: [:])
            }catch let err{
                print(err)
            }
        }
    }
    
    func disconnect(){
        loadProviderManager{$0?.connection.stopVPNTunnel()}
    }
}


// Generate and Load ConfigFile
extension VpnManager{

    fileprivate func getRuleConf() -> String{
        let Path = Bundle.main.path(forResource: "NEKitRule", ofType: "conf")
        let Data = try? Foundation.Data(contentsOf: URL(fileURLWithPath: Path!))
        let str = String(data: Data!, encoding: String.Encoding.utf8)!
        return str
    }
    
    fileprivate func setRulerConfig(_ manager:NETunnelProviderManager){
        let httpgithub = UserDefaults.standard
        let lianjiePDstr = httpgithub.array(forKey: "httpgithub")
        let httpgithubdirect = httpgithub.array(forKey: "httpgithubdirect")
        
        let user = UserDefaults.standard
        let userdefaults = user.dictionary(forKey: "线路参数")
        let orignConf = manager.protocolConfiguration as! NETunnelProviderProtocol
        orignConf.providerConfiguration = ["ss_address": userdefaults?["ss_address"] ?? "", "ss_method": "AES256CFB", "ss_port":userdefaults?["ss_port"] ?? 0, "ss_password": userdefaults?["ss_password"] ?? "", "Steamconf":getRuleConf() as AnyObject? ?? "","httpgithub":lianjiePDstr as AnyObject? ?? "","httpgithubdirect":httpgithubdirect as AnyObject? ?? ""]
        manager.protocolConfiguration = orignConf
    }
}
