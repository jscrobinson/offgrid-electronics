# Meshtastic Configuration Deep Dive

Comprehensive reference for all Meshtastic configuration options and what they do.

---

## Radio Configuration

### Region

Must be set before the radio will transmit. Determines the frequency band and regulatory parameters.

```bash
meshtastic --set lora.region US
```

The region sets the allowed frequency range, duty cycle limits, and maximum transmit power for legal compliance. Using the wrong region for your country may be illegal.

### Modem Presets

The modem preset determines the LoRa modulation parameters: bandwidth, spreading factor, and coding rate. These directly control the tradeoff between range and data rate.

```bash
meshtastic --set lora.modem_preset LONG_FAST
```

| Preset | Bandwidth | Spreading Factor | Coding Rate | Data Rate | Range | Best For |
|--------|-----------|-----------------|-------------|-----------|-------|----------|
| **SHORT_FAST** | 250 kHz | SF7 | 4/5 | ~6.8 kbps | Shortest | Dense local networks, high throughput |
| **SHORT_SLOW** | 250 kHz | SF8 | 4/5 | ~3.9 kbps | Short | Local with better range than SHORT_FAST |
| **MEDIUM_FAST** | 250 kHz | SF9 | 4/5 | ~2.2 kbps | Medium | Balanced urban use |
| **MEDIUM_SLOW** | 250 kHz | SF10 | 4/5 | ~1.2 kbps | Medium-long | Suburban networks |
| **LONG_FAST** | 250 kHz | SF11 | 4/5 | ~0.67 kbps | Long | **Default. Good general-purpose preset.** |
| **LONG_MODERATE** | 125 kHz | SF11 | 4/8 | ~0.34 kbps | Longer | Moderate range improvement over LONG_FAST |
| **LONG_SLOW** | 125 kHz | SF12 | 4/8 | ~0.18 kbps | Longest | Maximum range, very slow |
| **VERY_LONG_SLOW** | 62.5 kHz | SF12 | 4/8 | ~0.09 kbps | Maximum | Extreme range, extremely slow |

**Understanding the parameters:**
- **Bandwidth (BW):** wider = faster data but less sensitive (shorter range)
- **Spreading Factor (SF):** higher = more range but slower (each step up roughly doubles airtime)
- **Coding Rate (CR):** more redundancy = better error correction but more airtime

**All nodes in a mesh must use the same modem preset** to communicate. You cannot mix presets.

**Recommendation:**
- Start with **LONG_FAST** (the default) — it's a good balance
- Use **MEDIUM_FAST** if you have many nodes in a small area (reduces airtime/congestion)
- Use **LONG_SLOW** only if you need maximum range and can tolerate very slow messaging

### Hop Limit

```bash
meshtastic --set lora.hop_limit 3
```

- Default: 3
- Range: 1-7
- Each hop = another node retransmitting your message
- More hops = wider coverage but more airtime consumed and higher latency
- For a small local network (5-10 nodes), 3 is fine
- For a large network, keep it low (2-3) to prevent airtime congestion

### TX Power

```bash
meshtastic --set lora.tx_power 20
```

- Measured in dBm
- Default varies by region (typically 20-30 dBm)
- Maximum depends on regional regulations:
  - US: 30 dBm (1W) ERP
  - EU 868: 14 dBm (25 mW) ERP (with duty cycle limits)
- Higher TX power = more range but more battery drain
- For solar-powered relay nodes, maximize TX power
- For mobile battery-powered nodes, consider reducing to save battery

---

## Channels

Channels are logical communication groups within the mesh. Each channel has its own name and encryption key.

### Primary Channel

- Default primary channel: **LongFast** with the publicly known default key
- All Meshtastic nodes start on LongFast — this is the "calling channel"
- **LongFast is NOT private** — anyone with a Meshtastic device can read these messages
- Good for: public communication, meeting other Meshtastic users, range testing

### Creating Private Channels

```bash
# Create a new primary channel with a random encryption key
meshtastic --ch-set name "MyGroup" --ch-index 0
meshtastic --ch-set psk random --ch-index 0

# Or set a specific key (base64-encoded 256-bit key)
meshtastic --ch-set psk "base64:YOUR_KEY_HERE" --ch-index 0
```

### Secondary Channels

You can have up to 8 channels (index 0-7). Index 0 is always the primary channel.

```bash
# Add a secondary channel
meshtastic --ch-set name "EmergOnly" --ch-index 1
meshtastic --ch-set psk random --ch-index 1
meshtastic --ch-enable --ch-index 1
```

### Sharing Channel Settings

The easiest way to get other nodes onto your channel:

```bash
# Generate a URL containing channel config
meshtastic --qr
```

