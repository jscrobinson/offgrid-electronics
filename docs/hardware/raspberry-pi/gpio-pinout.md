# Raspberry Pi GPIO Pinout Reference

## 40-Pin Header Diagram

All Raspberry Pi models (except Pico) from the Pi 1 B+ onward share the same 40-pin GPIO header layout.

Pin 1 is closest to the corner of the board, next to the SD card slot (or on Pi 5, marked with a square solder pad).

```
                       3V3  (1)  (2)  5V
              SDA1 / GPIO2  (3)  (4)  5V
              SCL1 / GPIO3  (5)  (6)  GND
                     GPIO4  (7)  (8)  GPIO14 / TXD
                       GND  (9)  (10) GPIO15 / RXD
                    GPIO17  (11) (12) GPIO18 / PCM_CLK / PWM0
                    GPIO27  (13) (14) GND
                    GPIO22  (15) (16) GPIO23
                       3V3  (17) (18) GPIO24
        MOSI / GPIO10  (19) (20) GND
        MISO / GPIO9   (21) (22) GPIO25
        SCLK / GPIO11  (23) (24) GPIO8  / CE0
                       GND  (25) (26) GPIO7  / CE1
         ID_SD / GPIO0 (27) (28) GPIO1  / ID_SC
                    GPIO5   (29) (30) GND
                    GPIO6   (31) (32) GPIO12 / PWM0
             PWM1 / GPIO13  (33) (34) GND
  PCM_FS / PWM1 / GPIO19   (35) (36) GPIO16
                    GPIO26  (37) (38) GPIO20 / PCM_DIN
                       GND  (39) (40) GPIO21 / PCM_DOUT
```

### Quick Reference: Pin Types

```
Pin Layout (physical pin numbers):

    [3V3] [5V ]     <-- Power
    [SDA] [5V ]     <-- I2C data / Power
    [SCL] [GND]     <-- I2C clock / Ground
    [GP4] [TXD]     <-- GPIO / UART transmit
    [GND] [RXD]     <-- Ground / UART receive
    [G17] [G18]     <-- GPIO / PWM0
    [G27] [GND]     <-- GPIO / Ground
    [G22] [G23]     <-- GPIO
    [3V3] [G24]     <-- Power / GPIO
    [MOS] [GND]     <-- SPI MOSI / Ground
    [MIS] [G25]     <-- SPI MISO / GPIO
    [CLK] [CE0]     <-- SPI clock / SPI chip select 0
    [GND] [CE1]     <-- Ground / SPI chip select 1
    [ID ] [ID ]     <-- EEPROM ID (reserved for HATs)
    [GP5] [GND]     <-- GPIO / Ground
    [GP6] [G12]     <-- GPIO / PWM0
    [G13] [GND]     <-- PWM1 / Ground
    [G19] [G16]     <-- PWM1 / GPIO
    [G26] [G20]     <-- GPIO
    [GND] [G21]     <-- Ground / GPIO
```

---

## Pin Function Tables

### Power Pins

| Physical Pin | Function | Notes |
|---|---|---|
| 1, 17 | 3.3V Power | Regulated 3.3V output. Max ~50 mA shared across both pins (from SoC regulator). On Pi 4/5, up to ~800mA total from dedicated regulator. |
| 2, 4 | 5V Power | Connected directly to the 5V power input. Can draw significant current (limited by your power supply). Can also power the Pi if you feed regulated 5V here. |
| 6, 9, 14, 20, 25, 30, 34, 39 | Ground | All connected internally. Use any available ground pin. |

### GPIO Pins (General Purpose I/O)

All GPIO pins operate at **3.3V logic. They are NOT 5V tolerant.** Applying 5V to any GPIO pin will damage the SoC permanently.

