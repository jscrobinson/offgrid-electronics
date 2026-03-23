# Arduino Pinout Reference

## Arduino Uno R3 Pinout

### Physical Layout (Top View, USB Port on Left)

```
                          +-----+
             +------------| USB |------------+
             |            +-----+            |
             |  [ ]  NC          IOREF  [ ]  |
             |  [ ]  IOREF       RESET  [ ]  |
             |  [ ]  RESET        3.3V  [ ]  |
             |  [ ]  3.3V          5V   [ ]  |
             |  [ ]  5V           GND   [ ]  |
             |  [ ]  GND          GND   [ ]  |
             |  [ ]  GND          VIN   [ ]  |
             |                               |
        A0   |  [ ]  A0            13~  [ ]  |   D13/SCK/LED
        A1   |  [ ]  A1            12~  [ ]  |   D12/MISO
        A2   |  [ ]  A2            11~  [ ]  |   D11/MOSI/PWM
        A3   |  [ ]  A3            10~  [ ]  |   D10/SS/PWM
   SDA  A4   |  [ ]  A4             9~  [ ]  |   D9/PWM
   SCL  A5   |  [ ]  A5             8   [ ]  |   D8
             |                               |
             |  [ ]  A6             7   [ ]  |   D7
             |  [ ]  A7             6~  [ ]  |   D6/PWM
             |                      5~  [ ]  |   D5/PWM
             |                      4   [ ]  |   D4
             |                      3~  [ ]  |   D3/PWM/INT1
             |                      2   [ ]  |   D2/INT0
             |                      1   [ ]  |   D1/TX
             |                      0   [ ]  |   D0/RX
             |                               |
             |          [  ICSP  ]           |
             |          [  HEADER]           |
             +-------------------------------+

~ = PWM capable pin
```

### Uno Pin Function Table

| Pin | Digital | Analog | PWM | Special Function | Notes |
|-----|---------|--------|-----|------------------|-------|
| D0 | Yes | - | - | UART RX (Serial) | Shared with USB-serial; avoid if using Serial |
| D1 | Yes | - | - | UART TX (Serial) | Shared with USB-serial; avoid if using Serial |
| D2 | Yes | - | - | INT0 (External Interrupt) | attachInterrupt(digitalPinToInterrupt(2), isr, mode) |
| D3 | Yes | - | **Yes** | INT1 (External Interrupt) | PWM frequency ~490 Hz |
| D4 | Yes | - | - | - | Used by SD card shields (CS) |
| D5 | Yes | - | **Yes** | Timer0 OC0B | PWM frequency ~980 Hz |
| D6 | Yes | - | **Yes** | Timer0 OC0A | PWM frequency ~980 Hz |
| D7 | Yes | - | - | - | General purpose |
| D8 | Yes | - | - | - | General purpose |
| D9 | Yes | - | **Yes** | Timer1 OC1A | PWM frequency ~490 Hz |
| D10 | Yes | - | **Yes** | SPI SS, Timer1 OC1B | PWM ~490 Hz; SPI chip select |
| D11 | Yes | - | **Yes** | SPI MOSI, Timer2 OC2A | PWM ~490 Hz |
| D12 | Yes | - | - | SPI MISO | - |
| D13 | Yes | - | - | SPI SCK, LED_BUILTIN | Onboard LED; may cause issues as input (LED loads pin) |
| A0 | Yes (D14) | **Yes** | - | ADC0 | 10-bit (0-1023) |
| A1 | Yes (D15) | **Yes** | - | ADC1 | 10-bit (0-1023) |
| A2 | Yes (D16) | **Yes** | - | ADC2 | 10-bit (0-1023) |
| A3 | Yes (D17) | **Yes** | - | ADC3 | 10-bit (0-1023) |
| A4 | Yes (D18) | **Yes** | - | ADC4, I2C SDA | Shared with I2C; cannot use as analog if I2C active |
| A5 | Yes (D19) | **Yes** | - | ADC5, I2C SCL | Shared with I2C; cannot use as analog if I2C active |

### Uno Power Pins

