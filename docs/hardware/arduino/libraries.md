# Arduino Libraries Reference

## Installing Libraries

### Arduino IDE Library Manager

1. Open `Sketch > Include Library > Manage Libraries...` (or `Ctrl+Shift+I`)
2. Search for the library name
3. Select version and click "Install"
4. Libraries install to `~/Arduino/libraries/` (Linux) or `Documents\Arduino\libraries\` (Windows)

### Arduino CLI

```bash
# Search
arduino-cli lib search "DHT sensor"

# Install latest version
arduino-cli lib install "DHT sensor library"

# Install specific version
arduino-cli lib install "DHT sensor library@1.4.4"

# List installed libraries
arduino-cli lib list

# Update all libraries
arduino-cli lib upgrade
```

### PlatformIO

Add to `platformio.ini`:
```ini
lib_deps =
    adafruit/DHT sensor library@^1.4.4
    adafruit/Adafruit Unified Sensor@^1.1.9
```
PlatformIO automatically downloads dependencies on build.

### Manual Installation

1. Download the library `.zip` file
2. Arduino IDE: `Sketch > Include Library > Add .ZIP Library...`
3. Or extract to `~/Arduino/libraries/LibraryName/`

### Library Structure

```
LibraryName/
  library.properties    # Metadata (name, version, author, depends)
  src/
    LibraryName.h       # Header file (public API)
    LibraryName.cpp     # Implementation
  examples/
    BasicExample/
      BasicExample.ino
  keywords.txt          # Syntax highlighting definitions
  README.md
```

### Including Libraries

```cpp
#include <Wire.h>            // System/installed library (angle brackets)
#include "MyLocalFile.h"     // File in sketch folder (quotes)
```

---

## Core Libraries (Included with Arduino)

### Wire (I2C)

Two-wire interface for communicating with I2C devices (sensors, displays, EEPROMs).

```cpp
#include <Wire.h>

void setup() {
    Wire.begin();          // Join I2C bus as master
    // Wire.begin(0x08);   // Join as slave with address 0x08
}

// --- Master: Writing to a device ---
Wire.beginTransmission(0x68);  // Start talking to device at address 0x68
Wire.write(0x6B);              // Write register address
Wire.write(0x00);              // Write data value
Wire.endTransmission();        // Send stop, returns 0 on success

// --- Master: Reading from a device ---
Wire.beginTransmission(0x68);
Wire.write(0x3B);              // Register to read from
Wire.endTransmission(false);   // Send repeated start (not stop)
Wire.requestFrom(0x68, 6);    // Request 6 bytes from device

while (Wire.available()) {
    byte b = Wire.read();     // Read one byte
}

// --- I2C Scanner (find all devices on the bus) ---
void scanI2C() {
    for (byte addr = 1; addr < 127; addr++) {
        Wire.beginTransmission(addr);
        if (Wire.endTransmission() == 0) {
            Serial.print(F("Device found at 0x"));
            Serial.println(addr, HEX);
        }
    }
}
```

**Common I2C addresses:**
| Device | Address |
|--------|---------|
| MPU6050 (accelerometer/gyro) | 0x68 (or 0x69) |
| BMP280/BME280 (pressure/temp) | 0x76 (or 0x77) |
| SSD1306 OLED (128x64) | 0x3C (or 0x3D) |
| DS1307/DS3231 RTC | 0x68 |
| PCF8574 I/O expander | 0x20-0x27 |
| AT24C32/256 EEPROM | 0x50-0x57 |
| ADS1115 ADC | 0x48-0x4B |

**Tips:**
- I2C needs pull-up resistors (4.7k ohm typical). Many breakout boards include them.
- If you have multiple boards with pull-ups, too many paralleled resistors can cause issues. Remove extras.
- `Wire.setClock(400000)` switches to 400 kHz Fast Mode (default is 100 kHz).

### SPI

High-speed synchronous serial for SD cards, displays, radio modules, etc.

```cpp
#include <SPI.h>

void setup() {
    SPI.begin();  // Initialize SPI (sets SCK, MOSI, SS as outputs)
    pinMode(10, OUTPUT);   // Chip select pin
    digitalWrite(10, HIGH); // Deselect device
}

void loop() {
    SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE0));
    digitalWrite(10, LOW);          // Select device
    byte response = SPI.transfer(0x42);  // Send byte, receive byte simultaneously
    digitalWrite(10, HIGH);         // Deselect device
    SPI.endTransaction();
}

