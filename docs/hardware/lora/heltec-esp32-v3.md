# Heltec WiFi LoRa 32 V3 Reference

## Overview

The Heltec WiFi LoRa 32 V3 is a compact development board combining an ESP32-S3 microcontroller, Semtech SX1262 LoRa transceiver, and a 0.96" OLED display. It is a popular choice for LoRa projects, Meshtastic nodes, and IoT sensor platforms due to its integrated display, small form factor, and good feature set.

## Specifications

| Component | Detail |
|-----------|--------|
| MCU | ESP32-S3FN8 (or ESP32-S3R8), dual-core Xtensa LX7, 240 MHz |
| Flash | 8 MB (quad SPI) |
| PSRAM | 8 MB (quad SPI, QSPI) |
| LoRa | Semtech SX1262, 868 MHz or 915 MHz variant |
| Display | 0.96" OLED, SSD1306 controller, 128x64 pixels, white or blue |
| USB | USB-C, native USB (ESP32-S3 built-in USB) |
| WiFi | 802.11 b/g/n, 2.4 GHz |
| Bluetooth | BLE 5.0 (ESP32-S3) |
| Battery | JST 1.25mm 2-pin LiPo connector, onboard charging circuit |
| Charging | Via USB-C, ~500mA charge current |
| Antenna (LoRa) | Onboard PCB antenna or IPEX (U.FL) connector (variant dependent) |
| Antenna (WiFi/BT) | Onboard PCB antenna |
| Dimensions | ~50.2 x 25.5 x 10.2 mm |
| Operating voltage | 3.3V logic, 5V USB input, 3.7V LiPo |

## Pinout Reference

### LoRa SPI Interface (SX1262)

| Function | GPIO | Notes |
|----------|------|-------|
| SCK | 9 | SPI clock |
| MISO | 11 | SPI data out (from radio) |
| MOSI | 10 | SPI data in (to radio) |
| CS (NSS) | 8 | Chip select, active low |
| RST | 12 | Radio reset |
| BUSY | 13 | SX1262 busy status |
| DIO1 | 14 | Interrupt line (RX done, TX done, timeout) |

### OLED Display (SSD1306, I2C)

| Function | GPIO | Notes |
|----------|------|-------|
| SDA | 17 | I2C data |
| SCL | 18 | I2C clock |
| RST | 21 | OLED reset — must be toggled HIGH during init |
| Address | 0x3C | 7-bit I2C address |

**Important**: The OLED shares the Vext power rail (see below). You must set GPIO 36 LOW to power the OLED.

### Power Control

| Function | GPIO | Notes |
|----------|------|-------|
| Vext control | 36 | Controls external peripheral power (OLED, sensors). **LOW = ON**, HIGH = OFF |
| ADC battery | 1 | Battery voltage via voltage divider. Read with `analogRead(1)` |
| Battery voltage divider | — | Factor ~2:1. Actual voltage = ADC reading * 2 * 3.3 / 4095 (approximately) |

### User Interface

| Function | GPIO | Notes |
|----------|------|-------|
| User button (PRG) | 0 | Active LOW, directly connected. Also boot mode select. |
| LED | 35 | Onboard white LED |

### Available GPIOs

The Heltec V3 brings out a number of GPIOs on its pin headers. Be aware that many are already used internally.

| GPIO | Location | Notes |
|------|----------|-------|
| 2 | Header | General purpose |
| 3 | Header | General purpose |
| 4 | Header | General purpose |
| 5 | Header | General purpose |
| 6 | Header | General purpose |
| 7 | Header | General purpose |
| 19 | Header | General purpose |
| 20 | Header | UART0 RX (default serial) |
| 26 | Header | Available |
| 33 | Header | Available |
| 34 | Header | Available |
| 38 | Header | Available |
| 39 | Header | Available |
| 40 | Header | Available |
| 41 | Header | Available |
| 42 | Header | Available |
| 43 | Header | UART0 TX (default serial) |
| 44 | Header | Available |
| 45 | Header | Strapping pin — use with care |
| 46 | Header | Strapping pin — use with care |
| 47 | Header | Available |
| 48 | Header | Available |

**Note**: Unlike the original ESP32, the ESP32-S3 does not have input-only pins. All GPIOs support input and output.

## Programming with Arduino IDE

### Board Package Installation

1. Add the Heltec board package URL to Arduino IDE preferences (File -> Preferences -> Additional Board Manager URLs):
   ```
   https://github.com/Heltec-Aaron-Lee/WiFi_Kit_series/releases/download/0.0.9/package_heltec_esp32_index.json
   ```
   Check https://github.com/Heltec-Aaron-Lee/WiFi_Kit_series for the latest URL — it changes with versions.

