# Arduino Programming Guide

## Program Structure

Every Arduino sketch has two required functions:

```cpp
void setup() {
    // Runs once when the board powers on or resets
    // Initialize pins, serial, libraries here
}

void loop() {
    // Runs repeatedly after setup() completes
    // Main program logic goes here
}
```

The Arduino framework wraps these in a hidden `main()`:

```cpp
int main() {
    init();        // Initialize Arduino hardware (timers, ADC, etc.)
    setup();       // Your setup code
    for (;;) {
        loop();    // Your loop code, called forever
    }
}
```

---

## Digital I/O

### Pin Modes

```cpp
pinMode(pin, MODE);
// MODE can be:
//   INPUT       - High impedance input (floating if not externally pulled)
//   OUTPUT      - Push-pull output (can source or sink ~20mA)
//   INPUT_PULLUP - Input with internal ~20-50kΩ pull-up resistor enabled
```

### Digital Write

```cpp
digitalWrite(pin, HIGH);  // Set pin to VCC (5V on Uno)
digitalWrite(pin, LOW);   // Set pin to GND (0V)
```

### Digital Read

```cpp
int value = digitalRead(pin);  // Returns HIGH (1) or LOW (0)
```

### Example: Button with Internal Pull-Up

```cpp
const int BUTTON_PIN = 2;
const int LED_PIN = 13;

void setup() {
    pinMode(BUTTON_PIN, INPUT_PULLUP);  // HIGH when not pressed, LOW when pressed
    pinMode(LED_PIN, OUTPUT);
}

void loop() {
    if (digitalRead(BUTTON_PIN) == LOW) {  // Button pressed (active LOW)
        digitalWrite(LED_PIN, HIGH);
    } else {
        digitalWrite(LED_PIN, LOW);
    }
}
```

---

## Analog I/O

### Analog Read (ADC)

```cpp
int value = analogRead(A0);  // Returns 0-1023 (10-bit resolution)
// 0 = 0V, 1023 = 5V (or whatever analogReference is set to)

// Convert to voltage:
float voltage = value * (5.0 / 1023.0);
```

- Reading takes about 100 microseconds (10,000 readings/sec max)
- Pins A0-A5 on Uno, A0-A7 on Nano, A0-A15 on Mega
- Analog pins can also be used as digital I/O (D14-D19 on Uno)

### Analog Write (PWM)

```cpp
analogWrite(pin, dutyCycle);  // dutyCycle: 0-255
// 0 = always OFF, 127 = 50% duty cycle, 255 = always ON
```

- Only works on PWM-capable pins (marked with `~`)
- Uno/Nano PWM pins: 3, 5, 6, 9, 10, 11
- Default PWM frequency: ~490 Hz (pins 3, 9, 10, 11) or ~980 Hz (pins 5, 6)
- This is NOT a true analog output — it's a square wave. Use an RC filter for smoothing.

### Example: LED Fade

```cpp
const int LED_PIN = 9;  // Must be a PWM pin

void setup() {
    pinMode(LED_PIN, OUTPUT);
}

void loop() {
    // Fade up
    for (int brightness = 0; brightness <= 255; brightness++) {
        analogWrite(LED_PIN, brightness);
        delay(5);
    }
    // Fade down
    for (int brightness = 255; brightness >= 0; brightness--) {
        analogWrite(LED_PIN, brightness);
        delay(5);
    }
}
```

---

## Serial Communication

```cpp
void setup() {
    Serial.begin(9600);  // Initialize at 9600 baud
    Serial.println("Arduino is ready");
}

void loop() {
    Serial.print("Analog value: ");
    Serial.println(analogRead(A0));  // println adds newline
    delay(1000);
}
```

Key serial functions:
- `Serial.begin(baud)` — Initialize (9600, 115200, etc.)
- `Serial.print(data)` — Print without newline
- `Serial.println(data)` — Print with newline
- `Serial.write(byte)` — Send raw byte
- `Serial.available()` — Number of bytes waiting to be read
- `Serial.read()` — Read one byte (-1 if nothing available)
- `Serial.readString()` — Read until timeout (default 1 second)
- `Serial.parseInt()` — Parse next integer from buffer
- `Serial.parseFloat()` — Parse next float from buffer

