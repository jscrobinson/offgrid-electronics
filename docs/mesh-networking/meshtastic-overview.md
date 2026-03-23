# Meshtastic Overview

An open-source, encrypted, long-range mesh networking project for off-grid communication -- no internet, no cell towers, no infrastructure required.

---

## What is Meshtastic?

Meshtastic is open-source firmware that turns cheap LoRa radio hardware into a decentralized mesh network for text messaging, GPS location sharing, and telemetry -- all without any existing infrastructure.

- **No internet required** -- works completely off-grid
- **No cell towers** -- peer-to-peer mesh networking
- **No subscription** -- free and open-source forever
- **Encrypted** -- AES-256 encryption on all messages
- **Long range** -- 1-10km typical in urban/suburban, up to 100km+ with line of sight and good antennas
- **Low power** -- runs for hours to days on a single 18650 cell
- **License-free** -- uses ISM band frequencies (915MHz US, 868MHz EU) that don't require a radio license

---

## How the Mesh Works

### Mesh Networking Basics
Every Meshtastic node is both a user device and a relay. When you send a message:

1. Your node transmits the message via LoRa radio
2. Every node that hears the message stores it and retransmits it (if within hop limit)
3. The message propagates through the network until it reaches the destination or the hop limit is exhausted
4. Acknowledgment travels back through the mesh

### Hop Limit
- Default: 3 hops (your message can traverse up to 3 intermediate nodes)
- Maximum: 7 hops
- Each hop adds latency (LoRa is slow -- each transmission takes seconds)
- More hops = wider reach but more airtime consumption and latency
- Keep it as low as practical for your network

### Store and Forward
- The Store & Forward module allows nodes with enough RAM to store messages for offline users
- When a node comes online, it can request missed messages from a Store & Forward node
- Requires an ESP32 node with PSRAM (not available on nRF52 based devices)

### Addressing
- Every node has a unique 4-byte node ID (displayed as a hex number like !a1b2c3d4)
- Nodes also have short names (up to 4 characters) and long names
- Messages can be sent to specific nodes (DM) or broadcast to the channel

---

## Supported Hardware

### ESP32-Based (WiFi + Bluetooth)

| Device | LoRa Chip | GPS | Display | Battery | Notes |
|--------|-----------|-----|---------|---------|-------|
| **LILYGO T-Beam** | SX1276/SX1262 | Yes (built-in) | No (add-on) | 18650 holder | Most popular, great all-rounder |
| **LILYGO T-Beam Supreme** | SX1262 | Yes | No | 18650 holder | Updated T-Beam with improved design |
| **Heltec V3** | SX1262 | No | 0.96" OLED | LiPo (JST) | Compact, built-in display |
| **Heltec Wireless Tracker** | SX1262 | Yes | 0.96" TFT | LiPo (JST) | GPS + display, compact |
| **Station G1/G2** | SX1262 | Optional | Optional | External | Higher power, fixed installation |
| **RAK WisBlock** | SX1262 | Module option | Module option | LiPo | Modular system |

### nRF52-Based (Bluetooth Low Energy, Ultra Low Power)

| Device | LoRa Chip | GPS | Display | Battery | Notes |
|--------|-----------|-----|---------|---------|-------|
| **LILYGO T-Echo** | SX1262 | Yes | E-ink | LiPo (built-in) | E-ink display, very low power |
| **RAK WisBlock nRF52** | SX1262 | Module option | Module option | LiPo | Modular, ultra low power |

### Choosing Hardware
- **Want GPS + long battery life from 18650?** T-Beam
- **Want a compact node with display?** Heltec V3
- **Want ultra-low power with e-ink?** T-Echo
- **Want a modular system?** RAK WisBlock
- **Want a high-power fixed relay?** Station G1/G2

---

## Capabilities

### Text Messaging
- Send and receive encrypted text messages
- Direct messages (node-to-node) or broadcast to channel
- Message delivery confirmation (ACK)
- Emoji support
- Canned messages (quick replies from the device without a phone)

### GPS Location Sharing
- Nodes with GPS share their position on the mesh
- See all nodes on a map in the phone app
- Position update interval is configurable
- Track movement of other nodes in real-time

