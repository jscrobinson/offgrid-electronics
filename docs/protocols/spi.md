# SPI Protocol

## Overview

SPI (Serial Peripheral Interface) is a synchronous, full-duplex serial protocol for high-speed communication between a master and one or more slave devices.

```
         MCU (Master)              Slave Device
        ┌──────────┐              ┌──────────┐
        │     MOSI ├─────────────►│ MOSI/SDI │  (Master Out, Slave In)
        │     MISO │◄─────────────┤ MISO/SDO │  (Master In, Slave Out)
        │      SCK ├─────────────►│ SCK/SCLK │  (Serial Clock)
        │   CS/SS  ├─────────────►│ CS/SS    │  (Chip Select, active LOW)
        └──────────┘              └──────────┘
```

**Key characteristics:**
- **Four wires:** MOSI, MISO, SCK, CS (per device)
- **Master-slave:** Master generates clock and controls CS
- **Full duplex:** Data transmitted and received simultaneously
- **No addressing:** Each slave has its own CS line
- **No ACK mechanism:** Master has no way to know if slave received data
- **High speed:** Typically 1-80 MHz (device dependent)
- **No pull-up resistors needed** (push-pull outputs)

### Signal Names (Varies by Manufacturer)

| Traditional   | Newer Names     | Description              |
|--------------|-----------------|--------------------------|
| MOSI         | SDI, DIN, SI    | Master Out → Slave In    |
| MISO         | SDO, DOUT, SO   | Master In ← Slave Out    |
| SCK          | SCLK, CLK       | Serial Clock             |
| SS, CS       | CSN, nCS, CE    | Chip Select (active LOW) |

