# Raspberry Pi Networking

## WiFi Configuration

### NetworkManager (Bookworm and Later)

Raspberry Pi OS Bookworm switched from dhcpcd/wpa_supplicant to NetworkManager as the default networking stack.

```bash
# Check current connections
nmcli con show

# Check WiFi status
nmcli dev wifi list

# Connect to a WiFi network
sudo nmcli dev wifi connect "MyNetwork" password "MyPassword"

# Connect to a hidden network
sudo nmcli dev wifi connect "HiddenNetwork" password "MyPassword" hidden yes

# Disconnect
nmcli dev disconnect wlan0

# Delete a saved connection
sudo nmcli con delete "MyNetwork"

# Show connection details
nmcli con show "MyNetwork"

# Show IP addresses
ip addr show wlan0

# Show all network interfaces
nmcli dev status
```

**Connecting to WPA2-Enterprise (e.g., eduroam):**
```bash
sudo nmcli con add type wifi \
    con-name "eduroam" \
    ssid "eduroam" \
    wifi-sec.key-mgmt wpa-eap \
    802-1x.eap peap \
    802-1x.identity "user@university.edu" \
    802-1x.password "password" \
    802-1x.phase2-auth mschapv2
```

### wpa_supplicant (Bullseye and Earlier)

```bash
# Edit WiFi configuration
sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
```

```
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="PrimaryNetwork"
    psk="password1"
    priority=10
}

network={
    ssid="BackupNetwork"
    psk="password2"
    priority=5
}
```

Higher priority numbers are preferred. Use `wpa_passphrase` to generate hashed passwords:

```bash
wpa_passphrase "MyNetwork" "MyPassword"
# Output includes a hashed psk= line — use this instead of plaintext
```

```bash
# Apply changes without reboot
wpa_cli -i wlan0 reconfigure

# Check WiFi status
wpa_cli -i wlan0 status

# Scan for networks
sudo iwlist wlan0 scan | grep ESSID
```

### Disabling WiFi and Bluetooth (Power Saving)

```bash
# Temporary (until reboot)
sudo rfkill block wifi
sudo rfkill block bluetooth
sudo rfkill list    # Check status
sudo rfkill unblock wifi   # Re-enable

# Permanent: add to /boot/firmware/config.txt
dtoverlay=disable-wifi
dtoverlay=disable-bt
```

---

## Static IP Configuration

### Via NetworkManager (Bookworm)

```bash
# Set static IP on Ethernet
sudo nmcli con mod "Wired connection 1" \
    ipv4.method manual \
    ipv4.addresses "192.168.1.100/24" \
    ipv4.gateway "192.168.1.1" \
    ipv4.dns "192.168.1.1 8.8.8.8 8.8.4.4"

sudo nmcli con up "Wired connection 1"

# Set static IP on WiFi
sudo nmcli con mod "MyNetwork" \
    ipv4.method manual \
    ipv4.addresses "192.168.1.101/24" \
    ipv4.gateway "192.168.1.1" \
    ipv4.dns "192.168.1.1 8.8.8.8"

sudo nmcli con up "MyNetwork"

# Revert to DHCP
sudo nmcli con mod "Wired connection 1" ipv4.method auto
sudo nmcli con mod "Wired connection 1" ipv4.addresses ""
sudo nmcli con up "Wired connection 1"
```

### Via dhcpcd (Bullseye and Earlier)

Edit `/etc/dhcpcd.conf`:

```
interface eth0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8

interface wlan0
static ip_address=192.168.1.101/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8
```

```bash
sudo systemctl restart dhcpcd
```

---

## Ethernet Configuration

Ethernet is plug-and-play with DHCP by default. For static IP, see the section above.

### Checking Ethernet Link Status

```bash
# Check if cable is connected and link speed
ethtool eth0

# Quick check
ip link show eth0
# Look for "state UP" or "state DOWN"

# Check IP address
ip addr show eth0
```

### USB Ethernet Adapters

The Pi supports USB Ethernet adapters for additional ports. They appear as `eth1`, `eth2`, etc.

```bash
# List network interfaces
ip link show

# Check which adapter is which
lsusb   # Shows USB devices
dmesg | grep -i eth   # Shows when adapters were detected
```

---

## Creating a WiFi Hotspot (Access Point)

Turn the Pi into a wireless access point that other devices can connect to. Useful for field deployments, IoT gateways, and creating isolated networks.

### Method 1: NetworkManager Hotspot (Simplest, Bookworm)

