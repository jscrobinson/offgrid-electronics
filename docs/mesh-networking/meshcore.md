# MeshCore

An alternative open-source LoRa mesh networking firmware -- not Meshtastic -- created by Ripple Radios. MeshCore provides encrypted, off-grid text messaging over LoRa with a different protocol design emphasizing managed flooding, simplicity, and a clean separation between relay infrastructure and user devices.

---

## Overview

MeshCore is a standalone LoRa mesh firmware project. It is **not** a fork or variant of Meshtastic -- it is a completely separate codebase with its own mesh protocol, its own companion app, and its own network architecture.

**Key characteristics:**

- **Open source** -- source code available on GitHub (github.com/ripplebiz/MeshCore)
- **Encrypted** -- AES-256 encryption for all messages
- **No infrastructure required** -- fully off-grid, no internet, no cell towers
- **Managed flooding** -- a different approach to mesh routing than Meshtastic's simple flood-and-forget
- **Rooms** -- group messaging channels with their own encryption keys
- **Two node roles** -- clear distinction between autonomous repeaters and phone-paired companion radios
- **Companion app** -- dedicated MeshCore App for Android and iOS
- **Growing community** -- newer and smaller than Meshtastic but actively developed and gaining traction

MeshCore was created by the team behind Ripple Radios, who also sell pre-built MeshCore hardware. However, the firmware is open source and runs on widely available off-the-shelf LoRa boards.

---

## Supported Hardware

MeshCore runs on many of the same boards as Meshtastic. If you already own Meshtastic-compatible hardware, there is a good chance MeshCore supports it.

### Primary Boards

| Device | MCU | LoRa Chip | GPS | Display | Notes |
|--------|-----|-----------|-----|---------|-------|
| **Heltec V3** | ESP32-S3 | SX1262 | No | 0.96" OLED | Excellent starter board, compact, well-supported |
| **Lilygo T-Beam v1.1/1.2** | ESP32 | SX1276 or SX1262 | Yes | No (add-on) | Great for GPS-enabled nodes, 18650 battery holder |
| **Lilygo T-Beam Supreme** | ESP32-S3 | SX1262 | Yes | No | Updated T-Beam, improved power management |
| **Lilygo T-Deck** | ESP32-S3 | SX1262 | Optional | 2.8" LCD + keyboard | Standalone handheld -- no phone needed for messaging |
| **RAK WisBlock (RAK4631)** | nRF52840 | SX1262 | Optional | Optional | Very low power, excellent for solar repeaters |
| **Heltec T114** | nRF52840 | SX1262 | Optional | 1.14" TFT | Compact nRF52-based board, low power |
| **Station G2** | ESP32 | SX1262 | Optional | Optional | Higher power output, designed for fixed installations |

### Board Recommendations

**For your Heltec V3:** This is one of the best-supported MeshCore boards. Works well as either a companion radio or a repeater. The built-in OLED shows node status, message counts, and connection info. Compact enough for portable use, but the lack of GPS means it works best as a fixed repeater or as a companion radio where the phone provides location data.

**For your T-Beam 1.2:** Excellent choice for a GPS-enabled companion node or a mobile repeater. The built-in GPS means it can share location without a phone. The 18650 battery holder makes for easy power management in the field. If your T-Beam has the SX1276, it still works but the SX1262 variant has better receive sensitivity and lower power consumption.

**Best repeater board:** RAK4631 WisBlock for battery/solar deployments (nRF52840 sips power), Station G2 for fixed mains-powered installations (higher transmit power).

**Best standalone device:** T-Deck -- the built-in keyboard and screen mean you can type and read messages without a phone.

---

## Key Concepts

### Repeaters vs Companion Radios

This is the most important architectural concept in MeshCore. Every node is flashed as one of two roles:

**Repeater:**
- Operates autonomously -- no phone or app connection needed
- Sole purpose is to relay messages through the mesh
- Forwards packets from other nodes using managed flooding
- Broadcasts advert packets so other nodes know it exists
- Typically deployed in fixed locations (rooftops, hilltops, towers)
- Can be solar-powered and left unattended
- Has no user interaction beyond initial configuration
- Think of these as the mesh infrastructure

