# Common Raspberry Pi Projects

## NAS / File Server (Samba)

Turn a Pi into a network-attached storage device for sharing files across your local network.

**Best Pi for this:** Pi 4B (USB 3.0 + Gigabit Ethernet) or Pi 5 (NVMe support)

### Setup

```bash
# Attach a USB drive and find it
lsblk
# Format if needed (ext4 recommended for Linux, exfat for cross-platform)
sudo mkfs.ext4 /dev/sda1

# Create mount point and mount
sudo mkdir -p /mnt/nas
sudo mount /dev/sda1 /mnt/nas
sudo chown pi:pi /mnt/nas

# Auto-mount on boot — add to /etc/fstab
# First get the UUID:
sudo blkid /dev/sda1
# Add line to /etc/fstab:
# UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /mnt/nas ext4 defaults,noatime 0 2

# Install Samba
sudo apt install samba samba-common-bin

# Configure Samba share
sudo tee -a /etc/samba/smb.conf << 'EOF'

[NAS]
path = /mnt/nas
browseable = yes
writeable = yes
create mask = 0775
directory mask = 0775
valid users = pi
EOF

# Set Samba password for pi user
sudo smbpasswd -a pi

# Restart Samba
sudo systemctl restart smbd
```

**Accessing the share:**
- Windows: `\\raspberrypi.local\NAS` in File Explorer
- macOS: Finder > Go > Connect to Server > `smb://raspberrypi.local/NAS`
- Linux: `sudo mount -t cifs //raspberrypi.local/NAS /mnt/pi-nas -o user=pi`

**Performance tips:**
- Use ext4 filesystem for best Linux performance
- Connect the drive to a USB 3.0 port (blue port on Pi 4/5)
- Use Ethernet, not WiFi, for the Pi's network connection
- Expect ~100 MB/s read on Pi 4 with USB 3.0 SSD over Gigabit Ethernet

### Alternative: OpenMediaVault

For a full NAS operating system with a web UI, install OpenMediaVault:

```bash
wget -O - https://github.com/OpenMediaVault-Plugin-Developers/installScript/raw/master/install | sudo bash
```

Access the web UI at `http://raspberrypi.local` (default login: admin/openmediavault).

---

## Pi-hole (Network-Wide Ad Blocking DNS)

Pi-hole acts as a DNS sinkhole, blocking ads and trackers for every device on your network.

**Best Pi for this:** Any Pi works (even a Pi Zero 2 W). Minimal resource usage.

### Setup

```bash
curl -sSL https://install.pi-hole.net | bash
```

The installer is interactive. Key choices:
- **Upstream DNS:** Cloudflare (1.1.1.1), Google (8.8.8.8), or custom
- **Blocklists:** Default lists are fine to start
- **Web admin interface:** Yes (accessible at `http://pi.hole/admin` or `http://<pi-ip>/admin`)
- **Log queries:** Yes (useful for debugging, disable for privacy)

**After installation:**
1. Set your router's DHCP DNS server to the Pi's IP address (so all devices use Pi-hole automatically)
2. Or set DNS manually on individual devices

```bash
# Change web admin password
pihole -a -p

# Update blocklists
pihole -g

# Whitelist a domain
pihole -w example.com

# Blacklist a domain
pihole -b ads.example.com

# Check status
pihole status

# Temporarily disable (300 seconds)
pihole disable 300s
```

**Resource usage:** ~30 MB RAM, negligible CPU. SD card writes are the main concern for longevity (Pi-hole logs queries). Consider `log2ram` to reduce SD writes.

---

## VPN Server (WireGuard)

WireGuard is a modern, fast, and simple VPN. Run it on a Pi to access your home network remotely.

**Best Pi for this:** Pi 4B or newer (for throughput). Pi Zero 2 W works for light use.

### Setup

```bash
sudo apt install wireguard

# Generate server keys
wg genkey | sudo tee /etc/wireguard/server_private.key | wg pubkey | sudo tee /etc/wireguard/server_public.key
sudo chmod 600 /etc/wireguard/server_private.key

# Generate client keys
wg genkey | tee client_private.key | wg pubkey > client_public.key
```

