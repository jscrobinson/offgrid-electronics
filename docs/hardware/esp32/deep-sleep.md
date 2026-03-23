# ESP32 Deep Sleep and Power Management

## Sleep Mode Overview

The ESP32 provides multiple sleep modes, each trading responsiveness for power savings.

| Mode | CPU | WiFi/BT | RAM | RTC | Wakeup Time | Current (ESP32) |
|------|-----|---------|-----|-----|-------------|-----------------|
| Active | Running | Available | Powered | On | N/A | 80-260 mA |
| Modem Sleep | Running | Radio off between beacons | Powered | On | Instant | 20-30 mA |
| Light Sleep | Paused | Radio off | Powered | On | ~1 ms | 0.8-2 mA |
| Deep Sleep | Off | Off | Off* | On | ~10 ms | 10-150 uA |
| Hibernation | Off | Off | Off | Minimal | ~10 ms | 2.5-5 uA |

*In deep sleep, main SRAM is powered off. Only 8 KB RTC SRAM is retained.

### Current Consumption by Variant

| Variant | Deep Sleep (timer) | Deep Sleep (GPIO) | Hibernation |
|---------|-------------------|-------------------|-------------|
| ESP32 | ~10 uA | ~5 uA (ext0) | ~2.5 uA |
| ESP32-S2 | ~5 uA | ~5 uA | ~1 uA |
| ESP32-S3 | ~7 uA | ~7 uA | ~3 uA |
| ESP32-C3 | ~5 uA | ~5 uA | ~1 uA |
| ESP32-C6 | ~7 uA | ~7 uA | ~2 uA |

**Note:** These are chip-only figures. Dev boards draw much more (5-20 mA) due to USB-UART chips, LEDs, voltage regulators, etc. For battery operation, use bare modules or boards designed for low power (like the FireBeetle ESP32).

---

## Modem Sleep

WiFi modem powers down between DTIM beacon intervals. The CPU stays running. This is the default behavior when connected to WiFi.

```cpp
#include <WiFi.h>

void setup() {
    WiFi.begin("SSID", "password");
    while (WiFi.status() != WL_CONNECTED) delay(500);

    // Modem sleep is enabled by default
    // Explicitly set it:
    WiFi.setSleep(true);

    // Or disable for lowest latency (highest power):
    // WiFi.setSleep(false);
}
```

### WiFi Power Save Modes (ESP-IDF Level)

```cpp
#include "esp_wifi.h"

// Minimum power save (default when WiFi.setSleep(true))
esp_wifi_set_ps(WIFI_PS_MIN_MODEM);
// Radio wakes at every DTIM beacon

// Maximum power save
esp_wifi_set_ps(WIFI_PS_MAX_MODEM);
// Radio wakes less frequently, higher latency

// No power save
esp_wifi_set_ps(WIFI_PS_NONE);
// Radio always on, lowest latency, highest power
```

---

## Light Sleep

CPU pauses, RAM is retained, peripherals pause. Wakes quickly (~1 ms). WiFi connection can be maintained (with increased latency).

```cpp
#include "esp_sleep.h"
#include "esp_pm.h"

void enableLightSleep() {
    // Enable automatic light sleep
    esp_pm_config_esp32_t pm_config = {
        .max_freq_mhz = 240,
        .min_freq_mhz = 80,   // Can go as low as 10 for more savings
        .light_sleep_enable = true
    };
    ESP_ERROR_CHECK(esp_pm_configure(&pm_config));

    // With WiFi, use max modem power save
    esp_wifi_set_ps(WIFI_PS_MAX_MODEM);
}

// The system will automatically enter light sleep when all tasks are idle
// and wake up for WiFi beacons, timer events, GPIO events, etc.
```

### Manual Light Sleep

```cpp
void enterLightSleep(uint64_t sleep_us) {
    esp_sleep_enable_timer_wakeup(sleep_us);
    esp_light_sleep_start();  // Blocks until wakeup

    // Execution continues here after waking
    Serial.println("Woke from light sleep");
}
```

---

## Deep Sleep

