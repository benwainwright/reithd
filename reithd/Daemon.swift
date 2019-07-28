import CoreFoundation
import SystemConfiguration
import Foundation
import Darwin

func startDaemon() {
    do {
        let dnsKey = SCDynamicStoreKeyCreateNetworkGlobalEntity(kCFAllocatorDefault, kSCDynamicStoreDomainState, kSCEntNetDNS)
        try initDynamicStoreMonitoringRunLoop(callback: onDnsChange, keys: [dnsKey], patterns: nil)
        print("Reithd starting...")
        CFRunLoopRun()
    } catch(InitError.withMessage(let message)) {
        print(message)
        exit(1)
    } catch {
        print("Failed to initialise daemon...")
        exit(1)
    }
}

func onDnsChange(store: SCDynamicStore, changed: CFArray, info: UnsafeMutableRawPointer?) {
    let reith = Reith(store: store)
    if reith.isConnected() {
        if !reith.isConfigured() {
            reith.configureNetworkLocation(enabled: true)
        }
        reith.configureShells(enabled: true)
    } else {
        if reith.isConfigured() {
            reith.configureNetworkLocation(enabled: true)
        }
        reith.configureShells(enabled: false)
    }
}

func initDynamicStoreMonitoringRunLoop(callback:  @escaping SCDynamicStoreCallBack, keys: [CFString]? = nil, patterns: [CFString]? = nil) throws -> Void {
    let store = SCDynamicStoreCreate(kCFAllocatorDefault, "reithd" as CFString, callback, nil)
    if store == nil {
        throw InitError.withMessage("Could not create dynamic store")
    }

    let loop = SCDynamicStoreCreateRunLoopSource(kCFAllocatorDefault, store!, 0)
    if store == nil {
        throw InitError.withMessage("Could not create dynamic store runloop source")
    }

    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop!, CFRunLoopMode.defaultMode)

    if !SCDynamicStoreSetNotificationKeys(store!, keys as CFArray?, patterns as CFArray?) {
        throw InitError.withMessage("Failed to set notification keys")
    }
}
