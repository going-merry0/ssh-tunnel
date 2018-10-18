# SSH-Tunnel

Scripts for simplifying management of [SSH Dynamic Tunnel](https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding#Dynamic_Port_Forwarding).

You my heard MyEnTunnel in Windows or [SSH Proxy](https://itunes.apple.com/cn/app/ssh-proxy/id597790822?l=en&mt=12) in OSX, this script does what them do just via an easy-to-use command line.

## Install

For Ubuntu and OSX, just run:

```bash
wget -qO- https://raw.githubusercontent.com/hsiaosiyuan0/ssh-tunnel/master/install.sh | bash
```

For other \*nix platform, you need to install `expect` manually via the platform specific pkg manager.

## Usage

### Setup

| Option   | Meaning                                    |
| -------- | ------------------------------------------ |
| --host   | remote ssh host                            |
| --port   | remote ssh port                            |
| --user   | remote ssh username                        |
| --pass   | remote ssh password                        |
| --key    | file path of the private key of remote ssh |
| --listen | local port                                 |
| --action | start \| stop \| restart                   |

```bash
# choose to use password to do login
$ ssh-tunnel --host=46.76.166.185 --port=22 --user=root --pass=password --listen=7070

# or choose to use key to do login
$ ssh-tunnel --host=46.76.166.185 --port=22 --user=root --pass="" --key="file_path_of_your_private_key" --listen=7070
```

A config file will be generated at `~/.ssh-tunnel.cfg` after above command succeeds.

### Start

```bash
$ ssh-tunnel --action=start
```

### Stop

```bash
$ ssh-tunnel --action=stop
```

### Restart

```bash
$ ssh-tunnel --action=restart
```
