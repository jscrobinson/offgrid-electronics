# WiFi Access Point Setup on Linux / Raspberry Pi

Turn a Pi or Linux box into a WiFi access point with DHCP and optional internet sharing.

---

## Overview

Components needed:
1. **hostapd** — Creates the WiFi access point
2. **dnsmasq** — Provides DHCP (and optionally DNS) to connected clients
3. **iptables** — NAT/forwarding if sharing internet from another interface
4. **Captive portal** (optional) — Redirect clients to a local web page

---

## Prerequisites

```bash
# Check your WiFi adapter supports AP mode
iw list | grep -A 10 "Supported interface modes"
# Must show "AP" in the list

# Install required packages
sudo apt update
sudo apt install hostapd dnsmasq

# Stop services while configuring
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
```

### Which Interface?

```bash
# List wireless interfaces
iw dev
# Typically: wlan0 (built-in), wlan1 (USB adapter)

# If using Pi's built-in WiFi as AP and a USB adapter for internet:
# wlan0 = AP (hostapd)
# wlan1 or eth0 = internet uplink
```

---

## Static IP for the AP Interface

Configure the AP interface with a static IP. This will be the gateway for connected clients.

```bash
sudo nano /etc/dhcpcd.conf
```

Add at the bottom:

```
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
```

The `nohook wpa_supplicant` line prevents the interface from trying to connect to other networks.

**Alternative (if using NetworkManager instead of dhcpcd):**

```bash
sudo nmcli con add type wifi ifname wlan0 con-name hotspot \
    autoconnect no ssid "MyAP"
sudo nmcli con modify hotspot 802-11-wireless.mode ap \
    802-11-wireless.band bg \
    ipv4.method shared \
    ipv4.addresses 192.168.4.1/24
sudo nmcli con modify hotspot wifi-sec.key-mgmt wpa-psk \
    wifi-sec.psk "YourPassword"
sudo nmcli con up hotspot
# NetworkManager handles hostapd+dnsmasq automatically in this case
```

---

## hostapd Configuration

```bash
sudo nano /etc/hostapd/hostapd.conf
```

### Basic WPA2 Access Point

```ini
# Interface and driver
interface=wlan0
driver=nl80211

# Network name
ssid=OffGrid-AP

# Band and channel
hw_mode=g              # g = 2.4GHz, a = 5GHz
channel=7              # 1, 6, 11 are non-overlapping on 2.4GHz
ieee80211n=1           # Enable 802.11n (HT)
wmm_enabled=0          # QoS (disable for simplicity)

# Country code (required for proper channel/power regulation)
country_code=US

# Security
macaddr_acl=0          # 0 = accept all MACs
auth_algs=1            # 1 = WPA
wpa=2                  # WPA2 only
wpa_passphrase=YourSecurePassword
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP

# Optional: Hide SSID
#ignore_broadcast_ssid=1

# Optional: Limit connected clients
#max_num_sta=10
```

### 5 GHz Access Point (802.11ac)

```ini
interface=wlan0
driver=nl80211
ssid=OffGrid-5G
hw_mode=a
channel=36
ieee80211n=1
ieee80211ac=1
ht_capab=[HT40+][SHORT-GI-20][SHORT-GI-40]
vht_oper_chwidth=1
vht_oper_centr_freq_seg0_idx=42
country_code=US
wpa=2
wpa_passphrase=YourSecurePassword
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
```

**Note:** Not all WiFi adapters support 5 GHz AP mode. Check with `iw list`.

### Open Access Point (No Password)

```ini
interface=wlan0
driver=nl80211
ssid=OffGrid-Open
hw_mode=g
channel=7
country_code=US
# No wpa settings = open network
```

### Tell hostapd Where the Config Is

```bash
sudo nano /etc/default/hostapd
```

Set:
```
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```

---

## dnsmasq Configuration (DHCP + DNS)

Back up and replace the default config:

```bash
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo nano /etc/dnsmasq.conf
```

```ini
# Only listen on AP interface
interface=wlan0
listen-address=192.168.4.1

# Don't use /etc/resolv.conf
no-resolv

# Upstream DNS servers (for when internet is available)
server=8.8.8.8
server=1.1.1.1

# DHCP range
dhcp-range=192.168.4.10,192.168.4.100,255.255.255.0,24h

# Default gateway
dhcp-option=3,192.168.4.1

# DNS server
dhcp-option=6,192.168.4.1

# Static DHCP leases (optional)
#dhcp-host=aa:bb:cc:dd:ee:ff,sensor-node,192.168.4.50

# Domain
domain=local

# Log DHCP requests (useful for debugging)
log-dhcp

# Cache DNS queries
cache-size=1000
```

---

## IP Forwarding and NAT (Internet Sharing)

If you want clients connected to the AP to access the internet through another interface (e.g., eth0 for Ethernet or wlan1 for USB WiFi):

### Enable IP Forwarding

```bash
# Temporary (until reboot)
sudo sysctl -w net.ipv4.ip_forward=1

# Permanent
sudo nano /etc/sysctl.conf
# Uncomment: net.ipv4.ip_forward=1
sudo sysctl -p
```

### iptables NAT Rules

```bash
# Replace eth0 with your internet-connected interface
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

# Save rules (persist across reboots)
sudo apt install iptables-persistent
sudo netfilter-persistent save
```

---

## Start Everything

```bash
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq

sudo systemctl restart dhcpcd
sudo systemctl start hostapd
sudo systemctl start dnsmasq
```

### Verify