| Physical Pin | GPIO # | Default Function | Alternate Functions |
|---|---|---|---|
| 3 | GPIO2 | I2C1 SDA | SDA1 (with 1.8k pull-up to 3.3V on board) |
| 5 | GPIO3 | I2C1 SCL | SCL1 (with 1.8k pull-up to 3.3V on board) |
| 7 | GPIO4 | GPCLK0 | 1-Wire default pin |
| 8 | GPIO14 | UART0 TXD | |
| 10 | GPIO15 | UART0 RXD | |
| 11 | GPIO17 | GPIO | |
| 12 | GPIO18 | PCM CLK | PWM0 (hardware PWM channel 0) |
| 13 | GPIO27 | GPIO | |
| 15 | GPIO22 | GPIO | |
| 16 | GPIO23 | GPIO | |
| 18 | GPIO24 | GPIO | |
| 19 | GPIO10 | SPI0 MOSI | |
| 21 | GPIO9 | SPI0 MISO | |
| 22 | GPIO25 | GPIO | |
| 23 | GPIO11 | SPI0 SCLK | |
| 24 | GPIO8 | SPI0 CE0 | Chip select for SPI device 0 |
| 26 | GPIO7 | SPI0 CE1 | Chip select for SPI device 1 |
| 27 | GPIO0 | ID_SD | Reserved for HAT EEPROM (do not use) |
| 28 | GPIO1 | ID_SC | Reserved for HAT EEPROM (do not use) |
| 29 | GPIO5 | GPIO | |
| 31 | GPIO6 | GPIO | |
| 32 | GPIO12 | GPIO | PWM0 (hardware PWM channel 0) |
| 33 | GPIO13 | GPIO | PWM1 (hardware PWM channel 1) |
| 35 | GPIO19 | PCM FS | PWM1 (hardware PWM channel 1) |
| 36 | GPIO16 | GPIO | |
| 37 | GPIO26 | GPIO | |
| 38 | GPIO20 | PCM DIN | |
| 40 | GPIO21 | PCM DOUT | |

### Communication Buses

**I2C (Inter-Integrated Circuit):**

| Function | GPIO | Physical Pin |
|---|---|---|
| SDA (I2C1) | GPIO2 | Pin 3 |
| SCL (I2C1) | GPIO3 | Pin 5 |

- On-board 1.8k ohm pull-ups to 3.3V (already present on the Pi)
- Enable in `raspi-config` > Interface Options > I2C
- Or add `dtparam=i2c_arm=on` to `/boot/config.txt` (or `/boot/firmware/config.txt` on Bookworm)
- Bus speed: 100 kHz default, changeable via `dtparam=i2c_arm_baudrate=400000`

**SPI (Serial Peripheral Interface):**

| Function | GPIO | Physical Pin |
|---|---|---|
| MOSI (SPI0) | GPIO10 | Pin 19 |
| MISO (SPI0) | GPIO9 | Pin 21 |
| SCLK (SPI0) | GPIO11 | Pin 23 |
| CE0 (SPI0) | GPIO8 | Pin 24 |
| CE1 (SPI0) | GPIO7 | Pin 26 |

- Enable in `raspi-config` > Interface Options > SPI
- Two chip select lines allow two SPI devices on SPI0
- SPI1 is also available on GPIO19-21, GPIO16-18 (enable with device tree overlay)

**UART (Serial):**

| Function | GPIO | Physical Pin |
|---|---|---|
| TXD (UART0) | GPIO14 | Pin 8 |
| RXD (UART0) | GPIO15 | Pin 10 |

- By default, the serial console is mapped to the UART. Disable it to use the UART for your own purposes:
  ```bash
  sudo raspi-config   # Interface Options > Serial Port
  # "Login shell over serial?" -> No
  # "Enable serial port hardware?" -> Yes
  ```
- UART device: `/dev/serial0` (symlink to the appropriate hardware UART)
- On Pi 3/4/5 with Bluetooth: the mini-UART is assigned to GPIO14/15 by default. For full UART, add `dtoverlay=disable-bt` to config.txt (disables Bluetooth) or `dtoverlay=miniuart-bt` (swaps assignments).

**Hardware PWM:**

| PWM Channel | GPIO Options | Physical Pin |
|---|---|---|
| PWM0 | GPIO12 or GPIO18 | Pin 32 or Pin 12 |
| PWM1 | GPIO13 or GPIO19 | Pin 33 or Pin 35 |

- Only two independent hardware PWM channels
- Software PWM is available on any pin via gpiozero/pigpio but less precise
- Enable with device tree overlay if needed

---

## GPIO Programming

### Python: gpiozero (Recommended)

The modern, object-oriented GPIO library. Pre-installed on Raspberry Pi OS.

```python
from gpiozero import LED, Button, PWMLED, Servo, DistanceSensor
from signal import pause

# Simple LED
led = LED(17)              # GPIO17
led.on()
led.off()
led.toggle()
led.blink(on_time=1, off_time=1)

# Button with callback
button = Button(2)         # GPIO2
button.when_pressed = lambda: led.on()
button.when_released = lambda: led.off()

# PWM LED (brightness control)
pwm_led = PWMLED(18)       # Must be PWM-capable for hardware PWM
pwm_led.value = 0.5        # 50% brightness

# Servo
servo = Servo(17)
servo.min()                 # Move to minimum position
servo.mid()                 # Move to middle
servo.max()                 # Move to maximum
servo.value = 0.5           # Arbitrary position (-1 to 1)

# Ultrasonic distance sensor (HC-SR04)
sensor = DistanceSensor(echo=18, trigger=17)
print(f"Distance: {sensor.distance * 100:.1f} cm")

# Keep program running (for event-driven code)
pause()
```

