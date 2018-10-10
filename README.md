# SSH-Tunnel

Scripts for simplifying management of [SSH Dynamic Tunnel](https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding#Dynamic_Port_Forwarding).

Only supports ubuntu now.

## Install

```bash
wget -qO- https://raw.githubusercontent.com/hsiaosiyuan0/ssh-tunnel/master/install.sh | bash
```

## Usage

### Setup

Option | Meaning
-------|---------
--host | remote ssh host
--port | remote ssh port
--user | remote ssh username
--pass | remote ssh password
--key  | file path of the private key of remote ssh
--listen | local port
--action | start \| stop \| restart

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