### Telemetry
- **Device telemetry:** battery level, voltage, channel utilization, airtime
- **Environment telemetry:** temperature, humidity, barometric pressure (with BME280/BME680 sensor)
- **Power telemetry:** voltage, current monitoring for solar nodes

### Additional Modules
- **Range Test:** automated ping-pong with RSSI/SNR logging
- **Serial Module:** bridge serial data over the mesh (connect to other devices)
- **Remote GPIO:** control pins on remote nodes
- **External Notification:** buzzer/LED alerts on incoming messages
- **Canned Messages:** send pre-defined messages from the device (with rotary encoder or buttons)
- **Store & Forward:** store messages for offline nodes
- **MQTT Gateway:** bridge mesh messages to the internet (when connectivity is available)
- **Audio:** experimental walkie-talkie (codec2) on some hardware
- **Detection Sensor:** trigger alerts based on GPIO input (motion sensors, door sensors)

---

## Clients and Interfaces

### Mobile Apps
- **Android:** full-featured app (Google Play Store or F-Droid/GitHub APK)
  - Bluetooth and WiFi connection
  - Map view, channel management, device configuration
- **iOS:** full-featured app (App Store)
  - Bluetooth connection
  - Similar feature set to Android

### Web Interface
- Built-in web server on ESP32 devices (connect via WiFi)
- Access at http://meshtastic.local or the device's IP address
- Full configuration and messaging from a browser
- No app installation required

### Python CLI
- `pip install meshtastic`
- Full configuration, messaging, and firmware management from command line
- Scripting and automation capabilities
- Works over USB serial or TCP/IP
- Essential for advanced configuration and automation

### Other Clients
- **Web client (client.meshtastic.org):** browser-based client via WebSerial (USB) or WebBluetooth
- **Meshenger:** alternative Android client
- **Community integrations:** Home Assistant, Node-RED, Telegram bots, Discord bots

---

## Encryption

- **AES-256** encryption on all messages by default
- Each channel has its own encryption key (PSK -- Pre-Shared Key)
- Default channel ("LongFast") uses a publicly known key -- it is NOT private
- **For private communication:** create a channel with a custom encryption key and share it only with your group
- Key exchange is done via QR code or URL sharing (in person or over a trusted channel)
- End-to-end encryption -- relay nodes cannot read messages for channels they don't have the key for (they relay the encrypted payload)

---

## Range

### Typical Range

| Environment | Estimated Range |
|-------------|----------------|
| Dense urban (buildings, streets) | 1-3 km |
| Suburban | 3-8 km |
| Rural/open terrain | 5-15 km |
| Hilltop to hilltop (LOS) | 20-50 km |
| Mountain/tower to valley (LOS) | 50-100+ km |

### Factors Affecting Range
- **Height is everything** -- elevating a node by even a few meters dramatically improves range
- **Line of sight (LOS)** -- LoRa can penetrate some obstacles but LOS is always best
- **Antenna quality** -- upgrading from stock antenna to a tuned external antenna can double range
- **Modem preset** -- slower data rates = longer range (LONG_SLOW can reach further than SHORT_FAST)
- **TX power** -- higher power = more range (but more battery drain and regulatory limits)
- **Frequency** -- 868/915 MHz penetrates obstacles better than 2.4GHz WiFi

---

## Community and Use Cases

### Emergency Preparedness
- Communication when cell towers and internet are down
- Pre-positioned solar relay nodes provide coverage during disasters
- No reliance on any infrastructure -- works as long as nodes have power
- FEMA CERT teams and community emergency groups have adopted Meshtastic

### Outdoor Recreation
- Hiking, backpacking, and camping communication
- Group coordination without cell service
- GPS tracking of group members on a shared map
- Works in national parks and wilderness areas with no cell coverage

### Events and Gatherings
- Music festivals, conventions, large gatherings
- Coordinate with friends across a large venue
- No cell congestion issues (does not use cellular network)

### Neighborhood Networks

Build a local mesh covering your street or housing development.

### Getting Involved

- Website: https://meshtastic.org
- Discord: active community with thousands of members
- GitHub: https://github.com/meshtastic
- Subreddit: r/meshtastic
- YouTube: many build guides and range test videos from the community