**Companion Radio:**
- Pairs with a phone running the MeshCore App via Bluetooth
- This is your personal device -- you send and receive messages through it
- Still participates in the mesh (relays messages for others) but also provides user messaging
- The phone app is the user interface; the radio is the communication hardware
- Can share GPS location from the phone
- Think of this as your personal communicator

This separation is cleaner than Meshtastic's approach, where every node is both a relay and a user device by default. In MeshCore, you build your network backbone with repeaters, then interact with it through companion radios.

**Practical example:** Deploy two or three Heltec V3 boards as repeaters on elevated positions. Carry a T-Beam 1.2 as your companion radio paired with your phone. Your messages hop through the repeaters to reach other companion radio users.

### Rooms

Rooms are MeshCore's group messaging system. They are conceptually similar to Meshtastic channels but implemented differently.

- A room has a name and a shared encryption key
- Anyone who joins the same room (by name and key) can see messages sent to that room
- You can be in multiple rooms simultaneously
- Rooms provide group communication -- broadcast to everyone in the room
- Direct messages (DMs) between two specific nodes are also supported, separate from rooms
- Room keys are derived from the room name and a password/passphrase you set

**Typical room setup:**
- A general "everyone" room for the whole mesh
- A room per team or family group
- A room for emergency/priority traffic

### Managed Flooding

MeshCore uses **managed flooding** for message propagation, which differs from Meshtastic's approach:

- When a node receives a message to relay, it does not blindly rebroadcast it
- MeshCore tracks which nodes have already seen a packet and avoids redundant retransmissions
- Repeaters cooperate to ensure a message reaches its destination without excessive duplicate transmissions
- This reduces airtime congestion on busy networks compared to naive flooding
- The protocol uses path information gathered from advert packets to make smarter relay decisions

In practice, managed flooding means:
- Less wasted airtime on networks with many nodes
- Better scaling as the network grows
- Slightly more complex protocol logic (handled by the firmware, not by the user)
- Similar effective range to Meshtastic -- the physics of LoRa are the same

### Advert Packets

Nodes periodically broadcast **advert packets** (advertisements) to announce their presence on the mesh:

- Advert packets contain the node's ID, name, and role (repeater or companion)
- Other nodes use adverts to build a picture of the network topology
- Repeaters advertise regularly so the mesh knows they are alive and available for routing
- Companion radios also advertise so other users can see who is on the mesh
- Advert frequency is configurable -- more frequent adverts mean faster topology updates but more airtime usage

### Path Management

MeshCore maintains route information based on the adverts and traffic it observes:

- Each node builds a table of known nodes and the path (sequence of repeaters) to reach them
- This path data informs relay decisions -- a repeater can prefer a known-good route over blind rebroadcast
- Paths are updated dynamically as nodes appear, disappear, or as RF conditions change
- The companion app can display the path a message took to reach you (useful for network debugging)

---

## Installation / Flashing

### Method 1: Web Flasher (Recommended)

The easiest way to flash MeshCore is the official web flasher:

**URL:** `https://flasher.meshcore.co`

**Requirements:**
- A Chromium-based browser (Chrome, Edge, Brave) -- Firefox does not support WebSerial
- A USB cable connected to your board
- Correct USB drivers installed for your board's USB-to-serial chip (CP2102 for many ESP32 boards, CH9102 for Heltec V3)

**Steps:**

1. Connect your board via USB
2. Open `https://flasher.meshcore.co` in Chrome/Edge
3. Select your board from the dropdown list (e.g., "Heltec V3", "T-Beam 1.2 SX1276")
4. Select the firmware variant:
   - **Repeater** -- for relay/infrastructure nodes
   - **Companion** -- for nodes that will pair with a phone
5. Select your region (US 915 MHz, EU 868 MHz, etc.)
6. Click "Flash" and select the correct serial port when prompted
7. Wait for flashing to complete (typically 30-60 seconds)
8. The board will reboot with MeshCore firmware

**Important:** Select the correct board variant. Flashing T-Beam SX1276 firmware onto an SX1262 board (or vice versa) will not damage hardware but the radio will not function.

### Method 2: Manual Flashing with esptool (ESP32 boards)

For offline flashing or when the web flasher is not available:

```bash
# Install esptool if you don't have it
pip install esptool

# Download the correct firmware .bin file from:
# https://github.com/ripplebiz/MeshCore/releases

# Erase flash first (recommended for clean install)
esptool.py --chip esp32s3 --port /dev/ttyUSB0 erase_flash

# Flash the firmware (example for Heltec V3)
esptool.py --chip esp32s3 --port /dev/ttyUSB0 \
  --baud 921600 \
  write_flash 0x0 meshcore-heltec-v3-companion.bin
```

Adjust `--chip` for your board:
- Heltec V3, T-Deck, T-Beam Supreme: `esp32s3`
- T-Beam v1.1/1.2: `esp32`
- RAK4631, Heltec T114: these use nRF52840 and require different tools (adafruit-nrfutil or UF2 bootloader)

For **nRF52840 boards** (RAK4631, Heltec T114):

```bash
# These boards typically use UF2 bootloader
# Double-tap reset to enter bootloader mode
# A USB drive will appear -- copy the .uf2 firmware file to it
# The board reboots automatically after the file is copied

# Alternatively, using adafruit-nrfutil:
pip install adafruit-nrfutil
adafruit-nrfutil dfu serial --package meshcore-rak4631.zip -p /dev/ttyACM0
```

### Selecting the Correct Firmware Variant

Firmware filenames follow a pattern:

```
meshcore-<board>-<role>[-<variant>].bin
```

For example:
- `meshcore-heltec-v3-companion.bin` -- Heltec V3, companion role
- `meshcore-heltec-v3-repeater.bin` -- Heltec V3, repeater role
- `meshcore-tbeam-1.2-sx1276-companion.bin` -- T-Beam 1.2 with SX1276, companion role
- `meshcore-tbeam-1.2-sx1262-companion.bin` -- T-Beam 1.2 with SX1262, companion role

**Check your T-Beam's LoRa chip** before flashing. Look at the LoRa module on the board:
- SX1276 -- older, typically on boards sold before mid-2023
- SX1262 -- newer, better sensitivity, lower power consumption

If unsure, check the markings on the LoRa chip or look up the exact model you purchased.

### Initial Setup After Flashing

After flashing, the board will boot into MeshCore firmware:

- **ESP32 boards with OLED:** The screen will show a MeshCore logo, then display the node's default name and status
- **Boards without display:** The LED (if present) will blink to indicate the firmware is running

At this point, the node needs configuration. For companion radios, this is done through the MeshCore App. For repeaters, basic functionality starts immediately with default settings, but you should configure them via the app at least once (pair temporarily, configure, then switch the firmware to repeater or configure via serial).

---

## Configuration

### MeshCore Companion App

**Download:**
- Android: Google Play Store -- search "MeshCore"
- iOS: Apple App Store -- search "MeshCore"
- The app is free

**First connection:**

1. Power on your MeshCore companion radio
2. Open the MeshCore App on your phone
3. Enable Bluetooth on your phone
4. In the app, tap "Scan" or "Connect" to find nearby MeshCore devices
5. Select your device from the list (it will show as the default node name or board type)
6. The app will pair via BLE (Bluetooth Low Energy)

Once connected, the app is your primary interface for all configuration and messaging.

### Setting Node Name

- In the app, go to Settings (or tap the node name at the top)
- Set a **node name** -- this is how other users see you on the mesh
- Keep it short and recognizable (e.g., "JAKE", "BASE1", "RPT-HILL")
- The name is broadcast in advert packets

### Region and Frequency

- Select your regulatory region: **US** (915 MHz), **EU** (868 MHz), **AU** (915 MHz), **KR** (920 MHz), etc.
- All nodes in your mesh must use the same region/frequency settings to communicate
- The frequency band and LoRa parameters (spreading factor, bandwidth, coding rate) are set per-region with sensible defaults
- Advanced users can adjust LoRa parameters but the defaults work well for most cases

**For US users:** The default 915 MHz ISM band settings are legal and license-free.

### Creating and Joining Rooms

**To create a room:**
1. In the app, go to the Rooms section
2. Tap "Create Room" or "Add Room"
3. Enter a room name (e.g., "General", "Team-Alpha", "Emergency")
4. Enter a password/passphrase -- this generates the room's encryption key
5. Share the room name and password with others who should join

