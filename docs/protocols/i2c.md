# I2C Protocol

## Overview

I2C (Inter-Integrated Circuit, pronounced "I-squared-C" or "I-two-C") is a two-wire synchronous serial protocol for communication between ICs on the same board or short distances.

```
              ┌─── Device 1 (sensor)
              │
MCU ──SDA────┼─── Device 2 (EEPROM)
     SCL─────┤
              │
              ├─── Device 3 (DAC)
              │
             GND (shared)
```

**Key characteristics:**
- **Two wires:** SDA (data) and SCL (clock)
- **Master-slave:** Master initiates all communication
- **Addressing:** 7-bit (up to 127 devices) or 10-bit (rare)
- **Half-duplex:** Data flows one direction at a time
- **Open-drain:** Both lines are pulled HIGH by external resistors; devices can only pull LOW
- **Multi-master capable** (but rarely used in practice)

---

## Electrical Specifications

### Pull-Up Resistors

I2C lines are open-drain — they need external pull-up resistors to Vcc.

```
Vcc ──[R_p]──┬── SDA line ──── SDA pins of all devices
              │
Vcc ──[R_p]──┬── SCL line ──── SCL pins of all devices
              │
             GND (common to all)
```

| Speed Mode  | Clock Rate | Typical R_p (3.3V) | Typical R_p (5V) |
|------------|-----------|--------------------|--------------------|
| Standard   | 100 kHz    | 4.7kΩ              | 4.7kΩ              |
| Fast       | 400 kHz    | 2.2kΩ              | 2.2kΩ              |
| Fast+      | 1 MHz      | 1kΩ                | 1kΩ                |
| High Speed | 3.4 MHz    | External driver     | External driver     |

**Pull-up value depends on bus capacitance:**
- Lower resistance = faster rise times = higher speed possible
- Higher resistance = less power consumption
- Too low = device can't pull the line LOW (min ~1kΩ)
- Too high = slow rise times, signal integrity issues
- Bus capacitance limit: 400pF max (standard mode)

**Rule of thumb:** Use 4.7kΩ for most hobby applications at 100kHz. Use 2.2kΩ for 400kHz or when you have multiple devices on the bus.

### Only ONE Set of Pull-Ups

**Never use more than one set of pull-up resistors on the same bus.** Many breakout boards include pull-ups — if you connect multiple boards with pull-ups, the effective resistance drops too low.

Check breakout boards for pull-ups (usually labeled on the PCB or schematic). Desolder or cut the trace to disable extras if needed.

---

## Protocol Details

### Start and Stop Conditions

```
Start: SDA goes LOW while SCL is HIGH
Stop:  SDA goes HIGH while SCL is HIGH

     SCL: ────────┐  ┌──┐  ┌──┐  ┌──┐  ┌────────
                   └──┘  └──┘  └──┘  └──┘
     SDA: ──┐                              ┌──────
            └──────── data bits ──────────┘
          Start                           Stop
```

### Address Frame

After the start condition, the master sends a 7-bit device address + 1 R/W bit:

```
| Start | A6 | A5 | A4 | A3 | A2 | A1 | A0 | R/W | ACK |
|-------|----|----|----|----|----|----|-----|-----|-----|
  ↑       ↑ 7-bit address (MSB first) ↑     ↑      ↑
  |                                         |      |
  Master                                  0=Write  Slave pulls
  generates                               1=Read   SDA LOW
```

### Data Transfer

After the address byte is acknowledged, data bytes follow:

```
Write: Master sends data byte → Slave ACKs each byte
Read:  Slave sends data byte → Master ACKs each byte (NACK on last byte to end)
```

Each byte is 8 bits, MSB first, followed by an ACK/NACK bit.

### Register Read/Write

Most I2C devices use a register-based model:

**Register Write (e.g., configure a sensor):**
```
Start → [Device Address + W] → ACK → [Register Address] → ACK → [Data] → ACK → Stop
```

**Register Read (e.g., read sensor data):**
```
Start → [Device Address + W] → ACK → [Register Address] → ACK →
Repeated Start → [Device Address + R] → ACK → [Data from slave] → NACK → Stop
```

The repeated start sets the register pointer, then switches to read mode.

### Clock Stretching

A slow slave device can hold SCL LOW to pause the master while it processes data. The master must wait for SCL to go HIGH before continuing.

Some masters (notably the Raspberry Pi hardware I2C) have buggy clock stretching support. If you encounter issues, try:
- Reducing I2C speed
- Using software I2C (bit-banging)
- Adding a delay in the slave firmware

---

## Common Issues and Debugging

### No Response from Device

1. **Wrong address** — I2C addresses are specified inconsistently. Some datasheets give the 8-bit address (including R/W bit), some give the 7-bit address. An "8-bit address" of 0xD0 = 7-bit address 0x68
2. **Missing pull-up resistors** — most common issue
3. **SDA/SCL swapped** — easy wiring mistake
4. **Wrong voltage** — 3.3V device on 5V bus (or vice versa) without level shifter
5. **Device in reset/sleep** — check enable pins
6. **Address pin configuration** — many devices have A0/A1/A2 pins that set lower address bits. Check if they need to be tied HIGH or LOW

### Bus Lockup

If a slave device is interrupted mid-transaction (MCU reset during communication), the slave may hold SDA LOW, locking the bus.

**Recovery:**
1. Toggle SCL manually (9+ clock pulses) while SDA is released — this completes the slave's pending byte
2. Then send a Stop condition
3. Some MCUs have I2C bus recovery built into the HAL

