# Arduino Framework on ESP32

## Overview

The Arduino framework for ESP32 (arduino-esp32) provides the familiar Arduino API on top of ESP-IDF. It lets you use `setup()`, `loop()`, `digitalWrite()`, `Serial.print()`, and thousands of Arduino-compatible libraries while having access to the full power of the ESP32.

The ESP32 Arduino core is maintained by Espressif and is built on top of ESP-IDF. Version 2.x is based on ESP-IDF v4.4, and version 3.x is based on ESP-IDF v5.x.

---

## Installation in Arduino IDE

### Board Manager Setup

1. Open Arduino IDE
2. Go to File > Preferences (or Arduino IDE > Settings on macOS)
3. In "Additional Board Manager URLs", add:
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
   (If you already have URLs there, separate with a comma)
4. Go to Tools > Board > Boards Manager
5. Search "esp32"
6. Install "esp32 by Espressif Systems"

This installs support for all ESP32 variants (ESP32, S2, S3, C3, C6, H2).

### Board Selection

After installation, go to Tools > Board > ESP32 Arduino and select:

| Your Board | Select |
|-----------|--------|
| Generic ESP32 DevKit | ESP32 Dev Module |
| ESP32-WROVER DevKit | ESP32 Wrover Module |
| NodeMCU-32S | NodeMCU-32S |
| ESP32-S2 DevKit | ESP32S2 Dev Module |
| ESP32-S3 DevKit | ESP32S3 Dev Module |
| ESP32-C3 DevKit | ESP32C3 Dev Module |
| ESP32-C6 DevKit | ESP32C6 Dev Module |
| TTGO T-Display | TTGO T1 or ESP32 Dev Module |
| Heltec WiFi LoRa 32 | Heltec WiFi LoRa 32(V2) or (V3) |
| LILYGO T-Beam | T-Beam |

If your exact board isn't listed, use the generic "Dev Module" for your chip variant. It works fine; you just need to set the flash size and other options manually.

### Key Settings Under Tools Menu

- **Upload Speed:** 921600 (fast) or 115200 (reliable)
- **CPU Frequency:** 240 MHz (full speed) or 80 MHz (power saving)
- **Flash Frequency:** 80 MHz (fast) or 40 MHz (reliable)
- **Flash Mode:** QIO (fast, default) or DIO (compatible)
- **Flash Size:** Match your module (4 MB is most common)
- **Partition Scheme:** See section below
- **PSRAM:** Enable if your board has PSRAM (WROVER modules)
- **Core Debug Level:** None (production) or Verbose (debugging)

---

## GPIO Numbering

Unlike Arduino Uno/Mega where pin numbers are board-specific mappings, ESP32 GPIO numbers correspond directly to the chip's GPIO numbers. `GPIO2` is always referred to as pin `2` in code.

```cpp
// ESP32 GPIO numbering is direct
#define LED_PIN 2    // GPIO2 (built-in LED on many dev boards)
#define BUTTON 0     // GPIO0 (BOOT button on most dev boards)

void setup() {
    pinMode(LED_PIN, OUTPUT);
    pinMode(BUTTON, INPUT_PULLUP);
}

void loop() {
    digitalWrite(LED_PIN, !digitalRead(BUTTON));
}
```

### GPIO Availability Quick Reference (Original ESP32)

| GPIO | Usable? | Notes |
|------|---------|-------|
| 0 | Yes* | Strapping pin (boot mode). Has pull-up. Don't hold LOW at boot. |
| 1 | Yes* | TX0 (default Serial). Outputs debug at boot. |
| 2 | Yes* | Strapping pin. Must be LOW or floating for flash download. Built-in LED on many boards. |
| 3 | Yes* | RX0 (default Serial). HIGH at boot. |
| 4 | Yes | Safe to use |
| 5 | Yes* | Strapping pin. Outputs PWM at boot. |
| 6-11 | NO | Connected to SPI flash. Do not use. |
| 12 | Yes* | Strapping pin (MTDI). Affects flash voltage. Pull LOW if using 3.3V flash. |
| 13 | Yes | Safe to use |
| 14 | Yes | Outputs PWM at boot |
| 15 | Yes* | Strapping pin (MTDO). Outputs PWM at boot. |
| 16-17 | Yes* | Used for PSRAM on WROVER. Free on WROOM. |
| 18-19 | Yes | Safe to use (common SPI pins) |
| 21-23 | Yes | Safe to use (21=SDA, 22=SCL default I2C) |
| 25-27 | Yes | Safe to use (25, 26 are DAC channels) |
| 32-33 | Yes | Safe to use (ADC1) |
| 34-39 | Input only | No pull-up/pull-down. ADC1. GPIO36=VP, GPIO39=VN. |

