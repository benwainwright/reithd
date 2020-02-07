import Foundation
import Logging

class NetworkLocationConfigurer: ReithConfigurer {
  public override func configureForReith() {
    let configured = reithStatus.isConfigured()
    let connected = reithStatus.isConnected()

    if connected, !configured {
      doConfigure(enabled: true)
    } else if !connected, configured {
      doConfigure(enabled: false)
    }
  }

  private func doConfigure(enabled: Bool) {
    os_log("Configuring network location", log: OSLog.default, type: .debug)
    let onOrOff = enabled
      ? Constants.Strings.bbcOnNetwork
      : Constants.Strings.bbcOffNetwork

    _ = try! NetworkLocationConfigurer.runCommand(
      command: Constants.NetworkSetup.binaryLocation,
      args: [
        Constants.NetworkSetup.switchNetworkLocationFlag,
        onOrOff,
      ]
    )
  }

  private static func runCommand(command: String, args: [String]) throws -> String {
    os_log("Running command %@ %@", log: OSLog.default, type: .debug, command,
           args.joined(separator: " "))

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
    task.waitUntilExit()

    os_log("Command return code was %d", log: OSLog.default, type: .debug, task.terminationStatus)
    os_log("Command output was '%@'", log: OSLog.default, type: .debug, returnVal)

    return returnVal
  }
}