```bash
# Check hostapd status
sudo systemctl status hostapd

# Check dnsmasq status
sudo systemctl status dnsmasq

# Check the AP interface has the static IP
ip addr show wlan0

# Check connected clients
# DHCP leases:
cat /var/lib/misc/dnsmasq.leases
# WiFi clients:
iw dev wlan0 station dump
```

---

## Captive Portal

Redirect all HTTP traffic from connected clients to a local web page.

### Using iptables + nginx

```bash
sudo apt install nginx
```

**iptables redirect (add before NAT rules):**
```bash
# Redirect all port 80 traffic to local web server
sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 80

# Redirect DNS to local dnsmasq
sudo iptables -t nat -A PREROUTING -i wlan0 -p udp --dport 53 -j REDIRECT --to-port 53
```

**dnsmasq — resolve all domains to AP IP:**
Add to `/etc/dnsmasq.conf`:
```ini
# Redirect all DNS queries to the AP
address=/#/192.168.4.1
```

**nginx config** (`/etc/nginx/sites-available/captive`):
```nginx
server {
    listen 80 default_server;
    server_name _;

    root /var/www/captive;
    index index.html;

    # Captive portal detection endpoints
    location /generate_204 { return 302 http://192.168.4.1/; }  # Android
    location /hotspot-detect.html { return 302 http://192.168.4.1/; }  # Apple
    location /connecttest.txt { return 302 http://192.168.4.1/; }  # Windows
    location /ncsi.txt { return 302 http://192.168.4.1/; }  # Windows

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/captive /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
```

**Create the landing page:**
```bash
sudo mkdir -p /var/www/captive
sudo nano /var/www/captive/index.html
```

```html
<!DOCTYPE html>
<html>
<head><title>OffGrid Network</title></head>
<body>
    <h1>Welcome to the OffGrid Network</h1>
    <p>You are connected to a local network.</p>
    <p><a href="/docs/">Browse Documentation</a></p>
</body>
</html>
```

### Using nodogsplash (Simpler Alternative)

```bash
sudo apt install nodogsplash

sudo nano /etc/nodogsplash/nodogsplash.conf
```

```ini
GatewayInterface wlan0
GatewayAddress 192.168.4.1
MaxClients 50
AuthIdleTimeout 600
SplashPage splash.html
```

```bash
sudo systemctl enable nodogsplash
sudo systemctl start nodogsplash
```

---

## Simultaneous AP + Client (Tricky)

Some WiFi chips support running AP and client (station) mode simultaneously:

```bash
# Check if supported
iw list | grep -A 5 "valid interface combinations"
# Look for: #{ AP, managed } -- means one AP + one client

# Create virtual interface
sudo iw dev wlan0 interface add wlan0_ap type __ap

# wlan0 connects to upstream WiFi (station mode)
# wlan0_ap runs the access point (AP mode)
```

This is unreliable on many adapters. A USB WiFi adapter dedicated to AP mode is more stable.

---

## Troubleshooting

| Problem                        | Check                                              |
|--------------------------------|----------------------------------------------------|
| hostapd fails to start         | `journalctl -u hostapd` — check for driver/channel issues |
| No SSID visible                | Check `rfkill list` — unblock with `rfkill unblock wifi` |
| Clients connect but no DHCP    | Check dnsmasq is running, interface matches         |
| Clients get IP but no internet | Check ip_forward=1, iptables NAT, upstream interface|
| Channel not allowed             | Set correct `country_code` in hostapd.conf         |
| "Could not connect to wpa_supplicant" | Add `nohook wpa_supplicant` to dhcpcd.conf  |
| hostapd: "nl80211: Could not configure driver mode" | Driver doesn't support AP mode, try different adapter |

### Recommended USB WiFi Adapters for AP Mode

Chipsets with good Linux AP mode support:
- **Ralink RT5370** — Very common, well-supported
- **Realtek RTL8188CUS** — Widely available, cheap
- **Atheros AR9271** — Excellent Linux support, also works for monitoring
- **MediaTek MT7612U** — 802.11ac, dual band

Avoid: Realtek RTL88x2BU (driver issues), Intel (generally no AP mode).

---

## Complete Setup Script

```bash
#!/bin/bash
# Quick AP setup script for Raspberry Pi
# Run as root

INTERFACE="wlan0"
SSID="OffGrid-AP"
PASSWORD="changeme123"
IP="192.168.4.1"
DHCP_START="192.168.4.10"
DHCP_END="192.168.4.100"

apt update && apt install -y hostapd dnsmasq

systemctl stop hostapd dnsmasq

# Static IP
cat >> /etc/dhcpcd.conf << EOF

interface ${INTERFACE}
    static ip_address=${IP}/24
    nohook wpa_supplicant
EOF

# hostapd
cat > /etc/hostapd/hostapd.conf << EOF
interface=${INTERFACE}
driver=nl80211
ssid=${SSID}
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
wpa=2
wpa_passphrase=${PASSWORD}
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
country_code=US
EOF

echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' > /etc/default/hostapd

# dnsmasq
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig 2>/dev/null
cat > /etc/dnsmasq.conf << EOF
interface=${INTERFACE}
dhcp-range=${DHCP_START},${DHCP_END},255.255.255.0,24h
dhcp-option=3,${IP}
dhcp-option=6,${IP}
no-resolv
server=8.8.8.8
EOF

systemctl unmask hostapd
systemctl enable hostapd dnsmasq
systemctl restart dhcpcd hostapd dnsmasq

echo "AP '${SSID}' should now be visible."
echo "Connect and access ${IP} from a browser."
```