This outputs a URL like `https://meshtastic.org/e/#...` that encodes the channel name, encryption key, and modem preset. Share this URL or QR code with others. They import it in the app by scanning the QR code or clicking the link.

**Share channel URLs in person or over a trusted channel.** Anyone with the URL can join your encrypted channel.

### Channel Settings

```bash
# Set channel name
meshtastic --ch-set name "GroupName" --ch-index 0

# Set channel PSK (Pre-Shared Key)
meshtastic --ch-set psk random --ch-index 0     # Random 256-bit key
meshtastic --ch-set psk none --ch-index 0       # No encryption (not recommended)
meshtastic --ch-set psk default --ch-index 0    # Default public key

# Enable/disable uplink to MQTT
meshtastic --ch-set uplink_enabled true --ch-index 0

# Enable/disable downlink from MQTT
meshtastic --ch-set downlink_enabled true --ch-index 0
```

---

## Node Roles

The role determines how your node behaves in the mesh. This has a major impact on power consumption and network behavior.

```bash
meshtastic --set device.role CLIENT
```

| Role | Description | Power Use | Transmits | Relays | Best For |
|------|-------------|-----------|-----------|--------|----------|
| **CLIENT** | Default. Full-featured user node. | Medium | Yes | Yes | General use, phones connected |
| **CLIENT_MUTE** | Receives everything, only transmits when user sends a message. Does not relay. | Low | User-initiated only | No | Power saving, listen-only monitoring |
| **ROUTER** | Always-on relay that doesn't show as a user. Optimized for relaying. | High | Yes | Yes (priority) | Fixed elevated relay nodes |
| **REPEATER** | Minimal relay — just rebroadcasts. No phone connection, no display. | Medium | Relays only | Yes | Simple signal extender |
| **TRACKER** | Optimized for position broadcasting. Minimal other traffic. | Low | Position only | Minimal | GPS trackers, asset tracking |
| **SENSOR** | Optimized for telemetry broadcasting. | Low | Telemetry only | Minimal | Weather stations, environment monitors |
| **TAK** | Integration with ATAK/WinTAK. | Medium | Yes | Yes | TAK ecosystem users |
| **TAK_TRACKER** | TAK position broadcasting. | Low | Position only | No | TAK position tracking |
| **LOST_AND_FOUND** | Broadcasts position when button pressed. | Very Low | Button-triggered | No | Finding lost items |
| **CLIENT_HIDDEN** | Like CLIENT but doesn't appear in node list. | Medium | Yes | No | Covert operation |

### Role Recommendations

- **Mobile nodes with phone:** CLIENT (default)
- **Fixed relay on solar:** ROUTER
- **Simple extender at a friend's house:** REPEATER
- **You just want to listen:** CLIENT_MUTE
- **Tracking a vehicle/person:** TRACKER

---

## Module Configuration

### Telemetry Module

```bash
# Enable device telemetry (battery, voltage)
meshtastic --set telemetry.device_update_interval 900  # seconds (15 min)

# Enable environment telemetry (needs BME280/BME680 sensor)
meshtastic --set telemetry.environment_update_interval 900
meshtastic --set telemetry.environment_measurement_enabled true

# Sensor pin configuration (I2C)
meshtastic --set telemetry.environment_sensor_pin 21  # SDA
# SCL is typically auto-configured
```

### Position Module

```bash
# Position broadcast interval (seconds)
meshtastic --set position.position_broadcast_secs 900  # 15 minutes

# GPS update interval
meshtastic --set position.gps_update_interval 120  # 2 minutes

# Enable smart position (only broadcast when moved significantly)
meshtastic --set position.position_broadcast_smart_enabled true

# Fixed position (for stationary nodes — saves GPS power)
meshtastic --set position.fixed_position true
meshtastic --setlat 40.7128 --setlon -74.0060 --setalt 10
```

### Range Test Module

```bash
# Enable range test (sender)
meshtastic --set range_test.enabled true
meshtastic --set range_test.sender 30  # Send every 30 seconds

# On the receiver, range test results appear in messages with RSSI/SNR
```

### Store and Forward Module

```bash
# Enable store and forward (ESP32 with PSRAM only)
meshtastic --set store_forward.enabled true
meshtastic --set store_forward.records 100  # Number of messages to store
meshtastic --set store_forward.heartbeat true
```

### Serial Module

```bash
# Bridge serial data over the mesh
meshtastic --set serial.enabled true
meshtastic --set serial.rxd 16  # RX pin
meshtastic --set serial.txd 17  # TX pin
meshtastic --set serial.baud BAUD_9600
meshtastic --set serial.mode TEXTMSG  # or NMEA, PROTO
```

### External Notification Module