Main CPU and most peripherals are powered off. Only RTC controller, RTC memory (8 KB), and selected wakeup sources remain active. On wakeup, the ESP32 reboots from scratch (setup() runs again).

### Timer Wakeup

Most common deep sleep pattern: wake up periodically to do something.

```cpp
#define uS_TO_S_FACTOR 1000000ULL

void setup() {
    Serial.begin(115200);

    // Check wakeup reason
    esp_sleep_wakeup_cause_t reason = esp_sleep_get_wakeup_cause();
    switch (reason) {
        case ESP_SLEEP_WAKEUP_TIMER:
            Serial.println("Woke up from timer");
            break;
        case ESP_SLEEP_WAKEUP_EXT0:
            Serial.println("Woke up from external signal (ext0)");
            break;
        case ESP_SLEEP_WAKEUP_EXT1:
            Serial.println("Woke up from external signal (ext1)");
            break;
        case ESP_SLEEP_WAKEUP_TOUCHPAD:
            Serial.println("Woke up from touch");
            break;
        case ESP_SLEEP_WAKEUP_ULP:
            Serial.println("Woke up from ULP");
            break;
        default:
            Serial.println("Normal boot (not from deep sleep)");
            break;
    }

    // Do work here (read sensor, transmit, etc.)
    doSensorWork();

    // Configure timer wakeup: 5 minutes
    esp_sleep_enable_timer_wakeup(5 * 60 * uS_TO_S_FACTOR);

    Serial.println("Going to sleep for 5 minutes...");
    Serial.flush();  // Wait for serial output to complete

    esp_deep_sleep_start();
    // Code below here never executes
}

void loop() {
    // Never reached in deep sleep pattern
}
```

### ext0 Wakeup (Single GPIO)

Wake when a single RTC GPIO reaches a specified level. Supports internal pull-up/pull-down.

```cpp
#define WAKEUP_PIN GPIO_NUM_33  // Must be an RTC GPIO

void setup() {
    // Wake when pin goes HIGH
    esp_sleep_enable_ext0_wakeup(WAKEUP_PIN, 1);  // 1 = HIGH, 0 = LOW

    // Enable internal pull-down (so pin stays LOW when button not pressed)
    rtc_gpio_pulldown_en(WAKEUP_PIN);
    rtc_gpio_pullup_dis(WAKEUP_PIN);

    Serial.println("Going to sleep. Press button to wake.");
    Serial.flush();
    esp_deep_sleep_start();
}
```

RTC GPIOs on original ESP32:
- GPIO0, GPIO2, GPIO4, GPIO12-15, GPIO25-27, GPIO32-39
- (Not all GPIOs are RTC-capable. Only these work for deep sleep wakeup.)

### ext1 Wakeup (Multiple GPIOs)

Wake when any one (or all) of several GPIOs trigger.

```cpp
#define BUTTON1_PIN GPIO_NUM_33
#define BUTTON2_PIN GPIO_NUM_34
#define BUTTON3_PIN GPIO_NUM_35

void setup() {
    // Create bitmask of pins
    uint64_t bitmask = (1ULL << BUTTON1_PIN) |
                       (1ULL << BUTTON2_PIN) |
                       (1ULL << BUTTON3_PIN);

    // ESP_EXT1_WAKEUP_ANY_HIGH: wake if ANY pin goes HIGH
    // ESP_EXT1_WAKEUP_ALL_LOW: wake when ALL pins go LOW
    esp_sleep_enable_ext1_wakeup(bitmask, ESP_EXT1_WAKEUP_ANY_HIGH);

    Serial.println("Sleeping. Press any button to wake.");
    Serial.flush();
    esp_deep_sleep_start();
}

// After waking, find which pin triggered:
void checkWhichButton() {
    uint64_t wakeupBit = esp_sleep_get_ext1_wakeup_status();
    if (wakeupBit & (1ULL << BUTTON1_PIN)) Serial.println("Button 1");
    if (wakeupBit & (1ULL << BUTTON2_PIN)) Serial.println("Button 2");
    if (wakeupBit & (1ULL << BUTTON3_PIN)) Serial.println("Button 3");
}
```

