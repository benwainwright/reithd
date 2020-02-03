import CoreFoundation
import Darwin
import Foundation
import SystemConfiguration

let args = Utils.parseCommandLine(args: CommandLine.arguments)

if args.positional.count < 2 {
    print("Error: invalid usage")
    exit(1)
}

if args.positional[1] == Constants.Commands.initShell {
    print(ShellConfigurer.shellScript)
} else if args.positional[1] == Constants.Commands.startCommand {
    startDaemon()
}