| Pin | Function | Notes |
|-----|----------|-------|
| VIN | Voltage Input | 7-12V recommended, feeds onboard regulator |
| 5V | 5V Output/Input | Regulated 5V out, or can power board directly (bypass regulator) |
| 3.3V | 3.3V Output | 50 mA max from onboard regulator |
| GND | Ground | Multiple GND pins, all connected |
| RESET | Reset | Pull LOW to reset the MCU |
| IOREF | I/O Reference | Indicates logic voltage (5V) for shield compatibility |

---

## Arduino Nano Pinout

### Physical Layout (Top View, USB on Top)

```
                     +-----+
                     | USB |
                +----+-----+----+
           D13  | [ ]       [ ] |  D12
           3V3  | [ ]       [ ] |  D11  (PWM)
          AREF  | [ ]       [ ] |  D10  (PWM)
       A0  D14  | [ ]       [ ] |  D9   (PWM)
       A1  D15  | [ ]       [ ] |  D8
       A2  D16  | [ ]       [ ] |  D7
       A3  D17  | [ ]       [ ] |  D6   (PWM)
  SDA  A4  D18  | [ ]       [ ] |  D5   (PWM)
  SCL  A5  D19  | [ ]       [ ] |  D4
       A6       | [ ]       [ ] |  D3   (PWM/INT1)
       A7       | [ ]       [ ] |  D2   (INT0)
            5V  | [ ]       [ ] |  GND
         RESET  | [ ]       [ ] |  RESET
           GND  | [ ]       [ ] |  D0   (RX)
           VIN  | [ ]       [ ] |  D1   (TX)
                +---------------+
```

### Nano vs Uno Differences

- Same ATmega328P, same pin functions
- **A6 and A7 are analog-only** on the Nano (not available on the Uno as digital)
- No barrel jack — power via USB or VIN pin
- Smaller form factor fits breadboards directly
- Mini-USB (or Micro-USB on some clones)
- Some Nano clones use "old bootloader" — if upload fails, select `Tools > Processor > ATmega328P (Old Bootloader)` in Arduino IDE

---

## Arduino Mega 2560 Pinout

### Header Layout (Simplified)

```
Digital Pins (left side, top to bottom):
    D22-D53 (double-row header)
    D22 D23 D24 D25 D26 D27 D28 D29
    D30 D31 D32 D33 D34 D35 D36 D37
    D38 D39 D40 D41 D42 D43 D44 D45
    D46 D47 D48 D49 D50 D51 D52 D53

Standard header (right side, same as Uno):
    D0-D13, A0-A5 in same positions as Uno

Analog Pins (bottom):
    A0 A1 A2 A3 A4 A5 A6 A7
    A8 A9 A10 A11 A12 A13 A14 A15
```

### Mega Key Pin Assignments

**PWM Pins (15 total):** 2-13 and 44, 45, 46

**Hardware Serial Ports:**

| Port | TX Pin | RX Pin | Usage |
|------|--------|--------|-------|
| Serial (Serial0) | 1 | 0 | USB/programming |
| Serial1 | 18 | 19 | User serial |
| Serial2 | 16 | 17 | User serial |
| Serial3 | 14 | 15 | User serial |

**External Interrupt Pins (6 total):**

| Interrupt | Pin | attachInterrupt() call |
|-----------|-----|----------------------|
| INT0 | 2 | `attachInterrupt(digitalPinToInterrupt(2), isr, mode)` |
| INT1 | 3 | `attachInterrupt(digitalPinToInterrupt(3), isr, mode)` |
| INT2 | 21 | `attachInterrupt(digitalPinToInterrupt(21), isr, mode)` |
| INT3 | 20 | `attachInterrupt(digitalPinToInterrupt(20), isr, mode)` |
| INT4 | 19 | `attachInterrupt(digitalPinToInterrupt(19), isr, mode)` |
| INT5 | 18 | `attachInterrupt(digitalPinToInterrupt(18), isr, mode)` |

**I2C:** SDA = pin 20, SCL = pin 21 (also on dedicated SDA/SCL header near AREF)

**SPI:**