**Safest general-purpose pins:** 4, 13, 14, 16, 17 (if no PSRAM), 18, 19, 21, 22, 23, 25, 26, 27, 32, 33.

---

## Key Differences from AVR Arduino

### Voltage Levels
- ESP32 is **3.3V only**. Applying 5V to any GPIO will damage the chip.
- Use level shifters for 5V sensors/actuators, or choose 3.3V-compatible components.

### PWM (LEDC)
ESP32 doesn't use `analogWrite()` in the same way as AVR. It uses the LEDC peripheral:

```cpp
// Arduino-ESP32 v3.x (ESP-IDF v5 based)
// analogWrite works directly now
analogWrite(LED_PIN, 128);   // 0-255, just like AVR
analogWriteFrequency(LED_PIN, 5000);  // Set frequency
analogWriteResolution(LED_PIN, 10);    // 10-bit (0-1023)

// Or use the LEDC API directly for more control
#include "esp32-hal-ledc.h"
ledcAttach(LED_PIN, 5000, 8);     // pin, freq, resolution_bits
ledcWrite(LED_PIN, 128);          // duty 0-255 for 8-bit
```

### ADC
```cpp
// Basic analog read
int value = analogRead(34);    // 0-4095 (12-bit)

// Set attenuation for full 3.3V range
analogSetAttenuation(ADC_11db);  // 0-3.3V range
// Other options: ADC_0db (0-1.1V), ADC_2_5db (0-1.5V), ADC_6db (0-2.2V)

// Per-pin attenuation
analogSetPinAttenuation(34, ADC_11db);

// Read millivolts (calibrated)
int mv = analogReadMilliVolts(34);
```

**Remember:** ADC2 pins (GPIO0, 2, 4, 12-15, 25-27) cannot be used while WiFi is active.

### Serial Ports
ESP32 has 3 hardware UARTs:

```cpp
// Serial  = UART0 (USB, GPIO1=TX, GPIO3=RX) - used for programming/debug
// Serial1 = UART1 (default GPIO9=TX, GPIO10=RX - but these are flash pins!)
// Serial2 = UART2 (default GPIO17=TX, GPIO16=RX)

// Remap Serial1 to safe pins
Serial1.begin(9600, SERIAL_8N1, 26, 27);  // RX=26, TX=27

// Serial2 is safe on WROOM (GPIO16/17 are free)
Serial2.begin(9600);
```

### Interrupts
All GPIOs can be used as interrupt pins (not just specific pins like on AVR):

```cpp
volatile bool flag = false;

void IRAM_ATTR handleInterrupt() {
    flag = true;
}

void setup() {
    pinMode(4, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(4), handleInterrupt, FALLING);
}
```

The `IRAM_ATTR` attribute is important: it places the ISR in IRAM so it can execute even when flash is being accessed.

### Timing
```cpp
// millis() and micros() work as expected
unsigned long now = millis();

// delay() and delayMicroseconds() work
delay(1000);
delayMicroseconds(100);

// But delay() yields to FreeRTOS, which is usually what you want.
// For busy-wait (rare, avoid if possible):
ets_delay_us(100);
```

---

## Dual Core Programming

The ESP32 (original and S3) has two cores. By default, Arduino `setup()` and `loop()` run on core 1. WiFi runs on core 0. You can create tasks pinned to specific cores:

```cpp
TaskHandle_t sensorTask;
TaskHandle_t displayTask;

void sensorTaskFunction(void *parameter) {
    for (;;) {
        // Read sensors on core 0
        float temp = readTemperature();

        // Use a mutex or queue to share data safely
        xQueueSend(dataQueue, &temp, portMAX_DELAY);

        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}

void displayTaskFunction(void *parameter) {
    for (;;) {
        float temp;
        if (xQueueReceive(dataQueue, &temp, portMAX_DELAY)) {
            updateDisplay(temp);
        }
    }
}

QueueHandle_t dataQueue;

void setup() {
    Serial.begin(115200);

    dataQueue = xQueueCreate(10, sizeof(float));

    xTaskCreatePinnedToCore(
        sensorTaskFunction,   // Function
        "SensorTask",         // Name (for debugging)
        4096,                 // Stack size (bytes)
        NULL,                 // Parameter to pass
        1,                    // Priority (0 = lowest, configMAX_PRIORITIES-1 = highest)
        &sensorTask,          // Task handle
        0                     // Core (0 or 1)
    );

    xTaskCreatePinnedToCore(
        displayTaskFunction,
        "DisplayTask",
        4096,
        NULL,
        1,
        &displayTask,
        1                     // Run on core 1
    );
}

void loop() {
    // loop() is also on core 1
    // Can be empty if all work is in tasks
    vTaskDelay(pdMS_TO_TICKS(1000));
}
```

