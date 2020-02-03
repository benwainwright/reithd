import Foundation

class ReithConfigurer {
    var _reithStatus: ReithStatus?
    var reithStatus: ReithStatus {
        set {
            _reithStatus = newValue
        }

        get {
            return _reithStatus!
        }
    }

    public func configureForReith() {
        fatalError("Method must be overriden by inheriting classes")
    }
}
