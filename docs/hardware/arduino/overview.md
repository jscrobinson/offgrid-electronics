# Arduino Board Overview and Comparison

## Board Comparison Table

| Feature | Uno R3 | Nano | Mega 2560 | Nano Every | Nano 33 IoT |
|---|---|---|---|---|---|
| **MCU** | ATmega328P | ATmega328P | ATmega2560 | ATmega4809 | SAMD21G18A |
| **Clock** | 16 MHz | 16 MHz | 16 MHz | 20 MHz | 48 MHz |
| **Flash** | 32 KB | 32 KB | 256 KB | 48 KB | 256 KB |
| **SRAM** | 2 KB | 2 KB | 8 KB | 6 KB | 32 KB |
| **EEPROM** | 1 KB | 1 KB | 4 KB | 256 B | None (emulated) |
| **Digital I/O** | 14 (6 PWM) | 14 (6 PWM) | 54 (15 PWM) | 14 (5 PWM) | 14 (11 PWM) |
| **Analog Inputs** | 6 | 8 | 16 | 8 | 8 (12-bit) |
| **Logic Level** | 5V | 5V | 5V | 5V | 3.3V |
| **USB** | Type-B | Mini-USB | Type-B | Micro-USB | Micro-USB |
| **WiFi/BT** | No | No | No | No | Yes (NINA-W102) |
| **Size (mm)** | 68.6 x 53.4 | 45 x 18 | 101.5 x 53.3 | 45 x 18 | 45 x 18 |
| **Price Range** | $20-27 | $20-24 | $38-46 | $14-18 | $25-32 |

## Detailed Board Descriptions

### Arduino Uno R3

The most popular and well-documented Arduino board. Ideal for learning and prototyping.

- **Microcontroller:** ATmega328P (8-bit AVR)
- **Operating Voltage:** 5V
- **Input Voltage (recommended):** 7-12V via barrel jack
- **Input Voltage (limits):** 6-20V
- **DC Current per I/O Pin:** 20 mA (absolute max 40 mA)
- **DC Current for 3.3V Pin:** 50 mA (from onboard regulator)
- **14 digital I/O pins**, 6 provide PWM output (pins 3, 5, 6, 9, 10, 11)
- **6 analog input pins** (A0-A5), 10-bit resolution (0-1023)
- **Communication:** 1x UART, 1x I2C, 1x SPI
- **Interrupt pins:** 2 (pins 2 and 3)
- **LED_BUILTIN:** Pin 13
- **Bootloader:** Optiboot, uses 512 bytes of flash
- **Programmer header:** ICSP for direct AVR programming

**Use cases:** Learning, prototyping, simple sensor reading, motor control, most shield-compatible projects. The enormous ecosystem of shields and tutorials makes this the default starting point.

### Arduino Nano

Electrically identical to the Uno but in a breadboard-friendly DIP form factor.

- **Same ATmega328P** with same specs as Uno
- **Smaller footprint:** 45 x 18 mm, fits directly in a breadboard
- **Mini-USB** connector (some clones use Micro-USB)
- **8 analog inputs** (A0-A7), two more than the Uno
- **No barrel jack** — powered via USB or the VIN pin (7-12V)
- **CH340 USB-serial chip** on many clone boards (may need driver install)

**Use cases:** Breadboard prototyping, compact projects, wearables, embedded in final builds where space matters. Functionally identical to Uno, just smaller.

**Clone note:** Nano clones are extremely cheap ($2-5) and widely available. Most work fine. Watch for CH340 vs FTDI USB chips — you may need to install the CH340 driver on Windows/Mac.

### Arduino Mega 2560

The large-scale Arduino for projects that outgrow the Uno.

- **Microcontroller:** ATmega2560 (8-bit AVR)
- **256 KB flash** (8 KB used by bootloader)
- **8 KB SRAM**, 4 KB EEPROM
- **54 digital I/O pins**, 15 provide PWM (pins 2-13, 44-46)
- **16 analog inputs** (A0-A15), 10-bit resolution
- **4 hardware UARTs:** Serial (0,1), Serial1 (18,19), Serial2 (16,17), Serial3 (14,15)
- **I2C:** SDA=20, SCL=21
- **SPI:** MOSI=51, MISO=50, SCK=52, SS=53
- **6 external interrupt pins:** 2, 3, 18, 19, 20, 21
- **Pin-compatible with Uno** for shields (pins 0-13, A0-A5 match Uno layout)

**Use cases:** 3D printers (RAMPS board), CNC machines, large LED arrays, projects needing multiple serial devices, robotics with many sensors and actuators.

### Arduino Nano Every

A modernized Nano with a newer MCU at a lower price point.

- **Microcontroller:** ATmega4809 (8-bit AVR, newer megaAVR 0-series)
- **20 MHz clock** (slightly faster than classic Nano)
- **48 KB flash**, 6 KB SRAM, 256 bytes EEPROM
- **Same Nano form factor**, drop-in replacement in most cases
- **5V logic level**
- **Hardware differences from classic Nano:**
  - Different timer architecture (TCB timers instead of classic Timer0/1/2)
  - Some libraries that directly access AVR registers may not be compatible
  - Uses JTAG2UPDI for programming instead of traditional ISP

**Use cases:** Drop-in Nano replacement for new designs, budget-friendly projects. Be aware of library compatibility if migrating from classic Nano.

### Arduino Nano 33 IoT

A Nano-sized board with ARM processor and wireless connectivity.

