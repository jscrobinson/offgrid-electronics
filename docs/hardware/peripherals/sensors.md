# Common Sensors Reference

Practical wiring, libraries, and gotchas for the most common hobbyist/field sensors.

---

## Temperature Sensors

### DS18B20 — Digital Temperature (1-Wire)

**Specs:** -55°C to +125°C, ±0.5°C accuracy (at -10 to +85°C), 12-bit resolution, 1-Wire protocol.

**Wiring:**
```
DS18B20        MCU
-------        ---
VCC (red)   →  3.3V or 5V
GND (black) →  GND
DATA (yellow)→ Any GPIO
```
**Required:** 4.7kΩ pull-up resistor between DATA and VCC. Without it, you'll get -127°C or 85°C readings.

**Parasite power mode:** Can run on just GND + DATA (power drawn from data line). Unreliable over long cable runs — use normal 3-wire mode.

**Arduino:**
```cpp
#include <OneWire.h>
#include <DallasTemperature.h>

OneWire oneWire(4);  // DATA on GPIO4
DallasTemperature sensors(&oneWire);

void setup() {
    sensors.begin();
}

void loop() {
    sensors.requestTemperatures();
    float tempC = sensors.getTempCByIndex(0);
    // Multiple sensors share one bus — use index or address
}
```

**Libraries:** `OneWire` + `DallasTemperature`

**Gotchas:**
- Reading 85°C means the sensor hasn't completed conversion yet — add delay or check `isConversionComplete()`
- Reading -127°C means communication failure — check pull-up resistor
- Multiple sensors on one wire: each has a unique 64-bit address. Use `getAddress()` to enumerate
- Waterproof probe versions exist with pre-wired cable (great for field use)
- Cable runs over 5m: use lower pull-up (2.2kΩ) or active pull-up circuit
- 12-bit conversion takes 750ms — set lower resolution (9-bit = 94ms) if speed matters

### DHT11 / DHT22 (AM2302) — Temperature + Humidity

**DHT11:** 0-50°C, ±2°C, 20-80% RH, ±5% RH. Cheap, low accuracy.
**DHT22:** -40 to 80°C, ±0.5°C, 0-100% RH, ±2-5% RH. Better, slightly more expensive.

**Wiring:**
```
DHT Pin 1 (VCC)  →  3.3V or 5V
DHT Pin 2 (DATA) →  GPIO + 10kΩ pull-up to VCC
DHT Pin 3         →  NC (not connected)
DHT Pin 4 (GND)  →  GND
```

**Arduino:**
```cpp
#include <DHT.h>

DHT dht(4, DHT22);  // GPIO4, sensor type

void setup() { dht.begin(); }

void loop() {
    float h = dht.readHumidity();
    float t = dht.readTemperature();
    if (isnan(h) || isnan(t)) {
        // Read failed — retry after 2s
        return;
    }
}
```

**Library:** `DHT sensor library` by Adafruit (also install `Adafruit Unified Sensor`)

**Gotchas:**
- Minimum 2 seconds between reads (DHT22) or 1 second (DHT11)
- First read after power-on is often garbage — discard it
- Very timing-sensitive protocol — can fail on ESP32 due to WiFi interrupts. Use `DHTesp` library for ESP32 instead
- 3.3V logic works but 5V is more reliable for longer wires
- Consider replacing DHT with BME280 — much more reliable

---

## Environmental Sensors (I2C)

### BME280 — Temperature + Humidity + Pressure

**Specs:** -40 to 85°C (±1°C), 0-100% RH (±3%), 300-1100 hPa (±1 hPa). I2C or SPI.

**Wiring (I2C):**
```
BME280     ESP32       RPi         Arduino Uno
------     -----       ---         -----------
VCC        3.3V        3.3V        3.3V (or 5V if module has regulator)
GND        GND         GND         GND
SDA        GPIO21      GPIO2       A4
SCL        GPIO22      GPIO3       A5
```

**I2C Address:** 0x76 (SDO→GND) or 0x77 (SDO→VCC). Default on most modules is 0x76.

**Arduino:**
```cpp
#include <Adafruit_BME280.h>

Adafruit_BME280 bme;

void setup() {
    if (!bme.begin(0x76)) {
        // Sensor not found — check wiring and address
    }
}

void loop() {
    float temp = bme.readTemperature();      // °C
    float hum  = bme.readHumidity();         // %
    float pres = bme.readPressure() / 100.0; // hPa
    float alt  = bme.readAltitude(1013.25);  // meters (set sea-level pressure)
}
```

