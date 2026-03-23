# Meshtastic on Heltec V3 (WiFi LoRa 32 V3)

The Heltec V3 is a compact, affordable Meshtastic device with a built-in OLED display. This guide covers everything specific to running Meshtastic on the Heltec V3.

---

## Hardware Overview

| Feature | Specification |
|---------|--------------|
| MCU | ESP32-S3 (dual-core, 240MHz, WiFi + BLE 5.0) |
| LoRa | SX1262 |
| Frequency | 868 MHz (EU) or 915 MHz (US) — buy the correct one |
| Display | 0.96" OLED (128x64, SSD1306) |
| GPS | None (external GPS can be added) |
| Battery | LiPo via JST 1.25mm 2-pin connector |
| USB | USB-C |
| Antenna | IPEX (u.FL) connector + included PCB antenna (some versions) |
| Size | ~50mm x 25mm x 10mm |
| Weight | ~15g (without battery) |

---

## No Built-In GPS

Unlike the T-Beam, the Heltec V3 does not have GPS. This means:
- Your node will not broadcast its position automatically
- You can still receive and display other nodes' positions
- Other nodes will see your node in their list but without a map location

### Adding External GPS

You can add a GPS module via serial (UART):

**Compatible GPS Modules:**
- u-blox NEO-6M (cheapest, widely available)
- u-blox NEO-7M/8M (faster fix, more accurate)
- Quectel L76K (used in T-Beam V1.2)
- ATGM336H (cheap, decent performance)

**Wiring:**
```
GPS Module    →    Heltec V3
VCC           →    3.3V
GND           →    GND
TX            →    GPIO pin (configure as GPS RX in Meshtastic)
RX            →    GPIO pin (configure as GPS TX in Meshtastic)
```

**Configuration:**
```bash
meshtastic --set position.gps_enabled true
meshtastic --set position.rx_gpio YOUR_RX_PIN
meshtastic --set position.tx_gpio YOUR_TX_PIN
```

### Setting a Fixed Position (No GPS Needed)

For a stationary node, you can set coordinates manually:
```bash
meshtastic --set position.fixed_position true
meshtastic --setlat 40.7128 --setlon -74.0060 --setalt 10
```

---

## Battery

### LiPo Connection
- The Heltec V3 uses a **JST-PH 1.25mm 2-pin** connector for the battery
- This is a small white connector on the board — do not confuse it with the larger JST-PH 2.0mm used on some other boards
- Connect a single-cell 3.7V LiPo pack

### Battery Recommendations
| Battery | Capacity | Size | Notes |
|---------|----------|------|-------|
| Generic 1S LiPo 503035 | 500mAh | Small | Compact, short runtime |
| Generic 1S LiPo 603450 | 1000mAh | Medium | Good balance |
| Generic 1S LiPo 804050 | 2000mAh | Medium-large | Extended runtime |
| Generic 1S LiPo 105070 | 4000mAh | Large | Maximum runtime |

**There is no 18650 holder.** If you want to use an 18650, you'll need an external holder with wires terminated in a JST 1.25 connector.

### JST Connector Polarity Warning
- **JST connectors are NOT standardized for polarity** across manufacturers
- The Heltec V3 expects a specific polarity (check the silkscreen: + and - markings on the PCB)
- Some LiPo packs come with reversed JST connectors
- **Verify polarity with a multimeter before connecting** — reversed polarity can destroy the board
- If needed, swap the pins in the JST connector housing using a small tool or needle

### Charging
- The battery charges through USB-C when connected
- Built-in charge management IC handles CC-CV charging
- LED indicator shows charging status
- Charge current is limited (typically 500mA)

### Runtime Estimates

| Configuration | Approx. Current | Runtime (1000mAh) |
|--------------|----------------|-------------------|
| Default CLIENT, display on | ~80mA | ~11 hours |
| CLIENT, display timeout 30s | ~50mA | ~18 hours |
| ROUTER, display off | ~40mA | ~22 hours |
| Power saving, long intervals | ~25mA | ~36 hours |

---

## OLED Display

The built-in 0.96" OLED is one of the Heltec V3's best features.

### What It Shows
- **Splash screen:** Meshtastic logo on boot
- **Node info:** your node name, battery voltage, channel
- **Messages:** incoming text messages scroll on screen
- **Node list:** nearby nodes with signal strength
- **GPS info:** coordinates of your node and others (if available)
- **Signal info:** RSSI, SNR of received packets
- **Telemetry:** battery, airtime utilization

### Display Settings
```bash
# Screen on time (seconds, 0 = always on)
meshtastic --set display.screen_on_secs 60

# Flip the display (if mounted upside down)
meshtastic --set display.flip_screen true

# Display compass heading on top
meshtastic --set display.compass_north_top true
```

### Vext Pin (OLED Power Control)
- The Heltec V3 controls OLED power through a pin called "Vext"
- Meshtastic firmware handles this automatically — the display turns on during boot and follows the screen_on_secs timeout
- If you're writing custom firmware, you need to pull Vext LOW to enable the OLED and HIGH to disable it
- On Meshtastic, you don't need to configure this

### Display Power Impact
- The OLED draws ~20-30mA when active
- Setting a short screen timeout significantly improves battery life
- For battery-powered nodes, set `screen_on_secs` to 15-30 seconds
- For solar-powered or USB-powered nodes, leave it always on

