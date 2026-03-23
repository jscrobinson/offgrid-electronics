# CircuitPython Guide

CircuitPython is Adafruit's fork of MicroPython, designed to be beginner-friendly. The key difference: your board appears as a USB drive, and you edit code directly on that drive. Save the file and it auto-reloads.

---

## Key Differences from MicroPython

| Feature | CircuitPython | MicroPython |
|---------|--------------|-------------|
| Developer | Adafruit | Damien George / community |
| Firmware install | Drag-and-drop UF2 | esptool.py flash |
| File access | USB drive (CIRCUITPY) | Serial tools (mpremote, ampy) |
| Entry point | code.py (or main.py) | main.py |
| Auto-reload | Yes, on file save | No |
| Libraries | .mpy bundles from Adafruit | micropython-lib |
| Hardware API | board, digitalio, analogio, busio | machine module |
| Board support | Adafruit boards + selected others | Wider board support |
| WiFi | wifi + socketpool modules | network module |
| Focus | Education, maker projects | General embedded |

---

## Supported Boards

CircuitPython runs on 400+ boards. Key ones:

- **Adafruit Feather M4 Express** — ATSAMD51, great general-purpose
- **Adafruit Feather RP2040** — RP2040, lots of RAM
- **Adafruit QT Py ESP32-S3** — tiny, WiFi, great for IoT
- **Adafruit Metro M4 Express** — Arduino form factor
- **Raspberry Pi Pico / Pico W** — RP2040, budget friendly
- **Adafruit Circuit Playground Express** — built-in sensors and LEDs
- **Seeed XIAO series** — tiny form factor
- **ESP32-S2/S3 boards** — WiFi support

Check supported boards: https://circuitpython.org/downloads

---

## Installing Firmware (UF2 Bootloader)

Most CircuitPython boards use the UF2 bootloader, making firmware installation a simple drag-and-drop:

### Step 1: Enter Bootloader Mode

- **Double-tap the RESET button** (quickly, within 0.5s)
- A new USB drive appears named something like `FEATHERBOOT`, `RPI-RP2`, or `<BOARD>BOOT`
- The onboard LED usually turns green or pulses

### Step 2: Install Firmware

1. Download the `.uf2` file for your specific board from https://circuitpython.org/downloads
2. Drag the `.uf2` file onto the boot drive
3. The board auto-reboots and a new drive named `CIRCUITPY` appears

### ESP32-S2/S3 (no native UF2 bootloader)

For ESP32-based boards, some require initial setup via esptool:

```bash
# First time only — install the UF2 bootloader
pip install esptool
esptool.py --chip esp32s3 --port /dev/ttyACM0 erase_flash
# Then flash the combined .bin file from circuitpython.org
esptool.py --chip esp32s3 --port /dev/ttyACM0 \
    write_flash -z 0x0 adafruit-circuitpython-*.bin
```

After first install, future updates can use UF2 drag-and-drop.

---

## The CIRCUITPY Drive

When your board runs CircuitPython, it appears as a USB mass storage device named `CIRCUITPY`. This is your board's filesystem.

```
CIRCUITPY/
├── code.py          # Your main program (auto-runs)
├── boot.py          # Runs before USB, rarely needed
├── settings.toml    # WiFi credentials, secrets (CP 8.0+)
├── lib/             # Library folder (.mpy files go here)
│   ├── adafruit_dht.mpy
│   ├── adafruit_bme280.mpy
│   └── neopixel.mpy
└── data/            # Your data files (optional)
```

### code.py Auto-Run Behavior

- CircuitPython looks for code to run in this order: `code.py`, `code.txt`, `main.py`, `main.txt`
- When you save `code.py` on the CIRCUITPY drive, the board auto-reloads within seconds
- Press `Ctrl+C` in the serial console to interrupt the running program
- Press `Ctrl+D` to reload code.py
- Press any key in the serial console to enter the REPL

### settings.toml (CircuitPython 8.0+)

Store WiFi credentials and other configuration:

```toml
# settings.toml — on CIRCUITPY drive root
CIRCUITPY_WIFI_SSID = "MyNetwork"
CIRCUITPY_WIFI_PASSWORD = "MyPassword"
CIRCUITPY_WEB_API_PASSWORD = "webpassword"

# Custom values accessible in code
MQTT_BROKER = "192.168.1.100"
SENSOR_INTERVAL = "30"
```

Access in code:

```python
import os
ssid = os.getenv("CIRCUITPY_WIFI_SSID")
broker = os.getenv("MQTT_BROKER")
interval = int(os.getenv("SENSOR_INTERVAL", "60"))
```

---

## Installing Libraries

