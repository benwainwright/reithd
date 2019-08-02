import AppKit
import CoreFoundation
import Foundation
import SystemConfiguration
import Logging

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
    
    var configured = false
    
    if let httpsProxy: String = self.store.getValueFromStoreDict(
      storeKey: proxiesKey,
      dictKey: Constants.DynamicStoreDictionaryKeys.httpsProxyKey) {
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
      dictKey: Constants.DynamicStoreDictionaryKeys.reithDnsDomainNameKey) {
      connected = dnsDomainName == Constants.Config.reithDnsDomainName
    }
    
    if connected {
      os_log("Reith network is connected", log: OSLog.default, type: .debug)
    } else {
      os_log("Reith network is not connected", log: OSLog.default, type: .debug)
    }
    
    return connected
  }
  
  private func createFileIfNotExists(atPath: String, withContents: String) {
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: atPath) {
      os_log("Creating %@", log: OSLog.default, type: .debug, atPath)
      fileManager.createFile(atPath: atPath, contents:Data(withContents.utf8), attributes:nil)
    }
  }
  
  func unCommentLinesStartingWith(string: String, inContent:String) -> String {
    os_log("Uncommenting lines starting with %@", log: OSLog.default, type: .debug, string)
    let lines = inContent.components(separatedBy: "\n")
    var newLines = [String]()
    for line in lines {
      let range = NSRange(location: 0, length: line.utf16.count)
      let regex = try! NSRegularExpression(pattern: "^\\s*#\\s*(\(string).*)$")
      if let matchResult = regex.firstMatch(in: line, options: [], range: range) {
        if let commandRange = Range(matchResult.range(at: 1), in: line) {
          newLines.append("  \(String(line[commandRange]))")
        }
      } else {
        newLines.append(line)
      }
    }
    return newLines.joined(separator: "\n")
  }
  
  func commentLinesStartingWith(string: String, inContent:String) -> String {
    os_log("Commenting lines starting with %@", log: OSLog.default, type: .debug, string)
    let lines = inContent.components(separatedBy: "\n")
    var newLines = [String]()
    for line in lines {
      let range = NSRange(location: 0, length: line.utf16.count)
      let regex = try! NSRegularExpression(pattern: "^\\s*(\(string).*)$")
      if let matchResult = regex.firstMatch(in: line, options: [], range: range) {
        if let commandRange = Range(matchResult.range(at: 1), in: line) {
          newLines.append("# \(String(line[commandRange]))")
        }
      } else {
        newLines.append(line)
      }
    }
    return newLines.joined(separator: "\n")
  }
  
  func configureSshConfig(enabled: Bool) {
    os_log("Configuring SSH config", log: OSLog.default, type: .debug)
    let fileManager = FileManager.default
    let sshFolder = URL(string: "\(fileManager.homeDirectoryForCurrentUser).ssh")!.path
    
    if fileManager.fileExists(atPath: sshFolder) {
      let configFile = "\(sshFolder)/\(Constants.Config.sshConfigFile)"
      
      createFileIfNotExists(atPath: configFile, withContents: SshConfig.socksConfig)
      
      do {
        os_log("Loading %@", log: OSLog.default, type: .debug, configFile)
        var configFileContents = try String(contentsOfFile: configFile)
        
        if(enabled) {
          configFileContents = unCommentLinesStartingWith(string: Constants.Strings.sshProxyCommand, inContent: configFileContents)
        } else {
          configFileContents = unCommentLinesStartingWith(string: Constants.Strings.sshProxyCommand, inContent: configFileContents)
        }
        os_log("Writing %@ back to disk", log: OSLog.default, type: .debug, configFile)
        try configFileContents.write(toFile:configFile, atomically: true, encoding: String.Encoding.utf8)
      } catch {
        os_log("Access to %@ failed", log: OSLog.default, type: .error, configFile)
      }
    }
  }
  
  func configureNetworkLocation(enabled: Bool) {
    os_log("Configuring network location", log: OSLog.default, type: .debug)
    let onOrOff = enabled
      ? Constants.Strings.bbcOnNetwork
      : Constants.Strings.bbcOffNetwork
    
    _ = try! Utils.runCommand(
      command:Constants.NetworkSetup.binaryLocation,
      args:[
        Constants.NetworkSetup.switchNetworkLocationFlag,
        onOrOff
    ])
  }
  
  func configureShells(enabled: Bool) {
    os_log("Configuring shells", log: OSLog.default, type: .debug)
    for pid in Reith.getConfiguredShellPids() {
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
