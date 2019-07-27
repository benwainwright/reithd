import SystemConfiguration
import Foundation
import Darwin

func onDnsChange(store: SCDynamicStore, changed: CFArray, info: UnsafeMutableRawPointer?) {
    
}

let dnsKey = SCDynamicStoreKeyCreateNetworkGlobalEntity(kCFAllocatorDefault, kSCDynamicStoreDomainState, kSCEntNetDNS)

do {
    try initDynamicStoreMonitoringRunLoop(callback: onDnsChange, keys: [dnsKey], patterns: nil)
    print("Reithd starting...")
    CFRunLoopRun()
} catch(InitError.withMessage(let message)) {
    print(message)
    exit(1)
}
