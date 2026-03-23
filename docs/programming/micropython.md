# MicroPython Guide

MicroPython is a lean implementation of Python 3 optimized to run on microcontrollers with as little as 256KB of flash and 16KB of RAM. It provides a Python REPL directly on hardware, making embedded development faster and more interactive.

---

## Supported Boards

| Board | Chip | Flash | RAM | WiFi | Notes |
|-------|------|-------|-----|------|-------|
| ESP32 | Xtensa dual-core 240MHz | 4MB+ | 520KB | Yes | Most popular for MicroPython |
| ESP32-S3 | Xtensa dual-core 240MHz | 8MB+ | 512KB | Yes | USB-OTG, AI acceleration |
| ESP32-C3 | RISC-V 160MHz | 4MB | 400KB | Yes | Low-cost, BLE 5.0 |
| ESP8266 | Xtensa 80MHz | 1-4MB | 80KB | Yes | Legacy, limited RAM |
| RP2040 (Pico) | Dual ARM Cortex-M0+ 133MHz | 2MB | 264KB | No* | *Pico W has WiFi |
| STM32 | ARM Cortex-M | Varies | Varies | No | pyboard, Nucleo boards |
| nRF52840 | ARM Cortex-M4 64MHz | 1MB | 256KB | BLE | Bluetooth focused |

---

## Installing Firmware

### ESP32 (most common)

```bash
# Install esptool
pip install esptool

# Download firmware from https://micropython.org/download/
# For ESP32: esp32-20240101-v1.22.0.bin (or latest)

# Find your serial port
ls /dev/ttyUSB*       # Linux
ls /dev/tty.usb*      # macOS
# On Windows: COM3, COM4, etc.

# Erase flash first (important!)
esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash

# Write firmware
esptool.py --chip esp32 --port /dev/ttyUSB0 \
    --baud 460800 write_flash -z 0x1000 esp32-20240101-v1.22.0.bin
```

### ESP32-S3/C3

```bash
# Different flash offset for S3/C3
esptool.py --chip esp32s3 --port /dev/ttyUSB0 erase_flash
esptool.py --chip esp32s3 --port /dev/ttyUSB0 \
    --baud 460800 write_flash -z 0x0 esp32s3-20240101-v1.22.0.bin
```

### RP2040 (Raspberry Pi Pico)

1. Hold BOOTSEL button while plugging in USB
2. Pico appears as USB drive (RPI-RP2)
3. Drag and drop the `.uf2` firmware file onto the drive
4. Pico reboots automatically with MicroPython

---

## REPL (Read-Eval-Print Loop)

Connect via serial terminal at 115200 baud:

```bash
# Linux/macOS
screen /dev/ttyUSB0 115200
# or
picocom -b 115200 /dev/ttyUSB0
# or use minicom, PuTTY

# Using mpremote (recommended)
pip install mpremote
mpremote connect /dev/ttyUSB0
```

REPL special keys:
- `Ctrl+C` — interrupt running program
- `Ctrl+D` — soft reset
- `Ctrl+A` — enter raw REPL (for programmatic access)
- `Ctrl+B` — exit raw REPL
- `Ctrl+E` — paste mode (paste multi-line code, end with Ctrl+D)

---

## File System

MicroPython has a small internal filesystem. Two special files:

- **`boot.py`** — runs once at boot, before USB/REPL is available. Use for low-level setup (WiFi, pin config). Keep it minimal.
- **`main.py`** — runs after boot.py, after REPL is available. Put your application code here.

```python
# List files on the device
import os
os.listdir("/")

# File operations
with open("config.json", "w") as f:
    f.write('{"ssid": "MyNetwork"}')

with open("config.json", "r") as f:
    data = f.read()

os.mkdir("data")
os.remove("old_file.txt")
os.rename("old.txt", "new.txt")
os.stat("file.txt")       # file info (size, timestamps)
os.statvfs("/")            # filesystem info (free space)
```

### Transferring Files