**gpiozero advantages:**
- Clean, Pythonic API
- Handles cleanup automatically
- Built-in support for common components (LED, Button, Buzzer, Motor, Servo, sensors)
- Remote GPIO support (control pins over the network)
- Works on Raspberry Pi OS Bookworm without root (using lgpio backend)

### Python: RPi.GPIO (Legacy)

The older GPIO library. Still widely used in tutorials.

```python
import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM)     # Use GPIO numbers (not physical pin numbers)
# GPIO.setmode(GPIO.BOARD) # Use physical pin numbers

# Output
GPIO.setup(17, GPIO.OUT)
GPIO.output(17, GPIO.HIGH)
GPIO.output(17, GPIO.LOW)

# Input with pull-up
GPIO.setup(2, GPIO.IN, pull_up_down=GPIO.PUD_UP)
if GPIO.input(2) == GPIO.LOW:
    print("Button pressed")

# PWM
pwm = GPIO.PWM(18, 1000)   # Pin 18, 1000 Hz frequency
pwm.start(50)               # Start at 50% duty cycle
pwm.ChangeDutyCycle(75)     # Change to 75%
pwm.stop()

# Edge detection (interrupt-like)
def button_callback(channel):
    print(f"Button pressed on GPIO {channel}")

GPIO.add_event_detect(2, GPIO.FALLING, callback=button_callback, bouncetime=200)

# Cleanup when done (resets all pins)
GPIO.cleanup()
```

**Note:** RPi.GPIO requires root privileges on newer Pi OS versions. On Bookworm, use gpiozero with lgpio backend instead, which works without root.

### Python: lgpio and gpiod

For Raspberry Pi OS Bookworm and later, the recommended low-level libraries are:

```python
import lgpio

h = lgpio.gpiochip_open(0)      # Open GPIO chip

# Output
lgpio.gpio_claim_output(h, 17)
lgpio.gpio_write(h, 17, 1)      # HIGH
lgpio.gpio_write(h, 17, 0)      # LOW

# Input
lgpio.gpio_claim_input(h, 2, lgpio.SET_PULL_UP)
value = lgpio.gpio_read(h, 2)

lgpio.gpiochip_close(h)
```

### Command Line: pinctrl (Pi OS Bookworm+)

```bash
# Show all GPIO states
pinctrl

# Get specific pin state
pinctrl get 17

# Set pin as output and drive high
pinctrl set 17 op dh    # op=output, dh=drive high

# Set pin as output and drive low
pinctrl set 17 op dl    # dl=drive low

# Set pin as input with pull-up
pinctrl set 17 ip pu    # ip=input, pu=pull-up

# Set pin as input with pull-down
pinctrl set 17 ip pd    # pd=pull-down
```

On older systems, use `raspi-gpio` instead:
```bash
raspi-gpio get 17
raspi-gpio set 17 op dh
```

### Command Line: gpio (WiringPi — Legacy)

WiringPi is no longer maintained but is still found in many tutorials.

```bash
gpio -g mode 17 out
gpio -g write 17 1
gpio -g read 17
gpio readall      # Show all pin states in a nice table
```

---

## Important Warnings

### 3.3V Logic — NOT 5V Tolerant

The Raspberry Pi GPIO pins operate at 3.3V and have **no 5V tolerance**. Connecting a 5V signal directly to a GPIO pin will likely destroy the SoC.

**Interfacing with 5V devices:**
- Use a bidirectional logic level converter (recommended)
- Use a voltage divider for input (5V to 3.3V):
  ```
  5V Signal ---[1kΩ]---+---[2kΩ]--- GND
                        |
                    GPIO Pin (reads 3.3V)
  ```
- For output: 3.3V is usually accepted as HIGH by 5V logic (most 5V ICs have a HIGH threshold of ~2V)

### Current Limits

| Parameter | Limit |
|---|---|
| Max current per GPIO pin | 16 mA (safe maximum) |
| Max total current (all GPIO pins) | ~50 mA total |
| 3.3V rail | ~800 mA on Pi 4/5 (less on older models) |
| 5V rail | Limited by power supply minus Pi's own consumption |