### Important Rules for Multi-Core

- **Never share variables between tasks without synchronization.** Use queues, semaphores, or mutexes.
- Core 0 runs the WiFi/BT stack and the system event loop. CPU-intensive tasks on core 0 can cause WiFi disconnections.
- Keep ISRs short and use task notifications or queues to do the real work in a task.
- Default stack size for `loop()` is 8192 bytes. Custom tasks may need more or less.

---

## Partition Scheme Selection

In Arduino IDE: Tools > Partition Scheme

| Scheme | App Size | SPIFFS/LittleFS | OTA | Good For |
|--------|----------|-----------------|-----|----------|
| Default 4MB | 1.2 MB | 1.5 MB | No | Simple projects with filesystem |
| No OTA (2MB APP / 2MB SPIFFS) | 2 MB | 2 MB | No | Large code + large filesystem |
| Huge APP (3MB) | 3 MB | 1 MB | No | Large code (BLE + WiFi + display) |
| Minimal SPIFFS (1.9MB APP with OTA) | 1.9 MB | 128 KB | Yes | OTA-capable with good code space |
| 16MB Flash (various) | varies | varies | varies | Boards with 16 MB flash |

**Tip:** If your sketch compiles but fails to upload with "sketch too large", switch to a larger app partition. BLE + WiFi together can exceed 1.2 MB.

In PlatformIO:
```ini
board_build.partitions = huge_app.csv
```

---

## WiFi Libraries (Built-in)

The ESP32 Arduino core includes these WiFi-related libraries:

```cpp
#include <WiFi.h>          // WiFi station and AP
#include <WiFiClient.h>    // TCP client
#include <WiFiServer.h>    // TCP server
#include <WebServer.h>     // HTTP server
#include <HTTPClient.h>    // HTTP client
#include <WiFiClientSecure.h>  // HTTPS client
#include <ESPmDNS.h>       // mDNS responder
#include <WiFiUdp.h>       // UDP
#include <ArduinoOTA.h>    // OTA updates
```

---

## BLE Libraries (Built-in)

```cpp
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>       // CCCD descriptor for notifications

// Or use NimBLE (smaller, faster - install separately)
#include <NimBLEDevice.h>
```

---

## SPIFFS and LittleFS

```cpp
// SPIFFS (legacy, no directories)
#include <SPIFFS.h>

void setup() {
    if (!SPIFFS.begin(true)) {  // true = format on fail
        Serial.println("SPIFFS mount failed");
        return;
    }

    // Write
    File file = SPIFFS.open("/config.txt", FILE_WRITE);
    file.println("key=value");
    file.close();

    // Read
    file = SPIFFS.open("/config.txt", FILE_READ);
    while (file.available()) {
        Serial.write(file.read());
    }
    file.close();

    // Info
    Serial.printf("Total: %u bytes, Used: %u bytes\n",
        SPIFFS.totalBytes(), SPIFFS.usedBytes());
}

// LittleFS (recommended - supports directories, wear leveling, power-fail safe)
#include <LittleFS.h>

void setup() {
    if (!LittleFS.begin(true)) {
        Serial.println("LittleFS mount failed");
        return;
    }

    // Same API as SPIFFS
    File file = LittleFS.open("/data/sensor.csv", FILE_WRITE);
    // ... etc

    // Directory support
    LittleFS.mkdir("/data");
    File root = LittleFS.open("/");
    File entry = root.openNextFile();
    while (entry) {
        Serial.printf("  %s (%d bytes)\n", entry.name(), entry.size());
        entry = root.openNextFile();
    }
}
```

Upload files to the filesystem:
- **Arduino IDE:** Install the "ESP32 LittleFS Upload" plugin. Create a `data/` folder in your sketch directory, put files in it, then Tools > ESP32 Sketch Data Upload.
- **PlatformIO:** Put files in `data/` directory, run `pio run -t uploadfs`.

