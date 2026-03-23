# Meshtastic on LILYGO T-Beam

The T-Beam is the most popular Meshtastic device. This guide covers hardware details, setup, and configuration specific to the T-Beam.

---

## Hardware Overview

The T-Beam is an ESP32-based board with built-in LoRa radio, GPS, 18650 battery holder, and power management unit (PMU). It was practically designed for Meshtastic.

### Variants

| Version | LoRa Chip | GPS | PMU | Notes |
|---------|-----------|-----|-----|-------|
| T-Beam V1.0 | SX1276 | NEO-6M | AXP192 | Older, still widely available |
| T-Beam V1.1 | SX1276 or SX1262 | NEO-6M | AXP192 | Improved layout |
| T-Beam V1.2 | SX1262 | NEO-6M or L76K | AXP2101 | Current production, improved PMU |
| T-Beam Supreme | SX1262 | L76K or MAX-M10S | AXP2101 | Latest design, better GPS options |

### Frequency Variants
- **868 MHz** — for EU_868 region (SX1276 or SX1262)
- **915 MHz** — for US region (SX1276 or SX1262)
- **433 MHz** — for EU_433 region

**Make sure you buy the correct frequency for your region.** The hardware is frequency-specific. A 915 MHz board cannot be used on 868 MHz.

### SX1276 vs SX1262
- **SX1276:** older LoRa chip, good performance, wider bandwidth options
- **SX1262:** newer chip, better sensitivity (~2-3 dB improvement), lower power consumption, better for LONG_SLOW presets
- **If buying new, get the SX1262 variant.**

---

## Battery: 18650

The T-Beam has a built-in 18650 battery holder on the bottom of the PCB.

### Inserting the Battery

**CRITICAL: Check the polarity markings on your specific board before inserting the battery.**

On most T-Beam versions:
- **Positive (+) terminal of the 18650 faces toward the USB port**
- **Negative (-) terminal faces toward the antenna end**

However, board layouts have varied between revisions. Always look at the silkscreen markings (+ and - symbols) printed on the PCB near the battery holder.

**Inserting the battery backwards can permanently damage the board.** There is no reverse polarity protection on most T-Beam versions.

### Recommended Cells
- **Samsung 30Q** (3000mAh, 15A) — best all-rounder
- **LG HG2** (3000mAh, 20A) — also excellent
- **Samsung 35E** (3500mAh, 8A) — maximum runtime (current draw is low enough)
- **Panasonic NCR18650B** (3400mAh) — another good high-capacity option

Any quality 18650 cell will work. The T-Beam draws well under 1A, so high-drain capability is not needed. Prioritize capacity (mAh).

### Battery Life Estimates

| Configuration | Approx. Current | Runtime (3000mAh) |
|--------------|----------------|-------------------|
| Default CLIENT, GPS on | ~120mA avg | ~22 hours |
| CLIENT, GPS smart position | ~80mA avg | ~33 hours |
| ROUTER, GPS off | ~60mA avg | ~44 hours |
| Power saving, long intervals | ~30mA avg | ~88 hours |
| Deep sleep (not useful for mesh) | ~10uA | Years |

---

## GPS

### Built-In GPS
- Auto-detected by Meshtastic firmware — no configuration needed
- **Cold start** (first fix after being off for a long time) can take **2-10 minutes** outdoors
- **Warm start** (recent almanac data) takes 30-60 seconds
- **Hot start** (very recent fix) takes a few seconds

### Getting a GPS Fix
- **Must be outdoors** or near a window with clear sky view for initial fix
- Indoor GPS fix is unreliable — GPS signals are very weak and don't penetrate buildings well
- The GPS LED (on boards that have one) will blink when searching and go solid (or different pattern) when fixed
- The Meshtastic app will show your coordinates once GPS has a fix

### GPS Tips
- For a **fixed installation** (router on a roof), get one good GPS fix, then set a fixed position in config and disable GPS to save power:
  ```bash
  meshtastic --set position.fixed_position true
  meshtastic --setlat 40.7128 --setlon -74.0060 --setalt 10
  meshtastic --set position.gps_enabled false
  ```
- For mobile use, enable GPS smart position to reduce GPS power usage:
  ```bash
  meshtastic --set position.position_broadcast_smart_enabled true
  meshtastic --set position.gps_update_interval 120
  ```

### External GPS Antenna
- Some T-Beam versions have a u.FL connector for an external GPS antenna
- An external active GPS antenna significantly improves fix time and accuracy
- Useful for indoor installations or when the board is in an enclosure

---

## PMU (Power Management Unit)

### AXP192 (V1.0-V1.1)
- Manages battery charging and power distribution
- Monitors battery voltage, charge current, USB voltage
- Reports battery percentage to Meshtastic (visible in app and telemetry)
- Charges the 18650 at up to 1A from USB

### AXP2101 (V1.2 and Supreme)
- Updated PMU with improved efficiency
- Better low-power modes
- Same charging and monitoring functions

### Charging
- Plug in USB-C (or micro-USB on older boards) to charge the battery
- Charging indicator: usually a red LED when charging, green when full
- Charge current is automatically managed by the PMU
- You can use the T-Beam while charging — the PMU handles power path management
- Full charge takes 3-4 hours from empty depending on USB power source

---

## Antenna

