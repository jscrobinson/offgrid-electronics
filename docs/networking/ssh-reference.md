# SSH Reference

Secure Shell (SSH) for remote access, file transfer, tunneling, and security. Covers OpenSSH client and server.

---

## Connecting

```bash
# Basic connection
ssh user@hostname
ssh user@192.168.1.50
ssh pi@raspberrypi.local

# Specify port
ssh -p 2222 user@host

# Verbose (debugging connection issues)
ssh -v user@host     # verbose
ssh -vv user@host    # more verbose
ssh -vvv user@host   # maximum verbose

# Run a single command
ssh user@host "uptime"
ssh user@host "df -h && free -m"

# Run command with sudo
ssh user@host "sudo systemctl restart nginx"

# X11 forwarding (run GUI apps remotely)
ssh -X user@host
# Then run: firefox, gedit, etc. — they display on your screen
```

---

## SSH Key Authentication

Key-based auth is more secure than passwords and enables passwordless login.

### Generate a Key Pair

```bash
# Ed25519 (recommended — modern, fast, secure)
ssh-keygen -t ed25519 -C "user@machine"

# RSA (wider compatibility with older systems)
ssh-keygen -t rsa -b 4096 -C "user@machine"

# You'll be prompted for:
# - File location (default: ~/.ssh/id_ed25519)
# - Passphrase (recommended: adds protection if key is stolen)
```

This creates two files:
- `~/.ssh/id_ed25519` — private key (NEVER share this)
- `~/.ssh/id_ed25519.pub` — public key (safe to share)

### Copy Public Key to Server

```bash
# Automated method (recommended)
ssh-copy-id user@host
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@host

# Manual method (if ssh-copy-id not available)
cat ~/.ssh/id_ed25519.pub | ssh user@host "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

# Or copy and paste the content of id_ed25519.pub into:
# ~/.ssh/authorized_keys on the remote server
```

### File Permissions (critical — SSH will refuse if wrong)

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519           # private key
chmod 644 ~/.ssh/id_ed25519.pub       # public key
chmod 600 ~/.ssh/authorized_keys      # on server
chmod 600 ~/.ssh/config               # config file
```

---

## SSH Config File (~/.ssh/config)

Simplify connections with aliases and per-host settings.

```
# ~/.ssh/config

# Raspberry Pi in the field
Host pi-field
    HostName 192.168.4.10
    User pi
    IdentityFile ~/.ssh/id_ed25519
    Port 22

# Jump through a bastion host
Host internal-server
    HostName 10.0.1.50
    User admin
    ProxyJump bastion

Host bastion
    HostName bastion.example.com
    User jumpuser
    IdentityFile ~/.ssh/id_ed25519_bastion
    Port 2222

# Development server
Host dev
    HostName dev.example.com
    User deploy
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes
    LocalForward 5432 localhost:5432
    ServerAliveInterval 60
    ServerAliveCountMax 3

# GitHub (useful if SSH port 22 is blocked)
Host github.com
    HostName ssh.github.com
    Port 443
    User git
    IdentityFile ~/.ssh/id_ed25519

# Wildcard — apply to all hosts
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    AddKeysToAgent yes
    IdentitiesOnly yes
```

Usage:
```bash
ssh pi-field        # instead of: ssh -i ~/.ssh/id_ed25519 pi@192.168.4.10
ssh dev             # auto-forwards port 5432
ssh internal-server # auto-jumps through bastion
```

---

## SSH Tunneling

### Local Port Forward (-L)

Access a remote service through a local port. Traffic flows: local port -> SSH server -> target.

```bash
# Forward local port 8080 to remote's localhost:80
ssh -L 8080:localhost:80 user@remote-server
# Now: http://localhost:8080 reaches remote's web server

# Forward to a third-party host through the SSH server
ssh -L 5432:db-server:5432 user@bastion
# Now: localhost:5432 reaches db-server:5432 via bastion

# Multiple forwards
ssh -L 8080:localhost:80 -L 5432:db:5432 user@host

