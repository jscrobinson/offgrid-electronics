# IP Addressing and Subnetting

Practical reference for IPv4 and IPv6 addressing, subnet calculations, and network planning.

---

## IPv4 Address Structure

An IPv4 address is 32 bits, written as four decimal octets separated by dots.

```
  192  .  168  .   1   .  100
11000000.10101000.00000001.01100100

Each octet: 0-255 (8 bits)
Total: 32 bits = 4,294,967,296 possible addresses
```

### Network and Host Portions

A subnet mask divides the address into **network** (identifies the subnet) and **host** (identifies the device) portions:

```
IP Address:    192.168.1.100
Subnet Mask:   255.255.255.0
               ───────────── ───
               Network part  Host

Network:       192.168.1.0    (host bits all 0)
Broadcast:     192.168.1.255  (host bits all 1)
Usable hosts:  192.168.1.1 through 192.168.1.254  (254 hosts)
```

---

## CIDR Notation

CIDR (Classless Inter-Domain Routing) notation uses a slash followed by the number of network bits:

```
192.168.1.0/24  means  subnet mask 255.255.255.0  (24 bits for network)
10.0.0.0/8      means  subnet mask 255.0.0.0      (8 bits for network)
172.16.0.0/12   means  subnet mask 255.240.0.0    (12 bits for network)
```

---

## Subnet Masks

### How Subnet Masks Work

The mask is a contiguous block of 1s followed by 0s:

```
/24 = 11111111.11111111.11111111.00000000 = 255.255.255.0
/16 = 11111111.11111111.00000000.00000000 = 255.255.0.0
/8  = 11111111.00000000.00000000.00000000 = 255.0.0.0
```

### Common Subnets Reference Table

| CIDR | Subnet Mask | Addresses | Usable Hosts | Typical Use |
|------|-------------|-----------|--------------|-------------|
| /32 | 255.255.255.255 | 1 | 0* | Single host route |
| /31 | 255.255.255.254 | 2 | 2** | Point-to-point link |
| /30 | 255.255.255.252 | 4 | 2 | Point-to-point link |
| /29 | 255.255.255.248 | 8 | 6 | Small segment |
| /28 | 255.255.255.240 | 16 | 14 | Small office |
| /27 | 255.255.255.224 | 32 | 30 | Department |
| /26 | 255.255.255.192 | 64 | 62 | Medium segment |
| /25 | 255.255.255.128 | 128 | 126 | Half a /24 |
| /24 | 255.255.255.0 | 256 | 254 | Standard LAN |
| /23 | 255.255.254.0 | 512 | 510 | Two /24s |
| /22 | 255.255.252.0 | 1,024 | 1,022 | Four /24s |
| /21 | 255.255.248.0 | 2,048 | 2,046 | Eight /24s |
| /20 | 255.255.240.0 | 4,096 | 4,094 | Large site |
| /16 | 255.255.0.0 | 65,536 | 65,534 | Campus |
| /8  | 255.0.0.0 | 16,777,216 | 16,777,214 | Major ISP |

\* /32 is a host route, used in routing tables.
\** /31 per RFC 3021, no broadcast address needed on point-to-point.

**Formula**: For a given prefix length /n:
- Total addresses = 2^(32-n)
- Usable hosts = 2^(32-n) - 2 (subtract network and broadcast)

---

## Private Address Ranges

These ranges are non-routable on the public internet. Use them for local networks:

| Range | CIDR | Subnet Mask | Addresses | Common Use |
|-------|------|-------------|-----------|------------|
| 10.0.0.0 - 10.255.255.255 | 10.0.0.0/8 | 255.0.0.0 | 16.7M | Large enterprises, VPNs |
| 172.16.0.0 - 172.31.255.255 | 172.16.0.0/12 | 255.240.0.0 | 1M | Medium networks, Docker |
| 192.168.0.0 - 192.168.255.255 | 192.168.0.0/16 | 255.255.0.0 | 65K | Home/small office LANs |

### Other Special Addresses

| Range | Purpose |
|-------|---------|
| 127.0.0.0/8 | Loopback (localhost) |
| 169.254.0.0/16 | Link-local (APIPA, auto-assigned when no DHCP) |
| 0.0.0.0/0 | Default route (all destinations) |
| 255.255.255.255 | Broadcast to all hosts on local network |
| 224.0.0.0/4 | Multicast |

