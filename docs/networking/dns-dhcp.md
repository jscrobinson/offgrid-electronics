# DNS and DHCP

How name resolution and automatic IP assignment work on local networks. Practical setup with dnsmasq, Pi-hole, and systemd.

---

## How DNS Works

DNS (Domain Name System) translates domain names to IP addresses.

### Resolution Process

```
You type: https://example.com

1. Browser checks its cache
2. OS checks /etc/hosts
3. OS queries the configured DNS resolver (e.g., 192.168.1.1 or 1.1.1.1)
4. Resolver checks its cache
5. If not cached, resolver performs recursive lookup:
   a. Ask root server (.): "Who handles .com?"
   b. Ask .com TLD server: "Who handles example.com?"
   c. Ask example.com authoritative server: "What's the IP of example.com?"
   d. Answer: 93.184.216.34
6. Resolver caches the answer (for TTL duration)
7. IP returned to your browser
```

### DNS Record Types

| Type | Purpose | Example |
|------|---------|---------|
| A | IPv4 address | `example.com -> 93.184.216.34` |
| AAAA | IPv6 address | `example.com -> 2606:2800:220:1:...` |
| CNAME | Alias to another name | `www.example.com -> example.com` |
| MX | Mail server | `example.com -> mail.example.com (priority 10)` |
| TXT | Text data | SPF records, domain verification |
| NS | Nameserver | `example.com -> ns1.example.com` |
| SOA | Start of authority | Zone metadata (serial, refresh, TTL) |
| PTR | Reverse lookup (IP to name) | `34.216.184.93 -> example.com` |
| SRV | Service location | `_mqtt._tcp.local -> broker.local:1883` |

### /etc/resolv.conf

This file tells the system which DNS servers to use:

```
# /etc/resolv.conf
nameserver 192.168.1.1       # router (usually does DNS forwarding)
nameserver 1.1.1.1           # Cloudflare
nameserver 8.8.8.8           # Google
search local                  # default search domain
```

On modern systems, this file is often managed by `systemd-resolved` or `NetworkManager`. Direct edits may be overwritten.

```bash
# Check what's actually managing DNS
ls -la /etc/resolv.conf      # is it a symlink?

# If managed by systemd-resolved
resolvectl status

# To set DNS permanently on Raspberry Pi
# Edit /etc/dhcpcd.conf:
# static domain_name_servers=1.1.1.1 8.8.8.8

# Or edit /etc/resolv.conf and make it immutable
sudo chattr +i /etc/resolv.conf
```

### /etc/hosts (Local Overrides)

```
# /etc/hosts — checked BEFORE DNS
127.0.0.1       localhost
::1             localhost

# Local devices
192.168.1.50    pi-main pi-main.local
192.168.1.51    pi-sensor pi-sensor.local
192.168.1.100   nas nas.local
192.168.1.200   mqtt-broker mqtt.local

# Block domains (ad blocking without Pi-hole)
0.0.0.0         ads.example.com
0.0.0.0         tracking.example.com
```

### Common Public DNS Servers

| Provider | IPv4 | IPv6 |
|----------|------|------|
| Cloudflare | 1.1.1.1, 1.0.0.1 | 2606:4700:4700::1111 |
| Google | 8.8.8.8, 8.8.4.4 | 2001:4860:4860::8888 |
| Quad9 (security-focused) | 9.9.9.9, 149.112.112.112 | 2620:fe::fe |
| OpenDNS | 208.67.222.222, 208.67.220.220 | 2620:119:35::35 |

---

## DHCP Basics

DHCP (Dynamic Host Configuration Protocol) automatically assigns IP addresses and network settings to devices.

### The DORA Process

```
1. DISCOVER  Client broadcasts: "I need an IP address!" (UDP 67)
             src: 0.0.0.0:68 -> dst: 255.255.255.255:67

2. OFFER     DHCP server responds: "Here's 192.168.1.100"
             src: 192.168.1.1:67 -> dst: 255.255.255.255:68

3. REQUEST   Client broadcasts: "I'll take 192.168.1.100"
             (broadcast so other DHCP servers know)

4. ACKNOWLEDGE  Server confirms: "192.168.1.100 is yours for 24 hours"
                Also sends: subnet mask, gateway, DNS servers
```

### DHCP Lease

A lease is temporary. Before it expires, the client asks to renew:
- At 50% of lease time: client tries to renew with the same server
- At 87.5%: client broadcasts a renewal request to any server
- At 100%: lease expires, client must start over with DISCOVER

### What DHCP Provides

- IP address
- Subnet mask
- Default gateway
- DNS server(s)
- Lease duration
- Domain name
- NTP server (optional)
- Other options (TFTP server for PXE boot, etc.)

---

## dnsmasq --- Lightweight DNS + DHCP

dnsmasq is a combined DNS forwarder and DHCP server, perfect for small networks, Raspberry Pi, and embedded deployments.

### Installation

```bash
sudo apt install dnsmasq
sudo systemctl stop dnsmasq    # stop while configuring
```

### Configuration

`/etc/dnsmasq.conf`:

