import Foundation
import Logging

class Utils {
    static func runCommand(command: String, args: [String]) throws -> String {
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