---

## Subnetting Examples

### Example 1: Split 192.168.1.0/24 into 4 subnets

Need 4 subnets = 2^2, so borrow 2 bits: /24 becomes /26

```
Subnet 1: 192.168.1.0/26    (hosts: .1 - .62,   broadcast: .63)
Subnet 2: 192.168.1.64/26   (hosts: .65 - .126,  broadcast: .127)
Subnet 3: 192.168.1.128/26  (hosts: .129 - .190, broadcast: .191)
Subnet 4: 192.168.1.192/26  (hosts: .193 - .254, broadcast: .255)

Each subnet: 64 addresses, 62 usable hosts
```

### Example 2: Need at least 50 hosts per subnet

50 hosts needs 6 host bits (2^6 = 64 addresses, 62 usable): use /26

```
Network: 192.168.10.0/26
  Hosts: 192.168.10.1 - 192.168.10.62
  Broadcast: 192.168.10.63
  Gateway: 192.168.10.1 (typically)
```

### Example 3: Point-to-point link between two routers

Only need 2 addresses: use /30

```
Network: 10.0.1.0/30
  Router A: 10.0.1.1
  Router B: 10.0.1.2
  Network: 10.0.1.0
  Broadcast: 10.0.1.3
```

---

## Quick Mental Math for Subnets

### The "256 minus" trick

For subnets in the last octet: subtract the last octet of the subnet mask from 256 to get the block size.

```
/26 mask: 255.255.255.192
Block size: 256 - 192 = 64

Subnets start at: 0, 64, 128, 192
So: .0/26, .64/26, .128/26, .192/26
```

### Which subnet does an IP belong to?

Given 192.168.1.200 with /26 mask:

```
Block size = 64
200 / 64 = 3.125 → floor = 3
Subnet starts at: 3 * 64 = 192
Answer: 192.168.1.192/26
Usable range: .193 - .254
```

### Powers of 2 (memorize these)

```
2^1 = 2       2^5 = 32      2^9 = 512
2^2 = 4       2^6 = 64      2^10 = 1024
2^3 = 8       2^7 = 128     2^11 = 2048
2^4 = 16      2^8 = 256     2^12 = 4096
```

### Quick CIDR conversion

```
/24 = 256 hosts,   last octet mask = 0     (255.255.255.0)
/25 = 128 hosts,   last octet mask = 128   (255.255.255.128)
/26 = 64 hosts,    last octet mask = 192   (255.255.255.192)
/27 = 32 hosts,    last octet mask = 224   (255.255.255.224)
/28 = 16 hosts,    last octet mask = 240   (255.255.255.240)
/29 = 8 hosts,     last octet mask = 248   (255.255.255.248)
/30 = 4 hosts,     last octet mask = 252   (255.255.255.252)

Pattern: mask value = 256 - (number of addresses)
```

---

## VLSM (Variable Length Subnet Masking)

VLSM allows different subnet sizes within the same network. Allocate largest subnets first.

### Example: Allocate subnets from 10.1.0.0/24

Need: 100 hosts, 50 hosts, 25 hosts, 2 hosts (point-to-point)

```
1. 100 hosts → need 128 addresses → /25
   10.1.0.0/25     (hosts: .1-.126)

2. 50 hosts → need 64 addresses → /26
   10.1.0.128/26   (hosts: .129-.190)

3. 25 hosts → need 32 addresses → /27
   10.1.0.192/27   (hosts: .193-.222)

4. 2 hosts → need 4 addresses → /30
   10.1.0.224/30   (hosts: .225-.226)

Remaining: 10.1.0.228 - 10.1.0.255 (available for future use)
```

---

## IPv6 Basics

IPv6 uses 128-bit addresses, written as eight groups of four hex digits separated by colons.

### Address Format

```
Full:      2001:0db8:0000:0000:0000:0000:0000:0001
Shortened: 2001:db8::1

Rules for shortening:
1. Remove leading zeros in each group: 0db8 → db8, 0000 → 0
2. Replace ONE longest run of all-zero groups with ::
   (can only use :: once per address)
```

### Address Types

