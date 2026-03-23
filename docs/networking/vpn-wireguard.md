# WireGuard VPN Setup

WireGuard is a modern VPN that is faster, simpler, and more secure than OpenVPN or IPSec. It runs in the Linux kernel, uses state-of-the-art cryptography (Curve25519, ChaCha20, Poly1305), and has a minimal codebase (~4,000 lines vs 100,000+ for OpenVPN).

---

## Why WireGuard

- **Fast**: kernel-level, minimal overhead, great on Raspberry Pi
- **Simple**: configuration is a short INI file
- **Roaming**: handles IP changes gracefully (laptop, phone on mobile data)
- **Stealth**: silent when not sending data (no handshake response to unauthorized packets)
- **Modern crypto**: no cipher negotiation, no legacy baggage

---

## Installation

```bash
# Debian/Ubuntu/Raspberry Pi OS
sudo apt update
sudo apt install wireguard wireguard-tools

# Verify kernel module
sudo modprobe wireguard
lsmod | grep wireguard

# Check version
wg --version
```

For older kernels (pre-5.6), you may need to install the kernel module separately:
```bash
sudo apt install wireguard-dkms
```

---

## Key Generation

Every WireGuard peer (server and client) needs a key pair.

```bash
# Generate private key
wg genkey > server_private.key

# Derive public key from private key
cat server_private.key | wg pubkey > server_public.key

# One-liner: generate both
wg genkey | tee server_private.key | wg pubkey > server_public.key

# Generate a pre-shared key (optional, adds post-quantum security layer)
wg genpsk > preshared.key

# Protect key files
chmod 600 server_private.key preshared.key

# View keys
cat server_private.key
cat server_public.key
```

Generate keys for each peer:
```bash
# Server
wg genkey | tee server_private.key | wg pubkey > server_public.key

# Client 1 (laptop)
wg genkey | tee client1_private.key | wg pubkey > client1_public.key

# Client 2 (phone)
wg genkey | tee client2_private.key | wg pubkey > client2_public.key

# Client 3 (remote Pi)
wg genkey | tee client3_private.key | wg pubkey > client3_public.key
```

---

## Server Configuration

Create `/etc/wireguard/wg0.conf` on the server (e.g., a Pi or VPS):

```ini
[Interface]
# Server's private key
PrivateKey = <server_private_key>

# VPN IP address for this server
Address = 10.10.0.1/24

# UDP port to listen on
ListenPort = 51820

# Optional: run commands when interface goes up/down
# Enable NAT if clients need to reach the internet or LAN through this server
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# DNS for clients (optional, if server runs a DNS resolver)
# DNS = 10.10.0.1

# Save configuration changes made via wg command
SaveConfig = false

[Peer]
# Client 1: Laptop
PublicKey = <client1_public_key>
# PresharedKey = <preshared_key>    # optional
AllowedIPs = 10.10.0.2/32

[Peer]
# Client 2: Phone
PublicKey = <client2_public_key>
AllowedIPs = 10.10.0.3/32

[Peer]
# Client 3: Remote Pi
PublicKey = <client3_public_key>
AllowedIPs = 10.10.0.4/32
# If this Pi has its own subnet that should be routable:
# AllowedIPs = 10.10.0.4/32, 192.168.50.0/24
```

### Enable IP Forwarding

```bash
# Temporary
sudo sysctl -w net.ipv4.ip_forward=1

# Permanent
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.d/99-wireguard.conf
sudo sysctl -p /etc/sysctl.d/99-wireguard.conf
```

### Start the Server

```bash
# Start WireGuard interface
sudo wg-quick up wg0

# Enable on boot
sudo systemctl enable wg-quick@wg0

# Check status
sudo wg show
sudo wg show wg0

# Stop
sudo wg-quick down wg0
```

---

## Client Configuration

Create `/etc/wireguard/wg0.conf` on each client:

### Client 1: Laptop (route all traffic through VPN)