# Background tunnel (no shell)
ssh -fNL 8080:localhost:80 user@host
# -f = background after auth
# -N = no remote command
```

Use case: Access a web dashboard on a Pi that's only on a private network.

### Remote Port Forward (-R)

Expose a local service through the remote server. Traffic flows: remote port -> SSH client -> target.

```bash
# Make local port 3000 accessible on remote's port 8080
ssh -R 8080:localhost:3000 user@remote-server
# Now: remote-server:8080 reaches your local :3000

# Expose a local device through a public server
ssh -R 80:192.168.1.50:80 user@public-server
# Now: public-server:80 reaches your local device at 192.168.1.50:80
```

Use case: Make a local dev server accessible from the internet through a VPS.

### Dynamic Port Forward (-D) — SOCKS Proxy

Create a SOCKS proxy that tunnels all traffic through the SSH server.

```bash
ssh -D 1080 user@remote-server
# Configure browser/app to use SOCKS5 proxy: localhost:1080
# All traffic is encrypted through the SSH tunnel

# Background SOCKS proxy
ssh -fND 1080 user@remote-server
```

Use case: Browse the internet through a remote server's connection.

---

## File Transfer

### SCP (Secure Copy)

```bash
# Copy file to remote
scp file.txt user@host:/home/user/
scp file.txt user@host:~/                    # shorthand for home dir

# Copy file from remote
scp user@host:/var/log/syslog ./syslog.txt

# Copy directory (recursive)
scp -r mydir/ user@host:~/mydir/

# Specify port
scp -P 2222 file.txt user@host:~/

# Use SSH config host alias
scp file.txt pi-field:~/
```

### SFTP (SSH File Transfer Protocol)

Interactive file browser over SSH:

```bash
sftp user@host
sftp> ls                    # list remote files
sftp> lls                   # list local files
sftp> cd /var/log           # change remote dir
sftp> lcd ~/downloads       # change local dir
sftp> get syslog            # download file
sftp> get -r mydir/         # download directory
sftp> put file.txt          # upload file
sftp> put -r mydir/         # upload directory
sftp> mkdir newdir          # create remote dir
sftp> rm file.txt           # delete remote file
sftp> bye                   # exit
```

### rsync over SSH (best for syncing)

```bash
# Sync local to remote
rsync -avz --progress ./data/ user@host:~/data/

# Sync remote to local
rsync -avz user@host:~/data/ ./data/

# Flags:
# -a = archive (recursive, preserves permissions, timestamps, etc.)
# -v = verbose
# -z = compress during transfer
# --progress = show progress
# --delete = delete files on destination that don't exist on source
# -e "ssh -p 2222" = use non-standard SSH port

# Dry run (see what would change)
rsync -avzn --delete ./data/ user@host:~/data/
```

---

## SSH Agent

The SSH agent holds your decrypted private keys in memory, so you don't re-enter passphrases.

```bash
# Start agent
eval "$(ssh-agent -s)"

# Add key
ssh-add ~/.ssh/id_ed25519
ssh-add    # adds default keys

# List loaded keys
ssh-add -l

# Remove all keys
ssh-add -D

# Agent forwarding (use your local keys on remote servers)
ssh -A user@host
# On the remote host, you can now SSH to other servers using your local keys
# WARNING: Only use agent forwarding with trusted servers
```

---

## Multiplexing (ControlMaster)

Reuse a single SSH connection for multiple sessions. Speeds up subsequent connections dramatically.

Add to `~/.ssh/config`:

```
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
```

```bash
# Create the sockets directory
mkdir -p ~/.ssh/sockets

# First connection opens the master
ssh user@host

# Subsequent connections reuse it (instant, no re-auth)
ssh user@host        # new shell
scp file user@host:  # uses existing connection
sftp user@host       # uses existing connection

# Check master status
ssh -O check user@host

# Close master connection
ssh -O exit user@host
```

---

## tmux / screen (Persistent Sessions)

SSH sessions die when the connection drops. Use a terminal multiplexer for persistence.

### tmux (recommended)

```bash
# Install
sudo apt install tmux