**To join an existing room:**
1. Get the room name and password from someone already in the room
2. In the app, tap "Join Room"
3. Enter the exact room name and password (case-sensitive)
4. You will now see messages in that room

**Room tips:**
- You can be in multiple rooms at once
- Each room has independent encryption
- A room called "General" with password "general" on one mesh is a different encryption key from "General" with password "secret"
- Direct messages (DMs) between two nodes do not require rooms

### Setting Up Repeater Nodes

To deploy a repeater (e.g., your Heltec V3 on a rooftop):

1. Flash the **repeater** firmware variant onto the board
2. Optionally, connect via the app first to configure name, region, and LoRa settings
3. Deploy the repeater -- once powered on, it operates autonomously
4. No phone connection is needed for ongoing operation
5. The repeater will broadcast adverts and relay messages automatically

**Repeater configuration considerations:**
- Set a descriptive name (e.g., "RPT-HILLTOP", "RPT-ROOF")
- Ensure the region setting matches all other nodes in the mesh
- For solar-powered repeaters, consider sleep/power settings (see below)

### Setting Up Companion Nodes

Your personal device (e.g., T-Beam 1.2 you carry with you):

1. Flash the **companion** firmware variant
2. Open the MeshCore App and pair via Bluetooth
3. Set your node name, region, and any rooms you want to join
4. The companion radio will stay connected to your phone via BLE
5. Messages appear in the app; you compose and send from the app

### Power Settings and Sleep Modes

MeshCore supports power management features to extend battery life:

- **Repeaters:** Can be configured with sleep intervals. The node wakes periodically to relay messages, then sleeps to conserve power. This is important for solar/battery repeaters. Trade-off: sleeping repeaters add latency and may miss some packets during sleep.
- **Companion radios:** Generally stay awake while connected to the phone. When disconnected, they can enter a low-power state.
- **nRF52840 boards** (RAK4631, T114) have significantly lower baseline power consumption than ESP32 boards, making them better for always-on battery/solar repeaters.

**Battery life estimates (approximate):**

| Board | Role | Battery | Estimated Runtime |
|-------|------|---------|-------------------|
| Heltec V3 | Companion (active) | 1000mAh LiPo | 8-16 hours |
| Heltec V3 | Repeater (no sleep) | 1000mAh LiPo | 12-20 hours |
| T-Beam 1.2 | Companion (active) | 3000mAh 18650 | 18-30 hours |
| T-Beam 1.2 | Repeater (no sleep) | 3000mAh 18650 | 24-48 hours |
| RAK4631 | Repeater (no sleep) | 3000mAh LiPo | 3-7 days |

These are rough estimates. Actual battery life depends on message traffic, LoRa parameters (higher spreading factor = more power per message), GPS usage, display usage, and whether sleep modes are enabled.

### GPS Configuration

For boards with GPS (T-Beam, Wireless Tracker):

- GPS is used for location sharing -- your position is sent to the mesh
- GPS can be enabled/disabled in the app settings
- GPS increases power consumption significantly (add ~30-50mA draw)
- For fixed repeaters, you can set a static position instead of using GPS
- The T-Beam 1.2's GPS module is ready to use out of the box; first fix may take a few minutes outdoors

For boards without GPS (Heltec V3):
- Location data can come from the paired phone's GPS (for companion radios)
- Or set a fixed/static position in configuration

---

## MeshCore vs Meshtastic -- Detailed Comparison

This section is for users who know Meshtastic and want to understand how MeshCore differs.

### Protocol and Routing

| Aspect | Meshtastic | MeshCore |
|--------|-----------|----------|
| Routing method | Simple flooding -- every node rebroadcasts every packet (up to hop limit) | Managed flooding -- nodes use path information to make smarter relay decisions |
| Node roles | Every node is both user and relay | Distinct repeater (relay-only) and companion (user) roles |
| Hop limit | Configurable (default 3, max 7) | Uses path-aware routing; messages take discovered routes |
| Duplicate handling | Nodes track seen packet IDs and drop duplicates | Similar, but with additional path-based intelligence |
| Scaling | Can congest with many nodes (lots of duplicate transmissions) | Designed to handle larger networks with less airtime waste |