```bash
# Create a hotspot on wlan0
sudo nmcli dev wifi hotspot ifname wlan0 ssid "PiHotspot" password "MySecurePassword"

# Check hotspot status
nmcli con show "Hotspot"

# Stop hotspot
sudo nmcli con down "Hotspot"

# Start hotspot again
sudo nmcli con up "Hotspot"
```

This creates a simple hotspot. For more control (DHCP range, DNS, routing), use the hostapd method below.

### Method 2: hostapd + dnsmasq (Full Control)

This method creates a dedicated access point with DHCP server. Useful when you want the Pi to act as a router or gateway.

**Install packages:**
```bash
sudo apt install hostapd dnsmasq
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
```

**Configure a static IP for the AP interface:**

For NetworkManager (Bookworm), first remove wlan0 from NM control:
```bash
# Create /etc/NetworkManager/conf.d/unmanaged.conf
sudo tee /etc/NetworkManager/conf.d/unmanaged.conf << 'EOF'
[keyfile]
unmanaged-devices=interface-name:wlan0
EOF
sudo systemctl restart NetworkManager
```

Set static IP:
```bash
sudo ip addr add 192.168.4.1/24 dev wlan0
sudo ip link set wlan0 up
```

For persistence, add to `/etc/rc.local` or create a systemd service, or use dhcpcd (Bullseye):

```
# In /etc/dhcpcd.conf (Bullseye)
interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
```

**Configure dnsmasq:**

Back up the original config and create a new one:
```bash
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
sudo tee /etc/dnsmasq.conf << 'EOF'
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.50,255.255.255.0,24h
domain=local
address=/gw.local/192.168.4.1
EOF
```

**Configure hostapd:**

```bash
sudo tee /etc/hostapd/hostapd.conf << 'EOF'
interface=wlan0
driver=nl80211
ssid=PiHotspot
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=MySecurePassword
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF
```

For 5 GHz (Pi 3B+, 4, 5 — requires compliant country code):
```
hw_mode=a
channel=36
ieee80211n=1
ieee80211ac=1
```

**Point hostapd to the config file:**

```bash
# For systems using /etc/default/hostapd
sudo sed -i 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd
```

**Enable and start services:**
```bash
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq
sudo systemctl start hostapd
sudo systemctl start dnsmasq
```

### Sharing Internet (NAT Routing)

If the Pi has internet via Ethernet (eth0) and you want hotspot clients (wlan0) to access it:

```bash
# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1

# Make persistent:
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

# Set up NAT with iptables
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

# Save iptables rules (persist across reboots)
sudo apt install iptables-persistent
sudo netfilter-persistent save
```

### Simultaneous AP and Client (AP+STA)

Some Pi WiFi chipsets support running as an AP and connected to another WiFi network simultaneously. This is not officially supported and can be unreliable.

A more reliable approach: use a USB WiFi adapter for one role and the built-in WiFi for the other.

---

## Network Bridging

Bridging connects two interfaces at Layer 2, making devices on both interfaces appear to be on the same network.

### Bridge Ethernet and WiFi AP

```bash
sudo apt install bridge-utils

# Create bridge
sudo brctl addbr br0
sudo brctl addif br0 eth0

# Configure bridge in /etc/network/interfaces or via NetworkManager
# In hostapd.conf, change:
#   bridge=br0
# And remove the static IP from wlan0 — the bridge gets the IP instead
```

### Bridge for VMs/Containers

```bash
# Create a bridge for virtual machines
sudo nmcli con add type bridge con-name br0 ifname br0
sudo nmcli con add type ethernet con-name br0-eth0 ifname eth0 master br0
sudo nmcli con mod br0 ipv4.method manual ipv4.addresses "192.168.1.100/24" ipv4.gateway "192.168.1.1"
sudo nmcli con up br0
```

---

## Firewall Configuration

### UFW (Uncomplicated Firewall)

The simplest approach for most users.

```bash
sudo apt install ufw

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow specific services
sudo ufw allow ssh                  # Port 22
sudo ufw allow 80/tcp              # HTTP
sudo ufw allow 443/tcp             # HTTPS
sudo ufw allow 1883/tcp            # MQTT
sudo ufw allow from 192.168.1.0/24  # Allow entire local subnet
sudo ufw allow from 192.168.1.50 to any port 22  # SSH from specific IP only

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status verbose

# Delete a rule
sudo ufw delete allow 80/tcp

# Disable firewall
sudo ufw disable

# Reset all rules
sudo ufw reset
```

### iptables (Direct)