**Note:** The terms MOSI/MISO are being replaced in newer documentation with SDI/SDO (from the device's perspective) or COPI/CIPO (Controller Out Peripheral In / Controller In Peripheral Out) to use more inclusive terminology.

---

## Clock Modes (CPOL / CPHA)

SPI has four clock modes defined by two parameters:
- **CPOL** (Clock Polarity): Idle state of the clock (0=LOW, 1=HIGH)
- **CPHA** (Clock Phase): Which edge data is sampled on (0=first/leading, 1=second/trailing)

| Mode | CPOL | CPHA | Clock Idle | Data Sampled On   | Data Changed On    |
|------|------|------|-----------|-------------------|--------------------|
| 0    | 0    | 0    | LOW       | Rising edge       | Falling edge       |
| 1    | 0    | 1    | LOW       | Falling edge      | Rising edge        |
| 2    | 1    | 0    | HIGH      | Falling edge      | Rising edge        |
| 3    | 1    | 1    | HIGH      | Rising edge       | Falling edge       |

**Mode 0 is the most common** and is the default for most devices.

```
Mode 0 (CPOL=0, CPHA=0):

SCK:  ___┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐___
         │  ││  ││  ││  ││  ││  ││  ││  │
MOSI: ===X====X====X====X====X====X====X====X===
         D7   D6   D5   D4   D3   D2   D1   D0
         ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑
      Data sampled on rising edge

CS:   ───┘                                    └───
```

**Check the slave device's datasheet for the required SPI mode.** Using the wrong mode results in garbled data.

### Common Device SPI Modes

| Device Type          | Typical Mode | Notes                    |
|---------------------|-------------|--------------------------|
| SD cards            | Mode 0      | SPI mode during init     |
| SPI Flash (W25Q)    | Mode 0 or 3 | Both work                |
| SX1276/8 (LoRa)    | Mode 0      |                          |
| nRF24L01            | Mode 0      | Max 10 MHz               |
| MAX31855/MAX6675    | Mode 0      | Thermocouple reader      |
| ILI9341 (display)   | Mode 0      | Up to 40-80 MHz          |
| ADS1256 (ADC)       | Mode 1      | Note: not mode 0         |
| MCP3008 (ADC)       | Mode 0      | 10-bit, 8 channels       |
| ENC28J60 (Ethernet) | Mode 0      | Max 20 MHz               |

---

## Bit Order

**MSB first** (most significant bit first) is the default for the vast majority of SPI devices.

Some exceptions exist (e.g., certain LED drivers). Always check the datasheet.

---

## CS (Chip Select) Line

- **Active LOW** — device is selected when CS is driven LOW
- Each slave needs its own CS line from the master
- CS must go LOW before communication and HIGH after
- Some devices require CS to stay LOW for the entire transaction; others allow it to toggle between bytes

```
CS:   ─────┐                          ┌─────
           └──────────────────────────┘
SCK:  _____╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲____
MOSI: _____╳ byte 1  ╳ byte 2  ╳________
MISO: _____╳ byte 1  ╳ byte 2  ╳________
```

### Multiple Devices on One Bus

```
         MCU
        ┌───────┐
   MOSI │       ├──────────┬──── MOSI (Device A)
   MISO │       │◄─────────┤◄─── MISO (Device A)
    SCK │       ├──────────┼──── SCK  (Device A)
        │       │          │
    CS0 │       ├─────────►│ CS (Device A)
        │       │
    CS1 │       ├─────────►│ CS (Device B)
        │       │          │
   MOSI │       ├──────────┴──── MOSI (Device B)
   MISO │       │◄─────────┴◄─── MISO (Device B)
    SCK │       ├──────────┴──── SCK  (Device B)
        └───────┘
```

MOSI, MISO, and SCK are shared. Each device has its own CS line. **Only one CS should be LOW at a time.**

When CS is HIGH, the slave's MISO pin should go high-impedance (tri-state) so it doesn't interfere with other devices on the bus.

---

## Daisy Chaining

Some SPI devices support daisy chaining — data shifts through multiple devices on a single CS line:

```
MCU MOSI → MOSI[Dev1]MISO → MOSI[Dev2]MISO → MISO MCU
                CS ←──────────── CS ←──────── CS (shared)
```

Used in LED drivers (e.g., MAX7219 LED matrix) and shift registers (74HC595). Each device passes data through to the next.

---

## Software vs Hardware SPI

### Hardware SPI

- Uses the MCU's dedicated SPI peripheral
- Fixed pins (determined by the MCU)
- Faster (peripheral handles clocking)
- Non-blocking possible with DMA
- Limited number of SPI buses (usually 1-3)

**Arduino Uno hardware SPI pins:**
- MOSI: pin 11
- MISO: pin 12
- SCK: pin 13
- CS: any GPIO

**ESP32 hardware SPI:**
- VSPI (default): MOSI=23, MISO=19, SCK=18, CS=5
- HSPI: MOSI=13, MISO=12, SCK=14, CS=15
- Can be remapped to any GPIO

### Software SPI (Bit-Banging)

- Uses any GPIO pins
- Slower (MCU toggles pins manually)
- Blocks CPU during transfer
- Useful when hardware SPI pins are unavailable or you need more SPI buses

```cpp
// Simple software SPI byte transfer (Mode 0)
uint8_t softSPI_transfer(uint8_t data) {
    uint8_t received = 0;
    for (int i = 7; i >= 0; i--) {
        // Set MOSI
        digitalWrite(MOSI_PIN, (data >> i) & 1);
        // Clock HIGH — slave samples
        digitalWrite(SCK_PIN, HIGH);
        // Read MISO
        received |= (digitalRead(MISO_PIN) << i);
        // Clock LOW — prepare next bit
        digitalWrite(SCK_PIN, LOW);
    }
    return received;
}
```

---

## Arduino SPI Example

```cpp
#include <SPI.h>

const int CS_PIN = 10;

void setup() {
    pinMode(CS_PIN, OUTPUT);
    digitalWrite(CS_PIN, HIGH);  // Deselect device
    SPI.begin();
}

void readRegister(uint8_t reg) {
    SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE0));
    digitalWrite(CS_PIN, LOW);
    SPI.transfer(reg | 0x80);     // Set read bit (device-specific)
    uint8_t value = SPI.transfer(0x00);  // Clock out data
    digitalWrite(CS_PIN, HIGH);
    SPI.endTransaction();
    return value;
}

void writeRegister(uint8_t reg, uint8_t value) {
    SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE0));
    digitalWrite(CS_PIN, LOW);
    SPI.transfer(reg & 0x7F);    // Clear read bit (device-specific)
    SPI.transfer(value);
    digitalWrite(CS_PIN, HIGH);
    SPI.endTransaction();
}
```

---

## ESP32 SPI Example

```cpp
#include <SPI.h>

// Use VSPI (default)
SPIClass *vspi = new SPIClass(VSPI);
const int CS_PIN = 5;

void setup() {
    vspi->begin(18, 19, 23, CS_PIN);  // SCK, MISO, MOSI, CS
    pinMode(CS_PIN, OUTPUT);
    digitalWrite(CS_PIN, HIGH);
}

uint8_t readReg(uint8_t reg) {
    vspi->beginTransaction(SPISettings(4000000, MSBFIRST, SPI_MODE0));
    digitalWrite(CS_PIN, LOW);
    vspi->transfer(reg | 0x80);
    uint8_t val = vspi->transfer(0x00);
    digitalWrite(CS_PIN, HIGH);
    vspi->endTransaction();
    return val;
}
```

---

## Common SPI Devices

| Device          | Type                  | Max SPI Speed | Mode | Notes                      |
|----------------|-----------------------|---------------|------|----------------------------|
| ILI9341        | 320×240 TFT display  | 40-80 MHz     | 0    | Color LCD, cheap modules   |
| ST7789         | 240×240 TFT display  | 80 MHz        | 0    | IPS display, good colors   |
| SD card        | Storage               | 25 MHz (SD)   | 0    | Also supports SDIO         |
| W25Q32/64/128  | SPI Flash             | 80 MHz        | 0/3  | 4-64MB NOR flash           |
| SX1276/SX1262  | LoRa transceiver      | 10 MHz        | 0    | Long range radio           |
| nRF24L01+      | 2.4GHz radio          | 10 MHz        | 0    | Short range wireless       |
| MCP3008        | 10-bit ADC, 8-ch      | 3.6 MHz       | 0    | Simple analog input        |
| ADS1256        | 24-bit ADC            | ~2 MHz        | 1    | Precision measurement      |
| MAX31855       | Thermocouple reader   | 5 MHz         | 0    | K-type thermocouple        |
| ENC28J60       | Ethernet controller   | 20 MHz        | 0    | 10 Mbps Ethernet           |
| MAX7219        | LED matrix driver     | 10 MHz        | 0    | Daisy-chainable            |
| BME280         | Pressure/humidity/temp| 10 MHz        | 0    | Also supports I2C          |
| RFM95W/RFM96W | LoRa module           | 10 MHz        | 0    | HopeRF, SX1276-based       |

---

## SPI vs I2C Comparison

| Feature         | SPI                    | I2C                     |
|----------------|------------------------|-------------------------|
| Wires          | 4 + 1 CS per device    | 2 (shared)              |
| Speed          | 1-80+ MHz              | 100kHz-3.4MHz           |
| Duplex         | Full                   | Half                    |
| Addressing     | CS line per device     | 7-bit address           |
| Pull-ups       | Not needed             | Required                |
| Max devices    | Limited by CS pins     | 127 (address limit)     |
| Complexity     | Simple protocol        | More complex            |
| Distance       | Short (board level)    | Short (board level)     |
| Use when       | Speed matters, few devices | Many devices, few pins |

---

## Troubleshooting SPI

| Problem                      | Likely Cause                           | Fix                                |
|-----------------------------|----------------------------------------|------------------------------------|
| No response from device      | CS not going LOW, wrong wiring         | Check CS logic, verify connections |
| Garbled data                 | Wrong SPI mode (CPOL/CPHA)             | Check device datasheet, try mode 0 |
| Only reads 0xFF             | MISO not connected, device not responding | Check wiring, verify CS works   |
| Only reads 0x00             | Device powered off, wrong CS pin       | Verify power, check CS pin        |
| Intermittent errors          | Speed too high, signal integrity       | Reduce SPI clock speed            |
| Works alone, fails with other devices | CS not releasing MISO (tri-state) | Check CS wiring, add delays    |
| Data shifted by one bit     | Wrong bit order (MSB vs LSB)           | Toggle MSBFIRST/LSBFIRST          |