CircuitPython libraries come as pre-compiled `.mpy` files in the Adafruit CircuitPython Library Bundle.

### Method 1: Manual (Offline-Friendly)

1. Download the bundle from https://circuitpython.org/libraries
   - Match the bundle major version to your CircuitPython version (e.g., Bundle 9.x for CP 9.x)
2. Unzip the bundle
3. Copy needed `.mpy` files or folders from `lib/` into `CIRCUITPY/lib/`

### Method 2: circup (Command-Line Tool)

```bash
pip install circup

# List installed libraries
circup list

# Install a library
circup install adafruit_dht

# Update all libraries
circup update

# Install from a requirements file
circup install -r requirements.txt

# Show available libraries
circup show adafruit_bme280
```

### Method 3: On-Device (WiFi boards, CP 8.0+)

```python
import circuitpython_typing  # if available
# Use the Web Workflow at http://<board-ip>/cp/
```

### Common Libraries

| Library | Purpose |
|---------|---------|
| `neopixel` | WS2812/NeoPixel RGB LEDs |
| `adafruit_dht` | DHT11/DHT22 temperature/humidity |
| `adafruit_bme280` | BME280 temp/humidity/pressure |
| `adafruit_bme680` | BME680 air quality sensor |
| `adafruit_ssd1306` | SSD1306 OLED display |
| `adafruit_display_text` | Text rendering on displays |
| `adafruit_gps` | GPS NMEA parsing |
| `adafruit_rfm9x` | LoRa RFM95/96 radio |
| `adafruit_ads1x15` | ADS1015/ADS1115 ADC |
| `adafruit_ina219` | INA219 current/power sensor |
| `adafruit_sd` | SD card support |
| `adafruit_requests` | HTTP requests (WiFi boards) |
| `adafruit_minimqtt` | MQTT client |
| `adafruit_ntp` | Network time protocol |
| `adafruit_motor` | DC and stepper motors |
| `adafruit_servokit` | Multi-servo control (PCA9685) |

---

## board Module — Pin Names

CircuitPython uses human-readable pin names via the `board` module:

```python
import board

# See all available pins for your board
dir(board)
# Example output: ['A0', 'A1', 'D5', 'D6', 'SCL', 'SDA', 'TX', 'RX',
#                  'MOSI', 'MISO', 'SCK', 'NEOPIXEL', 'LED', ...]

# Use pin names directly
board.D13    # digital pin 13
board.A0     # analog pin 0
board.LED    # onboard LED
board.SCL    # I2C clock
board.SDA    # I2C data
board.TX     # UART transmit
board.RX     # UART receive

# Board info
board.board_id  # e.g., "adafruit_feather_m4_express"
```

---

## digitalio — Digital I/O

```python
import board
import digitalio
import time

# Output (LED)
led = digitalio.DigitalInOut(board.LED)
led.direction = digitalio.Direction.OUTPUT
led.value = True    # on
led.value = False   # off

# Input (Button) with pull-up
button = digitalio.DigitalInOut(board.D2)
button.direction = digitalio.Direction.INPUT
button.pull = digitalio.Pull.UP
# button.value is False when pressed (pulled to ground)

# Blink
while True:
    led.value = not led.value
    time.sleep(0.5)

# Button-controlled LED
while True:
    led.value = not button.value  # invert because pull-up
    time.sleep(0.01)
```

---

## analogio — Analog I/O

```python
import board
import analogio

# Analog input (0-65535 range, regardless of actual ADC resolution)
sensor = analogio.AnalogIn(board.A0)
raw = sensor.value           # 0-65535 (16-bit)
voltage = sensor.value * sensor.reference_voltage / 65535
print(f"Voltage: {voltage:.2f}V")

# Analog output (DAC — not all boards)
dac = analogio.AnalogOut(board.A0)
dac.value = 32768            # ~1.65V (half of 3.3V)
```

---

## busio — I2C, SPI, UART

### I2C

```python
import board
import busio

# Create I2C bus
i2c = busio.I2C(board.SCL, board.SDA, frequency=400000)
# or use the default I2C:
i2c = board.I2C()   # uses board.SCL and board.SDA

# Scan for devices
while not i2c.try_lock():
    pass
devices = i2c.scan()
print("Found:", [hex(d) for d in devices])
i2c.unlock()

# Most sensor libraries handle I2C internally:
import adafruit_bme280.basic
bme = adafruit_bme280.basic.Adafruit_BME280_I2C(i2c)
print(f"Temp: {bme.temperature:.1f}C")
print(f"Humidity: {bme.humidity:.1f}%")
print(f"Pressure: {bme.pressure:.1f} hPa")
```

### SPI

