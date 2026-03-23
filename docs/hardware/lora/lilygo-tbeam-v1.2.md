# LILYGO T-Beam v1.2 Reference

## Overview

The T-Beam v1.2 is a feature-rich development board combining an ESP32 microcontroller, Semtech LoRa transceiver, GPS module, power management IC, and 18650 battery holder in a single board. It is the most popular hardware platform for Meshtastic and is well-suited to any project requiring LoRa + GPS + battery power.

## Specifications

| Component | Detail |
|-----------|--------|
| MCU | ESP32-D0WDQ6, dual-core Xtensa LX6, 240 MHz |
| Flash | 4 MB |
| PSRAM | 8 MB (QSPI) |
| LoRa | Semtech SX1276 (868/915 MHz variant) or SX1262 (newer revisions) |
| GPS | u-blox NEO-6M or NEO-8M (revision dependent) |
| PMU | AXP2101 (v1.2); earlier versions used AXP192 |
| Battery | 18650 holder, single cell (3.7V nominal) |
| Charging | Built-in via AXP2101, USB-C input, ~500mA default charge rate |
| USB | USB-C, CP2102 or CH9102F USB-UART bridge |
| Antenna (LoRa) | IPEX (U.FL) connector — external antenna required |
| Antenna (GPS) | Onboard ceramic patch or IPEX connector (revision dependent) |
| WiFi | 802.11 b/g/n, 2.4 GHz (ESP32 built-in) |
| Bluetooth | BLE 4.2 (ESP32 built-in) |
| Dimensions | ~100 x 32 x 18 mm (approximate, with battery holder) |
| Operating voltage | 3.3V logic, 5V USB input, 3.0-4.2V battery |

## Pinout Reference

### LoRa SPI Interface (SX1276 Variant)

| Function | GPIO | Notes |
|----------|------|-------|
| SCK | 5 | SPI clock |
| MISO | 19 | SPI data out (from radio) |
| MOSI | 27 | SPI data in (to radio) |
| CS (NSS) | 18 | Chip select, active low |
| RST | 23 | Radio reset, active low |
| DIO0 | 26 | Interrupt: RX done, TX done |
| DIO1 | 33 | Optional: used for frequency hopping / timeout |
| DIO2 | 32 | Optional: used for FSK mode |

### LoRa SPI Interface (SX1262 Variant)

| Function | GPIO | Notes |
|----------|------|-------|
| SCK | 5 | SPI clock |
| MISO | 19 | SPI data out |
| MOSI | 27 | SPI data in |
| CS (NSS) | 18 | Chip select |
| RST | 23 | Radio reset |
| BUSY | 32 | SX1262 busy indicator |
| DIO1 | 33 | Interrupt line |

### GPS UART

| Function | GPIO | Notes |
|----------|------|-------|
| GPS TX | 34 | GPS module transmits NMEA to ESP32 (ESP32 RX) |
| GPS RX | 12 | ESP32 transmits to GPS module (for config commands) |
| PPS | — | Some revisions expose PPS (pulse-per-second) |

Use `Serial1` or `HardwareSerial` on these pins:
```cpp
HardwareSerial GPS(1);
GPS.begin(9600, SERIAL_8N1, 34, 12);  // RX=34, TX=12
```

### I2C Bus

| Function | GPIO | Notes |
|----------|------|-------|
| SDA | 21 | Shared: AXP2101 PMU + OLED (if connected) |
| SCL | 22 | Shared: AXP2101 PMU + OLED (if connected) |

I2C addresses on the bus:
- **0x34** — AXP2101 PMU
- **0x3C** — SSD1306 OLED (if connected externally)
- **0x42** or **0x10** — u-blox GPS (if I2C mode enabled, default is UART)

### User Interface

| Function | GPIO | Notes |
|----------|------|-------|
| User button | 38 | Active LOW, has internal pull-up. Middle button on board. |
| Onboard LED | 4 | Active HIGH |
| Power button | — | Connected to AXP2101, hardware-managed power on/off |

### Other Available GPIOs

| GPIO | Notes |
|------|-------|
| 0 | Boot button / strapping pin — avoid for general use |
| 2 | Strapping pin — can use with care |
| 13 | Available |
| 14 | Available |
| 15 | Strapping pin — can use with care |
| 25 | Available, DAC1 |
| 35 | Input only |
| 36 (VP) | Input only |
| 39 (VN) | Input only |