```ini
[Interface]
PrivateKey = <client1_private_key>
Address = 10.10.0.2/24
DNS = 1.1.1.1, 8.8.8.8

[Peer]
PublicKey = <server_public_key>
# PresharedKey = <preshared_key>
Endpoint = server-public-ip:51820
# Route ALL traffic through VPN:
AllowedIPs = 0.0.0.0/0, ::/0
# Keep connection alive (important behind NAT)
PersistentKeepalive = 25
```

### Client 2: Only route VPN subnet (split tunnel)

```ini
[Interface]
PrivateKey = <client2_private_key>
Address = 10.10.0.3/24

[Peer]
PublicKey = <server_public_key>
Endpoint = server-public-ip:51820
# Only route VPN traffic through tunnel:
AllowedIPs = 10.10.0.0/24
PersistentKeepalive = 25
```

### Client 3: Remote Pi (site-to-site)

```ini
[Interface]
PrivateKey = <client3_private_key>
Address = 10.10.0.4/24

[Peer]
PublicKey = <server_public_key>
Endpoint = server-public-ip:51820
AllowedIPs = 10.10.0.0/24
PersistentKeepalive = 25
```

### Start Client

```bash
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0

# Test connectivity
ping 10.10.0.1     # ping the server
```

---

## AllowedIPs Explained

`AllowedIPs` serves two purposes:
1. **Routing**: packets destined for these IPs go through the tunnel
2. **Filtering**: only packets FROM these IPs are accepted from this peer

```
AllowedIPs = 10.10.0.2/32          # only this single IP
AllowedIPs = 10.10.0.0/24          # entire VPN subnet
AllowedIPs = 10.10.0.0/24, 192.168.1.0/24  # VPN + remote LAN
AllowedIPs = 0.0.0.0/0, ::/0      # ALL traffic (full tunnel)
```

On the **server**, AllowedIPs for each peer is typically the peer's VPN IP (/32) plus any subnets behind it.

On the **client**, AllowedIPs determines what traffic goes through the tunnel.

---

## QR Code for Mobile Clients

Generate a QR code that the WireGuard mobile app (Android/iOS) can scan:

```bash
# Install qrencode
sudo apt install qrencode

# Create client config file
cat > client-phone.conf <<EOF
[Interface]
PrivateKey = <phone_private_key>
Address = 10.10.0.3/24
DNS = 1.1.1.1

[Peer]
PublicKey = <server_public_key>
Endpoint = your-server-ip:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

# Generate QR code (displays in terminal)
qrencode -t ansiutf8 < client-phone.conf

# Or generate a PNG image
qrencode -t png -o client-phone-qr.png < client-phone.conf

# On the phone: open WireGuard app > + > Scan from QR code
```

---

## Pi as VPN Server (Home or Field)

### Home Pi — Access your home network from anywhere

```
[Internet]
    |
[Home Router] --port forward UDP 51820--> [Raspberry Pi]
    |                                       wg0: 10.10.0.1/24
[Home LAN: 192.168.1.0/24]                eth0: 192.168.1.50
```

Setup:
1. Install WireGuard on the Pi
2. Configure as server (see above)
3. Port forward UDP 51820 on your router to the Pi's IP
4. Enable IP forwarding and NAT
5. Create client configs with `Endpoint = your-public-ip:51820`

For dynamic public IPs, use a dynamic DNS service (duckdns.org, etc.):
```bash
# Update DuckDNS every 5 minutes via cron
*/5 * * * * curl -s "https://www.duckdns.org/update?domains=mypi&token=TOKEN&ip=" > /dev/null
```

Then use `Endpoint = mypi.duckdns.org:51820` in client configs.

### Connect Remote IoT Devices

Scenario: sensors in the field need to report to a central server.

```
[Central Server / VPS]
  wg0: 10.10.0.1/24

[Field Pi #1]                [Field Pi #2]
  wg0: 10.10.0.10/24          wg0: 10.10.0.11/24
  LAN: 192.168.50.0/24        LAN: 192.168.51.0/24
```

Server config adds site-to-site routing:
```ini
[Peer]
# Field Pi #1
PublicKey = <field1_public_key>
AllowedIPs = 10.10.0.10/32, 192.168.50.0/24

[Peer]
# Field Pi #2
PublicKey = <field2_public_key>
AllowedIPs = 10.10.0.11/32, 192.168.51.0/24
```