```python
import board
import busio
import digitalio

spi = busio.SPI(board.SCK, MOSI=board.MOSI, MISO=board.MISO)
# or: spi = board.SPI()

cs = digitalio.DigitalInOut(board.D5)
cs.direction = digitalio.Direction.OUTPUT

# Lock SPI bus for use
while not spi.try_lock():
    pass
spi.configure(baudrate=1000000, phase=0, polarity=0)

cs.value = False
spi.write(bytes([0x01, 0x02]))
result = bytearray(4)
spi.readinto(result)
cs.value = True
spi.unlock()
```

### UART

```python
import board
import busio

uart = busio.UART(board.TX, board.RX, baudrate=9600)

# Write
uart.write(b"Hello\n")

# Read
data = uart.read(32)      # read up to 32 bytes (returns None if empty)
if data is not None:
    print(data.decode())

# Read line
line = uart.readline()     # reads until \n or timeout
```

---

## pwmio — PWM Output

```python
import board
import pwmio

# Create PWM output
pwm = pwmio.PWMOut(board.D9, frequency=1000, duty_cycle=0)

# Set duty cycle (0-65535)
pwm.duty_cycle = 32768     # 50%
pwm.duty_cycle = 0         # off
pwm.duty_cycle = 65535     # 100%

# LED fade
import time
while True:
    for dc in range(0, 65536, 256):
        pwm.duty_cycle = dc
        time.sleep(0.005)
    for dc in range(65535, -1, -256):
        pwm.duty_cycle = dc
        time.sleep(0.005)

# Servo (50Hz, duty 1ms-2ms)
servo = pwmio.PWMOut(board.D9, frequency=50, duty_cycle=0)
# 0 degrees: 1ms/20ms * 65535 = ~3277
# 90 degrees: 1.5ms/20ms * 65535 = ~4915
# 180 degrees: 2ms/20ms * 65535 = ~6553
```

---

## NeoPixel (WS2812 / RGB LEDs)

```python
import board
import neopixel
import time

# Built-in NeoPixel (many Adafruit boards have one)
pixel = neopixel.NeoPixel(board.NEOPIXEL, 1, brightness=0.3)
pixel[0] = (255, 0, 0)    # red
pixel[0] = (0, 255, 0)    # green
pixel[0] = (0, 0, 255)    # blue

# External NeoPixel strip
NUM_PIXELS = 30
pixels = neopixel.NeoPixel(board.D6, NUM_PIXELS, brightness=0.5, auto_write=False)

# Set individual pixels
pixels[0] = (255, 0, 0)
pixels[1] = (0, 255, 0)
pixels.show()              # update strip (when auto_write=False)

# Fill all pixels
pixels.fill((100, 0, 100))
pixels.show()

# Rainbow cycle
def wheel(pos):
    """Color wheel: 0-255 input to RGB tuple."""
    if pos < 85:
        return (255 - pos * 3, pos * 3, 0)
    elif pos < 170:
        pos -= 85
        return (0, 255 - pos * 3, pos * 3)
    else:
        pos -= 170
        return (pos * 3, 0, 255 - pos * 3)

while True:
    for j in range(256):
        for i in range(NUM_PIXELS):
            idx = (i * 256 // NUM_PIXELS + j) & 255
            pixels[i] = wheel(idx)
        pixels.show()
        time.sleep(0.01)
```

---

## DHT Temperature/Humidity Sensor

```python
import board
import adafruit_dht
import time

# DHT22 (more accurate) or DHT11
dht = adafruit_dht.DHT22(board.D4)
# dht = adafruit_dht.DHT11(board.D4)

while True:
    try:
        temp_c = dht.temperature
        humidity = dht.humidity
        print(f"Temp: {temp_c:.1f}C  Humidity: {humidity:.1f}%")
    except RuntimeError as e:
        # DHT sensors occasionally fail to read, just retry
        print(f"Read error: {e}")
    time.sleep(2)  # DHT22 needs minimum 2s between reads
```

---

## WiFi (ESP32-S2/S3, Pico W)

```python
import wifi
import socketpool
import ssl
import os

# Connect to WiFi (credentials from settings.toml)
wifi.radio.connect(
    os.getenv("CIRCUITPY_WIFI_SSID"),
    os.getenv("CIRCUITPY_WIFI_PASSWORD")
)
print(f"Connected! IP: {wifi.radio.ipv4_address}")

# Scan networks
for network in wifi.radio.start_scanning_networks():
    print(f"  {network.ssid:30s} ch={network.channel} rssi={network.rssi}")
wifi.radio.stop_scanning_networks()

# HTTP requests
import adafruit_requests
pool = socketpool.SocketPool(wifi.radio)
session = adafruit_requests.Session(pool, ssl.create_default_context())

response = session.get("http://api.example.com/data")
print(response.json())
response.close()

# MQTT
import adafruit_minimqtt.adafruit_minimqtt as MQTT

mqtt_client = MQTT.MQTT(
    broker=os.getenv("MQTT_BROKER"),
    port=1883,
    socket_pool=pool,
)
mqtt_client.connect()
mqtt_client.publish("sensor/temp", "22.5")
```