### Touch Wakeup

```cpp
#define TOUCH_PIN T3  // GPIO15 (touch pin 3)
#define TOUCH_THRESHOLD 40  // Lower = more sensitive

void setup() {
    touchAttachInterrupt(TOUCH_PIN, [](){}, TOUCH_THRESHOLD);
    esp_sleep_enable_touchpad_wakeup();

    Serial.println("Touch the pad to wake up");
    Serial.flush();
    esp_deep_sleep_start();
}

// After waking:
touch_pad_t touchPin = esp_sleep_get_touchpad_wakeup_status();
Serial.printf("Woke from touch pad %d\n", touchPin);
```

### Multiple Wakeup Sources

You can enable multiple wakeup sources. The ESP32 wakes on whichever triggers first.

```cpp
void setup() {
    // Timer: wake after 30 minutes no matter what
    esp_sleep_enable_timer_wakeup(30 * 60 * uS_TO_S_FACTOR);

    // ext0: wake immediately on button press
    esp_sleep_enable_ext0_wakeup(GPIO_NUM_33, HIGH);

    esp_deep_sleep_start();
}
```

---

## RTC Memory (Persisting Data Across Deep Sleep)

Variables in normal RAM are lost during deep sleep. Use `RTC_DATA_ATTR` to store data in 8 KB RTC SRAM that survives deep sleep (but not power cycles or resets).

```cpp
RTC_DATA_ATTR int bootCount = 0;
RTC_DATA_ATTR float lastTemperature = 0;
RTC_DATA_ATTR time_t lastTransmitTime = 0;
RTC_DATA_ATTR uint8_t sensorBuffer[256];  // Buffer for ULP or accumulated data

void setup() {
    Serial.begin(115200);
    bootCount++;
    Serial.printf("Boot #%d (last temp: %.1f)\n", bootCount, lastTemperature);

    float temp = readSensor();
    lastTemperature = temp;

    // Only transmit every 6th wake (every 30 min if sleeping 5 min)
    if (bootCount % 6 == 0) {
        connectWiFiAndTransmit(temp);
    }

    esp_sleep_enable_timer_wakeup(5 * 60 * uS_TO_S_FACTOR);
    esp_deep_sleep_start();
}
```

### RTC Memory Limitations

- 8 KB total for `RTC_DATA_ATTR` and `RTC_RODATA_ATTR` combined
- No structures with virtual functions or complex C++ objects
- Data persists only during deep sleep, not across hard resets or power cycles
- Use NVS (`Preferences`) for data that must survive power loss

---

## ULP Coprocessor

The ESP32 (original) has an Ultra Low Power (ULP) coprocessor that runs at 8 MHz while the main CPUs are asleep. It can:

- Read ADC values
- Monitor GPIO states
- Perform simple computations
- Wake the main CPU when conditions are met
- Uses ~100-150 uA while running

### ULP Use Cases

- Monitor a sensor and only wake the main CPU when a threshold is crossed
- Count pulses (e.g., rain gauge) while main CPU sleeps
- Periodically sample ADC and store results in RTC memory

### Simple ULP Example: ADC Threshold Wakeup

Using the ULP assembly (in ESP-IDF):

```c
// ulp_program.S (ULP assembly)
#include "soc/rtc_cntl_reg.h"
#include "soc/soc_ulp.h"

    .bss
    .global sample_counter
sample_counter: .long 0

    .global adc_value
adc_value: .long 0

    .text
    .global entry
entry:
    // Read ADC channel 6 (GPIO34), ADC unit 0
    adc r0, 0, 6

    // Store the value
    move r1, adc_value
    st r0, r1, 0

    // Compare with threshold (e.g., 2000 out of 4095)
    jumpr wake_up, 2000, GE

    // Not above threshold, go back to sleep
    halt

wake_up:
    // Value above threshold, wake main CPU
    wake
    halt
```

