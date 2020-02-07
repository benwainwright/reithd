import CoreFoundation
import Darwin
import Foundation
import SystemConfiguration

func parseCommandLine(args: [String]) -> (positional: [String], named: [String: String]) {
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

public final class CommandLineTool {
  private let arguments: (positional: [String], named: [String: String])

  public init(arguments: [String] = CommandLine.arguments) {
    self.arguments = parseCommandLine(args: arguments)
  }

  public func run() throws {
    if arguments.positional.count < 2 {
      print("Error: invalid usage")
      exit(1)
    }

    if arguments.positional[1] == Constants.Commands.initShell {
      print(ShellConfigurer.shellScript)
    } else if arguments.positional[1] == Constants.Commands.startCommand {
      startDaemon()
    }
  }
}
