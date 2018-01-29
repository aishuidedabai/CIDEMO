//
//  PacketTunnelProvider.swift
//  PacketTunnel
//
//  Created by TXB on 2018/01/22.
//

import NetworkExtension
import NEKit
import CocoaLumberjackSwift
import Yaml

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    var interface: TUNInterface!
    var enablePacketProcessing = false
    
    var proxyPort: Int!
    
    var proxyServer: ProxyServer!
    
    var lastPath:NWPath?
    
    var started:Bool = false

	override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
//        DDLog.removeAllLoggers()
//        DDLog.add(DDASLLogger.sharedInstance, with: DDLogLevel.info)
//        ObserverFactory.currentFactory = DebugObserverFactory()
        
        guard let conf = (protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration else{
            exit(EXIT_FAILURE)
        }
        
        let ss_adder = conf["ss_address"] as! String
        let ss_port = conf["ss_port"] as! Int
        let method = conf["ss_method"] as! String
        let password = conf["ss_password"] as!String
        
        let algorithm:CryptoAlgorithm
        algorithm = .AES256CFB
        let ssAdapterFactory = ShadowsocksAdapterFactory(serverHost: ss_adder, serverPort: ss_port, protocolObfuscaterFactory:ShadowsocksAdapter.ProtocolObfuscater.OriginProtocolObfuscater.Factory(), cryptorFactory: ShadowsocksAdapter.CryptoStreamProcessor.Factory(password: password, algorithm: algorithm), streamObfuscaterFactory: ShadowsocksAdapter.StreamObfuscater.OriginStreamObfuscater.Factory())
        
        let directAdapterFactory = DirectAdapterFactory()
        
        //Get lists from conf
       var UserRules:[NEKit.Rule] = []
        
        // Rules
        var rule_array : [NEKit.DomainListRule.MatchCriterion] = []
        rule_array.append(DomainListRule.MatchCriterion.keyword("google"))
        rule_array.append(DomainListRule.MatchCriterion.keyword("twitter"))
        rule_array.append(DomainListRule.MatchCriterion.keyword("yahoo"))
        rule_array.append(DomainListRule.MatchCriterion.keyword("instagram"))
        rule_array.append(DomainListRule.MatchCriterion.keyword("facebook"))
        rule_array.append(DomainListRule.MatchCriterion.keyword("whatsapp"))
        rule_array.append(DomainListRule.MatchCriterion.keyword("telegarm"))

        UserRules.append(DomainListRule(adapterFactory: directAdapterFactory, criteria: rule_array))
        var rule_arraysteam : [NEKit.DomainListRule.MatchCriterion] = []
        rule_arraysteam.append(DomainListRule.MatchCriterion.suffix("stream.com"))
        rule_arraysteam.append(DomainListRule.MatchCriterion.suffix("steamcommunity.com"))
        rule_arraysteam.append(DomainListRule.MatchCriterion.suffix("steampowered.com"))
        rule_arraysteam.append(DomainListRule.MatchCriterion.suffix("steamcommunity-a.akamaihd.net"))
        rule_arraysteam.append(DomainListRule.MatchCriterion.keyword("steamcommunity-a.akamaihd"))
        rule_arraysteam.append(DomainListRule.MatchCriterion.keyword("steamcommunity-a"))
        rule_arraysteam.append(DomainListRule.MatchCriterion.suffix("ytimg.com"))
        
       let arrip = [".deathmatchclassic.com",".modexpo.com",".poweredbysteam.net",".steamcommunity.com",".steamdevdays.com",".steamgames.com",".steamgames.net",".steampowered.com",".steampoweredgames.com",".steamserver.net",".steamstatic.com",".steamusers.com",".steamusers.net",".valve.net",".valvecorporation.com",".valvesoftware.com",".steam.net",".steamcontent.com",".steamcybercafe.com",".steammovies.org",".steampowered.co.nz",".steampowered.us",".steampoweredgames.net",".steampoweredgames.org",".steamusercontent.com",".steamvr.com",".valve.org",".valvecorp.net",".valvecorp.org",".valvecorporate.com",".valvessoftwares.com",".3games1box.com",".5games1box.com",".aheadofthegamemovie.com",".aheadofthegamethemovie.com",".aperturelaboratories.com",".aperturelabratories.com",".aperturescience.com",".as32590.net",".counterstrike.com.tw",".counter-strike.com.tw",".counter-strike.net",".counterstrike.tw",".counterstrike3.com",".counterstrike3.net",".counter-strike3.net",".counterstrike4.com",".counter-strike4.com",".counterstrike4.net",".counter-strike4.net",".counterstrike5.com",".counter-strike5.com",".counterstrike5.net",".counter-strike5.net",".counterstriketv.com",".cs-conditionzero.com",".csonline.com.tr",".csonline.com.tw",".csoturkey.com.tr",".csoturkey.info",".csoturkey.net",".dayofdefeat.com",".dayofdefeat1.com",".dayofdefeat1.net",".dayofdefeat2.com",".dayofdefeat2.net",".dayofdefeat3.com",".dayofdefeat3.net",".dayofdefeatmod.com",".dayofdefeattv.com",".dod1.net",".dod2.com",".dod2.net",".dod3.com",".dod3.net",".dota2.com",".freetoplaythemovie.com",".gamerlifemovie.com",".gamerlifethemovie.com",".getinsidetheorangebox.com",".half-life.com",".halflife.net",".half-life2.com",".halflife2movie.com",".half-life2movie.com",".halflife2portal.com",".half-life2portal.com",".halflife2portal.net",".half-life2portal.net",".halflife2sucks.com",".half-life2sucks.com",".halflife2themovie.com",".half-life3.com",".halflife3.net",".half-life3.net",".halflife3.org",".half-life3.org",".halflife3movie.com",".half-life3movie.com",".halflife3themovie.com",".halflifemac.com",".halflifeminerva.com",".half-lifeminerva.com",".half-lifemovie.com",".half-lifeportal.com",".halflifeportal.net",".half-lifeportal.net",".halflifethemovie.com",".hl2.org",".hl2portal.com",".hl2portal.net",".hl2sucks.com",".hlauth.net",".l4d.com",".l4d2.com.cn",".learningwithportals.com",".learnwithportals.com",".leftfourdead.com",".leftfourdead.net",".midnight-riders.com",".midnight-riders.net",".minervametastasis.com",".opposingforce.com",".opposing-force.com",".opposing-force.net",".opposing-force.org",".portal2-game.com",".portal2game.net",".portal2thegame.com",".portal2-thegame.com",".shopatvalve.com",".sourcefilmmaker.com",".steammoves.com",".teachwithportals.com",".teamfortress.com",".team-fortress.com",".team-fortress2.com",".teamfortressclassic.com",".teamfortressii.com",".team-fortressii.com",".teamfortresstv.com",".tf2.com",".tf-2.com",".tf-c.com",".tfclassic.org",".tfii.com",".tf-source.com",".tfsource.net",".tf-source.net",".theheartofracing.org",".thinkwithportals.com",".thinkwithportals.com",".valvestore.net",".valvesucks.com",".whatistheorangebox.com",".whatsinsidetheorangebox.com"]
        
        for line in arrip{//枚举数组需要 characters。characters是索引
            let string = NSString(format: "%@" , line )
            rule_arraysteam.append(DomainListRule.MatchCriterion.suffix(string as String))
        }
        
          UserRules.append(DomainListRule(adapterFactory: ssAdapterFactory, criteria: rule_arraysteam))
        // Rules
        let chinaRule = CountryRule(countryCode: "CN", match: true, adapterFactory: directAdapterFactory)
        let unKnowLoc = CountryRule(countryCode: "--", match: true, adapterFactory: directAdapterFactory)
        let dnsFailRule = DNSFailRule(adapterFactory: ssAdapterFactory)
     
        let allRule = AllRule(adapterFactory: ssAdapterFactory)
        UserRules.append(contentsOf: [chinaRule,unKnowLoc,dnsFailRule,allRule])
        
        let manager = RuleManager(fromRules: UserRules, appendDirect: true)
        
        RuleManager.currentManager = manager
        proxyPort =  9090

        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "8.8.8.8")
        networkSettings.mtu = 1500
        
        let ipv4Settings = NEIPv4Settings(addresses: ["192.169.89.1"], subnetMasks: ["255.255.255.0"])
        if enablePacketProcessing {
            ipv4Settings.includedRoutes = [NEIPv4Route.default()]
            ipv4Settings.excludedRoutes = [
                NEIPv4Route(destinationAddress: "10.0.0.0", subnetMask: "255.0.0.0"),
                NEIPv4Route(destinationAddress: "100.64.0.0", subnetMask: "255.192.0.0"),
                NEIPv4Route(destinationAddress: "127.0.0.0", subnetMask: "255.0.0.0"),
                NEIPv4Route(destinationAddress: "169.254.0.0", subnetMask: "255.255.0.0"),
                NEIPv4Route(destinationAddress: "172.16.0.0", subnetMask: "255.240.0.0"),
                NEIPv4Route(destinationAddress: "192.168.0.0", subnetMask: "255.255.0.0"),
                NEIPv4Route(destinationAddress: "17.0.0.0", subnetMask: "255.0.0.0"),
            ]
        }
        networkSettings.iPv4Settings = ipv4Settings
        
        let proxySettings = NEProxySettings()
        proxySettings.httpEnabled = true
        proxySettings.httpServer = NEProxyServer(address: "127.0.0.1", port: proxyPort)
        proxySettings.httpsEnabled = true
        proxySettings.httpsServer = NEProxyServer(address: "127.0.0.1", port: proxyPort)
        proxySettings.excludeSimpleHostnames = true
        // This will match all domains
        proxySettings.matchDomains = [""]
        proxySettings.exceptionList = [""]
        networkSettings.proxySettings = proxySettings
        
        if enablePacketProcessing {
            let DNSSettings = NEDNSSettings(servers: ["198.18.0.1"])
            DNSSettings.matchDomains = [""]
            DNSSettings.matchDomainsNoSearch = false
            networkSettings.dnsSettings = DNSSettings
        }
        
        setTunnelNetworkSettings(networkSettings) {
            error in
            guard error == nil else {
                DDLogError("Encountered an error setting up the network: \(error.debugDescription)")
                completionHandler(error)
                return
            }
            
            
            if !self.started{
                self.proxyServer = GCDHTTPProxyServer(address: IPAddress(fromString: "127.0.0.1"), port: NEKit.Port(port: UInt16(self.proxyPort)))
                try! self.proxyServer.start()
                self.addObserver(self, forKeyPath: "defaultPath", options: .initial, context: nil)
            }else{
                self.proxyServer.stop()
                try! self.proxyServer.start()
            }
            
            completionHandler(nil)
            
            
            if self.enablePacketProcessing {
                if self.started{
                    self.interface.stop()
                }
                
                self.interface = TUNInterface(packetFlow: self.packetFlow)
                
                
                let fakeIPPool = try! IPPool(range: IPRange(startIP: IPAddress(fromString: "198.18.1.1")!, endIP: IPAddress(fromString: "198.18.255.255")!))
                
                
                let dnsServer = DNSServer(address: IPAddress(fromString: "198.18.0.1")!, port: NEKit.Port(port: 53), fakeIPPool: fakeIPPool)
                let resolver = UDPDNSResolver(address: IPAddress(fromString: "114.114.114.114")!, port: NEKit.Port(port: 53))
                dnsServer.registerResolver(resolver)
                self.interface.register(stack: dnsServer)
                
                DNSServer.currentServer = dnsServer
                
                let udpStack = UDPDirectStack()
                self.interface.register(stack: udpStack)
                let tcpStack = TCPStack.stack
                tcpStack.proxyServer = self.proxyServer
                self.interface.register(stack:tcpStack)
                self.interface.start()
            }
            self.started = true

        }
        
    }
    

	override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        if enablePacketProcessing {
            interface.stop()
            interface = nil
            DNSServer.currentServer = nil
        }
        
        if(proxyServer != nil){
            proxyServer.stop()
            proxyServer = nil
            RawSocketFactory.TunnelProvider = nil
        }
        completionHandler()
        
        exit(EXIT_SUCCESS)
	}
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "defaultPath" {
            if self.defaultPath?.status == .satisfied && self.defaultPath != lastPath{
                if(lastPath == nil){
                    lastPath = self.defaultPath
                }else{
                    let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        self.startTunnel(options: nil){_ in}
                    }
                }
            }else{
                lastPath = defaultPath
            }
        }
        
    }

}