**Note**: GPIOs 34-39 are input-only on ESP32. GPIO 34 (GPS TX) is correctly assigned as an input to the ESP32.

## AXP2101 Power Management

The AXP2101 is an advanced PMU that handles:
- **Battery charging**: Li-ion/LiPo, configurable charge current and voltage
- **Battery monitoring**: Voltage, current, coulomb counter, percentage estimation
- **Power rails**: Multiple LDO and DC-DC outputs that can be individually controlled
- **Power button**: Hardware power on/off, configurable press duration
- **Temperature**: Internal temperature sensor

### Accessing the PMU

```cpp
#include <XPowersLib.h>  // Lewis He's XPowersLib

XPowersAXP2101 pmu;

void setup() {
    Wire.begin(21, 22);
    if (!pmu.begin(Wire, AXP2101_SLAVE_ADDRESS, 21, 22)) {
        Serial.println("AXP2101 init failed!");
        return;
    }

    // Enable GPS power (ALDO3 typically)
    pmu.setALDO3Voltage(3300);
    pmu.enableALDO3();

    // Enable LoRa power (ALDO2 typically)
    pmu.setALDO2Voltage(3300);
    pmu.enableALDO2();

    // Read battery voltage
    float battVoltage = pmu.getBattVoltage() / 1000.0;
    Serial.printf("Battery: %.2f V\n", battVoltage);

    // Check if charging
    bool charging = pmu.isCharging();
    Serial.printf("Charging: %s\n", charging ? "Yes" : "No");
}
```

### Power Rails (T-Beam v1.2 typical mapping)

| Rail | Voltage | Supplies | Notes |
|------|---------|----------|-------|
| DCDC1 | 3.3V | ESP32 core | Do not disable |
| ALDO2 | 3.3V | LoRa radio | Disable for deep sleep savings |
| ALDO3 | 3.3V | GPS module | Disable to cut GPS power |
| ALDO4 | — | Varies by revision | Check your specific board |

**Warning**: Rail assignments can vary between T-Beam sub-revisions. Verify with your specific board before disabling rails.

## Programming

### Arduino IDE

1. Install ESP32 board package: Add `https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json` to Board Manager URLs.
2. Install board package: **esp32** by Espressif Systems.
3. Board selection: **ESP32 Dev Module** (or "T-Beam" if available in your version).
4. Settings:
   - Flash Size: 4MB
   - Partition Scheme: "Default 4MB with spiffs" or "Minimal SPIFFS (1.9MB APP)" for larger sketches
   - PSRAM: Enabled
   - Upload Speed: 921600
   - Port: Select USB-C serial port

### Key Libraries

| Library | Purpose | Install via |
|---------|---------|-------------|
| RadioLib | LoRa SX1276/SX1262 radio control | Arduino Library Manager |
| TinyGPSPlus | GPS NMEA parsing | Arduino Library Manager |
| XPowersLib | AXP2101 PMU control | Arduino Library Manager (Lewis He) |
| Wire | I2C (built-in) | Built into ESP32 core |
| U8g2 | OLED display (if connected) | Arduino Library Manager |

### PlatformIO

```ini
[env:tbeam]
platform = espressif32
board = ttgo-t-beam
framework = arduino
monitor_speed = 115200
lib_deps =
    jgromes/RadioLib
    mikalhart/TinyGPSPlus
    lewisxhe/XPowersLib
    olikraus/U8g2
board_build.partitions = default.csv
build_flags =
    -DBOARD_HAS_PSRAM
```

### ESP-IDF

The T-Beam can be programmed with ESP-IDF directly. Use the `esp32` target. You will need to configure SPI, UART, and I2C peripherals manually to match the pin assignments above. ESP-IDF gives full control but requires significantly more setup than Arduino.

## Minimal LoRa Transmit Example (SX1276 with RadioLib)