For Arduino users, the ULP is more easily accessed through ESP-IDF APIs. Consider the HULP (Helper for ULP) library or writing ULP programs using the macro assembler in ESP-IDF.

### ESP32-S2/S3 RISC-V ULP

The S2 and S3 have a RISC-V-based ULP coprocessor that can be programmed in C:

```c
// ulp_main.c (runs on RISC-V ULP coprocessor)
#include "ulp_riscv.h"
#include "ulp_riscv_utils.h"
#include "ulp_riscv_adc_ulp_core.h"

volatile uint32_t adc_reading;
volatile uint32_t threshold = 2000;

int main(void) {
    while (1) {
        adc_reading = ulp_riscv_adc_read_channel(ADC_UNIT_1, ADC_CHANNEL_6);

        if (adc_reading > threshold) {
            ulp_riscv_wakeup_main_processor();
            break;
        }

        ulp_riscv_delay_cycles(8000 * 1000);  // ~1 second at 8MHz
    }

    ulp_riscv_halt();
    return 0;
}
```

---

## Complete Example: Battery-Powered Sensor Node

This example demonstrates a practical deep sleep sensor that wakes every 5 minutes, reads a temperature sensor, transmits via WiFi, and goes back to sleep.

```cpp
#include <WiFi.h>
#include <HTTPClient.h>
#include "esp_sleep.h"
#include "esp_adc_cal.h"

#define SLEEP_MINUTES 5
#define uS_TO_S_FACTOR 1000000ULL
#define WIFI_TIMEOUT_MS 10000
#define SENSOR_PIN 34
#define BATTERY_PIN 35

const char *WIFI_SSID = "SensorNetwork";
const char *WIFI_PASS = "password123";
const char *SERVER_URL = "http://192.168.1.100:8080/api/sensor";

RTC_DATA_ATTR int bootCount = 0;
RTC_DATA_ATTR int failedTransmissions = 0;

float readTemperature() {
    // Example: LM35 sensor on GPIO34
    // LM35 outputs 10mV per degree C
    int raw = analogRead(SENSOR_PIN);
    float voltage = raw * 3.3 / 4095.0;
    return voltage * 100.0;  // Convert to Celsius
}

float readBatteryVoltage() {
    // Battery through a 100k/100k voltage divider on GPIO35
    int raw = analogRead(BATTERY_PIN);
    float voltage = raw * 3.3 / 4095.0;
    return voltage * 2.0;  // Multiply by divider ratio
}

bool connectWiFi() {
    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASS);

    unsigned long start = millis();
    while (WiFi.status() != WL_CONNECTED) {
        if (millis() - start > WIFI_TIMEOUT_MS) {
            Serial.println("WiFi timeout");
            return false;
        }
        delay(100);
    }
    return true;
}

bool transmitData(float temp, float battery) {
    HTTPClient http;
    http.begin(SERVER_URL);
    http.addHeader("Content-Type", "application/json");

    char json[128];
    snprintf(json, sizeof(json),
        "{\"temp\":%.1f,\"battery\":%.2f,\"boot\":%d,\"rssi\":%d}",
        temp, battery, bootCount, WiFi.RSSI());

    int httpCode = http.POST(json);
    http.end();

    return (httpCode >= 200 && httpCode < 300);
}

void goToSleep() {
    // Disconnect WiFi cleanly (saves power, faster reconnect next time)
    WiFi.disconnect(true);
    WiFi.mode(WIFI_OFF);

    esp_sleep_enable_timer_wakeup(SLEEP_MINUTES * 60 * uS_TO_S_FACTOR);

    Serial.printf("Sleeping for %d minutes...\n", SLEEP_MINUTES);
    Serial.flush();

    esp_deep_sleep_start();
}

void setup() {
    Serial.begin(115200);
    bootCount++;

    // Set ADC attenuation
    analogSetAttenuation(ADC_11db);

    // Read sensors (do this BEFORE WiFi to avoid ADC2 conflict)
    float temperature = readTemperature();
    float battery = readBatteryVoltage();

    Serial.printf("Boot #%d: Temp=%.1fC, Batt=%.2fV\n",
        bootCount, temperature, battery);

    // Check battery level
    if (battery < 3.3) {
        Serial.println("Battery critically low! Extended sleep.");
        esp_sleep_enable_timer_wakeup(60 * 60 * uS_TO_S_FACTOR);  // 1 hour
        esp_deep_sleep_start();
    }

    // Connect and transmit
    if (connectWiFi()) {
        if (transmitData(temperature, battery)) {
            Serial.println("Data transmitted successfully");
            failedTransmissions = 0;
        } else {
            Serial.println("Transmission failed");
            failedTransmissions++;
        }
    } else {
        failedTransmissions++;
    }

    // If too many failures, do a longer sleep
    if (failedTransmissions > 10) {
        Serial.println("Too many failures, sleeping for 1 hour");
        esp_sleep_enable_timer_wakeup(60 * 60 * uS_TO_S_FACTOR);
        esp_deep_sleep_start();
    }

    goToSleep();
}

void loop() {
    // Never reached
}
```

