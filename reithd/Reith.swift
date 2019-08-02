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
  
  private func createFileIfNotExists(atPath: String, withContents: String) {
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: atPath) {
      fileManager.createFile(atPath: atPath, contents:Data(withContents.utf8), attributes:nil)
    }
  }
  
  func unCommentLinesStartingWith(string: String, inContent:String) -> String {
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
    let fileManager = FileManager.default
    let sshFolder = URL(string: "\(fileManager.homeDirectoryForCurrentUser).ssh")!.path
    
    if fileManager.fileExists(atPath: sshFolder) {
      let configFile = "\(sshFolder)/\(Constants.Config.sshConfigFile)"
      
      createFileIfNotExists(atPath: configFile, withContents: SshConfig.socksConfig)
      
      do {
        var configFileContents = try String(contentsOfFile: configFile)
        if(enabled) {
          configFileContents = unCommentLinesStartingWith(string: Constants.Strings.sshProxyCommand, inContent: configFileContents)
        } else {
          configFileContents = unCommentLinesStartingWith(string: Constants.Strings.sshProxyCommand, inContent: configFileContents)
        }
        try configFileContents.write(toFile:configFile, atomically: true, encoding: String.Encoding.utf8)
      } catch {
        // Do nothing
      }
    }
  }
  
  func configureNetworkLocation(enabled: Bool) {
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