- An LED with a 330-ohm resistor draws ~10 mA from a GPIO pin — that is fine
- A relay coil, motor, or any high-current load needs a transistor/MOSFET driver
- Multiple LEDs should use a shift register (74HC595) or GPIO expander (MCP23017)

### Pins 0 and 1 (GPIO0 / GPIO1) — Reserved for HAT EEPROM

Physical pins 27 and 28 (GPIO0 and GPIO1) are used by the HAT (Hardware Attached on Top) specification for auto-configuration EEPROM. Do not use them for general-purpose I/O unless you are certain no HAT EEPROM is present.

### Pull-Up on I2C Pins

GPIO2 (SDA) and GPIO3 (SCL) have permanent 1.8k ohm pull-up resistors to 3.3V on the board. This means:
- They always read HIGH when nothing is connected
- They are not suitable as general-purpose GPIO for most applications
- They are perfect for I2C (pull-ups are required by the I2C spec)

---

## Enabling Interfaces

### Via raspi-config

```bash
sudo raspi-config
# Navigate to: Interface Options
#   I2C -> Enable
#   SPI -> Enable
#   Serial Port -> Disable login shell, Enable hardware
#   1-Wire -> Enable
#   Remote GPIO -> Enable (for gpiozero remote access)
```

### Via config.txt

Edit `/boot/firmware/config.txt` (Bookworm) or `/boot/config.txt` (Bullseye and earlier):

```ini
# I2C
dtparam=i2c_arm=on
dtparam=i2c_arm_baudrate=400000    # Optional: 400kHz fast mode

# SPI
dtparam=spi=on

# UART (full UART on GPIO14/15, disabling Bluetooth)
dtoverlay=disable-bt

# 1-Wire on GPIO4
dtoverlay=w1-gpio

# Hardware PWM on GPIO18
dtoverlay=pwm,pin=18,func=2

# Additional I2C bus (I2C3 on GPIO4/5)
dtoverlay=i2c3,pins_4_5

# Additional SPI bus (SPI1)
dtoverlay=spi1-1cs
```

### Checking Connected I2C Devices

```bash
sudo apt install i2c-tools
i2cdetect -y 1    # Scan I2C bus 1 (the standard bus)

# Output shows addresses of connected devices:
#      0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
# 00:          -- -- -- -- -- -- -- -- -- -- -- -- --
# 10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
# 20: -- -- -- -- -- -- -- 27 -- -- -- -- -- -- -- --
# 30: -- -- -- -- -- -- -- -- -- -- -- -- 3c -- -- --
# 40: -- -- -- -- -- -- -- -- 48 -- -- -- -- -- -- --
# 50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
# 60: -- -- -- -- -- -- -- -- 68 -- -- -- -- -- -- --
# 70: -- -- -- -- -- -- -- --
```

### Checking SPI Devices

```bash
ls /dev/spidev*
# /dev/spidev0.0  /dev/spidev0.1   (SPI0, two chip selects)
```

---

## Raspberry Pi Pico GPIO (RP2040)

The Pico has a different pinout from the 40-pin Pi header.

```
         +-----+
GP0  (1) |o   o| (40) VBUS
GP1  (2) |o   o| (39) VSYS
GND  (3) |o   o| (38) GND
GP2  (4) |o   o| (37) 3V3_EN
GP3  (5) |o   o| (36) 3V3
GP4  (6) |o   o| (35) ADC_VREF
GP5  (7) |o   o| (34) GP28 / ADC2
GND  (8) |o   o| (33) GND
GP6  (9) |o   o| (32) GP27 / ADC1
GP7 (10) |o   o| (31) GP26 / ADC0
GP8 (11) |o   o| (30) RUN (reset)
GP9 (12) |o   o| (29) GP22
GND (13) |o   o| (28) GND
GP10(14) |o   o| (27) GP21
GP11(15) |o   o| (26) GP20
GP12(16) |o   o| (25) GP19
GP13(17) |o   o| (24) GP18
GND (18) |o   o| (23) GND
GP14(19) |o   o| (22) GP17
GP15(20) |o   o| (21) GP16
         +-----+
          USB
```

- **26 GPIO pins** (GP0-GP28, with GP23-25 used internally on Pico W for WiFi)
- **3 ADC inputs:** GP26 (ADC0), GP27 (ADC1), GP28 (ADC2) — 12-bit resolution
- **16 PWM channels** (all GPIO pins can do PWM)
- **2x UART, 2x SPI, 2x I2C:** Flexibly assignable to most GPIO pins
- **8 PIO state machines:** For custom protocols
- **3.3V logic, not 5V tolerant**