---

## Antenna

### Stock Antenna Options
The Heltec V3 comes with different antenna options depending on the version/seller:
- **PCB trace antenna:** printed on the board itself (some versions) — worst performance
- **External IPEX antenna:** small wire antenna connected via IPEX (u.FL) connector — better
- **SMA pigtail:** some sellers include an IPEX-to-SMA pigtail cable + rubber ducky antenna

### Upgrading the Antenna
For better range, connect an external antenna via the IPEX (u.FL) connector:
1. Get an **IPEX to SMA female pigtail** cable (~$2-5)
2. Connect a proper **915MHz or 868MHz SMA antenna** (match your region)
3. Mount the antenna as high as possible

**Warning:** the IPEX connector is fragile. Do not repeatedly connect/disconnect. Connect once and leave it.

### Antenna Recommendations
| Type | Gain | Use Case |
|------|------|----------|
| Stock IPEX wire | ~0 dBi | Indoor testing |
| Rubber ducky (via SMA pigtail) | ~2-3 dBi | Portable, general use |
| Half-wave whip | ~3-5 dBi | Better portable |
| Ground plane vertical | ~5-6 dBi | Fixed outdoor installation |

---

## Flashing Firmware

### Using the Web Flasher
1. Open https://flasher.meshtastic.org in Chrome or Edge
2. Connect the Heltec V3 via USB-C
3. Select **"heltec-v3"** as the device
4. Select the firmware version
5. Click Flash
6. Select the serial port when prompted

### If the Device Isn't Recognized

The Heltec V3 uses ESP32-S3 with native USB. On first flash or if the device is unresponsive:

1. **Hold the BOOT button** (small button, may be labeled "0" or "BOOT")
2. **While holding BOOT, press and release RST** (reset button)
3. **Release BOOT**
4. The device should now appear as a serial port in bootloader mode
5. Proceed with flashing

### USB-C Notes
- The ESP32-S3 native USB appears as a different type of serial device than the CP2102/CH340 on other boards
- On Linux: typically appears as `/dev/ttyACM0` (not `/dev/ttyUSB0`)
- On Windows: should auto-install drivers; appears as a COM port
- On macOS: appears as `/dev/cu.usbmodem*`

### Using esptool.py
```bash
# Put device in bootloader mode first (BOOT + RST sequence above)
esptool.py --chip esp32s3 --port /dev/ttyACM0 erase_flash
esptool.py --chip esp32s3 --port /dev/ttyACM0 --baud 921600 write_flash \
  0x0 bootloader.bin \
  0x8000 partitions.bin \
  0x10000 firmware.bin
```

---

## Good For

The Heltec V3 excels in these use cases:

### Compact Display Node
- Built-in OLED means you can read messages without a phone
- Great for a desk/shelf node that shows mesh activity

### Indoor Relay
- Small enough to place anywhere (window sill, bookshelf, mounted on wall)
- Display shows status without needing to connect a phone
- USB powered, no battery management needed

### Development and Testing
- Cheap (~$15-20) so you can buy several for testing
- Display provides instant feedback during development
- ESP32-S3 has more GPIO and RAM than the original ESP32 on T-Beam V1.x

### Portable Node (with LiPo)
- Very compact and light
- With a 1000-2000mAh LiPo, provides a full day of use
- Add a small case and it fits in a jacket pocket

### Sensor Node
- Connect I2C sensors (BME280 for temperature/humidity/pressure)
- Display shows local sensor readings
- Broadcasts telemetry to the mesh

---

## Heltec V3 vs T-Beam Comparison

| Feature | Heltec V3 | T-Beam |
|---------|-----------|--------|
| Price | ~$15-20 | ~$25-35 |
| MCU | ESP32-S3 | ESP32 (or S3 on Supreme) |
| LoRa | SX1262 | SX1276 or SX1262 |
| GPS | No | Yes (built-in) |
| Display | 0.96" OLED | No (add-on) |
| Battery | LiPo (JST 1.25) | 18650 holder |
| Size | Very compact | Larger (18650 holder) |
| Antenna | IPEX (u.FL) | SMA |
| Best for | Display nodes, compact builds | Mobile with GPS, long runtime |

---

## Pin Reference

Useful pins for connecting external peripherals:

| Function | GPIO | Notes |
|----------|------|-------|
| OLED SDA | 17 | I2C (shared with external I2C devices) |
| OLED SCL | 18 | I2C (shared with external I2C devices) |
| OLED RST | 21 | Display reset |
| Vext Control | 36 | LOW = Vext enabled, HIGH = disabled |
| User Button | 0 | BOOT button, usable as user button after boot |
| LED | 35 | White LED |
| ADC Battery | 1 | Battery voltage reading (through voltage divider) |
| LoRa NSS | 8 | SPI chip select |
| LoRa RST | 12 | LoRa reset |
| LoRa DIO1 | 14 | LoRa interrupt |
| LoRa BUSY | 13 | LoRa busy |
| LoRa SCK | 9 | SPI clock |
| LoRa MOSI | 10 | SPI data out |
| LoRa MISO | 11 | SPI data in |

*Pin numbers may vary slightly between board revisions. Always check the schematic for your specific version.*
