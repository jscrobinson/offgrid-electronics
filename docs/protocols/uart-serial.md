# UART / Serial Communication

## Overview

UART (Universal Asynchronous Receiver/Transmitter) is an asynchronous serial protocol — the most basic and widely used serial communication method.

```
  Device A                Device B
  ┌──────┐               ┌──────┐
  │   TX ├──────────────►│ RX   │
  │   RX │◄──────────────┤ TX   │
  │  GND ├───────────────┤ GND  │
  └──────┘               └──────┘

Note: TX→RX crossover! TX of one device connects to RX of the other.
```

**Key characteristics:**
- **Asynchronous** — no clock signal; both sides must agree on baud rate
- **Two wires** — TX (transmit) and RX (receive), plus ground
- **Full duplex** — can send and receive simultaneously
- **Point-to-point** — typically two devices only (one TX, one RX)
- **No addressing** — direct connection between two devices

---

## Frame Format

Each byte is transmitted as a frame:

```
Idle ─── Start ─── D0 ─── D1 ─── D2 ─── D3 ─── D4 ─── D5 ─── D6 ─── D7 ─── [Parity] ─── Stop ─── Idle
 (HIGH)  (LOW)         8 data bits (LSB first)                            (optional)   (HIGH)  (HIGH)
```

### Standard Configuration: 8N1

- **8** data bits
- **N** no parity
- **1** stop bit

This is the default for nearly everything. Other configurations (7E1, 8O1, 8N2, etc.) exist but are uncommon outside industrial applications.

### Parity Bit (Optional)

- **None** — no error checking (most common)
- **Even** — parity bit set so total 1-bits (including parity) is even
- **Odd** — parity bit set so total 1-bits (including parity) is odd

Parity only detects single-bit errors and is rarely used in modern applications. Higher-level protocols implement better error checking (checksums, CRC).

---

## Baud Rate

Baud rate is the number of signal transitions (bits) per second. Both devices **must use the same baud rate**.

### Common Baud Rates

| Baud Rate | Bytes/sec (8N1) | Common Use                        |
|-----------|----------------|-----------------------------------|
| 300       | ~30            | Legacy, very slow                  |
| 1200      | ~120           | Legacy modems                      |
| 2400      | ~240           | Slow sensors (some GPS default)    |
| 4800      | ~480           | Some GPS modules                   |
| 9600      | ~960           | Default for many devices, Arduino Serial Monitor default |
| 19200     | ~1,920         | Medium speed                       |
| 38400     | ~3,840         | Medium speed                       |
| 57600     | ~5,760         | Common for faster comms            |
| 115200    | ~11,520        | Fast, very common for modern devices |
| 230400    | ~23,040        | High speed                         |
| 460800    | ~46,080        | High speed                         |
| 921600    | ~92,160        | ESP32 default debug output         |
| 1000000   | ~100,000       | 1 Mbaud, some high-speed devices   |

**At 8N1:** Each byte needs 10 bit-times (1 start + 8 data + 1 stop), so effective byte rate ≈ baud/10.

**Use 115200 as your default** for new projects. It's fast enough for most purposes and universally supported. Use 9600 only when the device requires it or for maximum reliability on noisy links.

### Baud Rate Mismatch

If baud rates don't match, you'll see garbled characters or no data at all. Common symptoms:
- Receiving random/garbage characters → baud rate mismatch (usually a factor of 2x or some other ratio)
- Receiving nothing → baud rate very wrong, or TX/RX not connected
- Occasional errors → baud rate slightly off (clock tolerance issue)

**Clock tolerance:** UART requires <3-5% baud rate error between the two devices. Crystal oscillators are precise enough; internal RC oscillators may need calibration.

---

## Voltage Levels

### TTL UART (Logic Level)

What microcontrollers and most modules use:

| Logic | 3.3V TTL  | 5V TTL    |
|-------|-----------|-----------|
| HIGH  | 3.3V      | 5.0V      |
| LOW   | 0V        | 0V        |
| Idle  | HIGH      | HIGH      |

### RS-232

The original serial standard (DB-9/DB-25 connector on old PCs):

| Logic   | Voltage        |
|---------|----------------|
| Mark (1)| -3V to -15V   |
| Space (0)| +3V to +15V  |

