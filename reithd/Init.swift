import CoreFoundation
import Darwin
import Foundation
import SystemConfiguration


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