| Function | Mega Pin | Uno Pin |
|----------|----------|---------|
| MOSI | 51 | 11 |
| MISO | 50 | 12 |
| SCK | 52 | 13 |
| SS | 53 | 10 |

**Important:** The ICSP header also provides SPI. Many shields use ICSP for SPI (not pins 11-13), so shields designed for Uno SPI via pins 11-13 will NOT work on Mega without modification. Shields that use the ICSP header for SPI will work on both.

---

## Communication Bus Quick Reference

### I2C (Two Wire Interface)

```
        Arduino          I2C Device
        -------          ----------
  SDA --|A4/20|--+--+----|SDA|
                 |  |
                [R] |    R = 4.7kΩ pull-up to 3.3V or 5V
                 |  |    (many breakout boards include pull-ups)
  SCL --|A5/21|--+--+----|SCL|
                 |
                [R]
                 |
               VCC
```

| Board | SDA | SCL |
|-------|-----|-----|
| Uno/Nano | A4 | A5 |
| Mega | 20 (also A4 works) | 21 (also A5 works) |

- Bus speed: 100 kHz (standard), 400 kHz (fast mode)
- Multiple devices share the same two wires, each with a unique 7-bit address
- Use `Wire.begin()` for master, `Wire.begin(address)` for slave

### SPI (Serial Peripheral Interface)

```
        Arduino          SPI Device
        -------          ----------
  MOSI--|11/51|----------|MOSI/SDI|
  MISO--|12/50|----------|MISO/SDO|
  SCK --|13/52|----------|SCK/CLK |
  SS ---|10/53|----------|CS/SS   |
```

| Board | MOSI | MISO | SCK | SS |
|-------|------|------|-----|----|
| Uno/Nano | 11 | 12 | 13 | 10 |
| Mega | 51 | 50 | 52 | 53 |

- Full duplex, much faster than I2C (up to 8 MHz on AVR)
- One CS/SS line per device (no addressing like I2C)
- SS pin must be OUTPUT even if not using it, or SPI may switch to slave mode

### UART (Serial)

```
        Arduino          Serial Device
        -------          -------------
  TX ---|1/D1 |----------|RX|
  RX ---|0/D0 |----------|TX|
  GND --|GND  |----------|GND|
```

- TX connects to RX on the other device and vice versa (crossover)
- Match baud rates on both sides
- Common baud rates: 9600, 19200, 38400, 57600, 115200
- Uno/Nano: 1 hardware UART (shared with USB — be careful!)
- Mega: 4 hardware UARTs
- SoftwareSerial can add more ports on any digital pins (Uno/Nano)

---

## Analog Reference Options

The `analogReference()` function sets the voltage used as the top of the analog input range.

| Constant | Voltage | Board | Notes |
|----------|---------|-------|-------|
| DEFAULT | 5V (or 3.3V) | All | Uses VCC as reference |
| INTERNAL | 1.1V | Uno/Nano | Built-in 1.1V bandgap reference |
| INTERNAL1V1 | 1.1V | Mega | Same as INTERNAL |
| INTERNAL2V56 | 2.56V | Mega | Higher precision reference |
| EXTERNAL | AREF pin | All | Supply your own reference voltage on AREF |

**Warning:** Never apply voltage to the AREF pin while using DEFAULT reference. This can damage the MCU.

---

## Pin Current Limits

| Parameter | Limit |
|-----------|-------|
| Max current per I/O pin | 40 mA (absolute max), 20 mA recommended |
| Max current from 3.3V pin | 50 mA |
| Max total current (all pins combined) | 200 mA (ATmega328P), 400 mA (ATmega2560) |
| Max current from 5V pin (USB powered) | ~500 mA (limited by USB) |
| Max current from 5V pin (VIN powered) | ~800 mA (limited by onboard regulator heat) |

**Practical implications:**
- An LED with a 220-ohm resistor draws ~15 mA — fine for a few LEDs
- A standard servo draws 100-500 mA — power separately, not from Arduino 5V pin
- A relay module typically needs 70-80 mA per coil — use a transistor/MOSFET to switch
- Motors should ALWAYS be powered externally with a motor driver, never directly from pins