**Server config** (`/etc/wireguard/wg0.conf`):
```ini
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <contents of server_private.key>

# NAT for clients to access LAN/internet
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
# Client 1
PublicKey = <contents of client_public.key>
AllowedIPs = 10.0.0.2/32
```

```bash
# Enable IP forwarding
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Start WireGuard
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

# Check status
sudo wg show
```

**Client config** (for phone/laptop):
```ini
[Interface]
Address = 10.0.0.2/24
PrivateKey = <contents of client_private.key>
DNS = 192.168.1.100  # Pi-hole IP, if running Pi-hole

[Peer]
PublicKey = <contents of server_public.key>
Endpoint = your-public-ip:51820
AllowedIPs = 0.0.0.0/0  # Route all traffic through VPN
# Or: AllowedIPs = 192.168.1.0/24, 10.0.0.0/24  # Only route LAN traffic
PersistentKeepalive = 25
```

**Important:** You must forward port 51820/UDP on your router to the Pi's local IP.

### PiVPN (Easier Setup)

```bash
curl -L https://install.pivpn.io | bash
# Follow the interactive installer
# Manage clients:
pivpn add     # Add a new client
pivpn list    # List clients
pivpn qr      # Show QR code for mobile client
```

---

## MQTT Broker (Mosquitto)

MQTT is the standard messaging protocol for IoT. Mosquitto is a lightweight broker that runs well on a Pi.

**Best Pi for this:** Any Pi. Extremely lightweight.

### Setup

```bash
sudo apt install mosquitto mosquitto-clients

# Mosquitto starts automatically and listens on port 1883

# Test: open two terminals
# Terminal 1 (subscriber):
mosquitto_sub -h localhost -t "test/topic"

# Terminal 2 (publisher):
mosquitto_pub -h localhost -t "test/topic" -m "Hello MQTT"
```

### Configure Authentication

```bash
# Create password file
sudo mosquitto_passwd -c /etc/mosquitto/passwd myuser
# Enter password when prompted

# Configure Mosquitto
sudo tee /etc/mosquitto/conf.d/auth.conf << 'EOF'
listener 1883
allow_anonymous false
password_file /etc/mosquitto/passwd
EOF

sudo systemctl restart mosquitto
```

### TLS Encryption

```bash
# Generate self-signed certificates
sudo mkdir -p /etc/mosquitto/certs
cd /etc/mosquitto/certs

# CA key and certificate
sudo openssl req -new -x509 -days 3650 -extensions v3_ca -keyout ca.key -out ca.crt -subj "/CN=MQTT CA"

# Server key and certificate
sudo openssl genrsa -out server.key 2048
sudo openssl req -new -key server.key -out server.csr -subj "/CN=raspberrypi.local"
sudo openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650

sudo chown mosquitto:mosquitto /etc/mosquitto/certs/*
```

Add to Mosquitto config:
```
listener 8883
cafile /etc/mosquitto/certs/ca.crt
certfile /etc/mosquitto/certs/server.crt
keyfile /etc/mosquitto/certs/server.key
require_certificate false
```

### Connecting from Arduino/ESP32

See the PubSubClient library in the Arduino libraries documentation. Set the broker address to the Pi's IP and port 1883.

---

## Node-RED

A visual flow-based programming tool for wiring together IoT devices, APIs, and services.

**Best Pi for this:** Pi 4B with 2GB+ RAM.

### Setup

```bash
# Recommended install script (includes Node.js)
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)

# Enable on boot
sudo systemctl enable nodered

# Start now
sudo systemctl start nodered
```

Access the editor at `http://raspberrypi.local:1880`

### Key Features

- **Drag-and-drop flow editor** in the browser
- **MQTT nodes:** Subscribe/publish to MQTT topics (pairs well with Mosquitto)
- **HTTP nodes:** Create REST APIs or make HTTP requests
- **GPIO nodes:** Read/write Pi GPIO pins directly from flows
- **Dashboard:** Install `node-red-dashboard` for instant web dashboards:
  ```bash
  cd ~/.node-red
  npm install node-red-dashboard
  sudo systemctl restart nodered
  ```
  Dashboard at `http://raspberrypi.local:1880/ui`

