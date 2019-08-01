import AppKit
import CoreFoundation
import Foundation
import SystemConfiguration

class Reith {
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
    if let httpsProxy: String = self.store.getValueFromStoreDict(
      storeKey: proxiesKey,
      dictKey: Constants.DynamicStoreDictionaryKeys.httpsProxyKey) {
      return httpsProxy == Constants.Config.reithHttpUrl
    }
    return false
  }

  func isConnected() -> Bool {
    let dnsKey = SCDynamicStoreKeyCreateNetworkGlobalEntity(
      kCFAllocatorDefault,
      kSCDynamicStoreDomainState,
      kSCEntNetDNS
    )
    
    if let dnsDomainName: String = self.store.getValueFromStoreDict(
      storeKey: dnsKey,
      dictKey: Constants.DynamicStoreDictionaryKeys.reithDnsDomainNameKey) {
      return dnsDomainName == Constants.Config.reithDnsDomainName
    }
    
    return false
  }
  
  func configureNetworkLocation(enabled: Bool) {
    let onOrOff = enabled
      ? Constants.Strings.bbcOnNetwork
      : Constants.Strings.bbcOffNetwork
    
    _ = Utils.runCommand(
      command:Constants.Config.networkSetupLocation,
      args:[
        Constants.Strings.switchNetworkLocationFlag,
        onOrOff
    ])
  }

  func configureShells(enabled: Bool) {
    for pid in Reith.getConfiguredShellPids() {
      kill(pid, enabled ? SIGUSR1 : SIGUSR2)
    }
  }

  private static func getConfiguredShellPids() -> [pid_t] {
    let fileManager = FileManager.default
    if let url = URL(string: "\(fileManager.homeDirectoryForCurrentUser)\(Constants.Config.reithdDirName)/") {
      let enumerator = fileManager.enumerator(atPath: url.path)
      let pids = enumerator?.allObjects as? [String]
      if let returnVal = pids?.map({ Int32($0)! }) {
        return returnVal
      }
    }
    return []
  }
}
