# WiFi Access Point Setup on Linux / Raspberry Pi

Turn a Raspberry Pi or Linux box into a WiFi access point with DHCP, DNS, and optional internet sharing (NAT). Essential for field deployments, sensor networks, and captive portals.

---

## Prerequisites

```bash
# Required packages
sudo apt update
sudo apt install hostapd dnsmasq iptables

# Stop services while configuring
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq

# Check WiFi hardware
iw list
# Look for "AP" in "Supported interface modes"
# Not all WiFi adapters support AP mode

# Check interface names
ip link show
# Common: wlan0 (built-in), wlan1 (USB dongle)
```

---

## hostapd Configuration

hostapd creates the WiFi access point.

### Basic 2.4GHz AP

Create `/etc/hostapd/hostapd.conf`:

```ini
# Interface and driver
interface=wlan0
driver=nl80211

# Network name and channel
ssid=FieldStation
channel=7
hw_mode=g

# 802.11n support (better throughput)
ieee80211n=1
wmm_enabled=1

# Security
auth_algs=1
wpa=2
wpa_passphrase=YourSecurePassword123
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP

# Logging
logger_syslog=-1
logger_syslog_level=2

# Country code (required for proper channel/power regulation)
country_code=US

# Max clients
max_num_sta=10

# Isolate clients from each other (security)
# ap_isolate=1
```

### 5GHz AP (if hardware supports it)

```ini
interface=wlan0
driver=nl80211
ssid=FieldStation-5G
hw_mode=a
channel=36
ieee80211n=1
ieee80211ac=1
wmm_enabled=1
auth_algs=1
wpa=2
wpa_passphrase=YourSecurePassword123
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
country_code=US

# 802.11ac (WiFi 5) settings
ht_capab=[HT40+][SHORT-GI-20][SHORT-GI-40]
vht_oper_chwidth=1
vht_oper_centr_freq_seg0_idx=42
```

### Open Network (no password — captive portal use)

```ini
interface=wlan0
driver=nl80211
ssid=OpenNetwork
channel=7
hw_mode=g
ieee80211n=1
wmm_enabled=1
auth_algs=1
# No wpa settings = open network
```

### Tell hostapd where to find the config

```bash
# Edit /etc/default/hostapd
sudo nano /etc/default/hostapd
# Set: DAEMON_CONF="/etc/hostapd/hostapd.conf"

# Or for systemd-based setup
sudo systemctl unmask hostapd
```

---

## dnsmasq Configuration (DHCP + DNS)

dnsmasq provides DHCP (automatic IP assignment) and DNS (name resolution) for clients connecting to your AP.

### Static IP for the AP Interface

```bash
# Option 1: /etc/dhcpcd.conf (Raspberry Pi OS)
# Add to /etc/dhcpcd.conf:
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant

# Option 2: systemd-networkd or /etc/network/interfaces
# /etc/network/interfaces:
auto wlan0
iface wlan0 inet static
    address 192.168.4.1
    netmask 255.255.255.0
```

### dnsmasq Configuration

Backup the default config and create a new one:

```bash
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.backup
sudo nano /etc/dnsmasq.conf
```

`/etc/dnsmasq.conf`:

```ini
# Listen only on the AP interface
interface=wlan0
bind-interfaces

# DHCP range and lease time
dhcp-range=192.168.4.10,192.168.4.100,255.255.255.0,24h

# Default gateway (this device)
dhcp-option=option:router,192.168.4.1

# DNS servers to offer clients
dhcp-option=option:dns-server,192.168.4.1,8.8.8.8

# Domain
domain=local
local=/local/

# Static DHCP leases (by MAC address)
dhcp-host=dc:a6:32:xx:xx:xx,sensor-node-1,192.168.4.50
dhcp-host=b8:27:eb:xx:xx:xx,sensor-node-2,192.168.4.51

# Local hostnames
address=/dashboard.local/192.168.4.1
address=/api.local/192.168.4.1

# Logging
log-queries
log-dhcp
log-facility=/var/log/dnsmasq.log

# Upstream DNS (when connected to internet)
server=1.1.1.1
server=8.8.8.8

# Cache size
cache-size=1000
```

---

## Enabling IP Forwarding and NAT

If the Pi has internet via ethernet (eth0) and you want to share it with WiFi clients:

### Enable IP Forwarding

```bash
# Temporary (until reboot)
sudo sysctl -w net.ipv4.ip_forward=1

# Permanent
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.d/99-ipforward.conf
sudo sysctl -p /etc/sysctl.d/99-ipforward.conf
```

### iptables NAT Masquerade