Field Pi config enables forwarding so devices on 192.168.50.x can reach the VPN:
```bash
# On field Pi
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
```

---

## Management Commands

```bash
# Show status
sudo wg show
sudo wg show wg0

# Show detailed status
sudo wg show wg0 dump

# Add a peer on the fly (without editing config)
sudo wg set wg0 peer <public_key> allowed-ips 10.10.0.5/32

# Remove a peer
sudo wg set wg0 peer <public_key> remove

# Check interface
ip addr show wg0
ip route | grep wg0

# Test throughput
# On server: iperf3 -s
# On client: iperf3 -c 10.10.0.1
```

---

## Complete Setup Script

```bash
#!/bin/bash
# setup-wireguard-server.sh
set -euo pipefail

VPN_SUBNET="10.10.0"
SERVER_IP="${VPN_SUBNET}.1"
LISTEN_PORT=51820
WAN_IFACE="eth0"
NUM_CLIENTS=3

echo "=== Installing WireGuard ==="
sudo apt update
sudo apt install -y wireguard wireguard-tools qrencode

echo "=== Generating server keys ==="
cd /etc/wireguard
umask 077
wg genkey | tee server_private.key | wg pubkey > server_public.key
SERVER_PRIVKEY=$(cat server_private.key)
SERVER_PUBKEY=$(cat server_public.key)

echo "=== Creating server config ==="
cat > wg0.conf <<EOF
[Interface]
PrivateKey = $SERVER_PRIVKEY
Address = ${SERVER_IP}/24
ListenPort = $LISTEN_PORT
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ${WAN_IFACE} -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ${WAN_IFACE} -j MASQUERADE
EOF

echo "=== Generating client configs ==="
mkdir -p clients
for i in $(seq 1 $NUM_CLIENTS); do
    CLIENT_IP="${VPN_SUBNET}.$((i + 1))"
    wg genkey | tee "clients/client${i}_private.key" | wg pubkey > "clients/client${i}_public.key"
    CLIENT_PRIVKEY=$(cat "clients/client${i}_private.key")
    CLIENT_PUBKEY=$(cat "clients/client${i}_public.key")

    # Add peer to server config
    cat >> wg0.conf <<EOF

[Peer]
# Client $i
PublicKey = $CLIENT_PUBKEY
AllowedIPs = ${CLIENT_IP}/32
EOF

    # Create client config
    SERVER_ENDPOINT=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")
    cat > "clients/client${i}.conf" <<EOF
[Interface]
PrivateKey = $CLIENT_PRIVKEY
Address = ${CLIENT_IP}/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBKEY
Endpoint = ${SERVER_ENDPOINT}:${LISTEN_PORT}
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

    echo "Client $i config: /etc/wireguard/clients/client${i}.conf"
    echo "Client $i QR code:"
    qrencode -t ansiutf8 < "clients/client${i}.conf"
    echo ""
done

echo "=== Enabling IP forwarding ==="
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-wireguard.conf
sudo sysctl -w net.ipv4.ip_forward=1

echo "=== Starting WireGuard ==="
sudo systemctl enable wg-quick@wg0
sudo wg-quick up wg0

echo "=== Done! ==="
echo "Server public key: $SERVER_PUBKEY"
echo "Server endpoint: $(curl -s ifconfig.me 2>/dev/null || echo 'check your IP'):$LISTEN_PORT"
sudo wg show
```

---

## Troubleshooting

```bash
# Check if interface is up
ip link show wg0

# Check handshake (should show "latest handshake" after connection)
sudo wg show

# If no handshake:
# 1. Check firewall allows UDP on listen port
sudo ufw allow 51820/udp
# or
sudo iptables -A INPUT -p udp --dport 51820 -j ACCEPT

# 2. Check endpoint is reachable
nc -zuv server-ip 51820

# 3. Check keys match (server's public key in client config, client's public key in server config)

# 4. Check AllowedIPs don't overlap between peers on the server

# Debug with kernel logs
sudo dmesg | grep wireguard

# Check routing
ip route show table all | grep wg0
```
