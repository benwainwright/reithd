import Foundation

class Utils {
  static func runCommand(command: String, args: [String]) throws -> String  {
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
    
    return returnVal
  }
}