---

## Battery Life Calculations

### Formula

```
Battery Life (hours) = Battery Capacity (mAh) / Average Current (mA)
```

### Average Current Calculation

For a device that wakes, does work, and sleeps:

```
T_active = time awake (seconds)
T_sleep = time asleep (seconds)
I_active = current while awake (mA)
I_sleep = current while asleep (mA)

Average Current = (I_active * T_active + I_sleep * T_sleep) / (T_active + T_sleep)
```

### Example Calculations

**Scenario: ESP32 sensor node, wake every 5 minutes, transmit for 3 seconds**

- T_active = 3 seconds (WiFi connect + transmit)
- T_sleep = 297 seconds
- I_active = 150 mA (WiFi transmitting)
- I_sleep = 0.01 mA (10 uA deep sleep, bare module)

```
Average = (150 * 3 + 0.01 * 297) / 300
        = (450 + 2.97) / 300
        = 1.51 mA
```

With a 3000 mAh LiPo battery:
```
Life = 3000 / 1.51 = 1987 hours = ~83 days
```

**Scenario: Same, but wake every 30 minutes**

```
Average = (150 * 3 + 0.01 * 1797) / 1800
        = (450 + 17.97) / 1800
        = 0.26 mA

Life = 3000 / 0.26 = 11538 hours = ~481 days = ~1.3 years
```

**Scenario: Dev board with power LED and USB-UART chip (adds ~5 mA sleep current)**

```
Average = (150 * 3 + 5 * 297) / 300
        = (450 + 1485) / 300
        = 6.45 mA

Life = 3000 / 6.45 = 465 hours = ~19 days
```

This is why dev boards are terrible for battery operation. Cut the power LED trace or use bare modules.

### Quick Reference Table (3000 mAh battery, 3-sec active at 150 mA)

| Sleep Current | Wake Interval | Battery Life |
|--------------|---------------|-------------|
| 10 uA (bare module) | 5 min | ~83 days |
| 10 uA (bare module) | 15 min | ~170 days |
| 10 uA (bare module) | 30 min | ~1.3 years |
| 10 uA (bare module) | 60 min | ~2.3 years |
| 5 mA (dev board) | 5 min | ~19 days |
| 5 mA (dev board) | 15 min | ~24 days |
| 5 mA (dev board) | 30 min | ~27 days |

---

## ESP32-S3 and C3 Deep Sleep Differences

### ESP32-S3

- **Wakeup sources:** Timer, GPIO (any RTC GPIO), touch pad, ULP (RISC-V based)
- **No ext0/ext1:** Uses `esp_sleep_enable_gpio_wakeup()` with a different API
- **Deep sleep current:** ~7 uA
- **RTC memory:** 8 KB (same as original)

```cpp
// ESP32-S3 GPIO wakeup (replaces ext0/ext1)
#include "esp_sleep.h"

void setup() {
    // Configure GPIO wakeup
    gpio_config_t config = {
        .pin_bit_mask = (1ULL << GPIO_NUM_4),
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_ENABLE,
        .intr_type = GPIO_INTR_DISABLE
    };
    gpio_config(&config);

    esp_deep_sleep_enable_gpio_wakeup(
        (1ULL << GPIO_NUM_4),
        ESP_GPIO_WAKEUP_GPIO_HIGH  // Wake on HIGH
    );

    esp_deep_sleep_start();
}
```

