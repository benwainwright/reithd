import Foundation
import Logging

public class Utils {
  static func parseCommandLine(args: [String]) -> (positional: [String], named: [String: String]) {
    var named = [String: String]()
    var positional = [String]()
    var i = 0
    while i < args.count {
      if args[i].hasPrefix("--"), i < args.count - 1 {
        let nameIndex = args[i].index(args[i].startIndex, offsetBy: 2)
        let name = String(args[i][nameIndex...])
        named[name] = args[i + 1]
        i += 1
      } else {
        positional.append(args[i])
      }
      i += 1
    }
    return (positional: positional, named: named)
  }

  static func runCommand(command: String, args: [String]) throws -> String {
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

    os_log("Command return code was %@", log: OSLog.default, type: .debug, returnVal)
    os_log("Command output was %@", log: OSLog.default, type: .debug, task.terminationStatus)

    return returnVal
  }
}