- **Microcontroller:** SAMD21 Cortex-M0+ 32-bit ARM at 48 MHz
- **Wireless module:** u-blox NINA-W102 (ESP32-based, WiFi 802.11b/g/n + BT 4.2)
- **256 KB flash**, 32 KB SRAM
- **3.3V logic level — NOT 5V tolerant!** Use level shifters with 5V devices.
- **12-bit ADC** (0-4095 instead of Uno's 0-1023)
- **Crypto chip:** ATECC608A for secure communication
- **IMU:** LSM6DS3 (6-axis accelerometer + gyroscope)
- **Operating voltage:** 3.3V
- **Input voltage (VIN):** 5-18V

**Use cases:** IoT projects, WiFi-connected sensors, BLE devices, cloud-connected projects (Arduino IoT Cloud), wearables. When you need wireless in a small form factor.

## Development Environment Options

### Arduino IDE (v2.x)

The official graphical IDE. Best for beginners and quick prototyping.

- **Download:** https://www.arduino.cc/en/software
- **Features:** Code editor with syntax highlighting, serial monitor, serial plotter, board manager, library manager
- **Board Manager:** Install board definitions for non-AVR boards (ESP32, SAMD, etc.)
- **Sketchbook location:** `~/Arduino/` on Linux, `Documents/Arduino/` on Windows
- **Sketch structure:**
  ```
  MySketch/
    MySketch.ino      # Main sketch file (must match folder name)
    helper.h          # Additional header files
    helper.cpp        # Additional source files
  ```

**Keyboard shortcuts:**
- `Ctrl+R` — Verify/Compile
- `Ctrl+U` — Upload
- `Ctrl+Shift+M` — Serial Monitor
- `Ctrl+Shift+L` — Serial Plotter

### Arduino CLI

Command-line tool for scripting and CI/CD. No GUI needed.

```bash
# Install (Linux)
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

# Initialize configuration
arduino-cli config init

# Update board index
arduino-cli core update-index

# Install AVR core (for Uno, Nano, Mega)
arduino-cli core install arduino:avr

# List connected boards
arduino-cli board list

# Compile
arduino-cli compile --fqbn arduino:avr:uno MySketch/

# Upload
arduino-cli compile --fqbn arduino:avr:uno -u -p /dev/ttyACM0 MySketch/

# Install a library
arduino-cli lib install "Servo"

# Search for libraries
arduino-cli lib search "DHT"
```

**Fully Qualified Board Names (FQBN) — common boards:**
- `arduino:avr:uno`
- `arduino:avr:nano` (or `arduino:avr:nano:cpu=atmega328old` for old bootloader)
- `arduino:avr:mega:cpu=atmega2560`
- `arduino:megaavr:nona4809`
- `arduino:samd:nano_33_iot`

### PlatformIO

Professional-grade build system. Supports Arduino framework plus many others.

```bash
# Install via pip
pip install platformio

# Initialize a new project
pio init --board uno

# Build
pio run

# Upload
pio run --target upload

# Open serial monitor
pio device monitor --baud 9600
```

**platformio.ini example:**
```ini
[env:uno]
platform = atmelavr
board = uno
framework = arduino
monitor_speed = 9600
lib_deps =
    adafruit/Adafruit Unified Sensor@^1.1.9
    adafruit/DHT sensor library@^1.4.4
```

**Advantages over Arduino IDE:**
- Proper dependency management per-project (no global libraries)
- Multi-environment builds (build for Uno and ESP32 from same project)
- Integrated unit testing
- Works with VSCode, CLion, or command line
- Automatic library dependency resolution

## Shields and Expansion Ecosystem

Shields are add-on boards that stack on top of the Uno/Mega, providing extra functionality without wiring.

### Common Shields

| Shield | Function | Key Chips/Features |
|---|---|---|
| Ethernet Shield | Wired network | W5100/W5500, SD card slot |
| Motor Shield (L293D) | DC + stepper motors | 4 DC motors or 2 steppers |
| Motor Shield (L298N) | Higher current motors | 2A per channel |
| Relay Shield | Switch high-voltage loads | 4x relays, optoisolated |
| LCD Keypad Shield | 16x2 LCD + 5 buttons | HD44780, single analog pin for buttons |
| Data Logging Shield | SD card + RTC | DS1307 RTC, SD slot, prototyping area |
| CNC Shield (GRBL) | Stepper motor control | 4x A4988/DRV8825 driver sockets |
| Sensor Shield v5 | Breakout all pins | 3-pin servo/sensor headers on every pin |
| Proto Shield | Custom circuits | Breadboard area for prototyping |

### Breakout Modules (Non-Shield)

These connect via jumper wires rather than stacking:

- **Sensors:** DHT11/22 (temp/humidity), BME280 (temp/humidity/pressure), BMP280 (temp/pressure), MPU6050 (accelerometer/gyro), HC-SR04 (ultrasonic distance), PIR motion, photoresistors, soil moisture
- **Displays:** 0.96" OLED (SSD1306, I2C), Nokia 5110, TFT screens (ILI9341), 7-segment LED, MAX7219 LED matrix
- **Communication:** HC-05/06 (Bluetooth), nRF24L01 (2.4GHz radio), LoRa (SX1276/78), ESP8266 (WiFi via serial), GPS (NEO-6M)
- **Motor drivers:** L298N, TB6612FNG, A4988/DRV8825 (stepper), PCA9685 (16-ch PWM/servo)
- **Storage:** SD card module, AT24C256 EEPROM
- **Power:** LM2596 buck converter, TP4056 LiPo charger, INA219 current sensor

### Buying Tips

- Official Arduino boards are well-made but expensive. Clones from AliExpress/Amazon are 1/5 the price and usually work fine.
- For Nano clones, check if they use CH340G (common) or FTDI (rare) USB chip. CH340 needs a driver on Windows/Mac.
- "Old bootloader" vs "new bootloader" matters for Nano clones — if upload fails, try switching the bootloader option in the IDE.
- Buy sensors in kit bundles for learning — a 37-sensor kit is typically $15-25 and covers most common sensors.
