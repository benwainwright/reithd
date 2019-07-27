import CoreFoundation
import SystemConfiguration
import AppKit

class Reith {
    let store: Store

    init(store: SCDynamicStore) {
        self.store = Store(store: store)
    }

    func isConfigured() -> Bool {
        let proxiesKey = SCDynamicStoreKeyCreateNetworkGlobalEntity(kCFAllocatorDefault, kSCDynamicStoreDomainState, kSCEntNetProxies)
        if let proxiesDict: [String: String] = self.store.getDictionaryValue(key: proxiesKey) {
            guard let httpsProxy = proxiesDict[Constants.DynamicStoreDictionaryKeys.httpsProxy] else {
                return false
            }
            return httpsProxy == Constants.Config.reithHttpUrl

        }
        return false
    }

    func isConnected() -> Bool {
        return false
    }
    
    public static func getShellProccessIds() -> [Int] {
        return []
    }
    
    func configureReithForSystemProxy(enabled: Bool) -> Void {
        
    }
    
    func configureReithForShells(enabled: Bool) -> Void {
        
    }
}
