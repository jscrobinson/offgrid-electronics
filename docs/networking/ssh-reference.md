# SSH Reference

Connecting, keys, tunneling, file transfer, and hardening.

---

## Basic Connection

```bash
ssh user@hostname
ssh user@192.168.1.100
ssh -p 2222 user@host              # Non-standard port
ssh user@host command               # Run command and exit
ssh -v user@host                    # Verbose (debug connection issues)
ssh -vvv user@host                  # Extra verbose
```

---

## Key Generation

### Ed25519 (Recommended)

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
# Saves to ~/.ssh/id_ed25519 (private) and ~/.ssh/id_ed25519.pub (public)
# Enter a passphrase when prompted (recommended)
```

### RSA (Broader Compatibility)

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
# Saves to ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub
```

### Key Types Comparison

| Type      | Key Size    | Security | Speed   | Compatibility |
|-----------|-------------|----------|---------|---------------|
| ed25519   | 256-bit     | Excellent| Fast    | OpenSSH 6.5+  |
| rsa       | 4096-bit    | Good     | Slower  | Universal      |
| ecdsa     | 256/384/521 | Good     | Fast    | OpenSSH 5.7+  |

**Use ed25519 unless you need compatibility with very old systems.**

### Copy Public Key to Server

```bash
# Automatic method (recommended)
ssh-copy-id user@host
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@host

# Manual method
cat ~/.ssh/id_ed25519.pub | ssh user@host 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'

# Or on the server, manually add to:
# ~/.ssh/authorized_keys
```

### File Permissions (Critical)

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519          # Private key
chmod 644 ~/.ssh/id_ed25519.pub      # Public key
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/config
```

Incorrect permissions = SSH refuses to use the key silently.

---

## SSH Config File

`~/.ssh/config` saves you from typing long commands.

```
# Default settings for all hosts
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    AddKeysToAgent yes

# Raspberry Pi
Host pi
    HostName 192.168.1.50
    User pi
    Port 22
    IdentityFile ~/.ssh/id_ed25519

# Jump through bastion
Host internal-server
    HostName 10.0.0.5
    User admin
    ProxyJump bastion

Host bastion
    HostName bastion.example.com
    User jump-user
    IdentityFile ~/.ssh/id_ed25519_work

# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519

# Wildcard for lab machines
Host lab-*
    User root
    IdentityFile ~/.ssh/id_ed25519_lab
    StrictHostKeyChecking no        # Only for trusted LANs
    UserKnownHostsFile /dev/null
```

**Usage after config:**
```bash
ssh pi                   # Instead of: ssh pi@192.168.1.50
ssh internal-server      # Automatically jumps through bastion
```

---

## SSH Tunneling

### Local Port Forward (-L)

Forward a local port to a remote service. Access remote_host:remote_port as localhost:local_port.

```bash
ssh -L local_port:target_host:target_port user@ssh_server

# Example: Access remote web server at localhost:8080
ssh -L 8080:localhost:80 user@remote-server
# Now http://localhost:8080 → remote server's port 80

# Example: Access a database behind a firewall
ssh -L 3307:db-server:3306 user@bastion
# Now mysql -h 127.0.0.1 -P 3307 → db-server:3306

# Example: Access a remote Pi's VNC
ssh -L 5901:localhost:5900 pi@192.168.1.50
# Now VNC to localhost:5901
```

**Diagram:**
```
[Your PC:8080] ──SSH──> [SSH Server] ──> [Target:80]
                 Encrypted tunnel
```

### Remote Port Forward (-R)

Expose a local service to the remote network. Make remote_host:remote_port forward to your local machine.

```bash
ssh -R remote_port:target_host:target_port user@ssh_server

# Example: Expose local web server to the internet via a VPS
ssh -R 8080:localhost:3000 user@vps.example.com
# Now vps.example.com:8080 → your localhost:3000

# Example: Let remote server access your local service
ssh -R 9090:localhost:9090 user@remote-server
```

**Note:** By default, remote forwards only bind to 127.0.0.1 on the server. To bind to all interfaces, add `GatewayPorts yes` to the server's `sshd_config`.

### Dynamic Port Forward / SOCKS Proxy (-D)

Create a SOCKS5 proxy through the SSH tunnel. All traffic routed through the proxy goes through the SSH server.

```bash
ssh -D 1080 user@remote-server

# Configure browser/system to use SOCKS5 proxy at localhost:1080
# All DNS and traffic goes through the SSH tunnel
```

**Use cases:**
- Browse the web through a remote server's connection
- Access resources only available on the remote network
- Simple VPN alternative

### Tunnel Options

```bash
# Run tunnel in background without a shell
ssh -fN -L 8080:localhost:80 user@host
# -f = background after authentication
# -N = no remote command (tunnel only)

# Keep tunnel alive
ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -L 8080:localhost:80 user@host

# Kill background tunnel
# Find PID: ps aux | grep ssh
# Or use: ssh -O exit -L 8080:localhost:80 user@host (with multiplexing)
```

---

## File Transfer

### SCP (Secure Copy)

```bash
# Copy file to remote
scp file.txt user@host:/path/to/destination/
scp file.txt pi:/home/pi/                      # Using SSH config alias

# Copy from remote
scp user@host:/path/to/file.txt ./local/

# Copy directory
scp -r mydir/ user@host:/path/

# Specific port
scp -P 2222 file.txt user@host:/path/

# Preserve timestamps and permissions
scp -p file.txt user@host:/path/
```

### SFTP (SSH File Transfer Protocol)

```bash
sftp user@host

