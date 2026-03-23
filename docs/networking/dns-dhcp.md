# DNS & DHCP

How DNS works, DHCP basics, dnsmasq, Pi-hole, static leases, and mDNS/Avahi.

---

## How DNS Works

DNS (Domain Name System) translates human-readable names (example.com) to IP addresses (93.184.216.34).

### Resolution Process

1. **Browser/app** asks the OS resolver for "example.com"
2. **OS resolver** checks `/etc/hosts`, then its local cache
3. If not cached, queries the configured **recursive resolver** (e.g., 8.8.8.8 or your router)
4. Recursive resolver queries the **root servers** (.) — "Who handles .com?"
5. Root server responds with **.com TLD servers**
6. Recursive resolver queries .com TLD — "Who handles example.com?"
7. TLD responds with **authoritative nameserver** for example.com
8. Recursive resolver queries authoritative NS — "What's the IP for example.com?"
9. Authoritative NS responds with the IP address
10. Result is cached at each level (TTL determines cache duration)

```
Browser → OS Resolver → Recursive Resolver → Root NS
                                            → TLD NS (.com)
                                            → Authoritative NS (example.com)
                                            ← IP: 93.184.216.34
```

### DNS Record Types

| Type  | Purpose                          | Example                              |
|-------|----------------------------------|--------------------------------------|
| A     | IPv4 address                     | example.com → 93.184.216.34          |
| AAAA  | IPv6 address                     | example.com → 2606:2800:...          |
| CNAME | Alias to another name            | www.example.com → example.com        |
| MX    | Mail server                      | example.com → mail.example.com       |
| TXT   | Text data (SPF, DKIM, etc.)      | "v=spf1 include:..."                |
| NS    | Nameserver                       | example.com → ns1.example.com        |
| PTR   | Reverse DNS (IP to name)         | 34.216.184.93 → example.com          |
| SRV   | Service location                 | _sip._tcp.example.com → ...          |
| SOA   | Start of Authority               | Zone metadata                         |

### DNS Tools

```bash
# Query DNS
dig example.com
dig example.com A              # Specific record type
dig @8.8.8.8 example.com      # Query specific server
dig +short example.com         # Just the answer
dig +trace example.com         # Show full resolution chain

# Simple lookup
nslookup example.com
nslookup example.com 8.8.8.8  # Specific server
host example.com

# Reverse DNS
dig -x 93.184.216.34

# Check DNS response time
dig example.com | grep "Query time"

# View system DNS config
cat /etc/resolv.conf
resolvectl status              # systemd-resolved
```

---

## DHCP Basics

DHCP (Dynamic Host Configuration Protocol) automatically assigns IP addresses to devices on a network.

### DHCP Process (DORA)

1. **Discover:** Client broadcasts "I need an IP address"
2. **Offer:** DHCP server responds with an available IP
3. **Request:** Client says "I'll take that one"
4. **Acknowledge:** Server confirms the lease

### What DHCP Provides

- IP address
- Subnet mask
- Default gateway
- DNS server(s)
- Lease duration
- Optional: NTP server, domain name, MTU, routes

### DHCP Lease

Each IP assignment has a **lease time**. When the lease expires, the client must renew. Clients typically try to renew at 50% of lease time.

---

## dnsmasq

dnsmasq is a lightweight DNS forwarder and DHCP server — perfect for small networks, Raspberry Pi, embedded systems.

### Installation

```bash
sudo apt install dnsmasq
```

### Configuration

Edit `/etc/dnsmasq.conf` (or create a file in `/etc/dnsmasq.d/`):

```ini
# ============ GENERAL ============

# Don't read /etc/resolv.conf for upstream DNS
no-resolv

# Upstream DNS servers
server=1.1.1.1
server=8.8.8.8

# Only listen on specific interfaces
interface=eth0
bind-interfaces

# Don't forward short names (without dots)
domain-needed
bogus-priv

# ============ DNS ============

# Local domain
domain=home.local
local=/home.local/

# Custom DNS records
address=/myserver.home.local/192.168.1.10
address=/printer.home.local/192.168.1.20

# Block a domain (return NXDOMAIN)
address=/ads.example.com/

# Cache size
cache-size=1000

# Log DNS queries (debug)
#log-queries

# ============ DHCP ============

# DHCP range and lease time
dhcp-range=192.168.1.100,192.168.1.200,255.255.255.0,24h

# Default gateway
dhcp-option=3,192.168.1.1

# DNS server
dhcp-option=6,192.168.1.1

# NTP server
dhcp-option=42,192.168.1.1

# Domain name
dhcp-option=15,home.local

# Static DHCP leases (MAC → IP → hostname)
dhcp-host=aa:bb:cc:dd:ee:01,server,192.168.1.10
dhcp-host=aa:bb:cc:dd:ee:02,printer,192.168.1.20
dhcp-host=aa:bb:cc:dd:ee:03,esp32-sensor,192.168.1.30

# DHCP lease file
dhcp-leasefile=/var/lib/misc/dnsmasq.leases

# Always send these options, even if not requested
dhcp-authoritative

# Log DHCP transactions
log-dhcp
```

