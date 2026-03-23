# 1-Wire Protocol

## Overview

1-Wire is a low-speed serial protocol developed by Dallas Semiconductor (now Maxim/Analog Devices) that uses a single data wire plus ground for communication and, optionally, parasitic power.

```
MCU ──── DQ (Data) ──┬──┬──┬── ...
                      │  │  │
                   [Dev1][Dev2][Dev3]
                      │  │  │
GND ─────────────────┴──┴──┴── ...

Pull-up: 4.7kΩ from DQ to Vcc
```

**Key characteristics:**
- **Single data wire** + ground (two wires total, or three with Vcc)
- **Parasitic power** — devices can draw power from the data line
- **Unique addressing** — each device has a factory-programmed 64-bit ROM code
- **Multiple devices** on one bus (addressed individually)
- **Master-slave** — one master (MCU) controls timing
- **Timing-critical** — bit timing is precise (microseconds)
- **Low speed** — about 16 kbit/s (standard speed) or 125 kbit/s (overdrive)

---

## Electrical Setup

### Pull-Up Resistor

The data line (DQ) requires a pull-up resistor to Vcc:

```
Vcc (3.3V or 5V)
    │
  [4.7kΩ]  ← standard pull-up
    │
    ├──── DQ bus line ──── to all devices
    │
  MCU GPIO (open-drain or with tristate capability)
```

**4.7kΩ is the standard value.** For long cables or many devices, a lower value (2.2kΩ-3.3kΩ) may improve reliability.

### Parasitic Power Mode

Devices can operate without a Vcc connection by drawing power from the data line through an internal diode and storing it in an internal capacitor:

```
Vcc ──[4.7kΩ]──┬── DQ ── DS18B20 DQ pin
                │         DS18B20 Vcc → (not connected or tied to GND)
               GND ────── DS18B20 GND
```

**Parasitic power limitations:**
- Temperature conversions and EEPROM writes require more current than the pull-up can supply
- During these operations, the master must provide a "strong pull-up" — drive the DQ line HIGH directly (not through the resistor)
- Maximum of a few devices reliably in parasitic mode
- Some operations are slower in parasitic mode

**Recommendation:** Use external Vcc power (3-wire mode) when possible. It's more reliable, supports more devices, and avoids the strong pull-up complexity.

### Three-Wire (External Power) Mode

```
Vcc ──[4.7kΩ]──┬── DQ ── DS18B20 DQ pin
                │         DS18B20 Vcc ── Vcc
               GND ────── DS18B20 GND
```

---

## 64-Bit ROM Code

Every 1-Wire device has a unique, factory-programmed 64-bit identifier:

```
| 8-bit Family Code | 48-bit Serial Number | 8-bit CRC |
|    (LSB first)     |     (unique)         |           |
```

**Common family codes:**

| Code | Device             | Description                    |
|------|-------------------|--------------------------------|
| 0x28 | DS18B20           | Digital temperature sensor     |
| 0x10 | DS18S20           | Older temp sensor (9-bit)      |
| 0x22 | DS1822            | Economical temp sensor         |
| 0x3B | DS1825            | Temp sensor with address pins  |
| 0x01 | DS2401/DS1990A    | Silicon serial number / iButton|
| 0x26 | DS2438            | Smart battery monitor          |
| 0x29 | DS2408            | 8-channel addressable switch   |
| 0x3A | DS2413            | Dual-channel addressable switch|
| 0x1D | DS2423            | 4kbit RAM with counter         |

---

## Protocol Operation

### Reset / Presence Detect

Every transaction begins with a reset pulse:

1. Master pulls DQ LOW for at least 480μs
2. Master releases DQ (pull-up brings it HIGH)
3. After 15-60μs, slave pulls DQ LOW for 60-240μs (presence pulse)
4. Master reads presence: LOW = device present

```
Master:  ────┐                    ┌──────
             │   ≥480μs           │
             └────────────────────┘

Slave:                    ┌───────┐
                          │60-240μs│
             ─────────────┘       └──────
                 15-60μs
                 (wait)
```

### Write Bit

**Write 1:**
```
Master pulls LOW for 1-15μs, then releases (HIGH for remainder of 60μs slot)
```

**Write 0:**
```
Master pulls LOW for 60-120μs, then releases
```

### Read Bit

```
Master pulls LOW for 1-15μs, then releases
Master samples DQ at 15μs from start of slot
If DQ is HIGH: read 1
If DQ is LOW: read 0 (slave is holding it low)
Total slot: 60μs minimum
```

### ROM Commands

Before communicating with a specific device, the master issues a ROM command:

| Command       | Code | Description                                    |
|--------------|------|------------------------------------------------|
| Search ROM   | 0xF0 | Discover all device ROM codes on bus           |
| Read ROM     | 0x33 | Read ROM code (only works with single device)  |
| Match ROM    | 0x55 | Address a specific device by ROM code          |
| Skip ROM     | 0xCC | Address all devices (only works for commands where this makes sense) |
| Alarm Search | 0xEC | Find devices with alarm flag set               |

---

## DS18B20 Temperature Sensor

The most popular 1-Wire device. Measures temperature from -55°C to +125°C with ±0.5°C accuracy (from -10 to +85°C).

### DS18B20 Pinout (TO-92 package)

```
Flat side facing you:

  1     2     3
 GND   DQ   Vcc

Pin 1 (left):  GND
Pin 2 (center): DQ (data)
Pin 3 (right):  Vcc (or GND for parasitic)
```

### Resolution Settings