---

## Preferences (Non-Volatile Storage)

The `Preferences` library provides key-value storage in NVS (non-volatile storage) flash partition. Survives reboots and reflashing.

```cpp
#include <Preferences.h>

Preferences prefs;

void setup() {
    Serial.begin(115200);

    prefs.begin("my-app", false);  // namespace, readOnly

    // Read (with default value if key doesn't exist)
    unsigned int bootCount = prefs.getUInt("boots", 0);
    bootCount++;
    prefs.putUInt("boots", bootCount);

    String ssid = prefs.getString("ssid", "default_ssid");
    float calibration = prefs.getFloat("cal_factor", 1.0);

    // Write
    prefs.putString("ssid", "MyNetwork");
    prefs.putFloat("cal_factor", 1.023);

    // Other types
    prefs.putBool("configured", true);
    prefs.putBytes("key", data, length);  // Binary blob

    // Clear all keys in namespace
    // prefs.clear();

    // Remove single key
    // prefs.remove("ssid");

    prefs.end();

    Serial.printf("Boot #%u\n", bootCount);
}
```

Preferences are stored in the NVS partition (default 24 KB). Each key-value pair uses ~40 bytes of overhead plus the value size. Don't store large blobs here; use SPIFFS/LittleFS for files.

---

## Accessing ESP-IDF APIs from Arduino

You can call ESP-IDF functions directly from Arduino code:

```cpp
#include "esp_system.h"
#include "esp_sleep.h"
#include "esp_wifi.h"
#include "driver/adc.h"
#include "esp_adc_cal.h"

void setup() {
    Serial.begin(115200);

    // ESP-IDF chip info
    esp_chip_info_t chip;
    esp_chip_info(&chip);
    Serial.printf("Chip: %d cores, rev %d\n", chip.cores, chip.revision);
    Serial.printf("Flash: %d MB\n", spi_flash_get_chip_size() / (1024 * 1024));
    Serial.printf("Free heap: %d bytes\n", esp_get_free_heap_size());
    Serial.printf("MAC: ");

    uint8_t mac[6];
    esp_read_mac(mac, ESP_MAC_WIFI_STA);
    Serial.printf("%02X:%02X:%02X:%02X:%02X:%02X\n",
        mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);

    // Configure deep sleep via ESP-IDF API
    esp_sleep_enable_timer_wakeup(5 * 1000000);  // 5 seconds
    // esp_deep_sleep_start();
}
```

---

## Common Gotchas

### 1. WiFi + Bluetooth Together = Large Binary
Enabling both WiFi and BLE can produce binaries exceeding 1.2 MB. Use "Huge APP" or "Minimal SPIFFS" partition scheme.

### 2. analogRead Returns 0 on ADC2 Pins with WiFi
Use ADC1 pins (GPIO32-39) if WiFi is active. ADC2 is shared with the WiFi radio.

### 3. Serial Output at Boot
The ESP32 outputs boot messages at 115200 baud on UART0 (USB serial). If you use a different baud rate, you'll see garbage at the start. This is normal.

### 4. GPIO Behavior During Boot
Some GPIOs output pulses or have specific states during boot due to the strapping pin configuration. This can cause relays to click or LEDs to flash at startup. For critical outputs, use GPIOs that are stable at boot (like GPIO4).

### 5. watchdog Timer
Long `while` loops without `delay()` or `yield()` will trigger the watchdog timer reset. Always include at least `delay(1)` or `yield()` in tight loops.

### 6. String Fragmentation
Heavy use of `String` class leads to heap fragmentation on ESP32 just like on AVR, but it's less likely to be fatal due to more RAM. Still prefer `char[]` and `snprintf()` for production code.

### 7. PSRAM
If your board has PSRAM, enable it (Tools > PSRAM > Enabled). Then large allocations automatically use PSRAM:
```cpp
// Force allocation in PSRAM
uint8_t *buffer = (uint8_t *)ps_malloc(500000);

// Check available PSRAM
Serial.printf("PSRAM: %d bytes free\n", ESP.getFreePsram());
```

### 8. Core Panics and Crashes
If your ESP32 keeps rebooting and printing a backtrace, copy the hex addresses and use the ESP Exception Decoder (Arduino IDE plugin or PlatformIO's `esp32_exception_decoder` monitor filter) to find the crash location in your code.
