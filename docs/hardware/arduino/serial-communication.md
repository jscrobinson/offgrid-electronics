# Arduino Serial Communication

## Overview

Serial (UART) communication is the primary way an Arduino communicates with a computer, other microcontrollers, GPS modules, Bluetooth modules, and many other devices. It sends data one bit at a time over two wires (TX and RX).

### Hardware UART Ports

| Board | Ports | TX/RX Pins | Notes |
|-------|-------|------------|-------|
| Uno/Nano | 1 | 0/1 (shared with USB) | SoftwareSerial for additional ports |
| Mega 2560 | 4 | Serial: 1/0, Serial1: 18/19, Serial2: 16/17, Serial3: 14/15 | |
| Nano 33 IoT | 2 | Serial (USB), Serial1: pins 1/0 | |

On the Uno/Nano, the single UART is shared between USB and pins 0/1. You cannot use these pins for other serial devices while also using the serial monitor.

---

## Basic Serial Output

### Initialization

```cpp
void setup() {
    Serial.begin(9600);   // Start serial at 9600 baud
    // Common baud rates: 300, 1200, 2400, 4800, 9600, 19200,
    //                    38400, 57600, 74880, 115200, 230400

    while (!Serial);      // Wait for serial port to connect
                          // Only needed for boards with native USB (Leonardo, Nano 33 IoT)
                          // On Uno this returns immediately
}
```

### Printing Data

```cpp
Serial.print("Hello");          // Print string (no newline)
Serial.println("World");        // Print string + newline (\r\n)
Serial.println();               // Just a newline

// Numbers
Serial.println(42);             // Print integer: "42"
Serial.println(3.14159);        // Print float: "3.14"  (default 2 decimal places)
Serial.println(3.14159, 4);     // Print float: "3.1416" (4 decimal places)

// Number bases
Serial.println(255, BIN);       // "11111111"
Serial.println(255, OCT);       // "377"
Serial.println(255, HEX);       // "FF"
Serial.println(255, DEC);       // "255" (default)

// Raw bytes
Serial.write(65);               // Sends byte value 65 (ASCII 'A')
Serial.write("raw data", 8);    // Send buffer of specified length

// Memory-efficient printing (stores string in flash, not SRAM)
Serial.println(F("This string stays in flash memory"));
```

**print() vs write():**
- `print(65)` sends the characters "6" and "5" (2 bytes, human-readable)
- `write(65)` sends the byte value 65 (1 byte, which happens to be 'A' in ASCII)

### Formatted Output

Arduino has no `printf()` by default, but you can build formatted strings:

```cpp
// Method 1: Chained prints
Serial.print(F("Sensor: "));
Serial.print(sensorValue);
Serial.print(F(" at "));
Serial.print(millis());
Serial.println(F(" ms"));

// Method 2: snprintf (available on AVR)
char buffer[64];
snprintf(buffer, sizeof(buffer), "Sensor: %d at %lu ms", sensorValue, millis());
Serial.println(buffer);
// Note: %f (float) is NOT supported by default AVR snprintf to save flash.
// Use dtostrf() for floats:
char floatStr[8];
dtostrf(temperature, 6, 2, floatStr);  // width=6, precision=2
snprintf(buffer, sizeof(buffer), "Temp: %s C", floatStr);
```

---

## Reading Serial Input

### Checking for Available Data

```cpp
void loop() {
    if (Serial.available() > 0) {
        // Data is waiting in the receive buffer (64 bytes on AVR)
        // Process it
    }
}
```

### Reading Single Characters

```cpp
void loop() {
    if (Serial.available() > 0) {
        char c = Serial.read();   // Read one byte, returns -1 if buffer empty
        Serial.print(F("Received: "));
        Serial.println(c);
    }
}
```

### Reading a Complete Line