**Library:** `Adafruit BME280 Library`

**Gotchas:**
- Self-heating: reads ~1-2°C high if sampled continuously. Use forced mode with sleep between reads
- Many cheap "BME280" modules are actually **BMP280** (no humidity). Check chip ID: BME280=0x60, BMP280=0x58
- For altitude, you must set the current sea-level pressure for accuracy

### BMP280 — Temperature + Pressure (No Humidity)

Same as BME280 but without humidity sensor. Cheaper. Same wiring, same I2C addresses.

**Library:** `Adafruit BMP280 Library`

Use `bmp.begin(0x76)` — same gotchas apply minus humidity.

---

## Light Sensors

### LDR (Light Dependent Resistor) — Analog Light Level

**Wiring (voltage divider):**
```
3.3V → LDR → Junction → 10kΩ → GND
                 ↓
              ADC Pin
```

**Arduino:**
```cpp
int lightLevel = analogRead(A0);  // 0-1023 (Uno) or 0-4095 (ESP32)
// Higher value = more light (with LDR on top of divider)
```

**Gotchas:**
- Not calibrated — only gives relative light levels
- ESP32 ADC is nonlinear (especially at extremes). Use `analogReadMilliVolts()` on ESP32
- Response time is slow (~tens of ms) — fine for ambient light, not for fast pulses

### BH1750 — Digital Lux Sensor (I2C)

**Specs:** 1-65535 lux, 16-bit, I2C. Much more accurate than LDR.

**Address:** 0x23 (ADDR→GND) or 0x5C (ADDR→VCC)

**Arduino:**
```cpp
#include <BH1750.h>

BH1750 lightMeter;

void setup() {
    Wire.begin();
    lightMeter.begin();
}

void loop() {
    float lux = lightMeter.readLightLevel();
}
```

**Library:** `BH1750` by Christopher Laws

**Gotchas:**
- Takes ~120ms in high-res mode, ~16ms in low-res mode
- Direct sunlight can saturate (>65535 lux)

---

## Distance Sensors

### HC-SR04 — Ultrasonic Distance (2cm-400cm)

**Wiring:**
```
HC-SR04     MCU
-------     ---
VCC      →  5V (requires 5V!)
GND      →  GND
TRIG     →  Any GPIO
ECHO     →  GPIO (use voltage divider for 3.3V MCUs!)
```

**CRITICAL for ESP32/RPi:** ECHO pin outputs 5V. Use a voltage divider (1kΩ + 2kΩ) or level shifter to protect 3.3V GPIO.

**Arduino:**
```cpp
#define TRIG 5
#define ECHO 18

void setup() {
    pinMode(TRIG, OUTPUT);
    pinMode(ECHO, INPUT);
}

float getDistanceCm() {
    digitalWrite(TRIG, LOW);
    delayMicroseconds(2);
    digitalWrite(TRIG, HIGH);
    delayMicroseconds(10);
    digitalWrite(TRIG, LOW);

    long duration = pulseIn(ECHO, HIGH, 30000); // 30ms timeout
    if (duration == 0) return -1; // No echo
    return duration * 0.0343 / 2.0;
}
```

**Gotchas:**
- Soft surfaces (fabric, foam) absorb sound — poor reflection
- Narrow beam angle (~15°) — can miss thin objects
- Temperature affects speed of sound: `distance = duration * (331.3 + 0.606 * tempC) / 20000`
- Minimum range ~2cm — readings below this are unreliable

### VL53L0X — Laser Time-of-Flight (up to 2m)

**Specs:** 30mm to 2000mm, I2C, uses 940nm laser (eye-safe Class 1).

**Address:** Default 0x29, can be changed in software.

**Arduino:**
```cpp
#include <Adafruit_VL53L0X.h>

Adafruit_VL53L0X lox;

void setup() {
    lox.begin();
}

void loop() {
    VL53L0X_RangingMeasurementData_t measure;
    lox.rangingTest(&measure, false);
    if (measure.RangeStatus != 4) {  // 4 = out of range
        int distMm = measure.RangeMilliMeter;
    }
}
```

**Library:** `Adafruit VL53L0X`

**Gotchas:**
- Sunlight can interfere with readings (IR interference)
- Dark/absorptive surfaces reduce range
- Multiple VL53L0X on same I2C bus: need XSHUT pin to reassign addresses at startup