// SPI Modes (clock polarity and phase):
// SPI_MODE0: CPOL=0, CPHA=0 (most common)
// SPI_MODE1: CPOL=0, CPHA=1
// SPI_MODE2: CPOL=1, CPHA=0
// SPI_MODE3: CPOL=1, CPHA=1
```

**SPISettings parameters:**
1. Clock speed in Hz (max ~8 MHz on AVR, device dependent)
2. Bit order: MSBFIRST or LSBFIRST
3. SPI mode: SPI_MODE0 through SPI_MODE3

### Servo

Controls hobby RC servo motors (pulse-width modulation).

```cpp
#include <Servo.h>

Servo myServo;

void setup() {
    myServo.attach(9);      // Attach to pin 9
    // myServo.attach(9, 544, 2400);  // Custom min/max pulse width in microseconds
}

void loop() {
    myServo.write(90);      // Move to 90 degrees (0-180)
    delay(1000);
    myServo.write(0);       // Move to 0 degrees
    delay(1000);

    // For continuous rotation servos:
    // 90 = stop, 0 = full speed one way, 180 = full speed other way

    myServo.writeMicroseconds(1500);  // Direct pulse width control (1000-2000 us)
}
```

**Important notes:**
- The Servo library disables PWM (analogWrite) on pins 9 and 10 on Uno/Nano
- Each servo needs its own power supply for reliable operation (5-6V, 1A+ per servo)
- The library supports up to 12 servos on Uno, 48 on Mega

### LiquidCrystal (HD44780 LCD)

For character LCDs (16x2, 20x4) using the parallel HD44780 interface.

```cpp
#include <LiquidCrystal.h>

// Pins: RS, Enable, D4, D5, D6, D7 (4-bit mode)
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

void setup() {
    lcd.begin(16, 2);       // 16 columns, 2 rows
    lcd.print("Hello!");
}

void loop() {
    lcd.setCursor(0, 1);    // Column 0, Row 1 (second row)
    lcd.print(millis() / 1000);
    lcd.print(" seconds");
}

// Other useful functions:
lcd.clear();               // Clear display and home cursor
lcd.home();                // Move cursor to (0,0)
lcd.scrollDisplayLeft();   // Scroll text left
lcd.scrollDisplayRight();  // Scroll text right
lcd.noDisplay();           // Turn off display (data preserved)
lcd.display();             // Turn display back on
lcd.blink();               // Blinking cursor
lcd.noBlink();
lcd.cursor();              // Underline cursor
lcd.noCursor();
```

**For I2C LCDs** (with PCF8574 backpack — uses only 2 pins):
```cpp
#include <LiquidCrystal_I2C.h>  // Install from Library Manager

LiquidCrystal_I2C lcd(0x27, 16, 2);  // Address 0x27 (or 0x3F), 16x2

void setup() {
    lcd.init();
    lcd.backlight();
    lcd.print("Hello I2C!");
}
```

### SD (SD Card)

Read and write files on SD and microSD cards via SPI.

```cpp
#include <SD.h>
#include <SPI.h>

const int chipSelect = 4;  // CS pin (varies by shield/module)

void setup() {
    Serial.begin(9600);

    if (!SD.begin(chipSelect)) {
        Serial.println(F("SD init failed!"));
        return;
    }
    Serial.println(F("SD initialized."));

    // Write to a file
    File dataFile = SD.open("data.txt", FILE_WRITE);
    if (dataFile) {
        dataFile.println("Hello SD card!");
        dataFile.print("Millis: ");
        dataFile.println(millis());
        dataFile.close();  // MUST close to flush data
    }

    // Read a file
    File readFile = SD.open("data.txt");
    if (readFile) {
        while (readFile.available()) {
            Serial.write(readFile.read());
        }
        readFile.close();
    }

    // Check if file exists
    if (SD.exists("data.txt")) {
        Serial.println(F("File exists"));
    }

    // Delete a file
    SD.remove("data.txt");
}
```

**SD card tips:**
- Cards must be formatted as FAT16 or FAT32
- File names follow 8.3 format (8-char name, 3-char extension) unless using SdFat library
- The SD library uses about 512 bytes of SRAM for buffering
- CS pin is usually 4 (Ethernet shield), 10 (other shields), or configurable
- SD library uses SPI — pin 10 must be set as OUTPUT even if not used for CS

### EEPROM

Persistent storage that survives power cycles.

```cpp
#include <EEPROM.h>