### Securing Node-RED

Edit `~/.node-red/settings.js` to enable authentication:

```javascript
adminAuth: {
    type: "credentials",
    users: [{
        username: "admin",
        password: "$2b$08$...",  // Generate with: node -e "console.log(require('bcryptjs').hashSync('yourpassword', 8));"
        permissions: "*"
    }]
}
```

---

## Home Assistant

A powerful open-source home automation platform with hundreds of integrations.

**Best Pi for this:** Pi 4B with 4GB+ RAM, or Pi 5. SD card or SSD storage.

### Installation Options

**Option 1: Home Assistant OS (Dedicated)**

Flash the Home Assistant OS image to SD card using Raspberry Pi Imager (under "Other specific-purpose OS > Home assistants"). This takes over the entire Pi.

Access at `http://homeassistant.local:8123`

**Option 2: Home Assistant Container (Docker)**

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker pi

# Run Home Assistant
docker run -d \
    --name homeassistant \
    --privileged \
    --restart unless-stopped \
    -e TZ=America/New_York \
    -v /home/pi/homeassistant:/config \
    -v /run/dbus:/run/dbus:ro \
    --network host \
    ghcr.io/home-assistant/home-assistant:stable
```

**Option 3: Home Assistant Core (Python venv)**

For advanced users who want full control. Requires manual dependency management.

### Key Integrations for Electronics Projects

- **MQTT:** Connect Arduino/ESP32 sensors and actuators
- **ESPHome:** Configure ESP8266/ESP32 devices with YAML
- **Zigbee/Z-Wave:** Smart home device protocols (needs USB dongle)
- **GPIO:** Control Pi GPIO pins
- **Webhooks:** Trigger automations from external services
- **InfluxDB + Grafana:** Long-term data storage and visualization

---

## Media Server

### Kodi (LibreELEC)

Dedicated media center OS. Flash LibreELEC image to SD card.

- Plays local media, streams, IPTV
- Hardware-accelerated video decoding on Pi 4/5
- 4K HDR support on Pi 4/5
- Extensive add-on ecosystem

### Plex/Jellyfin Media Server

```bash
# Jellyfin (open-source alternative to Plex)
sudo apt install jellyfin

# Access at http://raspberrypi.local:8096
```

**Note:** The Pi 4/5 can direct-play most media but transcoding performance is limited. Use direct play/stream when possible by ensuring clients support the media format.

---

## IoT Gateway

Use the Pi as a central hub that bridges different IoT protocols.

### Architecture

```
Sensors/Devices              Pi Gateway              Cloud/Dashboard
-----------------            ----------              ---------------
Arduino (Serial) -----+
ESP32 (MQTT/WiFi) ----+--->  Mosquitto (MQTT)  ---> Node-RED ---> Dashboard
LoRa nodes (SPI) -----+     + Python scripts         |
Zigbee (USB dongle) ---+     + Node-RED              InfluxDB
BLE sensors -----------+                              Grafana
```

### Serial Gateway (Arduino to MQTT)

```python
#!/usr/bin/env python3
"""Bridge Arduino serial data to MQTT."""
import serial
import paho.mqtt.client as mqtt
import json
import time

SERIAL_PORT = "/dev/ttyACM0"
BAUD_RATE = 9600
MQTT_BROKER = "localhost"
MQTT_TOPIC = "sensors/arduino"

ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
client = mqtt.Client()
client.connect(MQTT_BROKER, 1883, 60)
client.loop_start()

while True:
    try:
        line = ser.readline().decode('utf-8').strip()
        if line:
            # Assuming Arduino sends "temperature,humidity" format
            parts = line.split(',')
            if len(parts) == 2:
                payload = json.dumps({
                    "temperature": float(parts[0]),
                    "humidity": float(parts[1]),
                    "timestamp": time.time()
                })
                client.publish(MQTT_TOPIC, payload)
                print(f"Published: {payload}")
    except (ValueError, serial.SerialException) as e:
        print(f"Error: {e}")
        time.sleep(1)
