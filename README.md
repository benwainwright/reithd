#  reithd

This project is a daemon that automatically reconfigures the user's system when connecting and disconnecting to the BBC corporate network ("Reith")

## Usage

At present, you can only run the daemon directly using `./reithd start`. I will be shortly be adding a homebrew install step that will put the binary in your path and install it is a launch agent

## What does it do?

When running, the daemon monitors the System Configuration database looking for changes in your DNS setup. When one occurrs, it will detect whether the new connection is a Reith network connection and reconfigure your system accordingly

### Network Location

Your network location will be switched to "BBC On Network" or "BBC Off Network" appropriately

### Shell

All shells that are configured to use reithd will automatically have their environment reconfigured with the correct proxy environment variables _immediately and transparently_. In order to configure your shell, you will need to insert the following line somewhere in your `~/.zshrc` or `~/.bashrc` file:

```bash
eval "$($PATH_TO_REITHD_FILE shell)"
```

#### How this works

This will inject a script into your shell startup which creates and removes pid files in `~/.reithd` when shell process starts up and shuts down respectively. When a change is detected, `reithd` will check this folder, collect the pid numbers and send `SIGUSR1` or `SIGUSR2` signals to each configured shell proccess. The injected shell startup script configures your shell to respond to these signals by either removing or adding proxy variables.

### SSH

Reithd will generate a file called `~/.ssh/config.reith.socks` and automatically comment out or uncomment any lines starting with `ProxyCommand` when the network changes. You can make use of this file by inserting the line

```bash
include ~/.ssh/config.reith.socks
```

anywhere in your `~/.ssh/config` file




