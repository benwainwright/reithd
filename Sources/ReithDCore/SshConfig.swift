class SshConfig {
  static let socksConfig = """
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
}