---

## Motion Sensors

### PIR (Passive Infrared) — Motion Detection

Common module: HC-SR501

**Wiring:**
```
PIR         MCU
---         ---
VCC      →  5V (some modules accept 3.3V — check)
OUT      →  GPIO (output is 3.3V on most modules)
GND      →  GND
```

**Usage:**
```cpp
#define PIR_PIN 13

void setup() {
    pinMode(PIR_PIN, INPUT);
}

void loop() {
    if (digitalRead(PIR_PIN) == HIGH) {
        // Motion detected
    }
}
```

**Adjustments (potentiometers on module):**
- **Sensitivity** — Detection range (up to ~7m)
- **Time delay** — How long output stays HIGH after detection (5s to 5min)
- **Jumper** — H = repeatable trigger, L = single trigger

**Gotchas:**
- 30-60 second warm-up period after power-on (ignore readings during this time)
- Detects warm-blooded animals, not just humans
- Sensitive to air currents from HVAC
- Can false trigger from rapid temperature changes
- ESP32 deep sleep: use PIR output as wake-up source on RTC GPIO

### MPU6050 — 6-Axis Accelerometer + Gyroscope (I2C)

**Specs:** 3-axis accelerometer (±2/4/8/16g), 3-axis gyroscope (±250/500/1000/2000°/s), built-in DMP, temperature sensor.

**Address:** 0x68 (AD0→GND) or 0x69 (AD0→VCC)

**Arduino:**
```cpp
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

Adafruit_MPU6050 mpu;

void setup() {
    mpu.begin();
    mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
    mpu.setGyroRange(MPU6050_RANGE_500_DEG);
    mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
}

void loop() {
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);

    float ax = a.acceleration.x;  // m/s²
    float gy = g.gyro.x;          // rad/s
    float t  = temp.temperature;   // °C
}
```

**Library:** `Adafruit MPU6050`

**Gotchas:**
- Gyro drifts over time — need sensor fusion (complementary filter, Madgwick, or Kalman) for stable angles
- DMP (Digital Motion Processor) can offload computation but is poorly documented
- Sensitive to vibration — mount securely with foam padding if needed
- Needs calibration: place flat, average ~1000 readings to determine offsets

---

## Air Quality Sensors

### MQ-2 / MQ-135 — Analog Gas Sensors

**MQ-2:** Combustible gases (LPG, methane, propane, hydrogen, smoke).
**MQ-135:** Air quality (NH3, NOx, benzene, smoke, CO2 approximation).

**Wiring:**
```
MQ-x Module    MCU
-----------    ---
VCC         →  5V (heater requires 5V)
GND         →  GND
AO          →  ADC pin (analog output)
DO          →  GPIO (digital threshold output, optional)
```

**Arduino:**
```cpp
int gasValue = analogRead(A0);
// Higher value = higher gas concentration
// DO pin goes LOW when threshold exceeded (set by onboard pot)
```

**Gotchas:**
- **Preheat time:** 24-48 hours for first use, 2-5 minutes for subsequent uses
- Power hungry: heater draws ~150mA at 5V — not suitable for battery operation
- Not calibrated — values are relative. For ppm readings, need calibration curve
- Cross-sensitive to many gases — cannot identify specific gases
- Analog output varies with temperature and humidity

### CCS811 — Digital Air Quality (I2C)

**Specs:** eCO2 (400-8192 ppm) and TVOC (0-1187 ppb), I2C.

**Address:** 0x5A (ADDR→GND) or 0x5B (ADDR→VCC)

**Arduino:**
```cpp
#include <Adafruit_CCS811.h>

Adafruit_CCS811 ccs;

void setup() {
    ccs.begin();
    // Wait for sensor to be ready
    while (!ccs.available());
}

void loop() {
    if (ccs.available() && !ccs.readData()) {
        int co2 = ccs.geteCO2();    // ppm
        int tvoc = ccs.getTVOC();   // ppb
    }
}
```

**Library:** `Adafruit CCS811 Library`

**Gotchas:**
- 20-minute burn-in on each power-up for stable readings
- 48-hour conditioning period for first use
- Feed it temperature/humidity from BME280 for compensation: `ccs.setEnvironmentalData(humidity, temperature)`
- Readings in first 20 minutes are unreliable
- Has a "baseline" value that should be saved/restored for consistent readings

---

## Soil Moisture

### Capacitive Soil Moisture Sensor v1.2/v2.0

