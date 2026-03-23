# WireGuard VPN

Install, configure, and run WireGuard — simple, fast, modern VPN.

---

## Why WireGuard

- **Simple:** ~4000 lines of code (vs OpenVPN's ~100,000)
- **Fast:** Kernel-space implementation, ChaCha20 encryption, minimal overhead
- **Modern cryptography:** Curve25519, ChaCha20, Poly1305, BLAKE2s
- **Stealthy:** Silent when idle — no response to unauthenticated packets
- **Roaming:** Seamlessly handles IP changes (mobile/WiFi switching)

---

## Installation

### Debian / Ubuntu / Raspberry Pi OS

```bash
sudo apt update
sudo apt install wireguard wireguard-tools
```

### Verify Kernel Module

```bash
sudo modprobe wireguard
lsmod | grep wireguard
```

If the kernel module isn't available (older kernels), WireGuard falls back to userspace (`wireguard-go`), which is slower but functional.

---

## Key Generation

Every peer (server and client) needs a key pair.

```bash
# Generate private key
wg genkey | tee privatekey | wg pubkey > publickey

# Or step by step:
wg genkey > server_private.key
cat server_private.key | wg pubkey > server_public.key

# Generate preshared key (optional, adds post-quantum resistance)
wg genpsk > preshared.key

# Set permissions
chmod 600 privatekey server_private.key preshared.key
```

---

## Server Configuration

### Create Config File

```bash
sudo nano /etc/wireguard/wg0.conf
```

```ini
[Interface]
# Server's private key
PrivateKey = <SERVER_PRIVATE_KEY>

# VPN IP address for the server
Address = 10.0.0.1/24

# Listen port (UDP)
ListenPort = 51820

# Save config on shutdown (optional, enables wg set persistence)
SaveConfig = false

# NAT rules (if routing client traffic to internet)
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Client 1
[Peer]
PublicKey = <CLIENT1_PUBLIC_KEY>
PresharedKey = <PRESHARED_KEY>
AllowedIPs = 10.0.0.2/32

# Client 2
[Peer]
PublicKey = <CLIENT2_PUBLIC_KEY>
AllowedIPs = 10.0.0.3/32
```

**Replace `eth0`** in PostUp/PostDown with your actual internet-facing interface (check with `ip route | grep default`).

### Enable IP Forwarding

```bash
# Temporary
sudo sysctl -w net.ipv4.ip_forward=1

# Permanent
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/99-wireguard.conf
sudo sysctl -p /etc/sysctl.d/99-wireguard.conf
```

### Open Firewall Port

```bash
sudo ufw allow 51820/udp
# Or with iptables:
sudo iptables -A INPUT -p udp --dport 51820 -j ACCEPT
```

### Start the Interface

```bash
# Start
sudo wg-quick up wg0

# Check status
sudo wg show

# Stop
sudo wg-quick down wg0
```

---

## Client Configuration

### Linux Client

```bash
sudo nano /etc/wireguard/wg0.conf
```

```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.0.0.2/24
DNS = 1.1.1.1, 8.8.8.8

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
PresharedKey = <PRESHARED_KEY>
Endpoint = server.example.com:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

**AllowedIPs explained:**
- `0.0.0.0/0, ::/0` — Route ALL traffic through VPN (full tunnel)
- `10.0.0.0/24` — Only route VPN subnet traffic (split tunnel)
- `10.0.0.0/24, 192.168.1.0/24` — Route multiple subnets through VPN

**PersistentKeepalive:** Send a keepalive packet every 25 seconds. Needed when the client is behind NAT to keep the connection alive.

### Connect

```bash
sudo wg-quick up wg0

# Verify
sudo wg show
ping 10.0.0.1          # Ping the server
curl ifconfig.me        # Should show server's public IP (if full tunnel)
```

---

## Systemd Service

```bash
# Enable WireGuard to start on boot
sudo systemctl enable wg-quick@wg0

# Start/stop/restart
sudo systemctl start wg-quick@wg0
sudo systemctl stop wg-quick@wg0
sudo systemctl restart wg-quick@wg0

# Check status
sudo systemctl status wg-quick@wg0
```

---

## QR Code for Mobile Clients

Generate a QR code that the WireGuard mobile app can scan:

```bash
sudo apt install qrencode

# Create client config
cat > client-phone.conf << EOF
[Interface]
PrivateKey = <PHONE_PRIVATE_KEY>
Address = 10.0.0.3/24
DNS = 1.1.1.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
PresharedKey = <PRESHARED_KEY>
Endpoint = server.example.com:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

# Generate QR code in terminal
qrencode -t ansiutf8 < client-phone.conf

# Or save as PNG
qrencode -t png -o client-phone.png < client-phone.conf
```

Open the WireGuard app on Android/iOS → "+" → "Scan from QR code" → scan the terminal output.

---

## Raspberry Pi as VPN Server

### Complete Setup Script

```bash
#!/bin/bash
# WireGuard VPN Server on Raspberry Pi

# Install
sudo apt update && sudo apt install -y wireguard qrencode

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-wireguard.conf
sudo sysctl -p /etc/sysctl.d/99-wireguard.conf

# Generate server keys
cd /etc/wireguard
umask 077
wg genkey | tee server_private | wg pubkey > server_public
wg genpsk > preshared

SERVER_PRIV=$(cat server_private)
SERVER_PUB=$(cat server_public)
PSK=$(cat preshared)

# Detect default interface
IFACE=$(ip route | grep default | awk '{print $5}' | head -1)

# Create server config
cat > wg0.conf << EOF
[Interface]
PrivateKey = ${SERVER_PRIV}
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ${IFACE} -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ${IFACE} -j MASQUERADE
EOF

echo "Server public key: ${SERVER_PUB}"
echo ""
echo "Now generate client keys and add [Peer] sections."
echo "Use: bash add-client.sh <client-name> <client-ip>"
```

### Add Client Script

```bash
#!/bin/bash
# add-client.sh <name> <ip>
# Example: add-client.sh phone 10.0.0.2

NAME=$1
IP=$2
SERVER_PUB=$(cat /etc/wireguard/server_public)
PSK=$(cat /etc/wireguard/preshared)
SERVER_ENDPOINT="YOUR_SERVER_IP:51820"  # Change this!

cd /etc/wireguard
umask 077

# Generate client keys
wg genkey | tee ${NAME}_private | wg pubkey > ${NAME}_public
CLIENT_PRIV=$(cat ${NAME}_private)
CLIENT_PUB=$(cat ${NAME}_public)

# Add peer to server config
cat >> wg0.conf << EOF

# ${NAME}
[Peer]
PublicKey = ${CLIENT_PUB}
PresharedKey = ${PSK}
AllowedIPs = ${IP}/32
EOF

# Create client config
cat > ${NAME}.conf << EOF
[Interface]
PrivateKey = ${CLIENT_PRIV}
Address = ${IP}/24
DNS = 1.1.1.1

[Peer]
PublicKey = ${SERVER_PUB}
PresharedKey = ${PSK}
Endpoint = ${SERVER_ENDPOINT}
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

echo "Client config: /etc/wireguard/${NAME}.conf"
echo ""
echo "QR Code:"
qrencode -t ansiutf8 < ${NAME}.conf

# Restart server to apply
systemctl restart wg-quick@wg0
```

### Port Forwarding

On your home router, forward **UDP port 51820** to the Pi's local IP address. Without this, external clients cannot reach the VPN server.

### Dynamic DNS

If your home IP changes, use a dynamic DNS service:

```bash
# Install ddclient
sudo apt install ddclient
# Configure with your DDNS provider (DuckDNS, No-IP, etc.)

# Or use DuckDNS directly:
echo "url=\"https://www.duckdns.org/update?domains=YOURDOMAIN&token=YOURTOKEN&ip=\"" | crontab -
```

Use the DDNS hostname as the Endpoint in client configs.

---

## Management Commands

```bash
# Show interface status and peers
sudo wg show
sudo wg show wg0

# Show brief status
sudo wg

# Add peer on the fly
sudo wg set wg0 peer <PUBLIC_KEY> allowed-ips 10.0.0.4/32

# Remove peer
sudo wg set wg0 peer <PUBLIC_KEY> remove

# Show transfer stats
sudo wg show wg0 transfer

# Show latest handshakes
sudo wg show wg0 latest-handshakes
```

---

## Troubleshooting

| Problem                        | Check                                              |
|--------------------------------|----------------------------------------------------|
| Can't connect                  | Firewall open for UDP 51820? Port forwarded?        |
| Handshake but no traffic       | Check AllowedIPs, IP forwarding, iptables rules    |
| DNS not working                | Set DNS in client Interface section                 |
| Slow speeds                    | Check MTU (try `MTU = 1420` in Interface section)  |
| Connection drops behind NAT    | Add `PersistentKeepalive = 25`                     |
| "RTNETLINK: Operation not permitted" | Run with sudo                               |
| Peers show "(none)" handshake  | Keys mismatch, endpoint wrong, or firewall blocking|

### Debug Steps

```bash
# Check WireGuard interface is up
ip addr show wg0

# Check routing
ip route show

# Test connectivity
ping 10.0.0.1  # From client to server VPN IP

# Check for errors
sudo journalctl -u wg-quick@wg0
dmesg | grep wireguard

# Verify port is listening
sudo ss -ulnp | grep 51820
```

---

## Security Notes

- **Private keys must never be shared** or transmitted over insecure channels
- **PresharedKey** adds symmetric encryption layer on top of Curve25519 — provides post-quantum resistance
- WireGuard does NOT provide anonymity — the server sees your real traffic
- Peers are identified by their public key — changing keys = changing identity
- WireGuard is silent to unauthenticated packets (stealth) — port scans won't detect it
- Config files contain private keys — set permissions to 600 and keep them secure