| Address/Prefix | Type | Purpose |
|-------|------|---------|
| ::1/128 | Loopback | Same as 127.0.0.1 in IPv4 |
| fe80::/10 | Link-local | Auto-configured on every interface, not routable |
| fd00::/8 (ULA) | Unique Local | Private addresses (like RFC 1918 in IPv4) |
| 2000::/3 | Global Unicast | Public, routable addresses |
| ff00::/8 | Multicast | One-to-many delivery |
| :: | Unspecified | Like 0.0.0.0 |

### Link-Local Addresses (fe80::)

Every IPv6 interface automatically gets a link-local address starting with `fe80::`. These are used for:
- Neighbor discovery
- Router discovery
- SLAAC (StateLess Address AutoConfiguration)
- Communication on the local link (not routed)

```
fe80::1a2b:3c4d:5e6f:7890%eth0

The %eth0 (or %wlan0) is the zone ID — specifies which interface,
since the same link-local address could exist on multiple interfaces.
```

### Unique Local Addresses (ULA) — fd00::/8

The IPv6 equivalent of private addresses. Use for local networks:

```
fd12:3456:7890::/48   — your site prefix (pick random 40-bit value)
fd12:3456:7890:1::/64 — subnet 1
fd12:3456:7890:2::/64 — subnet 2

Standard subnet size: /64 (2^64 = 18 quintillion host addresses per subnet)
```

### IPv6 Subnetting

IPv6 subnetting is simpler than IPv4:

```
ISP gives you:    2001:db8:abcd::/48    (65,536 /64 subnets)
Your subnets:     2001:db8:abcd:0001::/64  subnet 1
                  2001:db8:abcd:0002::/64  subnet 2
                  2001:db8:abcd:0003::/64  subnet 3
                  ...
                  2001:db8:abcd:ffff::/64  subnet 65535

/64 is the standard subnet size (required for SLAAC)
Each /64 has 2^64 host addresses — never worry about running out
```

### Dual Stack

Most modern networks run IPv4 and IPv6 simultaneously:

```bash
# Check your IPv6 addresses
ip -6 addr show

# Ping IPv6
ping6 fe80::1%eth0
ping6 2001:db8::1

# Common IPv6 DNS
2606:4700:4700::1111  # Cloudflare
2001:4860:4860::8888  # Google
```

---

## Practical Commands

```bash
# Show IP addresses
ip addr show
ip -4 addr show        # IPv4 only
ip -6 addr show        # IPv6 only
ifconfig               # older, still works

# Show routing table
ip route show
ip -6 route show
route -n               # older

# Set static IP (temporary)
sudo ip addr add 192.168.1.50/24 dev eth0
sudo ip route add default via 192.168.1.1

# Set static IP (permanent, Raspberry Pi / Debian)
# Edit /etc/dhcpcd.conf:
#   interface eth0
#   static ip_address=192.168.1.50/24
#   static routers=192.168.1.1
#   static domain_name_servers=1.1.1.1 8.8.8.8

# Test connectivity
ping 192.168.1.1
ping -c 4 8.8.8.8     # 4 pings then stop

# Discover devices on network
# Install nmap: sudo apt install nmap
nmap -sn 192.168.1.0/24              # ping scan
arp -a                                # show ARP table
ip neigh show                         # show neighbor table

# DNS lookup
nslookup example.com
dig example.com
host example.com

# Calculate subnets
# Install ipcalc: sudo apt install ipcalc
ipcalc 192.168.1.0/26
```

---

## Common Network Configurations

### Home Lab / Pi Setup

```
Network: 192.168.1.0/24
Gateway/Router: 192.168.1.1
DHCP Range: 192.168.1.100 - 192.168.1.200

Static assignments:
  Pi (main):     192.168.1.10
  Pi (backup):   192.168.1.11
  NAS:           192.168.1.20
  Print server:  192.168.1.30
  IoT gateway:   192.168.1.40
```

### Mesh Network

```
Network: 10.0.0.0/24
Node 1: 10.0.0.1
Node 2: 10.0.0.2
Node 3: 10.0.0.3
...

Or use per-node subnets:
Node 1 manages: 10.0.1.0/24
Node 2 manages: 10.0.2.0/24
```

### VPN Overlay

```
Physical LAN:    192.168.1.0/24
WireGuard VPN:   10.10.0.0/24
  Server:        10.10.0.1
  Client 1:      10.10.0.2
  Client 2:      10.10.0.3
```