### Common DHCP Options

| Option | Number | Purpose                    | Example                      |
|--------|--------|----------------------------|------------------------------|
| Router | 3      | Default gateway            | `dhcp-option=3,192.168.1.1`  |
| DNS    | 6      | DNS server                 | `dhcp-option=6,192.168.1.1`  |
| Domain | 15     | Domain name                | `dhcp-option=15,home.local`  |
| NTP    | 42     | NTP server                 | `dhcp-option=42,pool.ntp.org`|
| MTU    | 26     | Interface MTU              | `dhcp-option=26,1500`        |

### Management

```bash
# Test config
dnsmasq --test

# Restart
sudo systemctl restart dnsmasq

# View current leases
cat /var/lib/misc/dnsmasq.leases

# View logs
journalctl -u dnsmasq -f

# Clear DNS cache (restart dnsmasq)
sudo systemctl restart dnsmasq
```

---

## Pi-hole

Pi-hole is a network-wide ad blocker that acts as a DNS sinkhole. Built on dnsmasq/FTL.

### Installation

```bash
curl -sSL https://install.pi-hole.net | bash
# Follow the interactive installer
# Choose interface, upstream DNS, blocklists, etc.
```

### Post-Install

```bash
# Set/change admin password
pihole -a -p

# Access web interface
# http://pi.hole/admin  (if DNS is pointed to Pi-hole)
# http://192.168.1.x/admin
```

### Configure Devices to Use Pi-hole

**Option 1: Per-device** — Set DNS to Pi-hole IP in each device's network settings.

**Option 2: Router-wide** — Set Pi-hole as the DNS server in your router's DHCP settings. All devices on the network automatically use it.

**Option 3: Pi-hole as DHCP server** — Disable DHCP on your router, enable it in Pi-hole (Settings → DHCP).

### Pi-hole Commands

```bash
# Status
pihole status

# Update blocklists
pihole -g

# Enable/disable blocking
pihole disable          # Disable indefinitely
pihole disable 5m       # Disable for 5 minutes
pihole enable

# Query log
pihole -t               # Tail the log

# Whitelist/blacklist
pihole -w example.com   # Whitelist
pihole -b ads.bad.com   # Blacklist

# Update Pi-hole
pihole -up

# Flush logs
pihole flush
```

### Custom DNS Records in Pi-hole

Add to `/etc/pihole/custom.list`:
```
192.168.1.10 server.local
192.168.1.20 printer.local
192.168.1.50 pi.local
```

Or use the web interface: Local DNS → DNS Records.

### CNAME Records

Add to `/etc/dnsmasq.d/05-custom-cname.conf`:
```
cname=nas.local,server.local
```

---

## Static DHCP Leases

Assign a fixed IP to a device based on its MAC address.

### In dnsmasq

```ini
# In /etc/dnsmasq.conf or /etc/dnsmasq.d/static-leases.conf
dhcp-host=aa:bb:cc:dd:ee:01,hostname,192.168.1.10
dhcp-host=aa:bb:cc:dd:ee:02,192.168.1.20
```

### In Pi-hole

Web interface → Settings → DHCP → Static DHCP leases (bottom of page).

### Find MAC Address

```bash
# On the device itself
ip link show
# or
cat /sys/class/net/eth0/address

# From another machine on the same network
# After pinging the target:
arp -a
# or
ip neigh show
```

---

## mDNS / Avahi (Zero-Configuration Networking)

mDNS (Multicast DNS) allows devices to find each other on a local network using `.local` names without a DNS server.

### How It Works