```bash
# Buzzer or LED alert on incoming message
meshtastic --set external_notification.enabled true
meshtastic --set external_notification.output 13  # GPIO pin for buzzer/LED
meshtastic --set external_notification.active true  # Active high
meshtastic --set external_notification.alert_message true
meshtastic --set external_notification.output_ms 1000  # Duration in ms
```

### Canned Messages Module

```bash
# Enable canned messages (requires rotary encoder or buttons)
meshtastic --set canned_message.enabled true
meshtastic --set canned_message.rotary1_enabled true
meshtastic --set canned_message.inputbroker_pin_a 12  # Encoder pin A
meshtastic --set canned_message.inputbroker_pin_b 14  # Encoder pin B
meshtastic --set canned_message.inputbroker_pin_press 13  # Button pin

# Set canned messages (pipe-separated)
meshtastic --set canned_message.messages "OK|Help needed|On my way|At location|Going home"
```

---

## MQTT Gateway

MQTT allows bridging mesh messages to the internet (when a node has WiFi connectivity). This enables:
- Mesh messages appearing on the public Meshtastic MQTT server (map visibility)
- Bridging distant mesh networks via the internet
- Integration with home automation (Home Assistant, Node-RED)

### Basic MQTT Setup

```bash
# Enable WiFi
meshtastic --set network.wifi_enabled true
meshtastic --set network.wifi_ssid "YourWiFi"
meshtastic --set network.wifi_psk "YourPassword"

# Enable MQTT
meshtastic --set mqtt.enabled true
meshtastic --set mqtt.address "mqtt.meshtastic.org"  # Public server
meshtastic --set mqtt.username "meshdev"
meshtastic --set mqtt.password "large4cats"

# Enable uplink/downlink on the channel
meshtastic --ch-set uplink_enabled true --ch-index 0
meshtastic --ch-set downlink_enabled true --ch-index 0

# Encrypt MQTT traffic
meshtastic --set mqtt.encryption_enabled true
```

### Private MQTT Server

```bash
meshtastic --set mqtt.address "your-mqtt-server.local"
meshtastic --set mqtt.username "your_user"
meshtastic --set mqtt.password "your_password"
meshtastic --set mqtt.root "msh/your_region"
```

---

## Display and LED Settings

```bash
# Screen timeout (seconds, 0 = always on)
meshtastic --set display.screen_on_secs 60

# Flip screen (if mounted upside down)
meshtastic --set display.flip_screen true

# Display units
meshtastic --set display.units METRIC  # or IMPERIAL

# LED brightness (0-255)
meshtastic --set display.led_brightness_level 128

# Compass heading display
meshtastic --set display.compass_north_top true
```

---

## Power Settings

These settings control how aggressively the node sleeps to save battery.

```bash
# Light sleep seconds (how long between radio listen windows)
meshtastic --set power.ls_secs 300  # 5 minutes

# Minimum wake seconds (minimum time to stay awake after activity)
meshtastic --set power.min_wake_secs 10

# Mesh SDS (Super Deep Sleep) timeout — time before entering deep sleep when no activity
meshtastic --set power.mesh_sds_timeout_secs 7200  # 2 hours

# Wait Bluetooth seconds (how long to keep BT on waiting for a connection)
meshtastic --set power.wait_bluetooth_secs 60

# ADC multiplier override (for custom voltage dividers)
meshtastic --set power.adc_multiplier_override 2.0

# Power saving enabled
meshtastic --set power.is_power_saving true
```

### Power Profiles

**Maximum battery life (mobile tracker):**
```bash
meshtastic --set device.role TRACKER
meshtastic --set power.is_power_saving true
meshtastic --set power.ls_secs 300
meshtastic --set display.screen_on_secs 15
meshtastic --set position.gps_update_interval 300
meshtastic --set position.position_broadcast_secs 900
```

**Always-on relay (solar-powered):**
```bash
meshtastic --set device.role ROUTER
meshtastic --set power.is_power_saving false
meshtastic --set lora.tx_power 30
meshtastic --set display.screen_on_secs 0  # always on (or no display)
```

---

## Useful CLI Commands Reference

```bash
# Show all device info
meshtastic --info

# Show all nodes in the mesh
meshtastic --nodes

# Send a message
meshtastic --sendtext "Hello mesh!"

# Send a DM to a specific node
meshtastic --sendtext "Hello!" --dest '!a1b2c3d4'

# Export full configuration
meshtastic --export-config > my_config.yaml

# Import configuration
meshtastic --configure my_config.yaml

# Factory reset
meshtastic --factory-reset

# Reboot device
meshtastic --reboot

# Get specific setting
meshtastic --get lora.region

# Set multiple settings at once
meshtastic --set lora.region US --set lora.modem_preset LONG_FAST --set device.role CLIENT
```