```cpp
#include <RadioLib.h>

SX1276 radio = new Module(18, 26, 23, 33);  // CS, DIO0, RST, DIO1

void setup() {
    Serial.begin(115200);

    int state = radio.begin(
        915.0,    // frequency (MHz) — use 868.0 for EU
        125.0,    // bandwidth (kHz)
        9,        // spreading factor
        7,        // coding rate (4/7)
        0x12,     // sync word
        17,       // output power (dBm)
        8,        // preamble length
        0         // gain (0 = automatic)
    );

    if (state != RADIOLIB_ERR_NONE) {
        Serial.printf("Radio init failed: %d\n", state);
        while (true);
    }
    Serial.println("Radio initialized");
}

void loop() {
    int state = radio.transmit("Hello LoRa");
    if (state == RADIOLIB_ERR_NONE) {
        Serial.println("TX success");
    } else {
        Serial.printf("TX failed: %d\n", state);
    }
    delay(5000);
}
```

## Meshtastic

The T-Beam v1.2 is one of the officially supported Meshtastic hardware platforms.

### Flashing Meshtastic Firmware

1. Download the latest firmware from https://meshtastic.org/downloads
2. Select the T-Beam variant matching your LoRa chip (SX1276 or SX1262)
3. Flash via the web flasher at https://flasher.meshtastic.org or use `esptool.py`:

```bash
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 \
    --before default_reset --after hard_reset write_flash \
    0x0 firmware-tbeam-X.X.X.bin
```

4. Configure via Meshtastic app (Android/iOS) over Bluetooth or via the Python CLI.

For mesh networking details, see the mesh networking documentation.

## Common Issues and Troubleshooting

### GPS Takes Forever to Get a Fix
- **Cold start**: First fix can take 5-15 minutes, especially indoors. Go outside with clear sky view.
- **Warm start**: After first fix, subsequent fixes are faster (30s-2min) if the GPS has been powered recently.
- **Hot start**: If GPS was powered off briefly (<2 hours), fix is fast (<10s).
- **Tip**: Keep GPS powered (even in low-power mode) to maintain satellite almanac data.
- **Tip**: Ensure the ceramic patch antenna has a clear view of the sky. It will not work reliably indoors.

### Battery Polarity
- The 18650 holder has marked polarity. **Positive (+) faces the USB-C end** on most T-Beam revisions.
- Inserting the battery backwards can damage the PMU. Some boards have reverse-polarity protection, but do not rely on it.
- Use quality flat-top or button-top 18650 cells. Protected cells may be too long for the holder.

### Antenna Selection
- The IPEX connector is fragile. If using the board frequently, solder on an SMA pigtail.
- **Never transmit without an antenna connected** — this can damage the LoRa radio.
- Match antenna frequency to your LoRa band (868 or 915 MHz).
- A 1/4 wave whip antenna is the minimum. A proper tuned antenna dramatically improves range.

### USB Serial Not Detected
- Install CP2102 or CH9102F drivers depending on your board revision.
- Try a different USB-C cable — many cables are charge-only.
- On Linux, you may need to add yourself to the `dialout` group: `sudo usermod -aG dialout $USER`

### OLED Display
- The T-Beam does **not** have a built-in OLED. Some sellers include a small SSD1306 OLED that connects via the I2C header.
- If connecting an OLED: SDA=21, SCL=22, address 0x3C, 128x64 pixels.
- The I2C bus is shared with the AXP2101 PMU — both coexist fine at different addresses.

### AXP2101 vs AXP192
- T-Beam v1.2 uses AXP2101. Earlier versions (v1.0, v1.1) use AXP192.
- The libraries are **not** interchangeable. Use `XPowersLib` which supports both, or check your board version carefully.
- PMU register layouts differ completely between the two chips.

### Boot Loops or Crashes
- Ensure PSRAM is enabled in board settings.
- Check partition scheme — large sketches may not fit in default partition.
- If the LoRa radio fails to initialize, verify your code uses the correct chip (SX1276 vs SX1262) and pins.
- Brown-out detector can trigger on weak USB power — use a quality cable and port.

## Deep Sleep

To minimize power consumption:

```cpp
// Disable LoRa
radio.sleep();

// Disable GPS via PMU
pmu.disableALDO3();

// Configure wakeup source (user button on GPIO38)
esp_sleep_enable_ext0_wakeup(GPIO_NUM_38, 0);  // Wake on LOW

// Or timer wakeup
esp_sleep_enable_timer_wakeup(60 * 1000000ULL);  // 60 seconds

// Enter deep sleep
esp_deep_sleep_start();
```

Typical deep sleep current: ~10 uA (ESP32 only) to ~50 uA (with PMU quiescent current). With GPS and LoRa disabled via PMU, the board draws very little from the 18650.