### Encryption

Both use AES-256 encryption. The key derivation differs:
- **Meshtastic:** Channel key is derived from a PSK (pre-shared key) you set. Default channel uses a known key (not secure until you change it).
- **MeshCore:** Room key is derived from the room name + password. No "default open" channel -- you always set credentials.

### Channel / Room System

| Feature | Meshtastic Channels | MeshCore Rooms |
|---------|-------------------|----------------|
| Number supported | Up to 8 channels per node | Multiple rooms (no hard limit in normal use) |
| Encryption | Per-channel PSK | Per-room key (from name + password) |
| Default channel | "LongFast" with known key (public) | No default public room |
| Joining | Enter exact PSK or scan QR code | Enter room name + password |
| Discovery | Must know the PSK | Must know name + password |

### App Ecosystem

| Aspect | Meshtastic | MeshCore |
|--------|-----------|----------|
| Official app | Meshtastic App (Android, iOS) | MeshCore App (Android, iOS) |
| Third-party apps | Several (Meshenger, web client, etc.) | Limited -- MeshCore App is the primary client |
| Web interface | Yes (via WiFi on ESP32 nodes) | Limited |
| CLI / serial interface | Yes (meshtastic-cli, Python API) | Serial console available |
| MQTT bridge | Yes -- can bridge mesh to internet via MQTT | Not a primary feature |

### Community and Maturity

| Aspect | Meshtastic | MeshCore |
|--------|-----------|----------|
| Project age | Started ~2020, very mature | Newer, started ~2023, actively evolving |
| Community size | Large -- active Discord, Reddit, forums, many YouTube guides | Smaller but growing -- Discord, GitHub |
| Documentation | Extensive official docs | Improving, community-contributed |
| Hardware support | Very broad (dozens of boards) | Good and growing (covers most popular boards) |
| Plugin/module system | Yes -- position, telemetry, detection sensor, serial, etc. | More focused -- messaging and location |
| Firmware updates | Frequent, well-tested release cycle | Active development, updates via GitHub releases |

### Hardware Overlap

Most popular LoRa boards run both Meshtastic and MeshCore:
- Heltec V3 -- yes (both)
- T-Beam -- yes (both)
- T-Deck -- yes (both)
- RAK4631 -- yes (both)
- Station G2 -- yes (both)

**You cannot run both simultaneously on the same board.** A board is flashed with either Meshtastic or MeshCore firmware. Switching between them requires reflashing. No data is shared between the two platforms.

**If you have two boards** (e.g., Heltec V3 and T-Beam 1.2), you could run Meshtastic on one and MeshCore on the other to evaluate both. They will not communicate with each other -- the protocols are completely incompatible.

### When to Use Which

**MeshCore may be better when:**
- You want a cleaner separation between infrastructure (repeaters) and user devices
- You are building a network that needs to scale to many nodes with less airtime congestion
- You prefer MeshCore's simpler room-based group messaging
- You want a fresh start with a newer, potentially less complex codebase
- You value managed flooding over simple rebroadcast

**Meshtastic may be better when:**
- You need the largest community and most documentation
- You want extensive third-party app and integration support (MQTT, Home Assistant, etc.)
- You need advanced modules (telemetry, detection sensors, serial module, etc.)
- You need maximum hardware compatibility
- You want a proven, battle-tested system with years of deployment experience
- Your existing network is already Meshtastic

**For your offline emergency kit:** Consider having both firmwares on the USB stick so you can flash either depending on what network already exists in your area. If nearby people are running Meshtastic, you need Meshtastic. If they are running MeshCore, you need MeshCore. The two cannot interoperate.

---

## Network Planning

### Repeater Placement Strategy

The fundamental rule is the same as any LoRa deployment: **height is everything.**

- Place repeaters as high as possible -- rooftops, hilltops, towers, tall buildings
- A single well-placed repeater on a hilltop can cover a 10-20 km radius with clear line of sight
- In urban environments, expect 1-5 km between nodes depending on obstacles
- Repeaters should have line of sight to at least one other repeater and to the areas you want to serve

**Starter network layout:**

