# ESP32 Family Overview and Comparison

## Introduction

The ESP32 family from Espressif Systems is a line of low-cost, low-power system-on-chip (SoC) microcontrollers with integrated WiFi and (in most variants) Bluetooth. They are the backbone of countless IoT, embedded, and off-grid projects due to their combination of wireless connectivity, processing power, rich peripherals, and low price.

This document covers every major variant in the ESP32 family, their technical specifications, and practical guidance on which to choose.

---

## ESP32 (Original)

The original ESP32, released in 2016, remains the most widely used variant. It is a general-purpose workhorse.

### Key Specifications

- **CPU:** Xtensa LX6 dual-core, up to 240 MHz
- **RAM:** 520 KB SRAM
- **Flash:** External, typically 4 MB (up to 16 MB)
- **PSRAM:** Supported on WROVER modules (up to 8 MB)
- **WiFi:** 802.11 b/g/n, 2.4 GHz
- **Bluetooth:** Classic BT 4.2 + BLE 4.2
- **GPIO:** 34 pins (not all exposed on every module)
- **ADC:** 18 channels, 12-bit resolution (two ADC units: ADC1 with 8 channels, ADC2 with 10 channels)
- **DAC:** 2 channels, 8-bit (GPIO25, GPIO26)
- **I2C:** 2 buses
- **SPI:** 3 buses (SPI0/SPI1 used for flash; SPI2/HSPI and SPI3/VSPI available for user)
- **UART:** 3 ports
- **Touch:** 10 capacitive touch pins
- **Hall Sensor:** Built-in (low sensitivity, useful for detecting strong magnets)
- **Other:** PWM (via LEDC, 16 channels), I2S (2 buses), RMT (8 channels), SDMMC, Ethernet MAC
- **Operating voltage:** 3.3V (do NOT apply 5V to GPIO pins)
- **Deep sleep current:** ~10 uA (with RTC timer wakeup)

### Common Modules and Dev Boards

| Module | PSRAM | Flash | Antenna | Notes |
|--------|-------|-------|---------|-------|
| ESP32-WROOM-32 | No | 4 MB | PCB antenna | Most common, cheapest |
| ESP32-WROOM-32D | No | 4-16 MB | PCB antenna | Updated version of WROOM-32 |
| ESP32-WROVER | 8 MB | 4-16 MB | PCB antenna | Use for camera, large buffers |
| ESP32-WROVER-B | 8 MB | 4-16 MB | PCB or IPEX | Improved WROVER |

**Dev boards:** ESP32-DevKitC (Espressif), NodeMCU-32S, TTGO T-Display, Heltec WiFi Kit 32, LILYGO T-Beam (GPS+LoRa).

### ADC Caveats (Important)

- ADC2 **cannot be used while WiFi is active**. If you need analog reads during WiFi operation, use only ADC1 (GPIO32-39).
- The ADC is nonlinear at the extremes of its range. For accurate readings, use `esp_adc_cal` calibration functions or apply a lookup table.
- Input range depends on attenuation setting:
  - 0 dB: 0-1.1V
  - 2.5 dB: 0-1.5V
  - 6 dB: 0-2.2V
  - 11 dB: 0-3.3V (most common, but least accurate)

---

## ESP32-S2

Released in 2020 as a cost-reduced, security-focused variant.

### Key Specifications

- **CPU:** Xtensa LX7 single-core, up to 240 MHz
- **RAM:** 320 KB SRAM
- **Flash:** External, typically 4 MB
- **PSRAM:** Supported (up to 8 MB)
- **WiFi:** 802.11 b/g/n, 2.4 GHz
- **Bluetooth:** None
- **USB:** USB OTG 1.1 (native USB, no external chip needed)
- **GPIO:** 43 pins
- **ADC:** 20 channels, 13-bit resolution
- **DAC:** 2 channels, 8-bit
- **I2C:** 2 buses
- **SPI:** 4 buses (2 available for user)
- **UART:** 2 ports
- **Touch:** 14 capacitive touch pins
- **Security:** Secure boot v2, flash encryption, hardware crypto accelerator
- **Deep sleep current:** ~5 uA

### When to Use ESP32-S2

- Projects that need USB HID (keyboard, mouse emulation) or USB mass storage
- Security-critical applications (secure boot, flash encryption)
- No Bluetooth needed
- Lower power consumption than original ESP32
- Better ADC resolution (13-bit vs 12-bit)

### When NOT to Use ESP32-S2

- If you need Bluetooth of any kind
- If you need dual-core processing
- If you need high GPIO interrupt throughput (single core limits ISR handling)

---

## ESP32-S3

Released in 2021, the current flagship. Best for applications needing processing power, AI/ML, cameras, and displays.

### Key Specifications

