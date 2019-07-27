import CoreFoundation
import SystemConfiguration

class Reith {
    let store: Store

    init(store: Store) {
        self.store = store
    }

    func isConfigured() -> Bool {
        let proxiesKey = SCDynamicStoreKeyCreateNetworkGlobalEntity(kCFAllocatorDefault, kSCDynamicStoreDomainState, kSCEntNetProxies)
        if let proxiesDict = self.store.getDictionaryValue<String, Sring>(proxiesKey) {
            guard let httpsProxy = proxiesDict["HTTPSProxy"] else {
                return false
            }
            return httpsProxy == "www-cache.reith.bbc.co.uk"

        }
        return false
    }

    func isConnected() -> Bool {
    }


}