# SFTP commands:
sftp> ls                    # List remote files
sftp> lls                   # List local files
sftp> cd /remote/path       # Change remote directory
sftp> lcd /local/path       # Change local directory
sftp> get file.txt          # Download
sftp> put file.txt          # Upload
sftp> get -r directory/     # Download directory
sftp> put -r directory/     # Upload directory
sftp> rm file.txt           # Delete remote file
sftp> exit
```

### rsync over SSH (Best for Syncing)

```bash
# Sync local to remote
rsync -avz /local/path/ user@host:/remote/path/

# Sync remote to local
rsync -avz user@host:/remote/path/ /local/path/

# With custom SSH port
rsync -avz -e 'ssh -p 2222' /local/ user@host:/remote/

# Delete files on destination that don't exist on source
rsync -avz --delete /local/ user@host:/remote/

# Dry run (see what would change)
rsync -avzn /local/ user@host:/remote/

# Flags:
# -a = archive (preserves permissions, timestamps, symlinks)
# -v = verbose
# -z = compress during transfer
# -P = progress + partial (resume interrupted transfers)
```

---

## SSH Agent

The SSH agent holds your decrypted private keys in memory so you don't re-enter passphrases.

```bash
# Start agent (usually auto-started)
eval $(ssh-agent)

# Add key
ssh-add                              # Add default key
ssh-add ~/.ssh/id_ed25519            # Add specific key
ssh-add -l                           # List loaded keys

# Auto-add on first use (add to ~/.ssh/config)
# AddKeysToAgent yes
```

### Agent Forwarding

Allow the remote server to use your local SSH keys (e.g., to git pull on the server using your GitHub key):

```bash
ssh -A user@host
# Now on 'host', SSH commands use your local agent's keys
```

**Or in config:**
```
Host myserver
    ForwardAgent yes
```

**Security warning:** Only enable agent forwarding to servers you trust. A compromised server could use your forwarded agent to authenticate as you.

---

## Connection Multiplexing

Reuse a single SSH connection for multiple sessions — faster subsequent connections.

Add to `~/.ssh/config`:
```
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
```

```bash
mkdir -p ~/.ssh/sockets
```

First connection creates the socket. Subsequent `ssh`, `scp`, `sftp` to the same host reuse it instantly.

```bash
# Check active connections
ssh -O check user@host

# Close master connection
ssh -O exit user@host
```

---

## Security Hardening

Edit the server's `/etc/ssh/sshd_config`:

```bash
# Disable password authentication (key-only)
PasswordAuthentication no
ChallengeResponseAuthentication no

# Disable root login
PermitRootLogin no
# Or allow root with key only:
# PermitRootLogin prohibit-password

# Change default port (obscurity, not security, but reduces noise)
Port 2222

# Allow specific users only
AllowUsers pi admin

# Disable empty passwords
PermitEmptyPasswords no

# Limit authentication attempts
MaxAuthTries 3
MaxSessions 5

# Idle timeout
ClientAliveInterval 300
ClientAliveCountMax 2

# Disable X11 forwarding (if not needed)
X11Forwarding no

# Disable TCP forwarding (if not needed)
AllowTcpForwarding no

# Use only protocol 2
Protocol 2

# Restrict key exchange algorithms (modern only)
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
```

After editing:
```bash
# Test config syntax
sudo sshd -t

# Restart SSH
sudo systemctl restart sshd
```

### Additional Hardening

```bash
# Install fail2ban to block brute-force attempts
sudo apt install fail2ban
sudo systemctl enable fail2ban

# Default config bans IPs after 5 failed attempts for 10 minutes
# Customize: /etc/fail2ban/jail.local
```

### SSH Key Rotation

```bash
# Generate new key
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_new

# Add new key to servers
ssh-copy-id -i ~/.ssh/id_ed25519_new.pub user@host

# Test new key
ssh -i ~/.ssh/id_ed25519_new user@host

# Remove old key from server's ~/.ssh/authorized_keys
# Then delete old local key
```

---

## Common Issues

| Problem                           | Solution                                         |
|-----------------------------------|--------------------------------------------------|
| "Permission denied (publickey)"   | Check key permissions (600), check authorized_keys|
| "Host key verification failed"    | `ssh-keygen -R hostname` to remove old key       |
| Connection timeout                | Check firewall, verify port, try `ssh -v`        |
| "Too many authentication failures"| Specify key: `ssh -i ~/.ssh/key user@host`       |
| Broken pipe / disconnects         | Add `ServerAliveInterval 60` to config           |
| Slow connection setup             | Add `UseDNS no` to server sshd_config            |
| Can't forward port                | Check `AllowTcpForwarding` on server             |

---

## Quick Reference

| Task                              | Command                                         |
|-----------------------------------|-------------------------------------------------|
| Connect                           | `ssh user@host`                                 |
| Generate key                      | `ssh-keygen -t ed25519`                         |
| Copy key to server                | `ssh-copy-id user@host`                         |
| Local port forward                | `ssh -L 8080:target:80 user@host`               |
| Remote port forward               | `ssh -R 8080:localhost:3000 user@host`          |
| SOCKS proxy                       | `ssh -D 1080 user@host`                         |
| Copy file to remote               | `scp file.txt user@host:/path/`                 |
| Copy file from remote             | `scp user@host:/path/file.txt ./`               |
| Sync directories                  | `rsync -avz local/ user@host:/remote/`          |
| Background tunnel                 | `ssh -fN -L 8080:localhost:80 user@host`        |
| Run remote command                | `ssh user@host 'ls -la /tmp'`                   |
