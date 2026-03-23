# LoRa Mesh Alternatives

Beyond Meshtastic — other LoRa mesh and long-range communication projects.

---

## Overview Comparison

| Project            | Protocol     | Messaging | Range   | Hardware           | Complexity | Maturity  |
|--------------------|--------------|-----------|---------|--------------------|-----------:|-----------|
| Meshtastic         | Custom mesh  | Text, GPS | 10+ km  | ESP32+SX1262/76    | Low        | Mature    |
| Reticulum/LXMF     | Reticulum    | Full stack| 10+ km  | RNode, serial, IP  | Medium     | Active    |
| Disaster.radio     | Custom mesh  | Text      | ~5 km   | ESP32+SX1276       | Medium     | Stalled   |
| LoRa APRS          | APRS/AX.25   | Position  | 10+ km  | ESP32+SX1278       | Medium     | Active    |
| Custom (RadioLib)  | Your design  | Anything  | 10+ km  | Any LoRa module    | High       | Library   |

---

## RNode

### What It Is

RNode is an open-source LoRa transceiver that acts as a general-purpose radio interface. It presents itself as a standard serial/USB modem to the host computer, making it usable with many different protocols.

### Hardware

RNode firmware runs on:
- **LilyGo T-Beam** (ESP32 + SX1276/SX1262 + GPS)
- **LilyGo T3S3** (ESP32-S3 + SX1262)
- **LilyGo LoRa32** (ESP32 + SX1276/SX1278)
- **Heltec LoRa32** (ESP32 + SX1276/SX1278)
- **RAK4631** (nRF52840 + SX1262)
- Custom hardware with supported LoRa chips

### Flashing RNode Firmware

```bash
# Install rnodeconf
pip install rns

# Flash a supported board
rnodeconf --autoinstall

# Or specify board type
rnodeconf /dev/ttyUSB0 --firmware --board t3s3
```

### Key Features

- Acts as a transparent serial modem for LoRa
- Supports KISS protocol (standard TNC interface)
- Configurable frequency, bandwidth, spreading factor, TX power
- Can be used as a standalone Reticulum interface or generic LoRa modem
- Bluetooth and serial connectivity

### Configuration

```bash
# Configure RNode parameters
rnodeconf /dev/ttyUSB0 --freq 868000000 --bw 125000 --sf 7 --cr 5 --txp 17

# Check RNode info
rnodeconf /dev/ttyUSB0 --info
```

---

## Reticulum Network Stack

### What It Is

Reticulum is a cryptography-based networking protocol designed for unstable, low-bandwidth links. It provides encrypted, authenticated communication over any medium — LoRa, serial, TCP/IP, WiFi, even audio modems.

### Key Concepts

- **No IP addresses:** Uses cryptographic identity hashes (like Tor hidden services)
- **Transport agnostic:** Works over LoRa (via RNode), serial, TCP, UDP, I2P, pipes
- **End-to-end encrypted:** All communication is encrypted by default
- **Self-organizing:** No central servers, automatic routing
- **Bandwidth efficient:** Works on links as slow as 500 bits/second
- **Delay tolerant:** Handles intermittent connections gracefully

### Installation

```bash
pip install rns

# Verify installation
rnstatus
```

### Configuration

Config file: `~/.reticulum/config`

```ini
[reticulum]
  enable_transport = yes
  share_instance = yes

[interfaces]
  # LoRa via RNode
  [[RNode LoRa Interface]]
    type = RNodeInterface
    interface_enabled = true
    port = /dev/ttyUSB0
    frequency = 868000000
    bandwidth = 125000
    spreading_factor = 7
    coding_rate = 5
    txpower = 17
    flow_control = false

  # TCP interface (for linking over internet)
  [[TCP Server]]
    type = TCPServerInterface
    interface_enabled = true
    listen_ip = 0.0.0.0
    listen_port = 4242

  # Link to another Reticulum node over TCP
  [[TCP Client]]
    type = TCPClientInterface
    interface_enabled = true
    target_host = remote.server.com
    target_port = 4242
```

### LXMF — LoRa Messenger

LXMF (Lightweight Extensible Message Format) runs on top of Reticulum, providing a messaging layer similar to email.

#### NomadNet (Terminal-Based Client)

```bash
pip install nomadnet

# Run
nomadnet

# Text-based UI with:
# - Encrypted messaging
# - File transfer
# - Distributed bulletin boards (micro-pages)
# - Works over LoRa, TCP, or any Reticulum transport
```

#### Sideband (Mobile/Desktop App)