// Read/write single bytes
EEPROM.write(address, value);   // Write byte (0-255) to address
byte val = EEPROM.read(address); // Read byte from address

// Read/write any data type
float temp = 23.5;
EEPROM.put(0, temp);            // Write float starting at address 0
EEPROM.get(0, temp);            // Read float from address 0

// Only write if changed (preserves EEPROM life)
EEPROM.update(address, value);  // Recommended over write()

// EEPROM size
int size = EEPROM.length();     // 1024 on Uno, 4096 on Mega
```

**Wear leveling tip:** If logging data, distribute writes across addresses rather than always writing to the same location.

---

## Popular Third-Party Libraries

### Adafruit Unified Sensor + Specific Sensor Libraries

Adafruit provides a consistent sensor API through a base class.

```cpp
// Install both:
//   "Adafruit Unified Sensor"
//   "Adafruit BME280 Library" (or whichever sensor)

#include <Adafruit_Sensor.h>
#include <Adafruit_BME280.h>

Adafruit_BME280 bme;

void setup() {
    Serial.begin(9600);
    if (!bme.begin(0x76)) {
        Serial.println(F("BME280 not found!"));
        while (1);
    }
}

void loop() {
    Serial.print(F("Temp: "));
    Serial.print(bme.readTemperature());  // Celsius
    Serial.print(F(" C, Humidity: "));
    Serial.print(bme.readHumidity());     // %
    Serial.print(F(" %, Pressure: "));
    Serial.print(bme.readPressure() / 100.0);  // hPa
    Serial.println(F(" hPa"));
    delay(2000);
}
```

**Common Adafruit sensor libraries:**
- `Adafruit_BME280` — Temperature, humidity, pressure
- `Adafruit_BMP280` — Temperature, pressure
- `DHT sensor library` — DHT11/22 temp/humidity
- `Adafruit_MPU6050` — 6-axis accelerometer/gyro
- `Adafruit_INA219` — Current/voltage sensor
- `Adafruit_SSD1306` — OLED display driver
- `Adafruit_NeoPixel` — WS2812B addressable LEDs

### FastLED

High-performance addressable LED library (WS2812B, APA102, etc.).

```cpp
#include <FastLED.h>

#define NUM_LEDS 60
#define DATA_PIN 6

CRGB leds[NUM_LEDS];

void setup() {
    FastLED.addLeds<WS2812B, DATA_PIN, GRB>(leds, NUM_LEDS);
    FastLED.setBrightness(50);  // 0-255, limit for power management
}

void loop() {
    // Set individual LEDs
    leds[0] = CRGB::Red;
    leds[1] = CRGB(0, 255, 0);      // Green (R, G, B)
    leds[2] = CHSV(160, 255, 255);  // HSV: hue, saturation, value
    FastLED.show();

    // Fill all LEDs
    fill_solid(leds, NUM_LEDS, CRGB::Blue);
    FastLED.show();
    delay(1000);

    // Rainbow
    fill_rainbow(leds, NUM_LEDS, millis() / 10, 7);
    FastLED.show();

    // Power management: limit milliamps
    FastLED.setMaxPowerInVoltsAndMilliamps(5, 500);  // 5V, 500mA max
}
```

**Memory usage:** Each LED takes 3 bytes of SRAM. 60 LEDs = 180 bytes (significant on Uno).

**Supported chipsets:** WS2812B, WS2811, APA102, SK9822, WS2801, LPD8806, and many more.

### AccelStepper

Advanced stepper motor control with acceleration/deceleration profiles.

```cpp
#include <AccelStepper.h>

// Driver type, step pin, direction pin
AccelStepper stepper(AccelStepper::DRIVER, 3, 4);
// Use AccelStepper::DRIVER for A4988/DRV8825 step/dir drivers
// Use AccelStepper::FULL4WIRE for ULN2003/L293D with 4 wires

void setup() {
    stepper.setMaxSpeed(1000);      // Steps per second
    stepper.setAcceleration(500);   // Steps per second per second
}

void loop() {
    stepper.moveTo(2000);           // Move to absolute position
    stepper.run();                  // Must call every loop iteration

    // Non-blocking: run() returns true if still moving
    // Blocking alternative:
    // stepper.runToPosition();     // Blocks until position reached
}

// Other useful functions:
stepper.move(500);              // Move relative (500 steps from current)
stepper.currentPosition();      // Get current position
stepper.setCurrentPosition(0);  // Reset position counter
stepper.stop();                 // Decelerate to stop
stepper.distanceToGo();         // Steps remaining
stepper.isRunning();            // True if motor is moving
```

### OneWire + DallasTemperature (DS18B20)

For Dallas/Maxim 1-Wire temperature sensors.

```cpp
#include <OneWire.h>
#include <DallasTemperature.h>