```bash
# Enable NAT: traffic from wlan0 clients gets masqueraded through eth0
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Allow forwarding between interfaces
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Save iptables rules (persist across reboot)
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

# Restore on boot — add to /etc/rc.local before "exit 0":
iptables-restore < /etc/iptables.ipv4.nat

# Or use iptables-persistent
sudo apt install iptables-persistent
sudo netfilter-persistent save
```

---

## Starting Everything

```bash
# Start services
sudo systemctl start dhcpcd       # or networking
sudo systemctl start dnsmasq
sudo systemctl start hostapd

# Enable on boot
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq

# Check status
sudo systemctl status hostapd
sudo systemctl status dnsmasq

# View connected clients
cat /var/lib/misc/dnsmasq.leases
# Or:
arp -a
iw dev wlan0 station dump
```

---

## Complete Setup Script

```bash
#!/bin/bash
# setup-ap.sh — Configure Raspberry Pi as WiFi Access Point
set -euo pipefail

IFACE="wlan0"
AP_IP="192.168.4.1"
AP_SSID="FieldStation"
AP_PASS="YourSecurePassword123"
DHCP_START="192.168.4.10"
DHCP_END="192.168.4.100"
CHANNEL=7
INTERNET_IFACE="eth0"  # set to "" if no internet sharing

echo "=== Installing packages ==="
sudo apt update
sudo apt install -y hostapd dnsmasq

echo "=== Stopping services ==="
sudo systemctl stop hostapd 2>/dev/null || true
sudo systemctl stop dnsmasq 2>/dev/null || true

echo "=== Configuring static IP ==="
if ! grep -q "interface $IFACE" /etc/dhcpcd.conf; then
    cat <<EOF | sudo tee -a /etc/dhcpcd.conf

interface $IFACE
    static ip_address=${AP_IP}/24
    nohook wpa_supplicant
EOF
fi

echo "=== Configuring hostapd ==="
cat <<EOF | sudo tee /etc/hostapd/hostapd.conf
interface=$IFACE
driver=nl80211
ssid=$AP_SSID
hw_mode=g
channel=$CHANNEL
ieee80211n=1
wmm_enabled=1
auth_algs=1
wpa=2
wpa_passphrase=$AP_PASS
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
country_code=US
EOF

sudo sed -i 's|^#DAEMON_CONF=.*|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' \
    /etc/default/hostapd

echo "=== Configuring dnsmasq ==="
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.backup 2>/dev/null || true
cat <<EOF | sudo tee /etc/dnsmasq.conf
interface=$IFACE
bind-interfaces
dhcp-range=${DHCP_START},${DHCP_END},255.255.255.0,24h
dhcp-option=option:router,$AP_IP
dhcp-option=option:dns-server,$AP_IP
server=1.1.1.1
server=8.8.8.8
domain=local
cache-size=1000
EOF

if [[ -n "$INTERNET_IFACE" ]]; then
    echo "=== Enabling IP forwarding and NAT ==="
    echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ipforward.conf
    sudo sysctl -w net.ipv4.ip_forward=1

    sudo iptables -t nat -A POSTROUTING -o "$INTERNET_IFACE" -j MASQUERADE
    sudo iptables -A FORWARD -i "$IFACE" -o "$INTERNET_IFACE" -j ACCEPT
    sudo iptables -A FORWARD -i "$INTERNET_IFACE" -o "$IFACE" \
        -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

    # Restore on boot
    if ! grep -q "iptables-restore" /etc/rc.local 2>/dev/null; then
        sudo sed -i '/^exit 0/i iptables-restore < /etc/iptables.ipv4.nat' \
            /etc/rc.local
    fi
fi

echo "=== Starting services ==="
sudo systemctl unmask hostapd
sudo systemctl enable hostapd dnsmasq
sudo systemctl restart dhcpcd
sudo systemctl start hostapd dnsmasq

echo "=== Done! ==="
echo "SSID: $AP_SSID"
echo "Password: $AP_PASS"
echo "AP IP: $AP_IP"
echo "DHCP Range: $DHCP_START - $DHCP_END"
```

---

## Captive Portal

A captive portal redirects all HTTP traffic to a local page. Useful for information displays or device registration in the field.

### Simple Captive Portal with dnsmasq + Python

1. Redirect all DNS to the AP:

Add to `/etc/dnsmasq.conf`:
```ini
# Redirect ALL DNS queries to the AP (captive portal)
address=/#/192.168.4.1
```

2. Redirect HTTP with iptables:

```bash
# Redirect all port 80 traffic to local web server
sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 \
    -j DNAT --to-destination 192.168.4.1:80

# Redirect HTTPS to local (browsers will show cert warning)
sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 443 \
    -j DNAT --to-destination 192.168.4.1:80
```