**Specs:** Analog output, corrosion-resistant (no exposed metal), 3.3-5V.

**Wiring:**
```
Sensor      MCU
------      ---
VCC      →  3.3V (preferred) or 5V
GND      →  GND
AOUT     →  ADC pin
```

**Arduino:**
```cpp
int moisture = analogRead(A0);
// Calibrate: read value in air (dry) and in water (wet)
// Typical ESP32: dry ~3200, wet ~1400 (inverted — lower = wetter)
int moisturePercent = map(moisture, dryValue, wetValue, 0, 100);
moisturePercent = constrain(moisturePercent, 0, 100);
```

**Gotchas:**
- v1.0 boards have exposed voltage regulator traces that corrode. Get v1.2 or v2.0
- Apply conformal coating or nail polish to the electronics (top half) — NOT the sensing area
- Calibrate for your specific soil type
- Power via GPIO and turn off between reads to extend life and save power
- ESP32 ADC nonlinearity affects readings — use `analogReadMilliVolts()`

---

## Power Monitoring

### INA219 — DC Current/Voltage/Power (I2C)

**Specs:** 0-26V, up to ±3.2A (with 0.1Ω shunt), 12-bit, I2C. Measures voltage, current, and power.

**Wiring:**
```
INA219 Module   Circuit
-------------   -------
VCC          →  3.3V or 5V
GND          →  GND
SDA          →  I2C SDA
SCL          →  I2C SCL
VIN+         →  Power source (+)
VIN-         →  Load (+)
```

The INA219 goes **in series** on the high side (between supply and load positive).

**Address:** 0x40-0x4F (set by A0/A1 solder jumpers). Default 0x40.

**Arduino:**
```cpp
#include <Adafruit_INA219.h>

Adafruit_INA219 ina219;

void setup() {
    ina219.begin();
    // For higher precision with lower currents:
    // ina219.setCalibration_16V_400mA();
}

void loop() {
    float busVoltage   = ina219.getBusVoltage_V();     // V
    float current_mA   = ina219.getCurrent_mA();       // mA
    float power_mW     = ina219.getPower_mW();          // mW
    float shuntVoltage = ina219.getShuntVoltage_mV();   // mV
    float loadVoltage  = busVoltage + (shuntVoltage / 1000);
}
```

**Library:** `Adafruit INA219`

**Gotchas:**
- Default shunt resistor (0.1Ω) limits to ±3.2A. For higher current, replace shunt and recalibrate
- Bus voltage is measured at VIN- (load side), not VIN+ (source side)
- Load voltage = bus voltage + shunt voltage
- Negative current means current flowing backwards
- 4 addresses available per bus — monitor up to 4 channels on one I2C bus

---

## I2C Scanner

When a sensor isn't responding, run the I2C scanner to verify it's detected:

```cpp
#include <Wire.h>

void setup() {
    Wire.begin();
    Serial.begin(115200);

    Serial.println("I2C Scanner");
    for (byte addr = 1; addr < 127; addr++) {
        Wire.beginTransmission(addr);
        if (Wire.endTransmission() == 0) {
            Serial.printf("Device found at 0x%02X\n", addr);
        }
    }
}
```

## Common I2C Addresses Quick Reference

| Sensor     | Address(es)          |
|------------|----------------------|
| BME280     | 0x76, 0x77           |
| BMP280     | 0x76, 0x77           |
| BH1750     | 0x23, 0x5C           |
| VL53L0X    | 0x29 (changeable)    |
| MPU6050    | 0x68, 0x69           |
| CCS811     | 0x5A, 0x5B           |
| INA219     | 0x40-0x4F            |
| SSD1306    | 0x3C, 0x3D           |

## General Sensor Tips

1. **Decoupling capacitors:** Add 100nF ceramic cap close to sensor VCC/GND for stable power
2. **Pull-ups for I2C:** Most breakout boards include pull-ups. If using multiple I2C devices, you may need to remove extras (too many pull-ups lower the resistance too far)
3. **Wire length:** I2C reliable to ~1m. For longer runs, reduce clock speed (`Wire.setClock(100000)`) or use differential I2C extenders
4. **Power cycling:** Control sensor power via MOSFET/GPIO to save power in sleep modes
5. **Averaging:** Take multiple readings and average for noisy sensors (ADC-based especially)
6. **Level shifting:** 5V sensors with 3.3V MCUs need level shifters or voltage dividers on data lines