**RS-232 voltages will damage microcontrollers!** Use a level converter (MAX232, MAX3232) between RS-232 and TTL.

### RS-485

Differential signaling for long-distance, multi-drop serial:

| State | A-B Voltage |
|-------|-------------|
| Logic 1 (Mark) | A < B (negative) |
| Logic 0 (Space) | A > B (positive) |

RS-485 supports distances up to 1200m and multi-drop (multiple devices on one bus). Used heavily in industrial/Modbus applications.

---

## USB-to-Serial Adapters

Most modern computers lack native serial ports. USB-to-serial adapters bridge USB to TTL UART.

| Chip    | Voltage | Max Baud  | Driver Support       | Notes                      |
|---------|---------|-----------|---------------------|----------------------------|
| FTDI FT232R | 3.3V/5V | 3 Mbaud | Excellent (all OS)  | Gold standard, reliable    |
| CP2102  | 3.3V    | 1 Mbaud   | Good (all OS)        | Silicon Labs, common       |
| CP2104  | 3.3V    | 2 Mbaud   | Good (all OS)        | Upgraded CP2102            |
| CH340G  | 3.3V/5V | 2 Mbaud   | Good (recent drivers)| Very cheap, most common on cheap boards |
| CH9102  | 3.3V    | 4 Mbaud   | Good                 | Newer CH340 replacement    |
| PL2303  | 3.3V    | 1 Mbaud   | Problematic (Win 10+)| Older chip, driver issues  |

**CH340G is on most cheap Arduino clones and ESP32 boards.** Works well — just install the CH340 driver if your OS doesn't include it.

**FTDI FT232R is the most reliable** for critical applications. Available on SparkFun and Adafruit breakouts.

### Wiring USB-to-Serial Adapter to MCU

```
Adapter         MCU
TX      ──────► RX
RX      ◄────── TX
GND     ──────  GND
3.3V/5V ──────  VCC (if powering MCU from adapter)

IMPORTANT: TX↔RX crossover!
```

---

## Flow Control

### No Flow Control (Most Common)

No handshaking — data is sent whenever ready. Works fine for most MCU applications where the receiver can keep up.

### Hardware Flow Control (RTS/CTS)

```
Device A          Device B
RTS  ──────────►  CTS    "I want to send"
CTS  ◄──────────  RTS    "I'm ready to receive"
```

- **RTS** (Request To Send): Output — asserted when the device wants to transmit
- **CTS** (Clear To Send): Input — asserted when the remote device is ready to receive

Used when:
- High data rates where buffer overflow is possible
- Bluetooth serial modules (HC-05, HM-10)
- Some GPS modules

### Software Flow Control (XON/XOFF)

Uses special characters in the data stream:
- **XOFF** (0x13, Ctrl-S): Pause transmission
- **XON** (0x11, Ctrl-Q): Resume transmission

Rarely used in embedded systems — complicates binary data transfer.

---

## Logic Level Converters for Mixed Voltage

### 3.3V Device ↔ 5V Device

**3.3V TX → 5V RX:** Usually works directly. Most 5V devices recognize 3.3V as HIGH (above their Vih threshold of ~2.0V).

**5V TX → 3.3V RX:** Needs conversion. Options:
1. **Resistor divider:** 1kΩ + 2kΩ divider (5V × 2k/(1k+2k) = 3.33V)
2. **BSS138 MOSFET level shifter** (bidirectional)
3. **Dedicated converter** (TXB0104, 74LVC1T45)

```
Simple 5V to 3.3V for UART RX:

5V TX ──[1kΩ]──┬── 3.3V device RX
               │
            [2kΩ]
               │
              GND
```

---

## Arduino Serial Example

```cpp
void setup() {
    Serial.begin(115200);    // USB serial (to computer)
    Serial1.begin(9600);     // Hardware UART1 (pins 0/1 on Mega, varies by board)
}

void loop() {
    // Forward data between USB serial and hardware serial
    if (Serial.available()) {
        Serial1.write(Serial.read());
    }
    if (Serial1.available()) {
        Serial.write(Serial1.read());
    }
}
```

### Software Serial (Arduino Uno)

The Uno has only one hardware UART (shared with USB). Use SoftwareSerial for additional ports:

```cpp
#include <SoftwareSerial.h>

SoftwareSerial gpsSerial(4, 3);  // RX=4, TX=3

void setup() {
    Serial.begin(115200);
    gpsSerial.begin(9600);
}

void loop() {
    while (gpsSerial.available()) {
        Serial.write(gpsSerial.read());
    }
}
```

**Limitations of SoftwareSerial:** Blocks interrupts during receive, unreliable above 57600 baud, cannot receive on multiple ports simultaneously. Use hardware serial whenever possible.

### ESP32 Serial

ESP32 has three hardware UARTs:

```cpp
// UART0: Default serial (USB), pins GPIO1(TX), GPIO3(RX)
Serial.begin(115200);

// UART1: Remappable to any GPIO
Serial1.begin(9600, SERIAL_8N1, 16, 17);  // RX=16, TX=17

// UART2: Remappable to any GPIO
Serial2.begin(9600, SERIAL_8N1, 26, 27);  // RX=26, TX=27
```

---

## Common UART Devices

| Device          | Default Baud | Notes                                |
|----------------|-------------|--------------------------------------|
| GPS (NEO-6M)   | 9600        | NMEA sentences, can configure higher |
| GPS (NEO-M8N)  | 9600        | UBX + NMEA, configurable             |
| HC-05 Bluetooth| 9600/38400  | AT commands at 38400, data at 9600   |
| HM-10 BLE      | 9600        | AT commands and data                 |
| ESP-01 (ESP8266)| 115200     | AT commands for WiFi                 |
| SIM800L (GSM)  | 9600/115200 | AT commands for cellular             |
| RFID (RDM6300) | 9600        | 125kHz RFID reader                   |
| Fingerprint (R307)| 57600    | Serial fingerprint sensor            |
| MP3 player (DFPlayer)| 9600  | Serial MP3/WAV player                |
| LoRa (REYAX)   | 115200      | AT commands for LoRa serial modules  |
| Debug console   | 115200      | Linux/Pi serial console              |
| RS-485 devices  | 9600-115200 | Via MAX485/RS-485 transceiver        |

---

## Debugging UART

### Common Problems

| Symptom                    | Cause                          | Fix                           |
|---------------------------|--------------------------------|-------------------------------|
| No data received          | TX/RX swapped                  | Swap TX and RX wires          |
| No data received          | Wrong baud rate                | Try common rates: 9600, 115200|
| Garbled characters        | Baud rate mismatch             | Match baud rates exactly      |
| Garbled characters        | Wrong voltage levels           | Add level converter           |
| First char corrupted      | Receiver not ready             | Add startup delay             |
| Data loss at high speed   | Buffer overflow                | Add flow control or reduce rate|
| Works sometimes           | Ground not connected           | Connect GND between devices   |
| É instead of é            | Character encoding mismatch    | Match UTF-8/ASCII settings    |

### Logic Analyzer for UART Debugging

Connect a logic analyzer to the TX and/or RX line. Set the protocol decoder to "UART" with the expected baud rate. This shows you exactly what bytes are being sent and can auto-detect baud rate.

### Terminal Programs

| Program   | Platform       | Notes                               |
|----------|----------------|-------------------------------------|
| Arduino Serial Monitor | All | Built into Arduino IDE             |
| PuTTY    | Windows        | Classic terminal emulator            |
| CoolTerm | Win/Mac/Linux  | Good for raw binary                  |
| minicom  | Linux          | Command-line terminal                |
| screen   | Linux/Mac      | `screen /dev/ttyUSB0 115200`         |
| picocom  | Linux          | Lightweight, `picocom -b 115200 /dev/ttyUSB0` |
| Tera Term| Windows        | Feature-rich, macros                 |

### Linux Serial Device Names

```
/dev/ttyUSB0   — USB-to-serial adapter (CH340, FTDI, CP2102)
/dev/ttyACM0   — USB CDC (Arduino Leonardo, ESP32-S2/S3, Pi Pico)
/dev/ttyS0     — Built-in serial port (Pi GPIO UART)
/dev/ttyAMA0   — Pi hardware UART (primary)
```

### Permission Issues on Linux

```bash
# Add user to dialout group (logout/login required)
sudo usermod -aG dialout $USER

# Or quick fix (temporary)
sudo chmod 666 /dev/ttyUSB0
```
