import CoreFoundation
import Darwin
import Foundation
import SystemConfiguration

func startDaemon() {
  do {
    let dnsKey = SCDynamicStoreKeyCreateNetworkGlobalEntity(kCFAllocatorDefault, kSCDynamicStoreDomainState, kSCEntNetDNS)
    try initDynamicStoreMonitoringRunLoop(callback: onDnsChange, keys: [dnsKey], patterns: nil)
    print("Reithd starting...")
    CFRunLoopRun()
  } catch let ReithdError.withMessage(message) {
    print(message)
    exit(1)
  } catch {
    print("Failed to initialise daemon...")
    exit(1)
  }
}

func onDnsChange(store: SCDynamicStore, changed _: CFArray, info _: UnsafeMutableRawPointer?) {
  let reith = Reith(store: store)
  if reith.isConnected() {
    if !reith.isConfigured() {
      reith.configureNetworkLocation(enabled: true)
    }
    reith.configureShells(enabled: true)
    reith.configureSshConfig(enabled: true)
  } else {
    if reith.isConfigured() {
      reith.configureNetworkLocation(enabled: false)
    }
    reith.configureShells(enabled: false)
    reith.configureSshConfig(enabled: false)
  }
}

func initDynamicStoreMonitoringRunLoop(callback: @escaping SCDynamicStoreCallBack, keys: [CFString]? = nil, patterns: [CFString]? = nil) throws {
  guard let store = SCDynamicStoreCreate(kCFAllocatorDefault, "reithd" as CFString, callback, nil) else {
    throw ReithdError.withMessage("Could not create dynamic store")
  }
  
  guard let loop = SCDynamicStoreCreateRunLoopSource(kCFAllocatorDefault, store, 0) else {
    throw ReithdError.withMessage("Could not create dynamic store runloop source")
  }
  
  CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, CFRunLoopMode.defaultMode)
  
  if !SCDynamicStoreSetNotificationKeys(store, keys as CFArray?, patterns as CFArray?) {
    throw ReithdError.withMessage("Failed to set notification keys")
  }
}