```ini
# ========== General ==========
# Don't read /etc/resolv.conf (we'll set our own upstream DNS)
no-resolv

# Upstream DNS servers
server=1.1.1.1
server=8.8.8.8

# Only listen on these interfaces
interface=eth0
interface=wlan0
bind-interfaces

# Don't forward queries without a domain part
domain-needed
# Don't forward reverse lookups for private ranges
bogus-priv

# ========== DNS ==========
# Local domain
domain=local
local=/local/

# Cache size (default 150)
cache-size=1000

# Local DNS entries
address=/dashboard.local/192.168.1.50
address=/mqtt.local/192.168.1.50
address=/sensor-api.local/192.168.1.50

# Block a domain (return NXDOMAIN)
address=/ads.example.com/

# Wildcard: all subdomains of a domain
address=/.ads.example.com/0.0.0.0

# Read /etc/hosts for additional entries
# (enabled by default)

# ========== DHCP ==========
# DHCP range for eth0
dhcp-range=eth0,192.168.1.100,192.168.1.200,255.255.255.0,24h

# DHCP range for wlan0 (if running AP)
dhcp-range=wlan0,192.168.4.10,192.168.4.100,255.255.255.0,12h

# Default gateway
dhcp-option=option:router,192.168.1.1

# DNS servers to assign to clients
dhcp-option=option:dns-server,192.168.1.50,1.1.1.1

# NTP server
dhcp-option=option:ntp-server,192.168.1.50

# Domain name
dhcp-option=option:domain-name,local

# ========== Static Leases (DHCP Reservations) ==========
# Format: dhcp-host=MAC,hostname,IP,lease-time
dhcp-host=dc:a6:32:aa:bb:cc,pi-main,192.168.1.50,infinite
dhcp-host=b8:27:eb:dd:ee:ff,pi-sensor,192.168.1.51,infinite
dhcp-host=aa:bb:cc:dd:ee:ff,nas,192.168.1.100,infinite

# Assign by hostname (if client sends hostname)
dhcp-host=laptop-john,192.168.1.150

# ========== Logging ==========
log-queries
log-dhcp
log-facility=/var/log/dnsmasq.log
```

### Start and Enable

```bash
sudo systemctl start dnsmasq
sudo systemctl enable dnsmasq
sudo systemctl status dnsmasq

# Test DNS
dig @localhost example.com
nslookup dashboard.local localhost

# View DHCP leases
cat /var/lib/misc/dnsmasq.leases

# View logs
tail -f /var/log/dnsmasq.log
```

---

## Pi-hole --- Ad-Blocking DNS

Pi-hole is a network-wide ad blocker that works as a DNS sinkhole. It uses dnsmasq internally.

### Installation

```bash
# One-line install
curl -sSL https://install.pi-hole.net | bash

# Or for more control, download and run manually
git clone --depth 1 https://github.com/pi-hole/pi-hole.git Pi-hole
cd Pi-hole/automated\ install/
sudo bash basic-install.sh
```

The installer asks for:
- Upstream DNS provider (Cloudflare, Google, etc.)
- Block lists (default lists are good)
- Web admin interface (yes)
- Logging (yes)

### Using Pi-hole

```bash
# Web dashboard
http://pi-ip/admin

# Command line
pihole status
pihole -c                    # real-time console
pihole -q example.com        # check if domain is blocked
pihole -w example.com        # whitelist a domain
pihole -b ads.example.com    # blacklist a domain
pihole -up                   # update Pi-hole
pihole -g                    # update gravity (block lists)
pihole restartdns            # restart DNS

# Point your router's DHCP to use Pi-hole as DNS
# Router DHCP settings: DNS server = Pi-hole's IP

# Or configure per-device:
# /etc/resolv.conf: nameserver 192.168.1.50
```

### Pi-hole + dnsmasq Custom DNS

Pi-hole includes dnsmasq. Add custom DNS records in:

```bash
# /etc/dnsmasq.d/99-custom.conf
address=/dashboard.local/192.168.1.50
address=/mqtt.local/192.168.1.50
address=/grafana.local/192.168.1.50

# Restart
pihole restartdns
```

---

## DHCP Reservation by MAC Address

Ensure a device always gets the same IP address.

### Method 1: dnsmasq

```ini
# /etc/dnsmasq.conf or /etc/dnsmasq.d/static-leases.conf
dhcp-host=dc:a6:32:aa:bb:cc,pi-main,192.168.1.50
dhcp-host=b8:27:eb:dd:ee:ff,pi-sensor,192.168.1.51
```

### Method 2: Router DHCP

Most routers have a DHCP reservation feature in the web UI:
1. Log into router (usually 192.168.1.1)
2. Find DHCP settings
3. Add reservation: MAC address to desired IP

### Finding MAC Addresses

```bash
# On the device itself
ip link show
ifconfig

# From another device on the network
arp -a
ip neigh show

# Scan the network
sudo nmap -sn 192.168.1.0/24
```

---

## systemd-resolved

Modern Linux systems often use systemd-resolved for DNS:

```bash
# Check status
resolvectl status
systemd-resolve --status    # older syntax

# Flush DNS cache
resolvectl flush-caches

# Check cache statistics
resolvectl statistics

# Set DNS for an interface
resolvectl dns eth0 1.1.1.1 8.8.8.8

# If conflicting with dnsmasq, disable it
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
# Remove the symlink and create a static resolv.conf
sudo rm /etc/resolv.conf
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
```

---

## mDNS / Avahi (.local Hostname Resolution)

mDNS (Multicast DNS) allows devices to be found by `hostname.local` without a DNS server. Used by default on most Linux and macOS systems.

### How It Works

```
Device "raspberrypi" announces: "I'm raspberrypi.local at 192.168.1.50"
Other devices on the LAN can then:
  ping raspberrypi.local
  ssh pi@raspberrypi.local
  http://raspberrypi.local

Uses multicast address 224.0.0.251:5353 (IPv4) / ff02::fb:5353 (IPv6)
```

### Avahi (Linux mDNS Implementation)

```bash
# Install (usually pre-installed on Raspberry Pi OS)
sudo apt install avahi-daemon avahi-utils

# Check status
sudo systemctl status avahi-daemon

# Find devices on the network
avahi-browse -a              # browse all services
avahi-browse -art            # browse all, resolve addresses, show TXT
avahi-browse _http._tcp      # browse web servers
avahi-browse _mqtt._tcp      # browse MQTT brokers
avahi-browse _ssh._tcp       # browse SSH servers

# Resolve a hostname
avahi-resolve -n raspberrypi.local
avahi-resolve -a 192.168.1.50    # reverse lookup

# Publish custom services
# Create XML file in /etc/avahi/services/
```

### Publishing Custom Services

Create `/etc/avahi/services/mqtt.service`:

```xml
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name>MQTT Broker on %h</name>
  <service>
    <type>_mqtt._tcp</type>
    <port>1883</port>
    <txt-record>info=Field sensor MQTT broker</txt-record>
  </service>
</service-group>
```

```bash
sudo systemctl restart avahi-daemon
# Now other devices can discover this MQTT broker:
avahi-browse _mqtt._tcp
```

### Change mDNS Hostname

```bash
# Raspberry Pi
sudo raspi-config  # System Options > Hostname

# Or manually
sudo hostnamectl set-hostname my-sensor-pi
# Also edit /etc/hosts to match

# Restart avahi
sudo systemctl restart avahi-daemon

# Now accessible as my-sensor-pi.local
```

### mDNS on Windows

Windows 10+ supports mDNS natively. Older versions need Bonjour (installed with iTunes or standalone).

```
# From Windows:
ping raspberrypi.local
ssh pi@raspberrypi.local
```

---

## DNS Lookup Tools

```bash
# dig (detailed)
dig example.com
dig example.com A              # specific record type
dig example.com MX
dig @1.1.1.1 example.com      # query specific server
dig +short example.com         # just the answer
dig +trace example.com         # follow the full resolution chain
dig -x 93.184.216.34          # reverse lookup

# nslookup (simpler)
nslookup example.com
nslookup example.com 1.1.1.1
nslookup -type=MX example.com

# host (simplest)
host example.com
host -t MX example.com
host 93.184.216.34             # reverse lookup

# Check what DNS server is being used
cat /etc/resolv.conf
resolvectl status

# Test local dnsmasq
dig @localhost dashboard.local
dig @192.168.1.50 mqtt.local
```

---

## Complete Network Setup Example

A field deployment with a Pi as DNS+DHCP server:

```
[Internet] --- [Pi: eth0 192.168.1.50] --- [Switch] --- [Sensors, Laptops]
                      |
                 [wlan0: AP mode, 192.168.4.1]
                      |
                 [WiFi Clients]

Pi provides:
- DNS server (dnsmasq) for local names and upstream forwarding
- DHCP server for automatic IP assignment
- WiFi AP (hostapd) for wireless clients
- NAT for internet sharing
- mDNS (avahi) for .local names
```

```ini
# /etc/dnsmasq.conf
no-resolv
server=1.1.1.1
server=8.8.8.8
interface=eth0
interface=wlan0
bind-interfaces
domain=field.local
local=/field.local/

# Wired clients
dhcp-range=eth0,192.168.1.100,192.168.1.200,24h
dhcp-option=eth0,option:router,192.168.1.50
dhcp-option=eth0,option:dns-server,192.168.1.50

# WiFi clients
dhcp-range=wlan0,192.168.4.10,192.168.4.100,12h
dhcp-option=wlan0,option:router,192.168.4.1
dhcp-option=wlan0,option:dns-server,192.168.4.1

# Static leases
dhcp-host=aa:bb:cc:11:22:33,sensor-1,192.168.1.101
dhcp-host=aa:bb:cc:44:55:66,sensor-2,192.168.1.102

# Local DNS
address=/dashboard.field.local/192.168.1.50
address=/mqtt.field.local/192.168.1.50
address=/grafana.field.local/192.168.1.50

cache-size=1000
log-queries
log-dhcp
```