```cpp
// Method 1: readStringUntil (simple but blocks up to timeout)
void loop() {
    if (Serial.available() > 0) {
        String input = Serial.readStringUntil('\n');
        input.trim();   // Remove trailing \r or whitespace
        Serial.print(F("Got: "));
        Serial.println(input);
    }
}

// Method 2: Character-by-character (non-blocking, memory-safe)
char inputBuffer[64];
int inputPos = 0;

void loop() {
    while (Serial.available() > 0) {
        char c = Serial.read();
        if (c == '\n') {
            inputBuffer[inputPos] = '\0';   // Null-terminate
            processCommand(inputBuffer);     // Handle the complete line
            inputPos = 0;                    // Reset for next line
        } else if (c != '\r' && inputPos < (int)sizeof(inputBuffer) - 1) {
            inputBuffer[inputPos++] = c;
        }
    }
}

void processCommand(const char* cmd) {
    Serial.print(F("Command: "));
    Serial.println(cmd);
}
```

Method 2 is strongly preferred because:
- No heap allocation (avoids String class)
- Non-blocking (does not wait for timeout)
- Buffer overflow protection

### Reading Numbers

```cpp
// parseInt() and parseFloat() skip non-numeric characters and block until timeout
void loop() {
    if (Serial.available() > 0) {
        int value = Serial.parseInt();    // Reads next integer
        Serial.print(F("Integer: "));
        Serial.println(value);
    }
}

// Better approach: read line, then parse
void processCommand(const char* cmd) {
    int value = atoi(cmd);          // Convert string to int
    float fval = atof(cmd);        // Convert string to float
    long lval = strtol(cmd, NULL, 10);  // String to long, base 10
}
```

### Serial Timeout

```cpp
Serial.setTimeout(1000);  // Set timeout in milliseconds (default: 1000)
// Affects: readString(), readStringUntil(), parseInt(), parseFloat(), readBytes()
```

---

## Parsing Structured Serial Data

### CSV Format

```
// Input: "23.5,65.2,1013.25"
char inputBuffer[64];
int inputPos = 0;

void loop() {
    while (Serial.available() > 0) {
        char c = Serial.read();
        if (c == '\n') {
            inputBuffer[inputPos] = '\0';
            parseCSV(inputBuffer);
            inputPos = 0;
        } else if (c != '\r' && inputPos < (int)sizeof(inputBuffer) - 1) {
            inputBuffer[inputPos++] = c;
        }
    }
}

void parseCSV(char* data) {
    char* token = strtok(data, ",");
    int fieldIndex = 0;
    float values[3];

    while (token != NULL && fieldIndex < 3) {
        values[fieldIndex++] = atof(token);
        token = strtok(NULL, ",");
    }

    Serial.print(F("Temp: ")); Serial.println(values[0]);
    Serial.print(F("Humidity: ")); Serial.println(values[1]);
    Serial.print(F("Pressure: ")); Serial.println(values[2]);
}
```

### Command Parser (Key=Value)

```cpp
// Input: "LED=ON", "SPEED=150", "MODE=AUTO"
void processCommand(const char* cmd) {
    char key[16], value[16];

    // Find the '=' separator
    const char* eq = strchr(cmd, '=');
    if (eq == NULL) {
        Serial.println(F("Invalid command format"));
        return;
    }

    int keyLen = eq - cmd;
    strncpy(key, cmd, keyLen);
    key[keyLen] = '\0';
    strcpy(value, eq + 1);

    if (strcmp(key, "LED") == 0) {
        if (strcmp(value, "ON") == 0) {
            digitalWrite(13, HIGH);
        } else if (strcmp(value, "OFF") == 0) {
            digitalWrite(13, LOW);
        }
    } else if (strcmp(key, "SPEED") == 0) {
        int speed = atoi(value);
        analogWrite(9, constrain(speed, 0, 255));
    }

    Serial.print(F("Set ")); Serial.print(key);
    Serial.print(F(" = ")); Serial.println(value);
}
```

### Binary Protocol

For higher throughput or communicating between microcontrollers, use a binary protocol:

```cpp
// Simple binary packet: [START] [LENGTH] [CMD] [DATA...] [CHECKSUM]
#define START_BYTE 0xAA

struct Packet {
    uint8_t command;
    uint8_t data[8];
    uint8_t length;
};

enum ParseState { WAIT_START, READ_LENGTH, READ_CMD, READ_DATA, READ_CHECKSUM };
ParseState state = WAIT_START;
Packet packet;
uint8_t dataIndex = 0;
uint8_t checksum = 0;
uint8_t expectedLength = 0;

void loop() {
    while (Serial.available()) {
        uint8_t b = Serial.read();

        switch (state) {
            case WAIT_START:
                if (b == START_BYTE) {
                    checksum = 0;
                    state = READ_LENGTH;
                }
                break;

            case READ_LENGTH:
                expectedLength = b;
                checksum ^= b;
                state = READ_CMD;
                break;

            case READ_CMD:
                packet.command = b;
                checksum ^= b;
                dataIndex = 0;
                packet.length = expectedLength - 1;  // Subtract command byte
                state = (packet.length > 0) ? READ_DATA : READ_CHECKSUM;
                break;

            case READ_DATA:
                packet.data[dataIndex++] = b;
                checksum ^= b;
                if (dataIndex >= packet.length) {
                    state = READ_CHECKSUM;
                }
                break;

            case READ_CHECKSUM:
                if (b == checksum) {
                    handlePacket(&packet);
                } else {
                    Serial.println(F("Checksum error"));
                }
                state = WAIT_START;
                break;
        }
    }
}
```

---

## SoftwareSerial

Adds additional serial ports on any digital pins (Uno/Nano only).

```cpp
#include <SoftwareSerial.h>

SoftwareSerial gpsSerial(4, 5);  // RX=4, TX=5

void setup() {
    Serial.begin(9600);        // Hardware serial for debugging
    gpsSerial.begin(9600);     // Software serial for GPS module
}

void loop() {
    // Forward GPS data to serial monitor
    while (gpsSerial.available()) {
        Serial.write(gpsSerial.read());
    }

    // Forward serial monitor input to GPS
    while (Serial.available()) {
        gpsSerial.write(Serial.read());
    }
}
```

**SoftwareSerial limitations:**
- Only one SoftwareSerial port can receive at a time. Use `mySerial.listen()` to select which.
- Maximum reliable baud rate is ~57600 (depends on clock speed).
- Uses pin-change interrupts, which can interfere with other interrupt-driven code.
- Cannot receive data while transmitting.
- Not all pins support receive. On Uno, all digital pins work. On Mega, only some pins support pin-change interrupts for RX.

**Alternative for Mega:** Use the 4 hardware serial ports (Serial1, Serial2, Serial3) instead.

**AltSoftSerial** is an alternative library that is more reliable than SoftwareSerial but is limited to specific pins (pin 8 for RX, pin 9 for TX on Uno).

---

## Communicating Between Arduinos

### Serial (UART)

```
Arduino A              Arduino B
---------              ---------
  TX (1) ------------- RX (0)
  RX (0) ------------- TX (1)
  GND    ------------- GND
```

Use SoftwareSerial so the hardware serial remains free for debugging:

```cpp
// Arduino A (Sender)
#include <SoftwareSerial.h>
SoftwareSerial link(4, 5);  // RX, TX

void setup() {
    link.begin(9600);
}

void loop() {
    int sensorVal = analogRead(A0);
    link.println(sensorVal);
    delay(100);
}
```

```cpp
// Arduino B (Receiver)
#include <SoftwareSerial.h>
SoftwareSerial link(4, 5);

void setup() {
    Serial.begin(9600);
    link.begin(9600);
}

void loop() {
    if (link.available()) {
        String data = link.readStringUntil('\n');
        Serial.print("Received: ");
        Serial.println(data);
    }
}
```

### Logic Level Warning

When connecting serial between devices with different logic levels:
- **5V Arduino to 5V Arduino:** Direct connection is fine.
- **5V Arduino to 3.3V device (ESP32, Raspberry Pi, GPS):** The 3.3V device's TX can usually be read by 5V Arduino. But **5V TX will damage 3.3V RX!** Use a voltage divider or level shifter:

```
5V TX ---[1kΩ]---+---[2kΩ]--- GND
                  |
              3.3V RX
```

Or use a bidirectional logic level converter module (recommended).

---

## Serial Debugging Tips

### 1. Always Initialize Serial in setup()

```cpp
void setup() {
    Serial.begin(115200);    // Use higher baud for less overhead
    Serial.println(F("=== Program Start ==="));
    Serial.print(F("Free RAM: "));
    Serial.println(freeRam());
}
```

### 2. Conditional Debug Output

```cpp
#define DEBUG 1  // Set to 0 to disable debug output

#if DEBUG
  #define DEBUG_PRINT(x) Serial.print(x)
  #define DEBUG_PRINTLN(x) Serial.println(x)
#else
  #define DEBUG_PRINT(x)
  #define DEBUG_PRINTLN(x)
#endif

void loop() {
    int val = analogRead(A0);
    DEBUG_PRINT(F("Sensor: "));
    DEBUG_PRINTLN(val);
}
```

### 3. Use Serial Plotter

The Arduino IDE Serial Plotter (`Ctrl+Shift+L`) graphs numeric data in real time.

```cpp
// Print multiple values separated by spaces or commas for multiple traces
void loop() {
    Serial.print(analogRead(A0));
    Serial.print(" ");
    Serial.print(analogRead(A1));
    Serial.print(" ");
    Serial.println(analogRead(A2));
    delay(50);
}
```

### 4. Timestamp Your Output

```cpp
void debugLog(const __FlashStringHelper* msg) {
    Serial.print(F("["));
    Serial.print(millis());
    Serial.print(F("] "));
    Serial.println(msg);
}

// Usage:
debugLog(F("Sensor read complete"));
// Output: [12345] Sensor read complete
```

### 5. Serial Monitor Settings

- **Line ending:** Set to "Newline" or "Both NL & CR" when sending commands
- **Baud rate:** Must match `Serial.begin()` value exactly
- **Autoscroll:** Enable for continuous data, disable to read specific values
- If you see garbage characters, the baud rate is probably wrong

### 6. Buffer Overflow

The hardware serial receive buffer is 64 bytes on AVR. If data arrives faster than you read it, bytes are lost.

```cpp
// Read the buffer as fast as possible
void loop() {
    while (Serial.available()) {    // while, not if — process all waiting bytes
        char c = Serial.read();
        // process byte
    }
    // Do other stuff
}
```

### 7. Serial Uses Flash and RAM

Every `Serial.print("string")` call stores the string in SRAM. Use `F()` macro for literal strings:

```cpp
Serial.println(F("This uses flash, not SRAM"));
```

On an Uno with 2KB SRAM, just 20 short debug strings can consume 10-20% of your memory.

---

## USB Serial Quirks

### Board Reset on Serial Connection

Most Arduino boards reset when a serial connection is opened. This is by design (allows the IDE to upload code). To prevent it:
- Place a 10uF capacitor between RESET and GND (disables auto-reset)
- Or in software, handle the reset gracefully (save state to EEPROM)

### Multiple Serial Monitors

Only one application can hold a serial port open at a time. Close the Arduino IDE serial monitor before using another tool (PuTTY, screen, minicom).

### USB Disconnect on Upload

During upload, the serial port is used by avrdude. Any serial monitoring tool must be disconnected first. The Arduino IDE handles this automatically.

### Finding the Serial Port

| OS | Port Format | Find With |
|----|-------------|-----------|
| Linux | `/dev/ttyACM0` or `/dev/ttyUSB0` | `ls /dev/tty*` or `dmesg | tail` |
| macOS | `/dev/cu.usbmodem*` or `/dev/cu.usbserial*` | `ls /dev/cu.*` |
| Windows | `COM3`, `COM4`, etc. | Device Manager |

```bash
# Linux: check what's connected
ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null

# Linux: monitor serial from command line
screen /dev/ttyACM0 9600
# Exit screen: Ctrl+A then K, then Y

# Or with minicom:
minicom -D /dev/ttyACM0 -b 9600
```