---

## Mu Editor

Mu is the recommended editor for CircuitPython beginners:

1. Download from https://codewith.mu/
2. Select **CircuitPython** mode (bottom right)
3. Mu auto-detects the CIRCUITPY drive
4. Edit code.py — it saves directly to the board
5. Click **Serial** button to see print output and REPL

Features:
- CircuitPython mode with auto-detection
- Serial console built-in
- Plotter for `print((value,))` tuples (use `Plotter` button)
- Syntax checking
- Simple, distraction-free interface

Alternatives:
- **VS Code** with CircuitPython extension (more powerful)
- **Thonny** (also works with CircuitPython)
- Any text editor (just save to CIRCUITPY drive, auto-reloads)

---

## Complete Example: Sensor Data Logger

```python
# code.py — Log temperature to SD card and serve via WiFi
import board
import busio
import time
import os
import wifi
import socketpool
import json
import adafruit_bme280.basic

# Setup I2C sensor
i2c = board.I2C()
bme = adafruit_bme280.basic.Adafruit_BME280_I2C(i2c)

# Connect WiFi
wifi.radio.connect(
    os.getenv("CIRCUITPY_WIFI_SSID"),
    os.getenv("CIRCUITPY_WIFI_PASSWORD")
)
print(f"IP: {wifi.radio.ipv4_address}")

# Data buffer (last 100 readings)
readings = []

# Simple web server
pool = socketpool.SocketPool(wifi.radio)
server_socket = pool.socket(pool.AF_INET, pool.SOCK_STREAM)
server_socket.bind(("0.0.0.0", 80))
server_socket.listen(2)
server_socket.settimeout(1)  # non-blocking

last_read = 0

while True:
    now = time.monotonic()

    # Read sensor every 30 seconds
    if now - last_read > 30:
        reading = {
            "temp": round(bme.temperature, 1),
            "humidity": round(bme.humidity, 1),
            "pressure": round(bme.pressure, 1),
            "time": now
        }
        readings.append(reading)
        if len(readings) > 100:
            readings.pop(0)
        print(f"T={reading['temp']}C H={reading['humidity']}% P={reading['pressure']}hPa")
        last_read = now

    # Handle web requests
    try:
        client, addr = server_socket.accept()
        buf = bytearray(1024)
        n = client.recv_into(buf)
        request = buf[:n].decode()

        if "GET /api" in request:
            body = json.dumps(readings[-10:])  # last 10 readings
            content_type = "application/json"
        else:
            body = f"""<html><body>
            <h1>Sensor Dashboard</h1>
            <p>Temperature: {readings[-1]['temp'] if readings else '?'}C</p>
            <p>Humidity: {readings[-1]['humidity'] if readings else '?'}%</p>
            <p>Pressure: {readings[-1]['pressure'] if readings else '?'} hPa</p>
            <p><a href="/api">JSON API</a></p>
            </body></html>"""
            content_type = "text/html"

        response = f"HTTP/1.1 200 OK\r\nContent-Type: {content_type}\r\n\r\n{body}"
        client.send(response.encode())
        client.close()
    except OSError:
        pass  # timeout, no connection waiting

    time.sleep(0.1)
```

---

## Troubleshooting

**Board not showing as CIRCUITPY:**
- Double-tap RESET to enter bootloader, re-flash firmware
- Try a different USB cable (some are charge-only, no data)
- Try a different USB port (avoid hubs)

**code.py not running:**
- Check serial console for errors (`Ctrl+C` then `Ctrl+D` to reload)
- Make sure file is named exactly `code.py` (not `Code.py`)
- Check for missing libraries in `lib/`

**ImportError for a library:**
- Download the correct bundle version matching your CP version
- Copy both `.mpy` files AND any required folders to `lib/`
- Some libraries depend on others (check documentation)

**Out of memory:**
- Use `.mpy` compiled libraries (not `.py` source)
- Reduce the number of imported libraries
- Simplify code, avoid large data structures
- Some boards have very limited RAM (SAMD21 = 32KB)

**CIRCUITPY drive is read-only:**
- The drive may be in safe mode (yellow/blinking LED)
- Double-tap RESET, delete problematic code.py
- If filesystem is corrupted, enter REPL and run:
  ```python
  import storage
  storage.erase_filesystem()
  ```