| Resolution | Conversion Time | Precision  |
|-----------|----------------|------------|
| 9-bit     | 93.75 ms       | 0.5°C      |
| 10-bit    | 187.5 ms       | 0.25°C     |
| 11-bit    | 375 ms         | 0.125°C    |
| 12-bit    | 750 ms         | 0.0625°C   |

Default is 12-bit. Lower resolution gives faster readings.

### DS18B20 Function Commands

| Command            | Code | Description                              |
|-------------------|------|------------------------------------------|
| Convert T         | 0x44 | Start temperature conversion             |
| Read Scratchpad   | 0xBE | Read 9 bytes of internal memory          |
| Write Scratchpad  | 0x4E | Write TH, TL, config registers           |
| Copy Scratchpad   | 0x48 | Copy scratchpad to EEPROM                |
| Recall E²         | 0xB8 | Load EEPROM to scratchpad                |
| Read Power Supply | 0xB4 | Check if device is in parasitic mode     |

---

## Arduino Implementation

### Libraries

- **OneWire** — low-level 1-Wire protocol library
- **DallasTemperature** — high-level DS18B20 library (uses OneWire)

Install both via Arduino Library Manager.

### Single Sensor Example

```cpp
#include <OneWire.h>
#include <DallasTemperature.h>

#define ONE_WIRE_BUS 4  // GPIO pin for DQ

OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

void setup() {
    Serial.begin(115200);
    sensors.begin();

    // Print device count
    Serial.print("Found ");
    Serial.print(sensors.getDeviceCount());
    Serial.println(" sensor(s).");
}

void loop() {
    sensors.requestTemperatures();  // Send Convert T to all devices
    float tempC = sensors.getTempCByIndex(0);  // Read first sensor

    Serial.print("Temperature: ");
    Serial.print(tempC);
    Serial.println(" °C");

    delay(1000);
}
```

### Multiple Sensors on One Bus

```cpp
#include <OneWire.h>
#include <DallasTemperature.h>

#define ONE_WIRE_BUS 4

OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

// Store addresses of each sensor
DeviceAddress sensor1, sensor2, sensor3;

void setup() {
    Serial.begin(115200);
    sensors.begin();

    // Get addresses by index (order may vary)
    sensors.getAddress(sensor1, 0);
    sensors.getAddress(sensor2, 1);
    sensors.getAddress(sensor3, 2);

    // Print addresses for identification
    printAddress(sensor1);
    printAddress(sensor2);
    printAddress(sensor3);

    // Set resolution (optional)
    sensors.setResolution(sensor1, 10);  // 10-bit = faster
}

void loop() {
    sensors.requestTemperatures();

    Serial.print("Sensor 1: ");
    Serial.print(sensors.getTempC(sensor1));
    Serial.print("°C  Sensor 2: ");
    Serial.print(sensors.getTempC(sensor2));
    Serial.print("°C  Sensor 3: ");
    Serial.print(sensors.getTempC(sensor3));
    Serial.println("°C");

    delay(1000);
}

void printAddress(DeviceAddress addr) {
    for (int i = 0; i < 8; i++) {
        if (addr[i] < 16) Serial.print("0");
        Serial.print(addr[i], HEX);
    }
    Serial.println();
}
```

### Address Discovery

```cpp
#include <OneWire.h>

OneWire ds(4);

void setup() {
    Serial.begin(115200);
    byte addr[8];

    Serial.println("Scanning for 1-Wire devices...");

    while (ds.search(addr)) {
        Serial.print("ROM = ");
        for (int i = 0; i < 8; i++) {
            Serial.print(addr[i], HEX);
            Serial.print(" ");
        }

        if (OneWire::crc8(addr, 7) != addr[7]) {
            Serial.println(" (CRC ERROR!)");
        } else {
            Serial.println(" (CRC OK)");
        }
    }

    ds.reset_search();
    Serial.println("Done.");
}

void loop() {}
```

---

## Practical Tips

### Wiring for Multiple Sensors

- Use Cat5/Cat6 cable for running to remote sensors (use one pair for DQ+GND, another for Vcc+GND)
- Keep total cable length under 100m for reliable operation (shorter is better)
- Use 3-wire (powered) mode for long cables
- Add a 100-150Ω resistor in series with DQ near the master to reduce reflections on long cables

### Maximizing Reliability

1. **Use external power** (Vcc connected), not parasitic mode
2. **Use quality pull-up:** 4.7kΩ for short cables, 2.2kΩ for long cables
3. **Star topology is OK** but a linear bus (daisy chain) with short stubs is better for long runs
4. **Add CRC checking** in your code — the DS18B20 provides CRC on all data
5. **Check for -127°C or 85°C readings** — these indicate communication errors or device not ready:
   - -127°C = device not found or communication error
   - 85°C = power-on reset value (conversion not complete)

### ESP32 Considerations

The 1-Wire protocol is timing-critical (microsecond precision). On ESP32:
- Disable interrupts during 1-Wire operations can help (the OneWire library handles this)
- WiFi interrupts can occasionally cause timing issues — retry on CRC errors
- Use a dedicated GPIO away from strapping pins
- The OneWire library works on ESP32 without modification

### DS2401 Silicon Serial Number

A simple 1-Wire device with just a 64-bit ROM code — no other functionality. Useful for:
- Board identification
- Licensing/anti-counterfeit
- Asset tracking
- Unique device addressing

Read it with the `Read ROM (0x33)` command (works when it's the only device on the bus) or `Search ROM (0xF0)` to enumerate.
