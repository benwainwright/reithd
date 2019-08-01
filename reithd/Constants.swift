import Foundation

struct Constants {

  struct Config {
    static let reithHttpUrl = "www-cache.reith.bbc.co.uk"
    static let reithHttpPort = 80
    static let reithFtpUrl = "ftp-gw.reith.bbc.co.uk:21"
    static let reithDnsDomainName = "national.core.bbc.co.uk"
    static let reithSocksUrl = "socks-gw.reith.bbc.co.uk:1080"
    static let reithdDirName = ".reithd"
    static let networkSetupLocation = "/usr/sbin/networksetup"
    static let sshConfigFile = "config.reith.socks"
  }
  
  struct Strings {
    static let bbcOnNetwork = "BBC On Network"
    static let bbcOffNetwork = "BBC Off Network"
    static let switchNetworkLocationFlag = "-switchtolocation"
    static let sshProxyCommand = "ProxyCommand"
  }

  struct DynamicStoreDictionaryKeys {
    static let httpsProxyKey = "HTTPSProxy"
    static let reithDnsDomainNameKey = "DomainName"
  }
  
  struct Commands {
    static let startCommand = "start"
    static let initShell = "shell"
  }

}
