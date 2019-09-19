import Foundation

struct Constants {
    struct Config {
        static let reithHttpUrl = "www-cache.reith.bbc.co.uk"
        static let reithHttpPort = 80
        static let reithFtpUrl = "ftp-gw.reith.bbc.co.uk:21"
        static let reithDnsDomainName = "national.core.bbc.co.uk"
        static let reithSocksUrl = "socks-gw.reith.bbc.co.uk:1080"
        static let reithdDirName = ".reithd"
        static let sshConfigFile = "config.reith.socks"
    }

    struct Strings {
        static let bbcOnNetwork = "BBC On Network"
        static let bbcOffNetwork = "BBC Off Network"
        static let sshProxyCommand = "ProxyCommand"
    }

    struct DynamicStoreDictionaryKeys {
        static let httpsProxyKey = "HTTPSProxy"
        static let reithDnsDomainNameKey = "DomainName"
    }

    struct Spotify {
        static let prefsPath = "Library/Application Support/Spotify/prefs"
        static let proxyAddressKey = "network.proxy.addr"
        static let proxyModeKey = "network.proxy.mode"
        static let spotifyBundleIdentifier = "com.spotify.client"
        static let spotifyAppName = "Spotify"
    }

    struct NetworkSetup {
        static let binaryLocation = "/usr/sbin/networksetup"
        static let switchNetworkLocationFlag = "-switchtolocation"
    }

    struct Commands {
        static let startCommand = "start"
        static let initShell = "shell"
    }
}
