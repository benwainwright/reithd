import Foundation
import Logging

class ShellConfigurer: ReithConfigurer {
  
  init() {
    _reithStatus = nil
  }
  
  private var _reithStatus: ReithStatus?
  var reithStatus: ReithStatus {
    set {
      _reithStatus = newValue
    }
    
    get {
      return _reithStatus!
    }
  }

  
  func configureForReith() -> Void {
    doConfigure(enabled: reithStatus.isConnected())
  }
  
  func doConfigure(enabled: Bool) -> Void {
    os_log("Configuring shells", log: OSLog.default, type: .debug)
    for pid in ShellConfigurer.getConfiguredShellPids() {
      os_log("Configuring shells", log: OSLog.default, type: .debug)
      var signal: Int32
      
      if enabled {
        os_log("Sending SIGUSR1 to process with pid %d", log: OSLog.default, type: .debug, pid)
        signal = SIGUSR1
      } else {
        os_log("Sending SIGUSR2 to process with pid %d", log: OSLog.default, type: .debug, pid)
        signal = SIGUSR2
      }
      
      kill(pid, signal)
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