See `serial-communication.md` for comprehensive serial coverage.

---

## Timing: millis() vs delay()

### delay() — Blocking

```cpp
delay(1000);       // Pause for 1000 ms (blocks everything)
delayMicroseconds(100);  // Pause for 100 us
```

**Problems with delay():**
- The processor does nothing during the delay — no reading sensors, no responding to inputs
- Cannot run multiple tasks at different intervals
- Makes the program unresponsive

### millis() — Non-Blocking Timing

```cpp
unsigned long previousMillis = 0;
const unsigned long interval = 1000;  // 1 second

void loop() {
    unsigned long currentMillis = millis();

    if (currentMillis - previousMillis >= interval) {
        previousMillis = currentMillis;
        // Do your periodic task here
        Serial.println(analogRead(A0));
    }

    // Other code runs here without being blocked
}
```

**Key points about millis():**
- Returns milliseconds since the board started (as `unsigned long`)
- Overflows after ~49.7 days — but subtraction works correctly due to unsigned arithmetic
- Resolution is 1 ms (Timer0 interrupt updates it)
- `micros()` returns microseconds (overflows after ~70 minutes, resolution 4 us on 16MHz)

### Multiple Timers Pattern

```cpp
unsigned long lastSensorRead = 0;
unsigned long lastDisplayUpdate = 0;
unsigned long lastSerialReport = 0;

void loop() {
    unsigned long now = millis();

    if (now - lastSensorRead >= 100) {      // Read sensor every 100ms
        lastSensorRead = now;
        readSensors();
    }

    if (now - lastDisplayUpdate >= 500) {    // Update display every 500ms
        lastDisplayUpdate = now;
        updateDisplay();
    }

    if (now - lastSerialReport >= 2000) {    // Serial report every 2s
        lastSerialReport = now;
        reportToSerial();
    }
}
```

---

## State Machines

State machines are the key pattern for writing responsive, non-blocking Arduino programs.

### Simple State Machine Example: Traffic Light

```cpp
enum TrafficState {
    STATE_GREEN,
    STATE_YELLOW,
    STATE_RED
};

TrafficState currentState = STATE_GREEN;
unsigned long stateStartTime = 0;

void setup() {
    pinMode(8, OUTPUT);  // Green
    pinMode(9, OUTPUT);  // Yellow
    pinMode(10, OUTPUT); // Red
    stateStartTime = millis();
}

void loop() {
    unsigned long elapsed = millis() - stateStartTime;

    switch (currentState) {
        case STATE_GREEN:
            digitalWrite(8, HIGH);
            digitalWrite(9, LOW);
            digitalWrite(10, LOW);
            if (elapsed >= 5000) {  // 5 seconds
                currentState = STATE_YELLOW;
                stateStartTime = millis();
            }
            break;

        case STATE_YELLOW:
            digitalWrite(8, LOW);
            digitalWrite(9, HIGH);
            digitalWrite(10, LOW);
            if (elapsed >= 2000) {  // 2 seconds
                currentState = STATE_RED;
                stateStartTime = millis();
            }
            break;

        case STATE_RED:
            digitalWrite(8, LOW);
            digitalWrite(9, LOW);
            digitalWrite(10, HIGH);
            if (elapsed >= 5000) {  // 5 seconds
                currentState = STATE_GREEN;
                stateStartTime = millis();
            }
            break;
    }
}
```

### Button Debouncing State Machine

```cpp
const int BUTTON_PIN = 2;
const unsigned long DEBOUNCE_DELAY = 50;

int buttonState = HIGH;
int lastReading = HIGH;
unsigned long lastDebounceTime = 0;

bool readDebouncedButton() {
    bool stateChanged = false;
    int reading = digitalRead(BUTTON_PIN);

    if (reading != lastReading) {
        lastDebounceTime = millis();
    }

    if ((millis() - lastDebounceTime) > DEBOUNCE_DELAY) {
        if (reading != buttonState) {
            buttonState = reading;
            stateChanged = true;
        }
    }

    lastReading = reading;
    return stateChanged && (buttonState == LOW);  // Returns true on press
}
```

---

