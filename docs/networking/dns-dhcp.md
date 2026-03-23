# DNS & DHCP

> How name resolution and automatic IP assignment work on local networks.

## DNS Basics

DNS (Domain Name System) translates human-readable domain names to IP addresses.

### How a DNS Query Works

1. **Browser cache** → already resolved recently?
2. **OS resolver** (`/etc/resolv.conf` or systemd-resolved) → cached locally?
3. **Recursive resolver** (ISP or 1.1.1.1/8.8.8.8) → asks on your behalf
4. **Root servers** → "ask the .com TLD server"
5. **TLD server** → "ask example.com's authoritative server"
6. **Authoritative server** → "example.com is 93.184.216.34"
7. Answer cached at each level (TTL determines how long)

### Common Record Types

| Type | Purpose | Example |
|---|---|---|
| A | IPv4 address | `example.com → 93.184.216.34` |
| AAAA | IPv6 address | `example.com → 2606:2800:220:1:...` |
| CNAME | Alias to another name | `www.example.com → example.com` |
| MX | Mail server | `example.com → mail.example.com (priority 10)` |
| TXT | Text data (SPF, DKIM, etc.) | `v=spf1 include:_spf.google.com ~all` |
| NS | Nameserver for zone | `example.com → ns1.example.com` |
| PTR | Reverse lookup (IP→name) | `34.216.184.93 → example.com` |
| SRV | Service location | `_sip._tcp.example.com → sip.example.com:5060` |

### DNS Configuration on Linux

```bash
# Check current DNS
cat /etc/resolv.conf

# Or with systemd-resolved
resolvectl status

# Test DNS resolution
dig example.com
nslookup example.com
host example.com

# Query specific DNS server
dig @8.8.8.8 example.com
```

### Common Public DNS Servers

| Provider | Primary | Secondary |
|---|---|---|
| Cloudflare | 1.1.1.1 | 1.0.0.1 |
| Google | 8.8.8.8 | 8.8.4.4 |
| Quad9 | 9.9.9.9 | 149.112.112.112 |
| OpenDNS | 208.67.222.222 | 208.67.220.220 |

## DHCP Basics

DHCP (Dynamic Host Configuration Protocol) automatically assigns IP addresses to devices on a network.

### DHCP Process (DORA)

1. **Discover**: Client broadcasts "I need an IP" (UDP 67/68)
2. **Offer**: Server offers an IP from its pool
3. **Request**: Client accepts the offer
4. **Acknowledge**: Server confirms the lease

### Lease Duration

- Devices get an IP for a set time (lease)
- At 50% of lease time, client tries to renew
- At 87.5%, client broadcasts for any DHCP server
- When lease expires, client must start over

## dnsmasq — Lightweight DNS + DHCP

dnsmasq is perfect for small networks (Pi, IoT gateway, WiFi AP).

### Install

```bash
sudo apt install dnsmasq
```

### Configuration

`/etc/dnsmasq.conf`:
```ini
# Interface to listen on
interface=eth0

# DHCP range: IP pool, subnet mask, lease time
dhcp-range=192.168.1.100,192.168.1.200,255.255.255.0,24h

# Default gateway
dhcp-option=3,192.168.1.1

# DNS server to advertise to clients
dhcp-option=6,192.168.1.1

# Static lease by MAC address
dhcp-host=aa:bb:cc:dd:ee:ff,192.168.1.50,raspberrypi

# Domain name
domain=local

# Enable DNS caching (default 150 entries)
cache-size=1000

# Upstream DNS servers
server=1.1.1.1
server=8.8.8.8

# Log DHCP transactions
log-dhcp

# Don't read /etc/resolv.conf (use servers above)
no-resolv
```

### Managing dnsmasq

```bash
# Start/restart
sudo systemctl restart dnsmasq

# Check status
sudo systemctl status dnsmasq

# View leases
cat /var/lib/misc/dnsmasq.leases

# Test DNS
dig @localhost example.com
```

## Pi-hole — Ad-Blocking DNS

Pi-hole acts as a DNS sinkhole, blocking ads and trackers network-wide.

### Install

```bash
curl -sSL https://install.pi-hole.net | bash
```

### Key Features

- Blocks ads/trackers for all devices on the network
- Web dashboard for monitoring and management
- Built on dnsmasq (or optionally FTL/unbound)
- DHCP server built-in (can replace your router's DHCP)
- Customizable blocklists and whitelists

### Configuration

1. Point your router's DNS to the Pi-hole's IP
2. Or set individual devices to use Pi-hole as DNS
3. Access dashboard at `http://pi.hole/admin` or `http://<PI_IP>/admin`

```bash
# Change password
pihole -a -p

# Update blocklists
pihole -g

# Enable/disable blocking
pihole enable
pihole disable 5m  # Disable for 5 minutes

# Check status
pihole status
```

## Static DHCP Leases / Reservations

Assign the same IP to a device every time based on its MAC address.

### In dnsmasq

```ini
# MAC, IP, hostname
dhcp-host=aa:bb:cc:dd:ee:ff,192.168.1.50,mydevice
dhcp-host=11:22:33:44:55:66,192.168.1.51,sensor-node
```

### Find a Device's MAC Address

```bash
# On the device itself
ip link show
ifconfig

# From the network (ARP table)
arp -a
ip neigh show

# Scan network
nmap -sn 192.168.1.0/24
```

## mDNS / Avahi (.local Hostname Resolution)

mDNS (Multicast DNS) lets devices find each other by name on a local network without a DNS server.

### How It Works

- Devices announce `hostname.local` via multicast (224.0.0.251, port 5353)
- Any device can resolve `raspberrypi.local` without configuring DNS
- Protocol: RFC 6762, implemented by Avahi (Linux) and Bonjour (Apple/Windows)

### Setup on Linux

```bash
# Install Avahi (often pre-installed on Pi)
sudo apt install avahi-daemon

# Your device is now reachable as <hostname>.local
ping raspberrypi.local

# Browse services on network
avahi-browse -art

# Publish a custom service
avahi-publish -s "My Web Server" _http._tcp 8080
```

### Service Discovery

mDNS also supports service discovery (DNS-SD):
```bash
# Find all HTTP servers
avahi-browse _http._tcp

# Find all SSH servers
avahi-browse _ssh._tcp

# Find all MQTT brokers
avahi-browse _mqtt._tcp
```

## Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| Device not getting IP | DHCP server not running | Check `systemctl status dnsmasq` |
| "Name not resolved" | DNS misconfigured | Check `/etc/resolv.conf`, try `dig` |
| `.local` not working | Avahi not running | `sudo systemctl start avahi-daemon` |
| DHCP conflicts | Multiple DHCP servers | Disable DHCP on router or dnsmasq |
| Slow DNS resolution | Bad upstream DNS | Try different DNS servers (1.1.1.1) |
| Lease not renewing | Firewall blocking UDP 67/68 | Check iptables rules |