For more granular control:

```bash
# View current rules
sudo iptables -L -v -n

# Allow established connections
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
sudo iptables -A INPUT -i lo -j ACCEPT

# Allow SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow ICMP (ping)
sudo iptables -A INPUT -p icmp -j ACCEPT

# Allow from local network
sudo iptables -A INPUT -s 192.168.1.0/24 -j ACCEPT

# Drop everything else
sudo iptables -A INPUT -j DROP

# Save rules
sudo apt install iptables-persistent
sudo netfilter-persistent save

# Clear all rules (start fresh)
sudo iptables -F
```

### nftables (Modern Replacement for iptables)

Debian Bookworm uses nftables as the backend for iptables (via iptables-nft compatibility layer). For direct nftables configuration:

```bash
sudo apt install nftables
sudo systemctl enable nftables

# Edit ruleset
sudo nano /etc/nftables.conf
```

```
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Allow established/related connections
        ct state established,related accept

        # Allow loopback
        iif "lo" accept

        # Allow ICMP
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept

        # Allow SSH
        tcp dport 22 accept

        # Allow from local network
        ip saddr 192.168.1.0/24 accept

        # Log and drop everything else
        log prefix "nft-drop: " drop
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

```bash
# Apply rules
sudo nft -f /etc/nftables.conf

# Verify
sudo nft list ruleset
```

---

## DNS Configuration

### Checking Current DNS

```bash
# Bookworm (NetworkManager)
nmcli dev show | grep DNS
resolvectl status

# Check what resolv.conf points to
cat /etc/resolv.conf
```

### Setting Custom DNS

```bash
# Via NetworkManager
sudo nmcli con mod "Wired connection 1" ipv4.dns "1.1.1.1 8.8.8.8"
sudo nmcli con mod "Wired connection 1" ipv4.ignore-auto-dns yes
sudo nmcli con up "Wired connection 1"
```

### Running a Local DNS Cache

```bash
sudo apt install dnsmasq

# Basic caching config in /etc/dnsmasq.conf:
# cache-size=1000
# no-resolv
# server=1.1.1.1
# server=8.8.8.8

sudo systemctl restart dnsmasq
```

---

## Network Diagnostics

```bash
# Check IP addresses
ip addr show
hostname -I          # Just the IP addresses

# Check routing table
ip route show

# Check DNS resolution
nslookup google.com
dig google.com

# Test connectivity
ping -c 4 8.8.8.8           # Test internet (IP)
ping -c 4 google.com        # Test DNS + internet

# Trace route
traceroute google.com

# Check open ports on the Pi
sudo ss -tlnp

# Check which process is using a port
sudo ss -tlnp | grep :80

# Network speed test
# Install speedtest-cli
sudo apt install speedtest-cli
speedtest-cli

# Monitor network traffic
sudo apt install iftop
sudo iftop -i eth0

# Check WiFi signal strength
iwconfig wlan0
# Or more detail:
iw dev wlan0 link
iw dev wlan0 scan | grep -E "SSID|signal"

# Monitor network connections in real time
watch -n 1 'ss -s'
```

---

## Useful Network Services

### mDNS (Avahi) — .local Hostname Resolution

Pre-installed on Raspberry Pi OS. Allows `raspberrypi.local` to work.

```bash
# Check avahi status
sudo systemctl status avahi-daemon

# Change hostname (also changes .local name)
sudo hostnamectl set-hostname mypi
# Then edit /etc/hosts to match:
sudo sed -i 's/raspberrypi/mypi/g' /etc/hosts
sudo systemctl restart avahi-daemon

# Discover other .local devices
avahi-browse -a
```

### SSH Tunneling (Port Forwarding)

Access services on the Pi remotely or through firewalls:

```bash
# Local port forwarding: access Pi's port 8080 via localhost:8080 on your machine
ssh -L 8080:localhost:8080 pi@raspberrypi.local

# Remote port forwarding: expose Pi's port 80 to a remote server
ssh -R 8080:localhost:80 user@remote-server.com

# SOCKS proxy: use the Pi as a proxy for all traffic
ssh -D 1080 pi@raspberrypi.local
# Then configure your browser to use SOCKS5 proxy on localhost:1080
```

### Wake-on-LAN

Not supported by the Pi's built-in Ethernet (no standby power to the NIC). However, you can use the Pi to send Wake-on-LAN packets to other machines:

```bash
sudo apt install wakeonlan
wakeonlan AA:BB:CC:DD:EE:FF   # MAC address of target machine
```