2. Open Board Manager, search for "Heltec", install **Heltec ESP32 Series Dev-boards**.

3. Select board: **WiFi LoRa 32(V3)** (under Heltec ESP32 Arduino).

4. Settings:
   - Upload Speed: 921600
   - USB CDC On Boot: Enabled (for Serial Monitor over USB-C)
   - Flash Size: 8MB
   - Partition Scheme: 8M with spiffs or custom
   - PSRAM: QSPI PSRAM
   - Port: Select the USB-C serial port

### Key Libraries

| Library | Purpose | Notes |
|---------|---------|-------|
| Heltec ESP32 Dev-Boards | Board support + display + LoRa drivers | Comes with board package |
| RadioLib | Alternative LoRa driver (recommended) | Arduino Library Manager |
| U8g2 or U8x8 | Alternative OLED library | More portable than Heltec library |
| Adafruit SSD1306 | Another OLED option | Arduino Library Manager |

## PlatformIO Configuration

```ini
[env:heltec_v3]
platform = espressif32
board = heltec_wifi_lora_32_V3
framework = arduino
monitor_speed = 115200
lib_deps =
    jgromes/RadioLib
    olikraus/U8g2
build_flags =
    -DARDUINO_USB_CDC_ON_BOOT=1
board_build.partitions = default_8MB.csv
```

**Note**: If you get no serial output, ensure `ARDUINO_USB_CDC_ON_BOOT=1` is set. The ESP32-S3 uses native USB CDC, not a separate UART bridge.

## OLED Display Usage

### With Heltec Library

The Heltec board package includes display support:

```cpp
#include "heltec.h"

void setup() {
    Heltec.begin(
        true,   // Display enable
        true,   // LoRa enable
        true,   // Serial enable
        true,   // PABOOST
        915E6   // LoRa frequency
    );
    Heltec.display->clear();
    Heltec.display->setFont(ArialMT_Plain_10);
    Heltec.display->drawString(0, 0, "Hello LoRa");
    Heltec.display->display();
}
```

### With U8g2 (Recommended for Portability)

```cpp
#include <U8g2lib.h>
#include <Wire.h>

// SSD1306 128x64, I2C, with reset pin
U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0, 21, 18, 17);
// Parameters: rotation, reset=21, clock=18, data=17

void setup() {
    // Power on Vext (OLED power)
    pinMode(36, OUTPUT);
    digitalWrite(36, LOW);  // LOW = power ON
    delay(100);

    u8g2.begin();
    u8g2.clearBuffer();
    u8g2.setFont(u8g2_font_ncenB08_tr);
    u8g2.drawStr(0, 12, "Hello LoRa!");
    u8g2.sendBuffer();
}
```

**Critical**: You MUST set GPIO 36 LOW before initializing the OLED, otherwise the display has no power and init will fail silently.

### Manual I2C Init

If using a generic SSD1306 library:

```cpp
Wire.begin(17, 18);  // SDA=17, SCL=18

// Reset the OLED
pinMode(21, OUTPUT);
digitalWrite(21, LOW);
delay(50);
digitalWrite(21, HIGH);
delay(50);
```

## LoRa with RadioLib

```cpp
#include <RadioLib.h>

SX1262 radio = new Module(8, 14, 12, 13);  // CS, DIO1, RST, BUSY

void setup() {
    Serial.begin(115200);

    int state = radio.begin(
        915.0,    // frequency MHz (868.0 for EU)
        125.0,    // bandwidth kHz
        9,        // spreading factor
        7,        // coding rate 4/7
        0x12,     // sync word
        22,       // output power dBm (SX1262 supports up to +22)
        8,        // preamble length
        1.6,      // TCXO voltage (1.6V for Heltec V3)
        false     // use LDO regulator
    );

    if (state != RADIOLIB_ERR_NONE) {
        Serial.printf("Radio init failed: %d\n", state);
        while (true);
    }
    Serial.println("SX1262 ready");
}

void loop() {
    int state = radio.transmit("Hello from Heltec V3");
    if (state == RADIOLIB_ERR_NONE) {
        Serial.println("TX OK");
    }
    delay(5000);
}
```

**Important RadioLib note for Heltec V3**: The SX1262 on this board uses a TCXO (temperature-compensated crystal oscillator) at 1.6V. You must pass the TCXO voltage parameter or the radio will not initialize correctly. If using older RadioLib examples that omit this parameter, you will get init failures.

## Power Management

### Vext Control

GPIO 36 controls the Vext power rail, which supplies the OLED display and the external header pin labeled "Vext". This allows you to power down the display and external sensors to save battery.