```bash
# mpremote (recommended)
mpremote cp main.py :main.py              # copy to device
mpremote cp :main.py local_main.py        # copy from device
mpremote ls                               # list files
mpremote rm :old_file.txt                 # delete file
mpremote run script.py                    # run without copying
mpremote mount .                          # mount local dir as device filesystem

# ampy (Adafruit, older but works)
pip install adafruit-ampy
ampy --port /dev/ttyUSB0 put main.py
ampy --port /dev/ttyUSB0 get main.py
ampy --port /dev/ttyUSB0 ls
ampy --port /dev/ttyUSB0 run test.py

# rshell
pip install rshell
rshell -p /dev/ttyUSB0
> cp main.py /pyboard/main.py
> cat /pyboard/main.py
```

---

## machine Module — Hardware Interface

### GPIO (Digital Pins)

```python
from machine import Pin
import time

# Output
led = Pin(2, Pin.OUT)         # GPIO2, output mode
led.value(1)                  # HIGH
led.value(0)                  # LOW
led.on()                      # HIGH
led.off()                     # LOW

# Input
button = Pin(0, Pin.IN, Pin.PULL_UP)
state = button.value()        # 0 = pressed (with pull-up)

# Input with interrupt
def button_handler(pin):
    print("Button pressed!", pin)

button.irq(trigger=Pin.IRQ_FALLING, handler=button_handler)

# Blink example
led = Pin(2, Pin.OUT)
while True:
    led.value(not led.value())
    time.sleep(0.5)
```

### ADC (Analog-to-Digital)

```python
from machine import ADC, Pin

# ESP32: ADC on GPIO 32-39 (ADC1), 0-3.3V, 12-bit (0-4095)
adc = ADC(Pin(34))
adc.atten(ADC.ATTN_11DB)     # full range 0-3.3V
                               # ATTN_0DB: 0-1.0V
                               # ATTN_2_5DB: 0-1.34V
                               # ATTN_6DB: 0-2.0V
                               # ATTN_11DB: 0-3.3V
adc.width(ADC.WIDTH_12BIT)    # 12-bit resolution (default)
raw = adc.read()               # 0-4095
voltage = raw * 3.3 / 4095

# RP2040: ADC on GPIO 26-28, 12-bit
adc = ADC(26)
raw = adc.read_u16()          # 0-65535 (16-bit interface)
```

### PWM

```python
from machine import Pin, PWM

pwm = PWM(Pin(2))
pwm.freq(1000)        # frequency in Hz
pwm.duty(512)         # duty cycle 0-1023 (ESP32)
pwm.duty_u16(32768)   # 0-65535 (cross-platform, 50%)
pwm.deinit()          # release the pin

# LED dimming
import time
pwm = PWM(Pin(2), freq=1000)
for duty in range(0, 1024, 8):
    pwm.duty(duty)
    time.sleep_ms(10)

# Servo (50Hz, 1-2ms pulse = 0-180 degrees)
servo = PWM(Pin(13), freq=50)
# duty for 1ms pulse at 50Hz: 1/20 * 1023 = ~51
# duty for 2ms pulse at 50Hz: 2/20 * 1023 = ~102
servo.duty(51)     # 0 degrees
servo.duty(77)     # 90 degrees
servo.duty(102)    # 180 degrees
```

### I2C

```python
from machine import I2C, Pin

# Software I2C (any pins)
i2c = I2C(0, scl=Pin(22), sda=Pin(21), freq=400000)

# Hardware I2C (specific pins, faster)
i2c = I2C(0, scl=Pin(22), sda=Pin(21), freq=400000)

# Scan for devices
devices = i2c.scan()
print("Found:", [hex(d) for d in devices])

# Read/Write
i2c.writeto(0x68, b'\x00')                  # write to device
data = i2c.readfrom(0x68, 7)                 # read 7 bytes
i2c.readfrom_mem(0x68, 0x00, 7)             # read from register
i2c.writeto_mem(0x68, 0x6B, b'\x00')        # write to register

# Example: read temperature from BMP280 at address 0x76
i2c.writeto_mem(0x76, 0xF4, b'\x27')        # set mode
raw = i2c.readfrom_mem(0x76, 0xFA, 3)       # read temp registers
```

### SPI