### ESP32-C3

- **Wakeup sources:** Timer, GPIO
- **No touch wakeup** (no touch pins on C3)
- **No ULP** coprocessor
- **Deep sleep current:** ~5 uA
- **GPIO wakeup:** Uses the same `esp_deep_sleep_enable_gpio_wakeup()` as S3

```cpp
// ESP32-C3 deep sleep
void setup() {
    esp_sleep_enable_timer_wakeup(5 * 60 * 1000000ULL);  // 5 minutes

    // GPIO wakeup
    gpio_config_t config = {
        .pin_bit_mask = (1ULL << GPIO_NUM_3),
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_ENABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE
    };
    gpio_config(&config);
    esp_deep_sleep_enable_gpio_wakeup(
        (1ULL << GPIO_NUM_3),
        ESP_GPIO_WAKEUP_GPIO_LOW
    );

    esp_deep_sleep_start();
}
```

### ESP32-C6

- **Wakeup sources:** Timer, GPIO, LP (low-power) core
- **Has LP core:** RISC-V low-power core similar to ULP but more capable
- **Deep sleep current:** ~7 uA

---

## Hibernation Mode

The lowest power mode. Only the RTC timer is running. No GPIO wakeup, no RTC memory retention.

```cpp
void enterHibernation(uint64_t sleep_us) {
    // Disable all wakeup sources except timer
    esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_PERIPH, ESP_PD_OPTION_OFF);
    esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_SLOW_MEM, ESP_PD_OPTION_OFF);
    esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_FAST_MEM, ESP_PD_OPTION_OFF);

    esp_sleep_enable_timer_wakeup(sleep_us);
    esp_deep_sleep_start();

    // On wake: full reboot, no RTC memory, boot count lost
}
```

Hibernation current: ~2.5 uA on original ESP32.

**When to use hibernation:**
- Maximum battery life is critical
- No data needs to persist between sleeps
- Only timer wakeup is needed (no GPIO, touch, or ULP)

---

## Power Optimization Tips

### Hardware

1. **Remove/disable power LED** on dev boards (cuts 2-5 mA)
2. **Use a low-quiescent-current LDO** (e.g., MCP1700 with 1.6 uA quiescent vs AMS1117 with 5 mA)
3. **Use a P-MOSFET to cut power to sensors** during deep sleep
4. **Add decoupling capacitors** (100 uF) near ESP32 power pins for WiFi TX bursts
5. **Use voltage dividers with high-value resistors** (100K+) for battery monitoring to minimize leakage

### Software

1. **Do all sensor reads before turning on WiFi** (ADC2 conflict, and sensors don't need WiFi)
2. **Use static IP** instead of DHCP (saves 1-3 seconds per wake cycle)
3. **Pre-configure WiFi channel and BSSID** for fastest reconnection:
   ```cpp
   RTC_DATA_ATTR int savedChannel = 0;
   RTC_DATA_ATTR uint8_t savedBSSID[6] = {0};

   // On first connect, save channel and BSSID
   savedChannel = WiFi.channel();
   memcpy(savedBSSID, WiFi.BSSID(), 6);

   // On subsequent connects, use saved values
   WiFi.begin(SSID, PASS, savedChannel, savedBSSID, true);
   ```
4. **Reduce WiFi TX power** if range allows
5. **Batch data** and transmit less frequently
6. **Use UDP instead of TCP** where possible (lower overhead, faster)
7. **Disable brownout detector** if using marginal power supply (risky but saves power during sleep):
   ```cpp
   #include "soc/rtc_cntl_reg.h"
   CLEAR_PERI_REG_MASK(RTC_CNTL_BROWN_OUT_REG, RTC_CNTL_BROWN_OUT_ENA);
   ```