### Stock Antenna
- The T-Beam comes with a small SMA-connected rubber ducky antenna
- Adequate for testing and casual use (1-5km depending on environment)
- Always make sure the antenna is connected before transmitting — transmitting without an antenna can damage the LoRa radio

### Antenna Upgrades (Biggest Performance Improvement You Can Make)

| Antenna Type | Gain | Size | Best For |
|-------------|------|------|----------|
| Stock rubber ducky | ~2 dBi | Small | Portable, testing |
| Half-wave whip (915MHz) | ~3-5 dBi | ~16cm | Portable, improved range |
| 5/8 wave ground plane | ~5-6 dBi | ~30cm + radials | Fixed base station |
| Yagi directional | ~8-12 dBi | 50cm+ | Point-to-point links |
| Slim Jim / J-pole | ~4-6 dBi | ~40cm | Fixed, omnidirectional |
| Colinear vertical | ~6-9 dBi | 1m+ | Fixed, maximum omnidirectional range |

### Antenna Connection
- T-Beam uses an **SMA Female** connector (the one with the hole and inner pin)
- Antennas typically have **SMA Male** connectors (the one with the center pin sticking out)
- If mounting the antenna remotely, use low-loss coax (LMR-400 for longer runs, RG-316 for short pigtails)
- Every connector and adapter adds loss — keep the antenna system simple

---

## User Button

- The T-Beam has a physical user button (labeled "USER" or "PROG")
- **Single press:** cycle through display pages (if display connected) or send canned message
- **Long press:** varies by firmware version (may toggle GPS, enter settings, etc.)
- **During boot (BOOT button):** hold while powering on to enter bootloader for flashing

---

## Flashing

### Normal Flashing
1. Connect USB cable
2. Use web flasher (flasher.meshtastic.org) or Python CLI
3. Select "T-Beam" as the device (select the correct variant: SX1276 or SX1262)

### If Auto-Bootloader Fails
Some T-Beam boards don't automatically enter bootloader mode:
1. Hold the **BOOT** button (small button near the USB port, may be labeled "IO0")
2. While holding BOOT, press and release the **RST** (reset) button
3. Release BOOT
4. The device is now in bootloader mode — proceed with flashing

### Choosing the Right Firmware
- **T-Beam with SX1276:** select "tbeam" firmware
- **T-Beam with SX1262:** select "tbeam-s3-core" or the specific SX1262 variant
- **T-Beam Supreme (ESP32-S3):** select the S3 variant firmware
- **Using the wrong firmware variant will not damage the board** but the radio will not function

---

## Recommended Settings by Use Case

### Mobile Node (Hiking, Events)
```bash
meshtastic --set device.role CLIENT
meshtastic --set lora.modem_preset LONG_FAST
meshtastic --set lora.hop_limit 3
meshtastic --set position.position_broadcast_smart_enabled true
meshtastic --set position.gps_update_interval 120
meshtastic --set position.position_broadcast_secs 900
meshtastic --set display.screen_on_secs 30
meshtastic --set power.is_power_saving true
```

### Fixed Relay / Router (Rooftop, Solar-Powered)
```bash
meshtastic --set device.role ROUTER
meshtastic --set lora.modem_preset LONG_FAST
meshtastic --set lora.hop_limit 3
meshtastic --set lora.tx_power 30
meshtastic --set position.fixed_position true
meshtastic --setlat YOUR_LAT --setlon YOUR_LON --setalt YOUR_ALT
meshtastic --set position.gps_enabled false
meshtastic --set power.is_power_saving false
```

### Solar-Powered Remote Router
```bash
meshtastic --set device.role ROUTER
meshtastic --set lora.modem_preset LONG_FAST
meshtastic --set lora.tx_power 27
meshtastic --set position.fixed_position true
meshtastic --setlat YOUR_LAT --setlon YOUR_LON --setalt YOUR_ALT
meshtastic --set position.gps_enabled false
meshtastic --set power.is_power_saving false
meshtastic --set display.screen_on_secs 0
meshtastic --set power.wait_bluetooth_secs 0
```
For solar router hardware: see solar-charging.md for panel and battery sizing.

---

## Known Issues and Tips

### V1.2 GPS UART Pins
- Some T-Beam V1.2 boards have the GPS on different UART pins than earlier versions
- Meshtastic firmware auto-detects this in recent versions — make sure you're running the latest firmware
- If GPS is not working after a flash, try updating to the latest firmware

### SX1262 Firmware Selection
- The SX1262 variant **requires** firmware compiled for SX1262
- Flashing SX1276 firmware on an SX1262 board (or vice versa) will result in no radio functionality
- The web flasher correctly handles this if you select the right device

### OLED Display Add-on
- The T-Beam does not have a built-in display (unlike Heltec V3)
- You can add a 0.96" or 1.3" I2C OLED display (SSD1306) connected to the I2C header
- Meshtastic will auto-detect the display
- Typical I2C address: 0x3C
- Connection: SDA, SCL, VCC (3.3V), GND

### WiFi
- The T-Beam's ESP32 has WiFi capability
- Enable WiFi for web interface access or MQTT gateway:
  ```bash
  meshtastic --set network.wifi_enabled true
  meshtastic --set network.wifi_ssid "YourNetwork"
  meshtastic --set network.wifi_psk "YourPassword"
  ```
- Note: WiFi and Bluetooth can operate simultaneously but may slightly increase power consumption