3. Run a simple web server:

```python
#!/usr/bin/env python3
# captive_portal.py
from http.server import HTTPServer, SimpleHTTPRequestHandler
import os

class CaptiveHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        # Android captive portal detection
        if self.path in ('/generate_204', '/gen_204'):
            self.send_response(302)
            self.send_header('Location', 'http://192.168.4.1/')
            self.end_headers()
            return

        # Apple captive portal detection
        if self.path == '/hotspot-detect.html':
            self.send_response(302)
            self.send_header('Location', 'http://192.168.4.1/')
            self.end_headers()
            return

        # Serve portal page
        self.send_response(200)
        self.send_header('Content-Type', 'text/html')
        self.end_headers()
        self.wfile.write(b"""
        <html><body>
        <h1>Field Station Portal</h1>
        <p>Welcome to the field network.</p>
        <ul>
          <li><a href="http://192.168.4.1:8080">Sensor Dashboard</a></li>
          <li><a href="http://192.168.4.1:3000">Data API</a></li>
        </ul>
        </body></html>
        """)

server = HTTPServer(('0.0.0.0', 80), CaptiveHandler)
print("Captive portal running on port 80")
server.serve_forever()
```

---

## Dual-Band Setup (2.4GHz + 5GHz)

If you have two WiFi interfaces (built-in + USB dongle), run both bands:

```bash
# Check interfaces
iw dev
# Should show wlan0 and wlan1

# hostapd config for 2.4GHz (wlan0)
# /etc/hostapd/hostapd-2g.conf
interface=wlan0
ssid=FieldStation
hw_mode=g
channel=7
# ... (same as above)

# hostapd config for 5GHz (wlan1)
# /etc/hostapd/hostapd-5g.conf
interface=wlan1
ssid=FieldStation-5G
hw_mode=a
channel=36
ieee80211ac=1
# ... (same as 5GHz config above)

# Run both
sudo hostapd /etc/hostapd/hostapd-2g.conf &
sudo hostapd /etc/hostapd/hostapd-5g.conf &

# Configure both interfaces with static IPs
# wlan0: 192.168.4.1/24
# wlan1: 192.168.5.1/24

# dnsmasq serves DHCP on both
# /etc/dnsmasq.conf:
interface=wlan0
interface=wlan1
dhcp-range=wlan0,192.168.4.10,192.168.4.100,24h
dhcp-range=wlan1,192.168.5.10,192.168.5.100,24h
```

---

## Common Issues and Fixes

### hostapd fails to start

```bash
# Check logs
sudo journalctl -u hostapd -n 50

# Common fixes:
# 1. Kill conflicting processes
sudo airmon-ng check kill
# or
sudo killall wpa_supplicant

# 2. Interface not available
sudo rfkill unblock wifi
sudo ip link set wlan0 up

# 3. Driver doesn't support AP mode
iw list | grep -A 10 "Supported interface modes"
# Must show "AP"

# 4. Country code not set
sudo raspi-config  # Localization > WLAN Country
# Or add to hostapd.conf: country_code=US
```

### Channel conflicts

```bash
# Scan for nearby APs and their channels
sudo iwlist wlan0 scan | grep -E "Channel|ESSID"

# Pick a non-overlapping channel:
# 2.4GHz: use 1, 6, or 11 (non-overlapping)
# 5GHz: channels 36, 40, 44, 48 (UNII-1, usually OK indoors)
```

### Clients connect but no internet

```bash
# Check IP forwarding
cat /proc/sys/net/ipv4/ip_forward
# Should be 1

# Check iptables NAT
sudo iptables -t nat -L -v

# Check if Pi has internet
ping 8.8.8.8

# Check DNS
nslookup google.com 192.168.4.1
```

### WiFi adapter recommendations for AP mode

- **Raspberry Pi built-in** — works, limited range
- **TP-Link TL-WN722N v1** — great range, well-supported (v1 only, not v2/v3)
- **Alfa AWUS036ACH** — dual-band, high power, excellent for field use
- **Alfa AWUS036ACHM** — similar, good Linux support
- **Panda PAU09** — dual-band, good Linux compatibility

Check chipset before buying. Well-supported chipsets: Atheros AR9271, Ralink RT5370, Realtek RTL8812AU.

---

## Monitoring

```bash
# Connected clients
iw dev wlan0 station dump

# DHCP leases
cat /var/lib/misc/dnsmasq.leases

# Traffic monitoring
sudo apt install iftop
sudo iftop -i wlan0

# Bandwidth test between AP and client
# Install iperf3 on both:
sudo apt install iperf3
# On AP:
iperf3 -s
# On client:
iperf3 -c 192.168.4.1
```
