//
//  AssistantUtils.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 10/03/25.
//

import UIKit

struct AssistantUtils {
    
    static var appType = "ios"
    static var deviceInfo = "iphone"
    static var deviceModel = UIDevice.current.model
    static let osVersion = UIDevice.current.systemVersion
    
    #warning("Update Version String after updating sdk-version")
    static var sdkVersion = "1.0.0"
    
    static var currentTimeMillis: String {
        return String(Int(Date().timeIntervalSince1970))
    }
    
    static var networkIP: String? {
        // Fetching device's IP address
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name = String(cString: interface!.ifa_name, encoding: .utf8)
                    if name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                        let saLen = (addrFamily == UInt8(AF_INET)) ? MemoryLayout<sockaddr_in>.size : MemoryLayout<sockaddr_in6>.size
                        var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface!.ifa_addr, socklen_t(saLen), &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST)
                        address = String(cString: host)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}