Sideband is a GUI application for LXMF messaging:
- Available for Android (F-Droid, APK), Linux, macOS
- Connects via Bluetooth to an RNode
- Or via TCP to a Reticulum network
- Encrypted messaging, file transfer, telemetry

```bash
# Install on Linux
pip install sbapp
```

### Reticulum Tools

```bash
# Check network status
rnstatus

# Discover paths to destinations
rnpath <destination_hash>

# Probe a destination (like ping)
rnprobe <destination_hash>

# Transfer files
rncp <source_file> <destination_hash>

# Remote command execution
rnx <destination_hash> <command>
```

### Why Use Reticulum Over Meshtastic

| Feature              | Meshtastic          | Reticulum                        |
|----------------------|---------------------|----------------------------------|
| Setup difficulty     | Very easy           | Moderate                         |
| Encryption           | AES256 (group key)  | Curve25519 per-identity          |
| Identity system      | Node name           | Cryptographic hash               |
| Transport options    | LoRa only           | LoRa, TCP, UDP, serial, any      |
| Internet bridging    | MQTT                | Native TCP/UDP interfaces         |
| Message size         | ~230 bytes          | Arbitrary (fragmented)            |
| Applications         | Messaging, GPS      | Messaging, files, pages, remote  |
| Mobile app           | Yes (polished)      | Sideband (functional)            |
| Community size       | Large               | Growing                          |

---

## Disaster.radio

### What It Is

Disaster.radio was designed as a solar-powered, long-range, mesh network built on ESP32 + LoRa hardware for community-owned resilient communication infrastructure.

### Status

The project has seen limited development since 2021-2022. The core concepts are sound but the software is not actively maintained. Consider it as **reference/inspiration** rather than a production-ready solution.

### Hardware

- ESP32 + SX1276 (LoRa32 boards)
- Solar panel + battery for autonomous operation
- Designed to be mounted outdoors permanently

### Features

- Web-based chat interface (connect via WiFi AP)
- LoRa mesh routing between nodes
- Solar powered for permanent deployment
- Each node creates a WiFi access point
- Users connect to the AP and open a web page to chat

### Building

```bash
git clone https://github.com/sudomesh/disaster-radio
cd disaster-radio

# Install PlatformIO
pip install platformio

# Build and flash
pio run -t upload
```

### Limitations

- Text chat only
- Limited range compared to Meshtastic (lower optimization)
- No encryption
- Small community, sporadic updates
- No mobile app

---

## LoRa APRS

### What It Is

APRS (Automatic Packet Reporting System) is a mature ham radio protocol for position reporting, telemetry, and messaging. LoRa APRS adapts this for LoRa hardware, bridging into the existing global APRS network.

**Note:** Transmitting on APRS frequencies requires a ham radio license (Technician class in US).

### Frequencies

| Region       | Frequency    |
|--------------|-------------|
| Europe       | 433.775 MHz  |
| North America| 433.775 MHz  |
| APRS-IS gate | Internet     |

### Hardware

- ESP32 + SX1278 (433 MHz LoRa module)
- T-Beam, LoRa32, or similar boards
- GPS module (for position reporting)

### Software: LoRa APRS Tracker

```bash
git clone https://github.com/lora-aprs/LoRa_APRS_Tracker
# Configure in src/config.h with your callsign and settings
# Flash with PlatformIO
```

### Software: LoRa APRS iGate

An iGate receives LoRa APRS packets and forwards them to the APRS-IS internet network:

```bash
git clone https://github.com/lora-aprs/LoRa_APRS_iGate
# Configure with your callsign, WiFi, and APRS-IS passcode
# Flash with PlatformIO
```

### APRS Packet Format

```
CALLSIGN-SSID>APRS,WIDE1-1:!DDMM.MMN/DDDMM.MME-comment
```

Example:
```
N0CALL-7>APRS,WIDE1-1:!4807.04N/01131.00E-LoRa Tracker
```

### Integration with APRS-IS

When an iGate is running, all LoRa APRS packets become visible on:
- **aprs.fi** — Web map of all APRS stations worldwide
- **APRS-IS** — Global APRS internet backbone
- Any APRS client (APRSDroid, Xastir, YAAC)

### Advantages

- Integrates with the existing global APRS infrastructure
- Position reporting visible worldwide (via iGate)
- Well-understood protocol with decades of development
- Two-way messaging possible
- Telemetry support (weather stations, sensors)

### Limitations

- Requires ham radio license to transmit
- Fixed packet format (not as flexible as custom protocols)
- 433 MHz LoRa hardware (not the more common 868/915 MHz)
- No encryption (APRS is inherently unencrypted per ham radio rules)

---