```
                    [RPT-HILLTOP]
                    /            \
           [RPT-ROOF-A]      [RPT-ROOF-B]
            /       \              |
    [User-1]    [User-2]      [User-3]
```

- 2-3 repeaters provide useful coverage for a neighborhood or small town
- One elevated repeater can serve as the backbone
- Companion radios (users) connect through whichever repeater they can reach

### Room Configuration for Groups

Plan your rooms before deployment:

- **Mesh-wide room:** One room that all users join for general communication (e.g., room name "General", shared password)
- **Team/family rooms:** Private rooms for specific groups (e.g., "Smith-Family" with a private password)
- **Emergency room:** A dedicated room for emergency traffic, known to all users
- Keep room passwords simple enough to share verbally but not obvious to outsiders

### Mixing Repeaters and Companion Nodes

- Repeaters do not need to join rooms -- they relay all encrypted traffic regardless of whether they can decrypt it
- Only companion radios (paired with phones) join rooms and read messages
- This means repeaters are "dumb pipes" -- they forward everything, which is the correct behavior for infrastructure
- You do not need to configure room credentials on repeaters

### Range Expectations

MeshCore uses the same LoRa radio hardware as Meshtastic, so range is determined by the same physics:

| Environment | Expected Range |
|-------------|---------------|
| Dense urban (buildings, streets) | 0.5 - 2 km |
| Suburban (houses, some trees) | 1 - 5 km |
| Rural (open fields, some trees) | 5 - 15 km |
| Line of sight (hilltop to hilltop) | 10 - 50+ km |
| Extreme LOS (mountain to mountain, optimized) | 50 - 100+ km |

**Key factors:**
- Antenna quality matters enormously -- a proper external antenna vs the stock stubby antenna can double or triple range
- Height above ground is the single most important factor
- LoRa spreading factor (SF): higher SF = longer range but slower data rate and more airtime
- Bandwidth: lower bandwidth = longer range but slower
- Transmit power: 915 MHz boards typically transmit at 20-22 dBm (legal limit varies by region)

---

## Troubleshooting

### Node Not Appearing in App

**Symptom:** You open the MeshCore App and scan for devices but your board does not appear.

**Fixes:**
1. **Confirm firmware is running:** Check that the board's display (if present) or LED shows MeshCore activity. If the display is blank or shows nothing, the firmware may not have flashed correctly.
2. **Check firmware variant:** You must flash the **companion** variant to pair with the app. Repeater firmware does not advertise for BLE pairing.
3. **Bluetooth on phone:** Ensure Bluetooth and Location Services are enabled on your phone (Android requires location permission for BLE scanning).
4. **Distance:** Keep the board within 1-2 meters of your phone during initial pairing.
5. **Reboot both:** Power-cycle the board (unplug and replug USB or toggle the power switch) and restart the app.
6. **Unpair old devices:** If you previously paired and something went wrong, remove the device from your phone's Bluetooth settings and try again.
7. **Check USB power:** If running from USB, ensure the port provides enough current. Some USB hubs or laptop ports are marginal.

### Messages Not Being Relayed

**Symptom:** You can see other nodes (adverts are arriving) but your messages do not reach distant nodes.

**Fixes:**
1. **Check rooms:** Both sender and receiver must be in the same room to see room messages. Verify room name and password match exactly (case-sensitive).
2. **Repeater is running:** Confirm your repeaters are powered on and showing activity. A repeater with a display should show packet counts increasing.
3. **Same region/frequency:** All nodes must be on the same frequency settings. A node on US 915 MHz cannot communicate with one on EU 868 MHz.
4. **Range issue:** The sending node may be out of range of any repeater. Test by moving closer.
5. **Airtime congestion:** On a very busy network, messages may be delayed. LoRa is slow -- each message takes seconds to transmit. Wait and retry.
6. **Firmware version mismatch:** Ensure all nodes are on the same (or compatible) firmware version. Major version mismatches can cause protocol incompatibilities.

### Bluetooth Pairing Issues

**Symptom:** The app finds the device but fails to connect or disconnects frequently.