## Memory Management

ATmega328P has only 2 KB of SRAM. Memory management matters.

### Memory Types

| Memory | Size (Uno) | Content | Speed |
|--------|-----------|---------|-------|
| Flash | 32 KB | Program code + constants | Fast read, slow write (10K cycles) |
| SRAM | 2 KB | Variables, stack, heap | Fast read/write |
| EEPROM | 1 KB | Persistent storage | Slow (3.3 ms write, 100K cycles) |

### Where Your RAM Goes

```
SRAM Layout:
+------------------+ 0x0100
| Global variables |  (static allocation at compile time)
| (data + bss)     |
+------------------+
|        |         |
|  Heap  v         |  (dynamic allocation: malloc, new, String)
|                  |
|  Free RAM        |
|                  |
|  Stack ^         |  (local variables, function calls, return addresses)
|        |         |
+------------------+ 0x08FF (2KB boundary)
```

### Check Free RAM

```cpp
int freeRam() {
    extern int __heap_start, *__brkval;
    int v;
    return (int)&v - (__brkval == 0 ? (int)&__heap_start : (int)__brkval);
}

void setup() {
    Serial.begin(9600);
    Serial.print("Free RAM: ");
    Serial.println(freeRam());  // Should be > 200 bytes to be safe
}
```

### F() Macro — Store Strings in Flash

Every string literal in your code is copied to SRAM at startup. The `F()` macro keeps strings in flash.

```cpp
// BAD: "Hello World" takes 12 bytes of SRAM
Serial.println("Hello World");

// GOOD: String stays in flash, SRAM is not used
Serial.println(F("Hello World"));
```

This matters a lot when you have many print statements. Each string consumes SRAM permanently.

### PROGMEM — Store Data in Flash

```cpp
#include <avr/pgmspace.h>

// Store large constant arrays in flash instead of SRAM
const int sineTable[] PROGMEM = {
    0, 6, 12, 18, 25, 31, 37, 43, 49, 56, 62, 68, 74, 80, 86, 92,
    97, 103, 109, 114, 120, 125, 131, 136, 141, 146, 151, 156, 161,
    // ... more values
};

// Reading from PROGMEM requires special function
int value = pgm_read_word(&sineTable[index]);

// For byte arrays:
const byte myData[] PROGMEM = { 0x00, 0x01, 0x02 };
byte b = pgm_read_byte(&myData[index]);

// For strings:
const char myString[] PROGMEM = "Stored in flash!";
char buffer[20];
strcpy_P(buffer, myString);  // Copy from flash to RAM buffer
```

### Avoid the String Class

The Arduino `String` class (capital S) uses dynamic memory allocation (heap). On a 2 KB SRAM device, this leads to heap fragmentation and crashes.

```cpp
// BAD: String class fragments memory over time
String message = "Sensor: ";
message += String(analogRead(A0));
message += " at ";
message += String(millis());
Serial.println(message);

// GOOD: Use char arrays (C strings) or just print in pieces
Serial.print(F("Sensor: "));
Serial.print(analogRead(A0));
Serial.print(F(" at "));
Serial.println(millis());
```

If you must use strings, use fixed-size `char` arrays with `snprintf`:

```cpp
char buffer[40];
snprintf(buffer, sizeof(buffer), "Sensor: %d at %lu", analogRead(A0), millis());
Serial.println(buffer);
```

### EEPROM — Persistent Storage

```cpp
#include <EEPROM.h>

// Write a byte (address 0-1023 on Uno)
EEPROM.write(0, 42);

// Read a byte
byte val = EEPROM.read(0);

// Write any data type
float temperature = 23.5;
EEPROM.put(10, temperature);  // Writes at address 10-13 (4 bytes)

// Read any data type
float readTemp;
EEPROM.get(10, readTemp);

// Only write if value changed (extends EEPROM life)
EEPROM.update(0, 42);  // Only writes if current value != 42
```

**EEPROM endurance:** ~100,000 write cycles per address. Use `update()` instead of `write()` to avoid unnecessary writes.

---

## Common Patterns

### Map and Constrain