```

```bash
# Install dependencies
pip3 install pyserial paho-mqtt

# Run as a systemd service for auto-start — create /etc/systemd/system/serial-mqtt.service:
# [Unit]
# Description=Serial to MQTT Bridge
# After=network.target mosquitto.service
#
# [Service]
# ExecStart=/usr/bin/python3 /home/pi/serial_mqtt_bridge.py
# Restart=always
# User=pi
#
# [Install]
# WantedBy=multi-user.target

sudo systemctl enable serial-mqtt
sudo systemctl start serial-mqtt
```

---

## Wireless Access Point

See the detailed instructions in `networking.md` under "Creating a WiFi Hotspot (Access Point)".

A Pi-based access point is useful for:
- Field deployments where there is no existing WiFi
- Creating an isolated IoT network
- Captive portal for sensor configuration
- Mesh networking with multiple Pis

---

## Data Logging with InfluxDB + Grafana

Long-term time-series data storage and visualization.

### InfluxDB

```bash
# Install InfluxDB 2.x
wget https://dl.influxdata.com/influxdb/releases/influxdb2_2.7.1-1_arm64.deb
sudo dpkg -i influxdb2_2.7.1-1_arm64.deb
sudo systemctl enable influxdb
sudo systemctl start influxdb
```

Access setup at `http://raspberrypi.local:8086`

### Grafana

```bash
sudo apt install -y apt-transport-https software-properties-common
wget -q -O - https://apt.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/grafana-archive-keyring.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt update
sudo apt install grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

Access at `http://raspberrypi.local:3000` (default login: admin/admin)

Add InfluxDB as a data source in Grafana, then build dashboards to visualize your sensor data.

---

## Quick Reference: Resource Requirements

| Project | Min RAM | Storage | Pi Model (Minimum) | Notes |
|---|---|---|---|---|
| Pi-hole | 512 MB | 2 GB | Zero 2 W | Very lightweight |
| Mosquitto MQTT | 256 MB | 1 GB | Zero 2 W | Extremely lightweight |
| WireGuard VPN | 512 MB | 1 GB | Zero 2 W | Low overhead |
| Samba NAS | 512 MB | OS + external drive | Pi 4B (for USB 3.0) | USB 3.0 matters for speed |
| Node-RED | 1 GB | 4 GB | Pi 3B+ | More RAM for complex flows |
| Home Assistant | 2 GB | 32 GB | Pi 4B (4GB) | Grows with integrations |
| Grafana + InfluxDB | 2 GB | 32 GB+ | Pi 4B (4GB) | Database grows over time |
| Plex/Jellyfin | 2 GB | OS + media drive | Pi 4B (4GB) | Transcoding is CPU-limited |

---

## Running Multiple Services

A Pi 4 with 4-8 GB RAM can comfortably run several of these services simultaneously:

```
Typical home server stack:
- Pi-hole (DNS)         ~30 MB RAM
- Mosquitto (MQTT)      ~10 MB RAM
- WireGuard (VPN)       ~5 MB RAM
- Node-RED              ~150 MB RAM
- Samba (file sharing)  ~30 MB RAM
- Total: ~225 MB + OS   ~600 MB
= ~825 MB total         Fits easily in 2 GB
```

Use Docker or Podman to isolate services:

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker pi

# Use docker-compose for multi-service stacks
sudo apt install docker-compose
```

A `docker-compose.yml` for a common stack:

```yaml
version: '3'
services:
  mosquitto:
    image: eclipse-mosquitto
    ports:
      - "1883:1883"
    volumes:
      - ./mosquitto/config:/mosquitto/config
      - ./mosquitto/data:/mosquitto/data
    restart: unless-stopped

  nodered:
    image: nodered/node-red
    ports:
      - "1880:1880"
    volumes:
      - ./nodered:/data
    restart: unless-stopped

  influxdb:
    image: influxdb:2
    ports:
      - "8086:8086"
    volumes:
      - ./influxdb:/var/lib/influxdb2
    restart: unless-stopped

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    volumes:
      - ./grafana:/var/lib/grafana
    restart: unless-stopped
```

```bash
docker-compose up -d
```
