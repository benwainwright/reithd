import AppKit
import CoreFoundation
import Foundation
import Logging
import SystemConfiguration

class ReithStatus {
    let store: Store

    init(store: SCDynamicStore) {
        self.store = Store(store: store)
    }

    func isConfigured() -> Bool {
        let proxiesKey = SCDynamicStoreKeyCreateNetworkGlobalEntity(
            kCFAllocatorDefault,
            kSCDynamicStoreDomainState,
            kSCEntNetProxies
        )

        var configured = false

        if let httpsProxy: String = self.store.getValueFromStoreDict(
            storeKey: proxiesKey,
            dictKey: Constants.DynamicStoreDictionaryKeys.httpsProxyKey
        ) {
            os_log("HTTPS proxy is currently set to %@", log: OSLog.default, type: .debug, httpsProxy)
            configured = httpsProxy == Constants.Config.reithHttpUrl
        }

        if configured {
            os_log("Network location is currently set to '%@'", log: OSLog.default, type: .debug, Constants.Strings.bbcOnNetwork)
        } else {
            os_log("Network location is currently set to '%@'", log: OSLog.default, type: .debug, Constants.Strings.bbcOffNetwork)
        }

        return configured
    }

    func isConnected() -> Bool {
        let dnsKey = SCDynamicStoreKeyCreateNetworkGlobalEntity(
            kCFAllocatorDefault,
            kSCDynamicStoreDomainState,
            kSCEntNetDNS
        )

        var connected = false

        if let dnsDomainName: String = self.store.getValueFromStoreDict(
            storeKey: dnsKey,
            dictKey: Constants.DynamicStoreDictionaryKeys.reithDnsDomainNameKey
        ) {
            os_log("DNS Domain name is currently set to %@", log: OSLog.default, type: .debug, dnsDomainName)
            connected = dnsDomainName == Constants.Config.reithDnsDomainName
        }

        if connected {
            os_log("Reith network is connected", log: OSLog.default, type: .debug)
        } else {
            os_log("Reith network is not connected", log: OSLog.default, type: .debug)
        }

        return connected
    }
}
