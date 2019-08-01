import Foundation

class Utils {
  static func runCommand(command: String, args: [String]) -> String {
    let task = Process()

    task.launchPath = command
    task.arguments = args
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    
    return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String    
  }
}