```cpp
// Map a value from one range to another (integer math)
int pwmValue = map(sensorValue, 0, 1023, 0, 255);

// Constrain a value to a range
int safe = constrain(value, 0, 255);  // Clamps to 0-255
```

**Warning:** `map()` uses integer math. For floating point:
```cpp
float mapFloat(float x, float inMin, float inMax, float outMin, float outMax) {
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}
```

### Averaging Readings (Smoothing)

```cpp
const int NUM_READINGS = 10;
int readings[NUM_READINGS];
int readIndex = 0;
long total = 0;

int smoothRead(int pin) {
    total -= readings[readIndex];
    readings[readIndex] = analogRead(pin);
    total += readings[readIndex];
    readIndex = (readIndex + 1) % NUM_READINGS;
    return total / NUM_READINGS;
}
```

### Exponential Moving Average (Less Memory)

```cpp
float ema = 0;
const float alpha = 0.1;  // Smoothing factor (0-1, lower = smoother)

void loop() {
    int raw = analogRead(A0);
    ema = alpha * raw + (1.0 - alpha) * ema;
    // Use ema as your smoothed value
}
```

### Bit Manipulation

```cpp
// Set a bit
PORTB |= (1 << 5);       // Set bit 5 of PORTB (pin 13 on Uno)

// Clear a bit
PORTB &= ~(1 << 5);      // Clear bit 5

// Toggle a bit
PORTB ^= (1 << 5);       // Toggle bit 5

// Check a bit
if (PINB & (1 << 5)) {}  // True if bit 5 is set

// Arduino macros
bitSet(variable, bit);
bitClear(variable, bit);
bitRead(variable, bit);
bitWrite(variable, bit, value);
```

### Direct Port Manipulation (Fast I/O)

```cpp
// Much faster than digitalWrite() — useful for tight timing
// Uno pin mapping:
//   PORTD = pins 0-7    (DDRD for direction, PIND for reading)
//   PORTB = pins 8-13   (DDRB, PINB)
//   PORTC = pins A0-A5  (DDRC, PINC)

// Set pin 13 as output and HIGH (pin 13 = PORTB bit 5)
DDRB |= (1 << 5);   // Set as output
PORTB |= (1 << 5);  // Set HIGH
PORTB &= ~(1 << 5); // Set LOW

// digitalWrite takes ~6 us, direct port takes ~0.06 us (100x faster)
```

---

## The Bootloader

The bootloader is a small program in flash that runs at reset and listens for new code over serial.

- **Optiboot** (Uno): Uses 512 bytes of flash, waits ~1 second for upload, then jumps to your code
- The bootloader is why the board resets when you open the serial monitor
- Uploading via a programmer (ISP/ICSP) bypasses the bootloader and gives you the full flash
- If the bootloader gets corrupted, you need a programmer to reflash it

### Burning a Bootloader

If you have an Uno, you can use it as a programmer for another Uno/Nano:

1. Upload the "ArduinoISP" sketch to the programmer Uno
2. Wire the programmer to the target (MOSI-MOSI, MISO-MISO, SCK-SCK, D10-RESET)
3. In IDE: Select the target board, select "Arduino as ISP" programmer
4. Click "Burn Bootloader"

---

## Compilation Process

When you click "Verify" or "Upload":

1. **Preprocessing:** Arduino IDE inserts `#include <Arduino.h>`, generates function prototypes
2. **Compilation:** `avr-gcc` compiles `.ino` files (treated as C++) and any `.cpp` files
3. **Linking:** Links with Arduino core library and any included libraries
4. **Hex generation:** Produces a `.hex` file (the binary for the MCU)
5. **Upload:** `avrdude` sends the hex file to the bootloader via serial

You can see the full output by enabling "Show verbose output during compilation" in IDE preferences.

### Compiler Output — Reading Memory Usage

```
Sketch uses 3462 bytes (10%) of program storage space. Maximum is 32256 bytes.
Global variables use 214 bytes (10%) of dynamic memory, leaving 1834 bytes for local variables. Maximum is 2048 bytes.
```

- **Program storage (flash):** Keep under 90% to allow room for growth
- **Dynamic memory (SRAM):** If this exceeds 75%, you may encounter runtime crashes. Stack and heap grow toward each other and can collide.