- **CPU:** Xtensa LX7 dual-core, up to 240 MHz
- **RAM:** 512 KB SRAM
- **Flash:** External, typically 4-16 MB (some modules have 8 MB octal flash)
- **PSRAM:** Supported, up to 8 MB octal PSRAM (faster than quad PSRAM)
- **WiFi:** 802.11 b/g/n, 2.4 GHz
- **Bluetooth:** BLE 5.0 (no classic BT)
- **USB:** USB OTG 1.1 (native) + USB Serial/JTAG
- **GPIO:** 45 pins
- **ADC:** 20 channels, 12-bit
- **DAC:** None (removed in S3)
- **I2C:** 2 buses
- **SPI:** 4 buses (2 available for user)
- **UART:** 3 ports
- **Touch:** 14 capacitive touch pins
- **AI Acceleration:** Vector instructions for neural network inference (up to 3x faster than S2 for ML tasks)
- **LCD/Camera interfaces:** Dedicated parallel interfaces for camera (DVP) and LCD (8/16-bit parallel)
- **Deep sleep current:** ~7 uA

### When to Use ESP32-S3

- Camera projects (ESP-CAM successor, OV2640/OV5640)
- TFT display projects (parallel RGB displays)
- Edge AI / TinyML (person detection, keyword spotting, gesture recognition)
- Projects needing both WiFi and BLE 5.0
- USB applications
- Any project that would benefit from PSRAM (large buffers, web servers with assets)

### Notable S3 Boards

- **ESP32-S3-DevKitC-1:** Espressif reference board
- **LILYGO T-Display-S3:** Built-in 1.9" TFT, great for sensor displays
- **ESP32-S3-EYE:** Camera + mic + display for AI demos
- **Seeed Studio XIAO ESP32S3 Sense:** Tiny form factor with camera

---

## ESP32-C3

Released in 2021, the budget option for simple IoT devices.

### Key Specifications

- **CPU:** RISC-V single-core, 160 MHz
- **RAM:** 400 KB SRAM
- **Flash:** External, typically 4 MB
- **PSRAM:** Not supported
- **WiFi:** 802.11 b/g/n, 2.4 GHz
- **Bluetooth:** BLE 5.0 (no classic BT)
- **USB:** USB Serial/JTAG (for programming/debug only, not OTG)
- **GPIO:** 22 pins
- **ADC:** 6 channels, 12-bit (2 on ADC1, 4 on ADC2)
- **DAC:** None
- **I2C:** 1 bus
- **SPI:** 3 buses (1 available for user)
- **UART:** 2 ports
- **Touch:** None
- **Deep sleep current:** ~5 uA
- **Price:** Lowest in the ESP32 family (~$1-2 in quantity)

### When to Use ESP32-C3

- Simple IoT sensors (temperature, humidity, soil moisture)
- WiFi-connected relays and switches
- BLE beacons or BLE sensor nodes
- Cost-sensitive mass production
- Projects where a full ESP32 is overkill
- Open-source RISC-V advocacy

### When NOT to Use ESP32-C3

- Camera or display projects (insufficient RAM, no PSRAM)
- Projects needing many GPIO pins
- Audio processing (no I2S on some early revisions, limited CPU)
- Projects needing classic Bluetooth (SPP)

---

## ESP32-C6

Released in 2023, the connectivity-focused variant supporting the latest wireless standards.

### Key Specifications

- **CPU:** RISC-V single-core, 160 MHz (high-power core) + RISC-V low-power core
- **RAM:** 512 KB SRAM
- **Flash:** External, typically 4 MB
- **PSRAM:** Not supported
- **WiFi:** 802.11ax (WiFi 6), 2.4 GHz
- **Bluetooth:** BLE 5.0
- **802.15.4:** Thread and Zigbee support (same radio as used in Matter/Thread smart home devices)
- **USB:** USB Serial/JTAG
- **GPIO:** 30 pins
- **ADC:** 7 channels, 12-bit
- **DAC:** None
- **I2C:** 2 buses
- **SPI:** 1 bus available for user
- **UART:** 3 ports
- **Deep sleep current:** ~7 uA

### When to Use ESP32-C6

- Matter/Thread smart home devices
- Zigbee networks (mesh sensor networks)
- WiFi 6 applications (better performance in congested environments)
- Bridge between Zigbee/Thread and WiFi
- Future-proofing IoT deployments

---

## Family Comparison Table

