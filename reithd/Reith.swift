import CoreFoundation
import SystemConfiguration

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
    
    func configureReithForSystemProxy(enabled: Bool) -> Void {
        
    }
    
    func configureReithForShells(enabled: Bool) -> Void {
        
    }
}