**Arduino bus recovery:**
```cpp
// Manual clock pulse recovery
pinMode(SDA_PIN, INPUT);
pinMode(SCL_PIN, OUTPUT);
for (int i = 0; i < 9; i++) {
    digitalWrite(SCL_PIN, HIGH);
    delayMicroseconds(5);
    digitalWrite(SCL_PIN, LOW);
    delayMicroseconds(5);
}
// Now reinitialize I2C
Wire.begin();
```

### Signal Integrity Issues

- **Slow rise times** (rounded signal edges) — pull-up resistance too high, or too much bus capacitance. Use lower pull-up values
- **Ringing/overshoot** — pull-up resistance too low, or long wires acting as transmission lines. Use higher pull-up values
- **Crosstalk** — route SDA and SCL apart from noisy signals
- **Long cables** — I2C is designed for on-board communication (<1 meter). For longer distances, use I2C extender ICs (P82B715, PCA9600) or switch to RS-485

---

## Scanning for Devices

### Arduino I2C Scanner

```cpp
#include <Wire.h>

void setup() {
    Wire.begin();
    Serial.begin(115200);
    Serial.println("I2C Scanner");
}

void loop() {
    Serial.println("Scanning...");
    int found = 0;
    for (byte addr = 1; addr < 127; addr++) {
        Wire.beginTransmission(addr);
        if (Wire.endTransmission() == 0) {
            Serial.print("Device found at 0x");
            Serial.println(addr, HEX);
            found++;
        }
    }
    Serial.print("Found ");
    Serial.print(found);
    Serial.println(" device(s).");
    delay(5000);
}
```

### Linux (Raspberry Pi)

```bash
# List I2C buses
ls /dev/i2c-*

# Scan bus 1 (default on modern Pi)
i2cdetect -y 1

# Read a register from device 0x68, register 0x75
i2cget -y 1 0x68 0x75

# Write 0x00 to device 0x68, register 0x6B
i2cset -y 1 0x68 0x6B 0x00

# Dump all registers of device 0x68
i2cdump -y 1 0x68
```

### ESP32 (Arduino framework)

```cpp
#include <Wire.h>

void setup() {
    Serial.begin(115200);
    Wire.begin(21, 22);  // SDA=21, SCL=22 (ESP32 defaults)
    // Can also use any GPIO: Wire.begin(SDA_PIN, SCL_PIN);

    for (byte addr = 1; addr < 127; addr++) {
        Wire.beginTransmission(addr);
        if (Wire.endTransmission() == 0) {
            Serial.printf("Found: 0x%02X\n", addr);
        }
    }
}
```

---

## Level Shifting for Mixed Voltage Buses

When mixing 3.3V and 5V I2C devices:

### BSS138 MOSFET Level Shifter (Bidirectional)

```
3.3V side                          5V side

SDA_3V3 ──┬── S ─[BSS138]─ D ──┬── SDA_5V
           │      Gate          │
        [4.7kΩ]    │         [4.7kΩ]
           │      3.3V          │
         3.3V                  5V

(Same circuit for SCL)
```

This is the standard method. Pre-built modules are available for a few dollars.

### Dedicated I2C Level Shifter ICs

- **PCA9306** — bidirectional I2C level translator, no pull-ups needed on one side
- **TXS0102** — auto-direction level translator (works but can have issues with I2C)
- **PCA9517** — I2C hub with level shifting and bus buffering

---

## Common I2C Devices and Addresses

| Device              | Description                    | Default Address | Alt Addresses     |
|--------------------|-------------------------------|-----------------|-------------------|
| SSD1306            | 128×64 OLED display           | 0x3C            | 0x3D              |
| BMP280             | Pressure/temperature sensor   | 0x76            | 0x77              |
| BME280             | Pressure/humidity/temp sensor | 0x76            | 0x77              |
| MPU6050            | 6-axis IMU (accel+gyro)       | 0x68            | 0x69              |
| DS3231             | Real-time clock               | 0x68            | (fixed)           |
| ADS1115            | 16-bit ADC                    | 0x48            | 0x49, 0x4A, 0x4B |
| MCP4725            | 12-bit DAC                    | 0x60            | 0x61              |
| PCA9685            | 16-ch PWM driver              | 0x40            | 0x40-0x7F (6 addr bits) |
| PCF8574            | 8-bit GPIO expander           | 0x20            | 0x20-0x27         |
| AT24C32/64/128/256 | EEPROM                        | 0x50            | 0x50-0x57         |
| INA219             | Current/power monitor         | 0x40            | 0x40-0x4F         |
| HTU21D/SHT30       | Humidity/temp sensor          | 0x40 / 0x44     | varies            |
| TSL2561            | Light sensor                  | 0x39            | 0x29, 0x49        |
| VL53L0X            | Time-of-flight distance       | 0x29            | (configurable in SW)|
| MCP23017           | 16-bit GPIO expander          | 0x20            | 0x20-0x27         |

**Note:** Some devices share the same default address (MPU6050 and DS3231 are both 0x68, INA219 and PCA9685 both 0x40). Check address pin configurations or use an I2C multiplexer (TCA9548A) to resolve conflicts.

### I2C Multiplexer

The **TCA9548A** provides 8 I2C sub-buses, allowing you to use multiple devices with the same address:

```cpp
// Select channel 0
Wire.beginTransmission(0x70);  // TCA9548A address
Wire.write(1 << 0);            // Channel 0
Wire.endTransmission();

// Now communicate with devices on channel 0
```
