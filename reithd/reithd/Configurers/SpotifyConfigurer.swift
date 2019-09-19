import Foundation
import Logging
import AppKit

class SpotifyConfigurer: ReithConfigurer {
    public override func configureForReith() {
        doConfigure(enabled: reithStatus.isConnected())
    }

    private func changeValueInConfigFile(key: String, value: String, inContent: String) -> String {
        let lines = inContent.components(separatedBy: "\n")
        var newLines = [String]()
        for line in lines {
            let parts = line.components(separatedBy: "=")
            if parts.count > 1 {
                let newValue = parts[0] == key ? value : parts[1]
                newLines.append("\(parts[0])=\(newValue)")
            } else {
                newLines.append(line)
            }
        }
        return newLines.joined(separator: "\n")
    }
  
    private func rebootSpotify() {
        let workspace = NSWorkspace.shared
        let apps = workspace.runningApplications
        for app in apps {
            if let identifier = app.bundleIdentifier {
                if identifier == Constants.Spotify.spotifyBundleIdentifier {
                    app.terminate()
                    workspace.launchApplication(Constants.Spotify.spotifyAppName)
                }
            }
        }
    }

    private func doConfigure(enabled: Bool) {
        os_log("Configuring Spotify config", log: OSLog.default, type: .debug)
        let fileManager = FileManager.default
        let prefsPath = Constants.Spotify.prefsPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let spotifyConfigFileUrl = "\(fileManager.homeDirectoryForCurrentUser)\(prefsPath!)"
        let spotifyConfigFile = URL(string: spotifyConfigFileUrl)!.path
        if fileManager.fileExists(atPath: spotifyConfigFile) {
            do {
                var configFileContents = try String(contentsOfFile: spotifyConfigFile)
                configFileContents = changeValueInConfigFile(key: Constants.Spotify.proxyModeKey, value: enabled ? "4" : "1", inContent: configFileContents)
                configFileContents = changeValueInConfigFile(key: Constants.Spotify.proxyAddressKey, value: enabled ? "\"\(Constants.Config.reithSocksUrl)@socks5\"" : "\"\"", inContent: configFileContents)
                try configFileContents.write(toFile: spotifyConfigFile, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                os_log("Access to %@ failed", log: OSLog.default, type: .error, spotifyConfigFile)
            }
            rebootSpotify()
        }
    }
}