## Custom LoRa with RadioLib

### What It Is

RadioLib is a universal Arduino radio library supporting SX1276, SX1278, SX1262, SX1268, and many other radio chips. Use it to build your own custom protocols.

### Installation

```
Arduino: Library Manager -> "RadioLib"
PlatformIO: lib_deps = jgromes/RadioLib
```

### Basic Point-to-Point Communication

**Transmitter:**
```cpp
#include <RadioLib.h>

// SX1276 on SPI with CS=18, DIO0=26, RST=14, DIO1=33
SX1276 radio = new Module(18, 26, 14, 33);

void setup() {
    Serial.begin(115200);

    int state = radio.begin(
        868.0,    // frequency (MHz)
        125.0,    // bandwidth (kHz)
        7,        // spreading factor
        5,        // coding rate (4/5)
        0x12,     // sync word
        17,       // output power (dBm)
        8,        // preamble length
        0         // gain (0 = auto)
    );

    if (state != RADIOLIB_ERR_NONE) {
        Serial.printf("Radio init failed: %d\n", state);
        while (true);
    }
}

void loop() {
    int state = radio.transmit("Hello LoRa!");
    if (state == RADIOLIB_ERR_NONE) {
        Serial.println("Sent successfully");
    }
    delay(5000);
}
```

**Receiver:**
```cpp
#include <RadioLib.h>

SX1276 radio = new Module(18, 26, 14, 33);

void setup() {
    Serial.begin(115200);
    radio.begin(868.0, 125.0, 7, 5, 0x12, 17, 8, 0);
}

void loop() {
    String message;
    int state = radio.receive(message);

    if (state == RADIOLIB_ERR_NONE) {
        Serial.print("Received: ");
        Serial.println(message);
        Serial.printf("RSSI: %.1f dBm\n", radio.getRSSI());
        Serial.printf("SNR: %.1f dB\n", radio.getSNR());
    } else if (state != RADIOLIB_ERR_RX_TIMEOUT) {
        Serial.printf("Receive error: %d\n", state);
    }
}
```

### Building a Simple Mesh

For a basic mesh, you need:

1. **Packet structure** with source, destination, hop count
2. **Routing** — flood-based (rebroadcast everything) or routing table
3. **Duplicate detection** — packet ID to avoid infinite loops
4. **Acknowledgments** — optional, for reliability

```cpp
struct MeshPacket {
    uint8_t  src;         // Source node ID
    uint8_t  dst;         // Destination (0xFF = broadcast)
    uint8_t  packetId;    // Unique packet ID
    uint8_t  hopCount;    // Remaining hops
    uint8_t  payloadLen;  // Payload length
    uint8_t  payload[200]; // Data
};

// Simple flood routing
void handleReceived(MeshPacket &pkt) {
    if (isDuplicate(pkt.src, pkt.packetId)) return;
    markSeen(pkt.src, pkt.packetId);

    if (pkt.dst == myNodeId || pkt.dst == 0xFF) {
        processPayload(pkt);
    }

    if (pkt.hopCount > 0) {
        pkt.hopCount--;
        radio.transmit((uint8_t*)&pkt, sizeof(MeshPacket));
    }
}
```

### RadioLib Features

- Interrupt-driven receive (non-blocking)
- Channel Activity Detection (CAD) — check if channel is busy before transmitting
- Frequency hopping
- AES encryption support
- LoRaWAN support (OTAA and ABP)
- FSK mode in addition to LoRa
- Supports SX1261/62/68, SX1272/76/77/78/79, RFM95/96/97/98

### When to Use RadioLib vs. Meshtastic/Reticulum

**Use RadioLib when:**
- You need a custom protocol tailored to your specific use case
- You want full control over radio parameters
- You're building a sensor network with specific timing requirements
- You want to implement LoRaWAN
- You're doing radio experiments or research

**Use Meshtastic/Reticulum when:**
- You want a working mesh network quickly
- You need a proven, tested protocol
- You want mobile apps and ecosystem
- You don't want to write networking code

---

## Summary: Choosing a LoRa Mesh Solution

**Just want to chat off-grid:** Meshtastic. Easiest setup, best mobile apps, largest community.

**Need encryption and multi-transport:** Reticulum + LXMF. Strongest privacy, works over LoRa + internet + serial. Steeper learning curve.

**Ham radio operator wanting APRS:** LoRa APRS. Integrates with global APRS network. Requires license.

**Building something custom:** RadioLib. Maximum flexibility but you write everything yourself.

**Permanent solar-powered nodes:** Study Disaster.radio concepts, but implement on Meshtastic or Reticulum (better maintained).