```cpp
// Power ON external peripherals
pinMode(36, OUTPUT);
digitalWrite(36, LOW);   // LOW = ON (counterintuitive but correct)

// Power OFF external peripherals
digitalWrite(36, HIGH);  // HIGH = OFF
```

### Battery Monitoring

```cpp
void setup() {
    analogReadResolution(12);
    // GPIO 1 is connected to battery via voltage divider
}

float getBatteryVoltage() {
    int raw = analogRead(1);
    // Voltage divider ratio is approximately 390k/100k
    // Reference voltage is 3.3V, 12-bit ADC (0-4095)
    float voltage = (raw / 4095.0) * 3.3 * ((390.0 + 100.0) / 100.0);
    return voltage;
}
```

The exact voltage divider ratio may vary slightly. Calibrate against a multimeter reading for accuracy.

### Deep Sleep

```cpp
void enterDeepSleep(uint64_t sleepMicroseconds) {
    // Turn off OLED and peripherals
    digitalWrite(36, HIGH);  // Vext OFF

    // Put radio to sleep
    radio.sleep();

    // Configure wakeup
    esp_sleep_enable_timer_wakeup(sleepMicroseconds);
    // Or wakeup on button press (GPIO 0)
    esp_sleep_enable_ext0_wakeup(GPIO_NUM_0, 0);

    esp_deep_sleep_start();
}
```

### Current Consumption

| State | Approximate Current |
|-------|-------------------|
| Active (WiFi + LoRa + OLED) | ~120-180 mA |
| Active (LoRa TX at +22 dBm) | ~140 mA peak |
| Active (LoRa RX) | ~15-20 mA |
| OLED off, LoRa idle | ~30-50 mA |
| Deep sleep (Vext off, radio sleep) | ~20-30 uA |
| Deep sleep (minimal, all off) | ~10-15 uA |

A typical 1000 mAh LiPo in deep sleep (waking every 5 minutes for a sensor reading + LoRa TX) can last weeks to months depending on TX frequency and duration.

## Common Issues and Troubleshooting

### No Serial Output

The ESP32-S3 uses native USB CDC for serial communication. There is no separate USB-UART bridge chip.

- Ensure **USB CDC On Boot: Enabled** in Arduino IDE board settings, or `-DARDUINO_USB_CDC_ON_BOOT=1` in PlatformIO.
- After flashing, you may need to press the RST button or re-plug USB for the CDC port to enumerate.
- If you are stuck in a boot loop, hold the BOOT (GPIO 0) button while pressing RST to enter download mode.

### OLED Not Working

1. Is Vext enabled? `pinMode(36, OUTPUT); digitalWrite(36, LOW);` — this is the most common cause.
2. Is the reset pin toggled? GPIO 21 must be pulled LOW then HIGH during display init.
3. Correct I2C pins? SDA=17, SCL=18 — NOT the "default" ESP32-S3 I2C pins.
4. Correct address? 0x3C for SSD1306 128x64.

### LoRa Radio Init Fails

- Check that you are passing the TCXO voltage (1.6V) in RadioLib init.
- Verify correct pins: CS=8, DIO1=14, RST=12, BUSY=13.
- Make sure SPI is not conflicting with other peripherals.
- If using the Heltec library, do not simultaneously use RadioLib on the same SPI bus.

### WiFi and LoRa Simultaneously

The ESP32-S3 can run WiFi and LoRa at the same time since they use different radios (WiFi uses the internal radio, LoRa uses the SX1262 over SPI). However, simultaneous heavy WiFi traffic and LoRa operations can cause timing issues. Use interrupts for LoRa and avoid blocking calls.

### Upload Fails

- Hold the BOOT button (GPIO 0) while clicking upload, then release after "Connecting..." appears.
- Some USB-C cables do not support data — try another cable.
- On Linux, ensure you have permissions for the USB device (`/dev/ttyACM0`).
- If using PlatformIO, try reducing upload speed: `upload_speed = 460800`.

### Board Variants

Heltec has released multiple versions of the WiFi LoRa 32 family:
- **V1**: ESP32 + SX1278 (433 MHz). Old, avoid.
- **V2**: ESP32 + SX1276. Still available.
- **V2.1**: Minor revision of V2.
- **V3**: ESP32-S3 + SX1262. Current recommended version.

Pin assignments are **completely different** between V2 and V3. Code written for V2 will not work on V3 without pin changes. Always verify which version you have before using example code.

## Meshtastic on Heltec V3

The Heltec V3 is supported by Meshtastic. Flash using the web flasher at https://flasher.meshtastic.org and select the "Heltec V3" variant. The OLED display shows channel info, messages, and node status.