```python
from machine import SPI, Pin

# Hardware SPI
spi = SPI(1, baudrate=1000000, polarity=0, phase=0,
          sck=Pin(18), mosi=Pin(23), miso=Pin(19))

cs = Pin(5, Pin.OUT)

# Transfer data
cs.value(0)                    # select device
spi.write(b'\x01\x02')        # write bytes
data = spi.read(4)            # read 4 bytes
buf = bytearray(4)
spi.readinto(buf)              # read into existing buffer
spi.write_readinto(b'\x00\x00', buf)  # simultaneous write+read
cs.value(1)                    # deselect device
```

### UART (Serial)

```python
from machine import UART, Pin

# ESP32 has 3 UARTs (UART0 is REPL, use UART1 or UART2)
uart = UART(2, baudrate=9600, tx=Pin(17), rx=Pin(16))

# Write
uart.write("Hello\n")
uart.write(b'\x01\x02\x03')

# Read
if uart.any():                  # check if data available
    data = uart.read(10)        # read up to 10 bytes
    line = uart.readline()      # read until newline
```

### Timers

```python
from machine import Timer

# Periodic timer
def tick(timer):
    print("tick")

tim = Timer(0)
tim.init(period=1000, mode=Timer.PERIODIC, callback=tick)  # every 1s

# One-shot timer
tim.init(period=5000, mode=Timer.ONE_SHOT, callback=tick)

# Stop timer
tim.deinit()
```

### Deep Sleep and Power Management

```python
import machine
import time

# Light sleep (wakes on timer, GPIO, etc.)
machine.lightsleep(10000)      # sleep 10 seconds

# Deep sleep (lowest power, resets on wake)
machine.deepsleep(60000)       # sleep 60 seconds, then reset

# Wake on pin (ESP32)
from machine import Pin
wake_pin = Pin(0, Pin.IN, Pin.PULL_UP)
machine.wake_on_ext0(pin=wake_pin, level=machine.WAKEUP_ALL_LOW)
machine.deepsleep()

# Check wake reason
if machine.reset_cause() == machine.DEEPSLEEP_RESET:
    print("Woke from deep sleep")

# Reduce clock speed to save power
machine.freq(80000000)   # 80MHz instead of 240MHz
machine.freq()           # check current frequency
```

---

## network Module — WiFi

### Station Mode (connect to existing WiFi)

```python
import network

sta = network.WLAN(network.STA_IF)
sta.active(True)

# Scan for networks
networks = sta.scan()
for ssid, bssid, channel, rssi, authmode, hidden in networks:
    print(f"  {ssid.decode():30s} ch={channel} rssi={rssi}")

# Connect
sta.connect("MyNetwork", "MyPassword")

# Wait for connection
import time
while not sta.isconnected():
    time.sleep(1)
    print("Connecting...")

print("Connected!")
print("IP:", sta.ifconfig())    # (ip, subnet, gateway, dns)

# Check status
sta.isconnected()
sta.status()                     # network.STAT_GOT_IP, etc.
sta.config('mac')               # MAC address
```

### Access Point Mode (create WiFi network)

```python
import network

ap = network.WLAN(network.AP_IF)
ap.active(True)
ap.config(
    essid="ESP32-Sensor",
    password="12345678",          # min 8 chars, or "" for open
    authmode=network.AUTH_WPA2_PSK,
    channel=6,
    max_clients=4
)

print("AP IP:", ap.ifconfig())   # usually 192.168.4.1

# Simple web server on AP
import socket
s = socket.socket()
s.bind(("0.0.0.0", 80))
s.listen(1)
while True:
    conn, addr = s.accept()
    request = conn.recv(1024)
    response = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n"
    response += "<h1>ESP32 Sensor</h1><p>Temperature: 22.5C</p>"
    conn.send(response.encode())
    conn.close()
```

### Robust WiFi Connection Pattern

```python
import network
import time

def connect_wifi(ssid, password, timeout=15):
    sta = network.WLAN(network.STA_IF)
    sta.active(True)

    if sta.isconnected():
        sta.disconnect()
        time.sleep(1)

    sta.connect(ssid, password)

    start = time.time()
    while not sta.isconnected():
        if time.time() - start > timeout:
            sta.active(False)
            raise OSError("WiFi connection timeout")
        time.sleep(0.5)

    ip = sta.ifconfig()[0]
    print(f"Connected: {ip}")
    return ip
```

---

## WebREPL