| Feature | ESP32 | ESP32-S2 | ESP32-S3 | ESP32-C3 | ESP32-C6 |
|---------|-------|----------|----------|----------|----------|
| **Architecture** | Xtensa LX6 | Xtensa LX7 | Xtensa LX7 | RISC-V | RISC-V |
| **Cores** | 2 | 1 | 2 | 1 | 1 (+LP core) |
| **Max Frequency** | 240 MHz | 240 MHz | 240 MHz | 160 MHz | 160 MHz |
| **SRAM** | 520 KB | 320 KB | 512 KB | 400 KB | 512 KB |
| **PSRAM Support** | Yes (8 MB) | Yes (8 MB) | Yes (8 MB octal) | No | No |
| **Flash** | 4-16 MB | 4-16 MB | 4-16 MB | 4 MB | 4 MB |
| **WiFi** | 802.11n | 802.11n | 802.11n | 802.11n | 802.11ax (WiFi 6) |
| **Classic BT** | Yes (4.2) | No | No | No | No |
| **BLE** | 4.2 | No | 5.0 | 5.0 | 5.0 |
| **802.15.4** | No | No | No | No | Yes |
| **USB OTG** | No | Yes | Yes | No | No |
| **GPIO** | 34 | 43 | 45 | 22 | 30 |
| **ADC Channels** | 18 (12-bit) | 20 (13-bit) | 20 (12-bit) | 6 (12-bit) | 7 (12-bit) |
| **DAC** | 2 (8-bit) | 2 (8-bit) | None | None | None |
| **Touch Pins** | 10 | 14 | 14 | None | None |
| **I2C** | 2 | 2 | 2 | 1 | 2 |
| **SPI (user)** | 2 | 2 | 2 | 1 | 1 |
| **UART** | 3 | 2 | 3 | 2 | 3 |
| **Hall Sensor** | Yes | No | No | No | No |
| **Deep Sleep** | ~10 uA | ~5 uA | ~7 uA | ~5 uA | ~7 uA |
| **Price (module)** | $2-4 | $2-3 | $3-5 | $1-2 | $2-4 |

---

## Quick Selection Guide

### Choose ESP32 (Original) When:
- You need **classic Bluetooth** (SPP serial, A2DP audio)
- General-purpose projects with plenty of GPIO
- You want the widest community support, most tutorials, most libraries
- You need DAC output (audio, analog signal generation)
- Budget is moderate and complexity is medium

### Choose ESP32-S2 When:
- You need **USB device capability** without Bluetooth
- Security is paramount (secure boot v2)
- You need better ADC resolution (13-bit)
- Lower power than original ESP32 is important
- Cost is a concern and BT is not needed

### Choose ESP32-S3 When:
- **Camera or display** projects
- **AI/ML at the edge** (keyword detection, image classification)
- You need the most processing power in the family
- You need BLE 5.0 + WiFi simultaneously
- Large memory buffers (octal PSRAM)

### Choose ESP32-C3 When:
- **Simple IoT nodes** (sensors, switches, relays)
- **Cost is the primary concern**
- You want RISC-V
- BLE beacons or simple BLE peripherals
- Small form factor boards available

### Choose ESP32-C6 When:
- **Smart home / Matter / Thread** devices
- **Zigbee mesh** networks
- You need to bridge Thread/Zigbee to WiFi
- WiFi 6 is beneficial (dense AP environments)

---

## Common Pinout Notes (All Variants)

- **Strapping pins** exist on all variants. These pins determine boot mode at startup. Do not connect loads that pull them to unexpected levels during boot. On the original ESP32: GPIO0, GPIO2, GPIO5, GPIO12, GPIO15.
- **Input-only pins** on original ESP32: GPIO34, GPIO35, GPIO36, GPIO39 (no internal pull-up/pull-down).
- **Flash-connected pins:** On modules with quad SPI flash, GPIO6-11 are used for the flash chip and are **not available**. On octal flash/PSRAM modules (some S3), additional GPIOs are consumed.
- **USB pins** on S2/S3: GPIO19 (D-) and GPIO20 (D+) are reserved for USB.
- Always consult the specific module datasheet for which GPIOs are actually broken out.

---

## Power Supply Considerations

- All ESP32 variants run on 3.3V. Dev boards typically include a 3.3V LDO regulator.
- Peak current draw during WiFi TX bursts can reach **300-500 mA**. Your power supply must handle this.
- For battery projects, use an LDO or buck converter rated for at least 600 mA.
- A 100 uF + 10 uF capacitor near the power pins is strongly recommended for stable operation, especially with thin wires or long USB cables.
- When powered from batteries (LiPo 3.7V), you need a regulator. Direct connection risks overvoltage (4.2V fully charged) which can damage the chip.

---

## References

- Espressif Product Comparison: https://products.espressif.com/
- ESP32 Technical Reference Manual: https://www.espressif.com/sites/default/files/documentation/esp32_technical_reference_manual_en.pdf
- ESP32-S3 Datasheet: https://www.espressif.com/sites/default/files/documentation/esp32-s3_datasheet_en.pdf
- ESP32-C3 Datasheet: https://www.espressif.com/sites/default/files/documentation/esp32-c3_datasheet_en.pdf
