import Foundation
import Logging

class SshConfigurer: ReithConfigurer {
    static let configFile = """
    # This file was generated automatically and will be automatically
    # edited in place by reithd when you connect and disconnect to the
    # BBC corporate network.
    #
    # To use, add the line "include ~/.ssh/\(Constants.Config.sshConfigFile)"
    # to your ~/.ssh/config file

    Host github.com
      ProxyCommand nc -x "\(Constants.Config.reithSocksUrl)" -X 5 %h %p

    Host ?.access.*.cloud.bbc.co.uk
      ProxyCommand nc -x "\(Constants.Config.reithSocksUrl)" -X 5 %h %p
    """

    private func unCommentLinesStartingWith(string: String, inContent: String) -> String {
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

    private func commentLinesStartingWith(string: String, inContent: String) -> String {
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

    private func doConfigure(enabled: Bool) {
        os_log("Configuring SSH config", log: OSLog.default, type: .debug)
        let fileManager = FileManager.default
        let sshFolder = URL(string: "\(fileManager.homeDirectoryForCurrentUser).ssh")!.path

        if fileManager.fileExists(atPath: sshFolder) {
            let configFile = "\(sshFolder)/\(Constants.Config.sshConfigFile)"

            createFileIfNotExists(atPath: configFile, withContents: SshConfig.socksConfig)

            do {
                os_log("Loading %@", log: OSLog.default, type: .debug, configFile)
                var configFileContents = try String(contentsOfFile: configFile)

                if enabled {
                    configFileContents = unCommentLinesStartingWith(string: Constants.Strings.sshProxyCommand, inContent: configFileContents)
                } else {
                    configFileContents = commentLinesStartingWith(string: Constants.Strings.sshProxyCommand, inContent: configFileContents)
                }
                os_log("Writing %@ back to disk", log: OSLog.default, type: .debug, configFile)
                try configFileContents.write(toFile: configFile, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                os_log("Access to %@ failed", log: OSLog.default, type: .error, configFile)
            }
        }
    }

    public override func configureForReith() {
        doConfigure(enabled: reithStatus.isConnected())
    }

    private func createFileIfNotExists(atPath: String, withContents: String) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: atPath) {
            os_log("Creating %@", log: OSLog.default, type: .debug, atPath)
            fileManager.createFile(atPath: atPath, contents: Data(withContents.utf8), attributes: nil)
        }
    }
}
