#  reithd

This project is a daemon that automatically reconfigures the user's system when connecting and disconnecting to the BBC corporate network ("Reith")

## What does it do?

When running, the daemon monitors the System Configuration database looking for changes in your DNS setup. When one occurrs, it will detect whether the new connection is a Reith network connection and reconfigure your system accordingly

### Network Location

Your network location will be switched to "BBC On Network" or "BBC Off Network" appropriately

### Shell

All shells that are configured to use reithd will automatically have their environment reconfigured with the correct proxy environment variables. In order to configure your shell, you will need to insert the following line somewhere in your `~/.zshrc` or `~/.bashrc file`:

```bash
eval "$(reithd shell)"
```

#### How this works

This will inject a script into your shell startup which creates and removes pid files in `~/.reithd`. When a change is detected, `reithd` will check this folder, collect the pid numbers and send `SIGUSR1` or `SIGUSR2` signals to each configured shell. The injected shell startup configures your shell to respond to these signals by either removing or adding proxy variables.

### SSH

Reithd will generate a file called `~/.ssh/config.reith.socks` and automatically comment out or uncomment any lines starting with `ProxyCommand`. You can make use of this file by inserting the line

```bash
include ~/.ssh/config.reith.socks
```

anywhere in your `~/.ssh/config` file




