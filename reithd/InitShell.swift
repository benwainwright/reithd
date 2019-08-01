import Foundation

class InitShell {
  static let code = """
reithd-set-shell-config() {
  export http_proxy_port="\(Constants.Config.reithHttpPort)"
  export http_proxy_url="\(Constants.Config.reithHttpUrl)"
  export ftp_proxy="\(Constants.Config.reithFtpUrl)"
  export socks_proxy="\(Constants.Config.reithSocksUrl)"
  export http_proxy="$http_proxy_url:$http_proxy_port"
  export https_proxy="$http_proxy"
  export HTTP_PROXY="$http_proxy"
  export HTTPS_PROXY="$https_proxy"
  export FTP_PROXY="$ftp_proxy"
  export ALL_PROXY="$http_proxy"
  export NO_PROXY="localhost,127.0.0.1"
  export npm_config_proxy="http://$HTTP_PROXY"
  export npm_config_https_proxy="http://$HTTPS_PROXY"
}

reithd-clear-shell-config() {
  if [ ! -z "$http_proxy" ] || \
     [ ! -z "$HTTP_PROXY" ] || \
     [ ! -z "$https_proxy" ] || \
     [ ! -z "$HTTPS_PROXY" ] || \
     [ ! -z "$FTP_PROXY" ] || \
     [ ! -z "$ftp_proxy" ] || \
     [ ! -z "$npm_config_proxy" ] || \
     [ ! -z "$NO_PROXY" ] || \
     [ ! -z "$npm_config_https_proxy" ] || \
     [ ! -z "$ALL_PROXY" ]; then
    unset http_proxy HTTP_PROXY https_proxy \
      HTTPS_PROXY FTP_PROXY ftp_proxy \
      ALL_PROXY npm_config_proxy \
      npm_config_https_proxy NO_PROXY
  fi
}

reithd-configure-git-for-no-reith() {
  if command -v hub > /dev/null; then
    unalias hub 2> /dev/null
  else
    unalias git 2> /dev/null
  fi
}

reithd-configure-git-for-reith() {
   if command -v hub > /dev/null; then
    alias hub="hub -c http.proxy=\"$HTTP_PROXY\" -c https.proxy=\"$HTTP_PROXY\""
  else
    alias git="git -c http.proxy=\"$HTTP_PROXY\""
  fi
}

reithd-configure-reith() {
    reithd-set-shell-config
    reithd-configure-git-for-reith
}

reithd-unconfigure-reith() {
    reithd-clear-shell-config
    reithd-configure-git-for-no-reith
}

if [ ! -d "$HOME/.reithd" ]; then
  mkdir "$HOME/.reithd"
fi

touch "$HOME/.reithd/$$"
if [ "$ZSH_VERSION" ]; then
  zshexit() {
    rm "$HOME/.reithd/$$"
  }
else
  trap "rm '$HOME/.reithd/$$'" EXIT
fi
trap 'reithd-configure-reith' USR1
trap 'reithd-unconfigure-reith' USR2
"""
}