# Start new session
tmux
tmux new -s mysession

# Detach (session keeps running)
Ctrl+b, then d

# Reattach
tmux attach -t mysession
tmux a    # attach to most recent

# List sessions
tmux ls

# Kill session
tmux kill-session -t mysession

# Common keybindings (Ctrl+b, then...):
# d       detach
# c       new window
# n       next window
# p       previous window
# 0-9     switch to window N
# %       split pane vertically
# "       split pane horizontally
# arrow   switch between panes
# x       kill pane
# [       scroll mode (q to exit, arrows/PgUp/PgDn to scroll)
# z       zoom/unzoom pane (fullscreen toggle)
```

### screen (simpler, widely available)

```bash
# Start
screen
screen -S mysession

# Detach
Ctrl+a, then d

# Reattach
screen -r mysession
screen -r    # if only one session

# List
screen -ls
```

---

## Security Hardening

Edit `/etc/ssh/sshd_config` on the server:

### Disable Password Authentication

```ini
# /etc/ssh/sshd_config
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no                          # or keep yes for other PAM features
```

### Change Default Port

```ini
Port 2222   # any non-standard port, reduces automated attacks
```

### Restrict Users

```ini
AllowUsers pi admin               # only these users can SSH
# or
AllowGroups sshusers              # only this group
```

### Other Hardening

```ini
PermitRootLogin no                # never allow root SSH
MaxAuthTries 3                    # lock out after 3 failed attempts
LoginGraceTime 30                 # 30 seconds to authenticate
X11Forwarding no                  # disable unless needed
PermitEmptyPasswords no
ClientAliveInterval 300           # disconnect idle clients after 5 min
ClientAliveCountMax 2
```

After changes:
```bash
# Test config before restarting (important!)
sudo sshd -t

# Restart SSH
sudo systemctl restart sshd

# IMPORTANT: Keep an existing SSH session open while testing!
# If the config is wrong, you could lock yourself out.
```

### fail2ban (Block Brute Force Attacks)

```bash
sudo apt install fail2ban

# Create local config
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
```

Key settings in `/etc/fail2ban/jail.local`:

```ini
[sshd]
enabled = true
port = 2222          # match your SSH port
filter = sshd
logpath = /var/log/auth.log
maxretry = 3         # ban after 3 failures
bantime = 3600       # ban for 1 hour (seconds)
findtime = 600       # within 10 minutes
```

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Check status
sudo fail2ban-client status sshd

# Unban an IP
sudo fail2ban-client set sshd unbanip 192.168.1.100
```

---

## Common Patterns

### Keep SSH Running After Disconnect

```bash
# Use tmux or screen (see above)

# Or use nohup
ssh user@host "nohup ./long-script.sh > output.log 2>&1 &"

# Or use systemd on the remote
ssh user@host "sudo systemctl start my-service"
```

### SSH Through a Firewall

```bash
# If port 22 is blocked, try port 443 (usually open)
# On server, add to /etc/ssh/sshd_config:
# Port 22
# Port 443

# Connect on port 443
ssh -p 443 user@host
```

### Copy SSH Key to Multiple Hosts

```bash
for host in pi1 pi2 pi3 sensor1 sensor2; do
    ssh-copy-id -i ~/.ssh/id_ed25519.pub "pi@${host}.local"
done
```

### Quick Reverse Tunnel (Access Home Pi from Anywhere)

On the Pi (at home, behind NAT):
```bash
# Create persistent reverse tunnel to a VPS
ssh -fNR 2222:localhost:22 user@my-vps.com
# This maps VPS:2222 -> Pi:22
```

From anywhere:
```bash
# Connect to the Pi through the VPS
ssh -p 2222 pi@my-vps.com
```

Use autossh for automatic reconnection:
```bash
sudo apt install autossh
autossh -M 0 -fNR 2222:localhost:22 user@my-vps.com \
    -o "ServerAliveInterval 30" \
    -o "ServerAliveCountMax 3"
```
