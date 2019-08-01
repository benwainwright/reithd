import CoreFoundation
import SystemConfiguration

class Store {
  let store: SCDynamicStore

  init(store: SCDynamicStore) {
    self.store = store
  }

  func getValueFromStoreDict<V>(storeKey: CFString, dictKey: String) -> V? {
    guard let plist = SCDynamicStoreCopyValue(self.store, storeKey) else {
      return nil
    }

    guard let dict = plist as? [String: AnyObject] else {
      return nil
    }
    
    return dict[dictKey] as? V
  }
}
