import CoreFoundation
import Darwin
import Foundation
import SystemConfiguration
import Logging

var reithConfigurers: [ReithConfigurer] =
[
  SshConfigurer(),
  NetworkLocationConfigurer(),
  ShellConfigurer(),
  SpotifyConfigurer()
]

func startDaemon() {
  do {
    let dnsKey = SCDynamicStoreKeyCreateNetworkGlobalEntity(kCFAllocatorDefault, kSCDynamicStoreDomainState, kSCEntNetDNS)
    try initDynamicStoreMonitoringRunLoop(callback: onDnsChange, keys: [dnsKey], patterns: nil)
    os_log("Reithd starting", log: OSLog.default, type: .info)
    CFRunLoopRun()
  } catch let ReithdError.withMessage(message) {
    os_log("%@", log: OSLog.default, type: .error, message)
    exit(1)
  } catch {
    os_log("Failed to initialise daemon...", log: OSLog.default, type: .error)
    exit(1)
  }
}

func onDnsChange(store: SCDynamicStore, changed _: CFArray, info _: UnsafeMutableRawPointer?) {
  os_log("Reithd triggered", log: OSLog.default, type: .debug)
  let reithStatus = ReithStatus(store: store)
  
  for var configurer in reithConfigurers {
    configurer.reithStatus = reithStatus
    configurer.configureForReith()
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
