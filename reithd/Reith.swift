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

  func configureNetworkLocation(enabled _: Bool) {}

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