Access MicroPython REPL over WiFi (browser-based):

```python
# First time setup (run in serial REPL)
import webrepl_setup
# Follow prompts to set password and enable

# In boot.py for auto-start:
import webrepl
webrepl.start()

# Access via browser: http://micropython.org/webrepl/
# Connect to ws://192.168.4.1:8266 (AP mode)
# or ws://<device-ip>:8266 (station mode)
```

---

## uasyncio — Asynchronous Programming

MicroPython's lightweight asyncio for concurrent tasks without threads:

```python
import uasyncio as asyncio
from machine import Pin

# Basic async function
async def blink(pin, interval_ms):
    led = Pin(pin, Pin.OUT)
    while True:
        led.value(not led.value())
        await asyncio.sleep_ms(interval_ms)

# Read sensor periodically
async def read_sensor():
    while True:
        # read sensor...
        value = adc.read()
        print(f"Sensor: {value}")
        await asyncio.sleep(5)

# Handle network requests
async def serve_client(reader, writer):
    request = await reader.read(1024)
    response = "HTTP/1.1 200 OK\r\n\r\nHello"
    await writer.awrite(response.encode())
    await writer.aclose()

async def start_server():
    server = await asyncio.start_server(serve_client, "0.0.0.0", 80)

# Main — run multiple tasks concurrently
async def main():
    asyncio.create_task(blink(2, 500))
    asyncio.create_task(read_sensor())
    asyncio.create_task(start_server())

    # Keep main running
    while True:
        await asyncio.sleep(1)

# Entry point
asyncio.run(main())
```

---

## Memory Management

MicroPython runs on devices with very limited RAM. Memory management matters.

```python
import gc
import micropython

# Check free memory
gc.collect()                        # run garbage collection
print("Free:", gc.mem_free())       # free RAM in bytes
print("Used:", gc.mem_alloc())      # allocated RAM

# Memory info dump
micropython.mem_info()              # detailed memory report
micropython.mem_info(1)             # include memory map

# Tips for saving RAM:
# 1. Use const() for constant values
from micropython import const
_LED_PIN = const(2)                 # compiled as literal, saves RAM

# 2. Use bytearray instead of list for byte data
buf = bytearray(1024)              # much less overhead than list

# 3. Delete variables you no longer need
del large_data
gc.collect()

# 4. Use generators instead of lists
# BAD:  sum([x**2 for x in range(1000)])
# GOOD: sum(x**2 for x in range(1000))

# 5. Pre-allocate buffers and reuse them
buf = bytearray(64)
i2c.readfrom_into(0x68, buf)

# 6. Avoid string concatenation in loops
# BAD:  s = ""; for x in items: s += str(x)
# GOOD: parts = []; for x in items: parts.append(str(x)); s = "".join(parts)

# 7. Use frozen modules for large libraries (see below)

# Enable automatic GC
gc.enable()
gc.threshold(50000)    # run GC when this much is allocated
```

---

## Freezing Modules

Frozen modules are compiled into the firmware image and run from flash instead of RAM, saving significant memory.

```bash
# 1. Clone MicroPython source
git clone https://github.com/micropython/micropython.git
cd micropython

# 2. Place your modules in the frozen manifest
# ports/esp32/boards/manifest.py
# Add: freeze("path/to/your/modules")

# 3. Build firmware
cd ports/esp32
make submodules
make BOARD=ESP32_GENERIC

# 4. Flash the custom firmware
esptool.py --port /dev/ttyUSB0 erase_flash
esptool.py --port /dev/ttyUSB0 write_flash -z 0x1000 build-ESP32_GENERIC/firmware.bin
```

For simpler cases, use `.mpy` precompiled files:

```bash
# Install mpy-cross compiler
pip install mpy-cross

# Compile .py to .mpy (smaller, loads faster, uses less RAM)
mpy-cross mymodule.py
# Copy mymodule.mpy to device
```

---

## Differences from CPython

