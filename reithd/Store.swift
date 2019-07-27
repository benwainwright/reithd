import CoreFoundation
import SystemConfiguration

class Store {
    let store: SCDynamicStore

    init(store: SCDynamicStore) {
        self.store = store
    }

    func getDictionaryValue<K, V>(key: CFString) -> [K: V]? {

        guard let plist = SCDynamicStoreCopyValue(self.store, key) else {
            return nil
        }

        return plist as? [K: V]
    }
}