- Devices announce their hostname on the `.local` domain
- Uses multicast address 224.0.0.251:5353 (UDP)
- Each device responds to queries for its own name
- No central server needed

### Avahi (Linux mDNS Implementation)

```bash
# Install (usually pre-installed on Pi OS)
sudo apt install avahi-daemon

# Start and enable
sudo systemctl enable avahi-daemon
sudo systemctl start avahi-daemon
```

### Configure Hostname

```bash
# Set hostname
sudo hostnamectl set-hostname mypi

# The device is now reachable as:
# mypi.local
```

### Browse/Discover Services

```bash
# Install tools
sudo apt install avahi-utils

# Browse all services
avahi-browse -a

# Browse specific service type
avahi-browse _http._tcp       # Web servers
avahi-browse _ssh._tcp        # SSH servers
avahi-browse _printer._tcp    # Printers
avahi-browse _smb._tcp        # Samba/Windows shares

# Resolve a hostname
avahi-resolve -n mypi.local
avahi-resolve -a 192.168.1.50  # Reverse lookup

# Detailed service browsing
avahi-browse -art              # All services, resolve, terminate
```

### Publish Custom Services

Create a service file in `/etc/avahi/services/`:

```xml
<!-- /etc/avahi/services/http.service -->
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">Web Server on %h</name>
  <service>
    <type>_http._tcp</type>
    <port>80</port>
  </service>
</service-group>
```

```bash
sudo systemctl restart avahi-daemon
```

### mDNS on Different Platforms

| Platform | Implementation | Notes                                    |
|----------|---------------|------------------------------------------|
| Linux    | Avahi         | `avahi-daemon`                            |
| macOS    | Bonjour       | Built-in, always active                   |
| Windows  | Bonjour/mDNS  | Built-in on Win10+, or install Bonjour    |
| iOS      | Bonjour       | Built-in                                  |
| Android  | Varies        | Support is inconsistent                    |
| ESP32    | ESPmDNS       | `MDNS.begin("hostname")`                 |

### ESP32 mDNS

```cpp
#include <ESPmDNS.h>

void setup() {
    WiFi.begin(ssid, password);
    // ... wait for connection

    if (MDNS.begin("esp32-sensor")) {
        Serial.println("mDNS: esp32-sensor.local");
        MDNS.addService("http", "tcp", 80);  // Advertise web server
    }
}
```

Now the ESP32 is reachable at `esp32-sensor.local` from any mDNS-capable device on the LAN.

---

## DNS Over HTTPS / DNS Over TLS

For encrypted DNS queries (prevent ISP snooping):

### Using cloudflared (DoH Proxy)

```bash
# Install cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm
sudo mv cloudflared-linux-arm /usr/local/bin/cloudflared
sudo chmod +x /usr/local/bin/cloudflared

# Run as DNS proxy
cloudflared proxy-dns --port 5053 --upstream https://1.1.1.1/dns-query

# Point dnsmasq to cloudflared
# In /etc/dnsmasq.conf:
server=127.0.0.1#5053
```

### Using stubby (DoT)

```bash
sudo apt install stubby

# stubby listens on 127.0.0.1:53 by default
# Configure upstream in /etc/stubby/stubby.yml
# Point dnsmasq to: server=127.0.0.1#53
```

---

## Troubleshooting

| Problem                         | Check                                             |
|---------------------------------|---------------------------------------------------|
| Name resolution fails           | `cat /etc/resolv.conf` — correct DNS server?      |
| dnsmasq won't start             | Port 53 already in use? `sudo ss -ulnp | grep 53` |
| systemd-resolved conflicts      | `sudo systemctl disable systemd-resolved`          |
| DHCP not assigning IPs          | Check interface and range in dnsmasq.conf          |
| .local names not working        | Install/start avahi-daemon                         |
| Pi-hole blocking too much       | Check query log, whitelist domains                 |
| DNS slow                        | Check upstream servers, increase cache-size        |
| Lease not renewing              | Check lease file permissions, restart dnsmasq      |

### systemd-resolved Conflicts

On Ubuntu/newer Debian, `systemd-resolved` listens on port 53, conflicting with dnsmasq:

```bash
# Option 1: Disable systemd-resolved
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo rm /etc/resolv.conf
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf

# Option 2: Change systemd-resolved to not listen on port 53
sudo nano /etc/systemd/resolved.conf
# Set: DNSStubListener=no
sudo systemctl restart systemd-resolved
```