| Feature | CPython | MicroPython |
|---------|---------|-------------|
| Integer size | Arbitrary precision | Arbitrary (but slower for big ints) |
| Float | 64-bit double | 32-bit float (on most ports) |
| Strings | Full Unicode | UTF-8, limited Unicode support |
| Stdlib | Extensive | Minimal subset (u-prefixed versions) |
| Exceptions | Full traceback | Limited traceback info |
| Classes | Full MRO | Simplified, some features missing |
| Closures | Full support | Supported but use more RAM |
| Decorators | Full support | Supported |
| List comprehensions | Full | Supported |
| `*args`/`**kwargs` | Full | Supported |
| `async`/`await` | asyncio | uasyncio (similar but lighter) |

### Missing / Limited stdlib modules:

MicroPython includes subsets, often prefixed with `u`:
- `ujson` (or just `json`)
- `ure` (limited regex)
- `usocket` (or `socket`)
- `uos` (or `os`)
- `utime` (or `time`)
- `uhashlib`
- `ubinascii`
- `ustruct` (or `struct`)

**Not available:** `threading`, `multiprocessing`, `pathlib`, `typing`, `dataclasses`, `datetime` (use `time` module instead)

---

## mpremote Tool

The official tool for interacting with MicroPython devices:

```bash
pip install mpremote

# Connect (auto-detect port)
mpremote

# Specify port
mpremote connect /dev/ttyUSB0

# Run a local script on the device
mpremote run script.py

# File operations
mpremote fs ls              # list files
mpremote fs cp main.py :    # copy to device root
mpremote fs cp :data.log .  # copy from device
mpremote fs rm :old.py      # delete from device
mpremote fs mkdir :data     # create directory

# Mount local directory (files served live from PC)
mpremote mount .

# Install packages from micropython-lib
mpremote mip install aiohttp
mpremote mip install github:user/repo

# Chain commands
mpremote connect /dev/ttyUSB0 mount . run main.py

# Reset device
mpremote reset
mpremote bootloader         # enter bootloader mode
```

---

## Thonny IDE

Thonny is the easiest way to get started with MicroPython:

1. Download from thonny.org (works on Windows, macOS, Linux, Raspberry Pi)
2. Go to **Tools > Options > Interpreter**
3. Select **MicroPython (ESP32)** or your board
4. Select the serial port
5. Click OK — you now have a REPL and file editor

Features:
- Code editor with syntax highlighting
- REPL panel at bottom
- File manager (device and local)
- Firmware installer (Tools > Manage Plug-ins)
- Step debugger (limited on MicroPython)
- Package manager for micropython-lib

---

## Common Patterns

### WiFi + Sensor + Web Server

```python
# main.py — complete example
import network
import socket
import time
import json
from machine import Pin, ADC

# Connect WiFi
sta = network.WLAN(network.STA_IF)
sta.active(True)
sta.connect("MySSID", "MyPassword")
while not sta.isconnected():
    time.sleep(1)
print("IP:", sta.ifconfig()[0])

# Setup sensor
adc = ADC(Pin(34))
adc.atten(ADC.ATTN_11DB)

# Web server
s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("0.0.0.0", 80))
s.listen(2)

while True:
    conn, addr = s.accept()
    try:
        request = conn.recv(1024).decode()
        reading = adc.read() * 3.3 / 4095

        if "GET /api" in request:
            body = json.dumps({"voltage": reading})
            content_type = "application/json"
        else:
            body = f"<html><body><h1>Sensor: {reading:.2f}V</h1></body></html>"
            content_type = "text/html"

        conn.send(f"HTTP/1.1 200 OK\r\nContent-Type: {content_type}\r\n\r\n".encode())
        conn.send(body.encode())
    except Exception as e:
        print("Error:", e)
    finally:
        conn.close()
```

### MQTT Publish

```python
from umqtt.simple import MQTTClient
import time
from machine import ADC, Pin

client = MQTTClient("esp32_sensor", "192.168.1.100")
client.connect()

adc = ADC(Pin(34))
adc.atten(ADC.ATTN_11DB)

while True:
    voltage = adc.read() * 3.3 / 4095
    client.publish("sensor/voltage", str(voltage))
    time.sleep(60)
```

### Watchdog Timer (auto-reset on hang)

```python
from machine import WDT

# Enable watchdog — must feed within timeout or device resets
wdt = WDT(timeout=30000)  # 30 second timeout

while True:
    # ... do work ...
    wdt.feed()  # reset the watchdog timer
```
