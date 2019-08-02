//
//  NetworkLocationConfigurer.swift
//  reiithdtests
//
//  Created by Ben Wainwright on 02/08/2019.
//  Copyright © 2019 Ben Wainwright. All rights reserved.
//

import Foundation
import Logging

class NetworkLocationConfigurer : ReithConfigurer {
  
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
    
    let configured = reithStatus.isConfigured()
    let connected = reithStatus.isConnected()
    
    if connected && !configured {
      doConfigure(enabled: true)
    } else if !connected && configured {
      doConfigure(enabled: false)
    }
  }

  private func doConfigure(enabled: Bool) -> Void {
    os_log("Configuring network location", log: OSLog.default, type: .debug)
    let onOrOff = enabled
      ? Constants.Strings.bbcOnNetwork
      : Constants.Strings.bbcOffNetwork
    
    _ = try! NetworkLocationConfigurer.runCommand(
      command:Constants.NetworkSetup.binaryLocation,
      args:[
        Constants.NetworkSetup.switchNetworkLocationFlag,
        onOrOff
    ])
  }
  
  private static func runCommand(command: String, args: [String]) throws -> String  {

    os_log("Running command %@ %@", log: OSLog.default, type: .debug, command, args.joined(separator: " "))

    let task = Process()
    
    task.launchPath = command
    task.arguments = args
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    
    
    guard let returnVal = String(data: data, encoding: .utf8) else {
      throw ReithdError.withMessage("Failed to initialise string")
    }
    
    os_log("Command return code was %@", log: OSLog.default, type: .debug, returnVal)
    os_log("Command output was %@", log: OSLog.default, type: .debug, task.terminationStatus)

    return returnVal
  }
}