OneWire oneWire(2);                    // Data pin
DallasTemperature sensors(&oneWire);

void setup() {
    Serial.begin(9600);
    sensors.begin();
    Serial.print(F("Found "));
    Serial.print(sensors.getDeviceCount());
    Serial.println(F(" sensors"));
}

void loop() {
    sensors.requestTemperatures();           // Send command to all sensors
    float tempC = sensors.getTempCByIndex(0); // Read first sensor
    Serial.print(F("Temp: "));
    Serial.print(tempC);
    Serial.println(F(" C"));
    delay(1000);
}
```

**Wiring:** Data pin needs a 4.7k ohm pull-up resistor to VCC. Multiple sensors can share one data pin (each has a unique 64-bit address).

### PubSubClient (MQTT)

MQTT client for Arduino with Ethernet or WiFi.

```cpp
#include <WiFiNINA.h>      // For Nano 33 IoT (or ESP8266WiFi.h, etc.)
#include <PubSubClient.h>

WiFiClient wifiClient;
PubSubClient mqtt(wifiClient);

void callback(char* topic, byte* payload, unsigned int length) {
    // Handle incoming messages
    Serial.print(F("Message on "));
    Serial.print(topic);
    Serial.print(F(": "));
    for (unsigned int i = 0; i < length; i++) {
        Serial.print((char)payload[i]);
    }
    Serial.println();
}

void setup() {
    // Connect to WiFi first...
    mqtt.setServer("192.168.1.100", 1883);
    mqtt.setCallback(callback);
}

void loop() {
    if (!mqtt.connected()) {
        mqtt.connect("arduinoClient");
        mqtt.subscribe("sensors/command");
    }
    mqtt.loop();  // Must call regularly

    // Publish
    mqtt.publish("sensors/temperature", "23.5");
}
```

### IRremote

Send and receive infrared remote control signals.

```cpp
#include <IRremote.hpp>

const int RECV_PIN = 11;

void setup() {
    Serial.begin(9600);
    IrReceiver.begin(RECV_PIN, ENABLE_LED_FEEDBACK);
}

void loop() {
    if (IrReceiver.decode()) {
        Serial.println(IrReceiver.decodedIRData.decodedRawData, HEX);
        Serial.println(IrReceiver.decodedIRData.protocol);
        IrReceiver.resume();
    }
}

// Sending:
// IrSender.begin(3);  // Send pin
// IrSender.sendNEC(0x00, 0x12, 0);  // Protocol, address, command, repeats
```

---

## Library Version Management

### Pinning Versions

Different library versions can break your project. Always note which version you used.

**PlatformIO** (best approach):
```ini
lib_deps =
    adafruit/DHT sensor library@1.4.4    # Exact version
    fastled/FastLED@^3.5.0               # Compatible with 3.5.x
```

**Arduino CLI:**
```bash
arduino-cli lib install "FastLED@3.5.0"
```

### Library Conflicts

Common issues:
- **Timer conflicts:** Servo and tone() both use Timer1. Use `TimerOne` library or ServoTimer2 as alternatives.
- **Pin conflicts:** Some libraries hardcode pins. Read the library source.
- **Multiple I2C devices with same address:** Use an I2C multiplexer (TCA9548A).
- **Memory overflows:** Large libraries (Adafruit GFX + display driver) can consume most of Uno's SRAM. Monitor free RAM.

### Writing Your Own Library

Create a folder in your libraries directory:

**MyLibrary.h:**
```cpp
#ifndef MYLIBRARY_H
#define MYLIBRARY_H

#include <Arduino.h>

class MySensor {
public:
    MySensor(int pin);
    void begin();
    int read();
private:
    int _pin;
};

#endif
```

**MyLibrary.cpp:**
```cpp
#include "MyLibrary.h"

MySensor::MySensor(int pin) {
    _pin = pin;
}

void MySensor::begin() {
    pinMode(_pin, INPUT);
}

int MySensor::read() {
    return analogRead(_pin);
}
```

**library.properties:**
```
name=MyLibrary
version=1.0.0
author=Your Name
maintainer=Your Name
sentence=A brief description.
paragraph=A longer description.
category=Sensors
url=https://github.com/you/MyLibrary
architectures=avr
depends=Wire
```
