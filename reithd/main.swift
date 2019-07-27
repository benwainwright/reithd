import SystemConfiguration
import Foundation
import Darwin

func onDnsChange(store: SCDynamicStore, changed: CFArray, info: UnsafeMutableRawPointer?) {
    let reith = Reith(store: store)
    if reith.isConnected() {
        if !reith.isConfigured() {
            reith.configureReithForSystemProxy(enabled: true)
        }
        reith.configureReithForShells(enabled: true)
    } else {
        if reith.isConfigured() {
            reith.configureReithForSystemProxy(enabled: true)
        }
        reith.configureReithForShells(enabled: false)
    }
}

do {
    let dnsKey = SCDynamicStoreKeyCreateNetworkGlobalEntity(kCFAllocatorDefault, kSCDynamicStoreDomainState, kSCEntNetDNS)
    try initDynamicStoreMonitoringRunLoop(callback: onDnsChange, keys: [dnsKey], patterns: nil)
    print("Reithd starting...")
    CFRunLoopRun()
} catch(InitError.withMessage(let message)) {
    print(message)
    exit(1)
}
