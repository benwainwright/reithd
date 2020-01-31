import Foundation
import Logging

class ShellConfigurer: ReithConfigurer {
    public override func configureForReith() {
        doConfigure(enabled: reithStatus.isConnected())
    }

    func doConfigure(enabled: Bool) {
        os_log("Configuring shells", log: OSLog.default, type: .debug)
        for pid in ShellConfigurer.getConfiguredShellPids() {
            os_log("Configuring shells", log: OSLog.default, type: .debug)
            var signal: Int32

            if enabled {
                os_log("Sending SIGUSR1 to process with pid %d", log: OSLog.default, type: .debug, pid)
                signal = SIGUSR1
            } else {
                os_log("Sending SIGUSR2 to process with pid %d", log: OSLog.default, type: .debug, pid)
                signal = SIGUSR2
            }

            kill(pid, signal)
        }
    }

    private static func getConfiguredShellPids() -> [pid_t] {
        let fileManager = FileManager.default
        if let url = URL(string: "\(fileManager.homeDirectoryForCurrentUser)\(Constants.Config.reithdDirName)/") {
            let enumerator = fileManager.enumerator(atPath: url.path)
            let pids = enumerator?.allObjects as? [String]
            if let returnVal = pids?.map({ Int32($0)! }) {
                return returnVal
            }
        }
        return []
    }

    public static let shellScript = """
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
      if [ ! -z "$http_proxy" ] || \\
         [ ! -z "$HTTP_PROXY" ] || \\
         [ ! -z "$https_proxy" ] || \\
         [ ! -z "$HTTPS_PROXY" ] || \\
         [ ! -z "$FTP_PROXY" ] || \\
         [ ! -z "$ftp_proxy" ] || \\
         [ ! -z "$npm_config_proxy" ] || \\
         [ ! -z "$NO_PROXY" ] || \\
         [ ! -z "$npm_config_https_proxy" ] || \\
         [ ! -z "$ALL_PROXY" ]; then
        unset http_proxy HTTP_PROXY https_proxy \\
          HTTPS_PROXY FTP_PROXY ftp_proxy \\
          ALL_PROXY npm_config_proxy \\
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
        export REITH_CONNECTED=true
    }

    reithd-unconfigure-reith() {
        reithd-clear-shell-config
        reithd-configure-git-for-no-reith
        if [ ! -z "$REITH_CONNECTED" ]; then
            unset REITH_CONNECTED
        fi
    }
    
    reithd-is-connected-to-reith() {
        local commands output

        commands=$'open\nget State:/Network/Global/DNS\\nd.show'
        output=$(echo "$commands" | scutil)
        if [[ "$output" != *"national.core.bbc.co.uk"* ]]; then
            return 1
        fi
        return 0
    }
    
    if reithd-is-connected-to-reith; then
        reithd-configure-reith
    else
        reithd-unconfigure-reith
    fi

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