**Fixes:**
1. **One device at a time:** MeshCore companion radios support one BLE connection. If another phone is already paired, the second phone cannot connect.
2. **Clear pairing:** On your phone, go to Bluetooth settings, forget the MeshCore device, then re-pair from the app.
3. **App version:** Update the MeshCore App to the latest version.
4. **Android-specific:** Some Android phones have BLE bugs. Toggling Bluetooth off and on, or restarting the phone, can help.
5. **iOS-specific:** iOS can cache stale BLE connections. If the board has been reflashed, iOS may try to use old cached connection info. Forget the device in iOS Bluetooth settings and re-pair.
6. **Distance:** BLE range is typically 10-30 meters. Stay close during initial setup. Walls and bodies attenuate BLE significantly.

### Firmware Update Problems

**Symptom:** Flashing fails, board won't boot after flash, or web flasher does not detect the board.

**Fixes:**
1. **Correct firmware file:** Double-check you selected the right board and LoRa chip variant. Flashing T-Beam SX1276 firmware on an SX1262 board will not damage it but the radio will not work.
2. **USB cable:** Use a data-capable USB cable, not a charge-only cable. This is the most common cause of "device not detected."
3. **USB drivers:** Install the correct driver for your board's USB-serial chip:
   - Heltec V3: CH9102 driver
   - T-Beam: CP2102 driver
   - Boards with native USB (ESP32-S3 native): no driver needed, but may require holding BOOT button during connection
4. **Boot mode:** If the board will not enter flash mode, hold the BOOT button while pressing RESET (or while plugging in USB). Release BOOT after the flasher detects the device.
5. **Erase first:** For stubborn cases, do a full flash erase before writing new firmware:
   ```bash
   esptool.py --port /dev/ttyUSB0 erase_flash
   ```
6. **Browser issues (web flasher):** The web flasher requires Chrome, Edge, or Brave. Firefox and Safari do not support WebSerial. Ensure no other serial monitor (Arduino IDE, PuTTY, screen) has the port open.
7. **Power supply:** Some boards draw more current during flashing. Use a direct USB port on your computer, not a hub.

### Factory Reset

If a node is in a bad state and you want to start fresh:

1. Erase the flash completely using esptool (ESP32) or re-enter bootloader and reflash (nRF52)
2. Flash the firmware again from scratch
3. Reconfigure via the app

```bash
# Full erase for ESP32/ESP32-S3 boards
esptool.py --port /dev/ttyUSB0 erase_flash

# Then reflash
esptool.py --chip esp32s3 --port /dev/ttyUSB0 \
  --baud 921600 \
  write_flash 0x0 meshcore-heltec-v3-companion.bin
```

---

## Quick Reference

### Minimum Viable MeshCore Network

You need at least two companion radios (each paired with a phone) to have a conversation. Add repeaters to extend range.

**Simplest setup (two people, close range):**
- 2x Heltec V3 (or any supported board) flashed as companion
- 2x phones with MeshCore App
- Both join the same room
- Range: whatever direct LoRa range allows (0.5-15 km depending on environment)

**Basic network (extended range):**
- 1-3x boards flashed as repeaters, deployed at elevated positions
- 2+ boards flashed as companion, carried by users
- All on the same region/frequency settings
- Companion users joined to shared rooms

### Important URLs (Save for Offline Access)

- **Firmware releases:** `https://github.com/ripplebiz/MeshCore/releases`
- **Web flasher:** `https://flasher.meshcore.co`
- **Source code:** `https://github.com/ripplebiz/MeshCore`
- **MeshCore App (Android):** Google Play Store
- **MeshCore App (iOS):** Apple App Store
- **Community Discord:** Check the GitHub README for the current invite link

### Firmware Files to Keep on USB Stick

For your hardware, download and save these firmware files for offline flashing:

```
meshcore-heltec-v3-companion.bin
meshcore-heltec-v3-repeater.bin
meshcore-tbeam-1.2-sx1276-companion.bin    (if your T-Beam has SX1276)
meshcore-tbeam-1.2-sx1276-repeater.bin
meshcore-tbeam-1.2-sx1262-companion.bin    (if your T-Beam has SX1262)
meshcore-tbeam-1.2-sx1262-repeater.bin
```

Also keep `esptool.py` (via `pip install esptool`) on the USB stick for offline flashing without the web flasher.
