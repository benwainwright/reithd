import CoreFoundation
import SystemConfiguration
import Logging

class Store {
  let store: SCDynamicStore
  
  init(store: SCDynamicStore) {
    self.store = store
  }
  
  func getValueFromStoreDict<V>(storeKey: CFString, dictKey: String) -> V? {
    
    os_log("Getting value from dynamic store for key %@", log: OSLog.default, type: .debug, storeKey as String)
    
    guard let plist = SCDynamicStoreCopyValue(self.store, storeKey) else {
      os_log("Dynamic store didn't return anything", log: OSLog.default, type: .debug)
      return nil
    }
    
    guard let dict = plist as? [String: AnyObject] else {
      os_log("Value that was returned couldn't be casted to a dictionary", log: OSLog.default, type: .debug)
      return nil
    }
    
    os_log("Value that was returned was a dictionary, getting value for key %@", log: OSLog.default, type: .debug, dictKey)
    return dict[dictKey] as? V
  }
}
