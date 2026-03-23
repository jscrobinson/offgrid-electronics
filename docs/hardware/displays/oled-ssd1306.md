# SSD1306 OLED Display Guide

## Overview

The SSD1306 is a single-chip CMOS OLED driver IC for dot-matrix graphic display systems. It is by far the most common small OLED display controller in the hobbyist ecosystem. These displays are inexpensive, low-power, high-contrast, and easy to interface with virtually any microcontroller.

## Specifications

| Parameter | Value |
|---|---|
| Controller | Solomon Systech SSD1306 |
| Display sizes | 0.96" (most common), 1.3" (SSH1106 variant — see note) |
| Resolution | 128x64 or 128x32 pixels |
| Colors | Monochrome (white, blue, yellow-blue, or yellow-green depending on OLED panel) |
| Interface | I2C (2 pins) or SPI (5-7 pins) |
| Operating voltage | 3.3V or 5V (most modules have onboard regulator) |
| Logic level | 3.3V native, but most breakout boards are 5V tolerant |
| Viewing angle | >160 degrees |
| Operating temperature | -40 to +85°C |

**Important:** Many 1.3" OLED modules use the SSH1106 controller, not SSD1306. The SSH1106 has a 132x64 internal buffer (vs 128x64) and requires a different driver or offset configuration. Check your module's datasheet.

## Display Memory and Addressing

The SSD1306 has a 128x64 bit (1 KB) Graphics Display Data RAM (GDDRAM). Each bit represents one pixel. The RAM is organized into 8 pages (for 128x64) or 4 pages (for 128x32), with each page being 128 columns by 8 rows.

```
Page 0: rows 0-7     (128 bytes)
Page 1: rows 8-15    (128 bytes)
Page 2: rows 16-23   (128 bytes)
Page 3: rows 24-31   (128 bytes)
Page 4: rows 32-39   (128 bytes)  -- 128x64 only
Page 5: rows 40-47   (128 bytes)  -- 128x64 only
Page 6: rows 48-55   (128 bytes)  -- 128x64 only
Page 7: rows 56-63   (128 bytes)  -- 128x64 only
```

Each byte in a page represents a vertical column of 8 pixels, with bit 0 at the top and bit 7 at the bottom of that 8-pixel column.

### Addressing Modes

- **Page Addressing Mode**: Write data within a single page. Column counter auto-increments but wraps within the page. Useful for text-only displays where you update one row at a time.
- **Horizontal Addressing Mode**: Column counter increments and wraps to the next page automatically. Most efficient for full-screen buffer updates — this is what most libraries use.
- **Vertical Addressing Mode**: Page counter increments first, then column. Rarely used.

## Wiring

### I2C Connection

I2C requires only 4 wires. Most modules have a fixed I2C address, sometimes configurable via a solder jumper on the back of the PCB.

| OLED Pin | Connection |
|---|---|
| VCC | 3.3V or 5V |
| GND | GND |
| SCL | I2C clock (Arduino Uno: A5, ESP32: GPIO22 default, RPi: GPIO3/SCL) |
| SDA | I2C data (Arduino Uno: A4, ESP32: GPIO21 default, RPi: GPIO2/SDA) |

**I2C Address:** Usually **0x3C** (when address select pin/pad is LOW or unconnected). Some modules use **0x3D** (address select HIGH). If your display does not respond, try the other address or run an I2C scanner sketch.

**Pull-up resistors:** Most breakout modules include 4.7K pull-ups on SDA and SCL. If you are using bare modules or long wires, you may need external 4.7K or 10K pull-ups to VCC.

### SPI Connection

SPI is faster than I2C but uses more pins.

| OLED Pin | Arduino Uno | ESP32 | Function |
|---|---|---|---|
| VCC | 3.3V/5V | 3.3V | Power |
| GND | GND | GND | Ground |
| D0 (SCK/CLK) | D13 (or any) | GPIO18 | SPI Clock |
| D1 (MOSI/SDA) | D11 (or any) | GPIO23 | SPI Data |
| RES (RST) | D9 (any GPIO) | Any GPIO | Reset (active low) |
| DC (A0) | D8 (any GPIO) | Any GPIO | Data/Command select |
| CS | D10 (any GPIO) | GPIO5 | Chip Select (active low) |

## Arduino

### Library Installation

Install via Arduino Library Manager:
- **Adafruit SSD1306** (also installs dependency Adafruit GFX Library)
- Or **U8g2** (alternative, single library, supports many displays)

### Adafruit SSD1306 — I2C Example

```cpp
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET    -1      // -1 if sharing Arduino reset pin
#define SCREEN_ADDRESS 0x3C

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

void setup() {
  Serial.begin(115200);

  if (!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;); // halt
  }

  display.clearDisplay();

  // Draw text
  display.setTextSize(1);             // 6x8 pixels per character
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 0);
  display.println(F("Hello World!"));
  display.println(F("Line 2 here"));

  // Draw shapes
  display.drawRect(0, 20, 60, 30, SSD1306_WHITE);      // rectangle outline
  display.fillCircle(100, 40, 15, SSD1306_WHITE);       // filled circle
  display.drawLine(0, 63, 127, 63, SSD1306_WHITE);      // horizontal line

  display.display();  // MUST call display() to push buffer to screen
}

void loop() {
  // nothing
}
```

### Adafruit SSD1306 — SPI Example

```cpp
#include <SPI.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_DC    8
#define OLED_CS    10
#define OLED_RESET 9

// Hardware SPI: uses default MOSI (11) and SCK (13) on Uno
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &SPI, OLED_DC, OLED_RESET, OLED_CS);

void setup() {
  if (!display.begin(SSD1306_SWITCHCAPVCC)) {
    Serial.println(F("SSD1306 SPI init failed"));
    for (;;);
  }
  display.clearDisplay();
  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(10, 20);
  display.println(F("SPI OLED"));
  display.display();
}

void loop() {}
```

### Drawing Bitmaps

Convert images to byte arrays using tools like LCD Assistant, image2cpp (online), or GIMP export.

```cpp
// 16x16 smiley face bitmap (example)
static const uint8_t PROGMEM smiley_bmp[] = {
  0x07, 0xE0, 0x18, 0x18, 0x20, 0x04, 0x42, 0x42,
  0x42, 0x42, 0x80, 0x01, 0x80, 0x01, 0x80, 0x01,
  0x81, 0x81, 0x82, 0x41, 0x44, 0x22, 0x48, 0x12,
  0x20, 0x04, 0x18, 0x18, 0x07, 0xE0, 0x00, 0x00
};

display.drawBitmap(56, 24, smiley_bmp, 16, 16, SSD1306_WHITE);
display.display();
```

### U8g2 Alternative Library

U8g2 is a monochrome graphics library that supports a huge range of displays. It handles fonts better than Adafruit GFX and includes many built-in fonts.

```cpp
#include <U8g2lib.h>
#include <Wire.h>

// For 128x64 I2C SSD1306:
U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0, /* reset=*/ U8X8_PIN_NONE);

void setup() {
  u8g2.begin();
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_ncenB08_tr);  // choose a font
  u8g2.drawStr(0, 12, "Hello U8g2!");
  u8g2.drawFrame(0, 20, 60, 30);       // rectangle
  u8g2.sendBuffer();
}

void loop() {}
```

U8g2 constructor naming: `U8G2_<controller>_<size>_<name>_<buffer>_<comm>`
- Buffer: `F` = full frame buffer (fast, uses more RAM), `1`/`2` = page buffer (slower, less RAM)
- Comm: `HW_I2C`, `HW_SPI`, `SW_I2C`, `SW_SPI`

## ESP32

The ESP32 uses the same libraries as Arduino, but you need to specify I2C pins since the default may vary by board.

```cpp
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1
#define SCREEN_ADDRESS 0x3C

// ESP32 default I2C pins: SDA=21, SCL=22
// Override if your board uses different pins:
#define SDA_PIN 21
#define SCL_PIN 22

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

void setup() {
  Wire.begin(SDA_PIN, SCL_PIN);  // ESP32: specify I2C pins

  if (!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println("SSD1306 init failed");
    for (;;);
  }

  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 0);
  display.println("ESP32 + SSD1306");
  display.display();
}

void loop() {}
```

**ESP32 I2C pin notes by common boards:**
| Board | Default SDA | Default SCL |
|---|---|---|
| ESP32 DevKit | GPIO21 | GPIO22 |
| ESP32-S2 | GPIO8 | GPIO9 |
| ESP32-S3 | GPIO8 | GPIO9 |
| ESP32-C3 | GPIO8 | GPIO9 |
| Heltec WiFi Kit 32 | GPIO4 | GPIO15 (built-in OLED, RST=GPIO16) |
| TTGO T-Display | N/A (uses SPI TFT) | N/A |

## MicroPython

MicroPython has a built-in `ssd1306` module (or install via `upip`).

```python
from machine import Pin, I2C
import ssd1306

# ESP32 example
i2c = I2C(0, scl=Pin(22), sda=Pin(21), freq=400000)

# Scan for devices (debugging)
print("I2C devices:", [hex(d) for d in i2c.scan()])

oled = ssd1306.SSD1306_I2C(128, 64, i2c, addr=0x3C)

# Clear display
oled.fill(0)

# Draw text
oled.text("Hello!", 0, 0)
oled.text("MicroPython", 0, 12)
oled.text("Line 3", 0, 24)

# Draw shapes
oled.rect(0, 36, 60, 20, 1)          # rectangle outline
oled.fill_rect(70, 36, 30, 20, 1)    # filled rectangle
oled.hline(0, 60, 128, 1)            # horizontal line
oled.pixel(64, 32, 1)                # single pixel

oled.show()  # push buffer to display
```

### SPI with MicroPython

```python
from machine import Pin, SPI
import ssd1306

spi = SPI(1, baudrate=8000000, polarity=0, phase=0,
          sck=Pin(18), mosi=Pin(23))

oled = ssd1306.SSD1306_SPI(128, 64, spi,
                            dc=Pin(16),
                            res=Pin(17),
                            cs=Pin(5))

oled.fill(0)
oled.text("SPI OLED", 0, 0)
oled.show()
```

### Using framebuf Directly

The `ssd1306` module extends `framebuf.FrameBuffer`, so you have access to all framebuf methods:

```python
import framebuf

# The oled object IS a FrameBuffer, so these all work:
oled.fill(0)
oled.text("text", x, y, color)
oled.pixel(x, y, color)
oled.hline(x, y, w, color)
oled.vline(x, y, h, color)
oled.line(x1, y1, x2, y2, color)
oled.rect(x, y, w, h, color)
oled.fill_rect(x, y, w, h, color)
oled.scroll(dx, dy)
oled.blit(other_framebuf, x, y)
oled.show()
```

## Raspberry Pi (Python)

### Option 1: luma.oled (recommended)

```bash
pip3 install luma.oled
```

Enable I2C: `sudo raspi-config` -> Interfacing Options -> I2C -> Enable

```python
from luma.core.interface.serial import i2c
from luma.oled.device import ssd1306
from luma.core.render import canvas
from PIL import ImageFont

serial = i2c(port=1, address=0x3C)
device = ssd1306(serial, width=128, height=64)

with canvas(device) as draw:
    draw.rectangle(device.bounding_box, outline="white", fill="black")
    draw.text((10, 10), "Hello Pi!", fill="white")
    draw.text((10, 25), "luma.oled", fill="white")
    draw.ellipse((80, 10, 120, 50), outline="white")
```

luma.oled uses PIL/Pillow for drawing, which gives you access to TrueType fonts, antialiasing, and all PIL drawing primitives.

### Option 2: Adafruit CircuitPython (Blinka)

```bash
pip3 install adafruit-circuitpython-ssd1306 Pillow
```

```python
import board
import busio
import adafruit_ssd1306

i2c = busio.I2C(board.SCL, board.SDA)
oled = adafruit_ssd1306.SSD1306_I2C(128, 64, i2c, addr=0x3C)

oled.fill(0)
oled.text("CircuitPython", 0, 0, 1)
oled.rect(0, 15, 80, 30, 1)
oled.show()
```

## Power Consumption and Control

| State | Typical Current |
|---|---|
| All pixels OFF (display on, nothing drawn) | ~5-10 mA |
| Normal use (mixed content) | ~15-20 mA |
| All pixels ON | ~20-25 mA |
| Display OFF (sleep mode) | <10 uA |

### Contrast and Dimming

```cpp
// Adafruit SSD1306
display.ssd1306_command(SSD1306_SETCONTRAST);
display.ssd1306_command(128);  // 0-255, default is 207 (0xCF)

// Dim mode
display.dim(true);   // reduces contrast
display.dim(false);  // restores
```

```cpp
// U8g2
u8g2.setContrast(128);  // 0-255
```

### Sleep Mode (Power Saving)

```cpp
// Turn display off (content retained in RAM)
display.ssd1306_command(SSD1306_DISPLAYOFF);  // 0xAE

// Turn display back on
display.ssd1306_command(SSD1306_DISPLAYON);   // 0xAF
```

```python
# MicroPython
oled.poweroff()  # sleep
oled.poweron()   # wake
oled.contrast(128)  # 0-255
oled.invert(True)   # invert colors
```

## Common Issues and Troubleshooting

### Blank Display (Nothing Shows)

1. **Wrong I2C address.** Run an I2C scanner to find the actual address. Many modules are 0x3C, some are 0x3D.
   ```cpp
   // Arduino I2C scanner
   #include <Wire.h>
   void setup() {
     Wire.begin();
     Serial.begin(115200);
     for (byte addr = 1; addr < 127; addr++) {
       Wire.beginTransmission(addr);
       if (Wire.endTransmission() == 0) {
         Serial.print("Found device at 0x");
         Serial.println(addr, HEX);
       }
     }
   }
   void loop() {}
   ```
2. **Missing `display.display()` or `oled.show()` call.** Drawing functions write to the RAM buffer only; you must explicitly push the buffer to the screen.
3. **Wrong constructor parameters.** Make sure width/height match your display (128x64 vs 128x32). Using 128x64 init on a 128x32 display will show content only on the top half (or nothing at all).
4. **No I2C pull-up resistors.** If using long wires or bare modules without built-in pullups, add 4.7K resistors from SDA/SCL to VCC.
5. **Insufficient power.** Especially with 3.3V modules on long breadboard connections. Try a short, direct connection first.
6. **Reset pin not connected.** Some modules require the RST pin. If present, connect it to a GPIO and toggle it, or connect to MCU reset.

### Display Shows Garbled Content

1. **Wrong resolution in constructor.** 128x64 vs 128x32 — must match your actual display.
2. **Using SSD1306 library with SSH1106 display.** Many 1.3" displays are SSH1106. Use `U8g2` with the SSH1106 constructor, or `Adafruit_SH110X` library.
3. **I2C clock too fast.** Try reducing I2C speed: `Wire.setClock(100000);`
4. **Buffer corruption.** On AVR (Uno/Nano), 128x64 uses 1024 bytes of RAM — that is half the Uno's 2KB. If your sketch uses a lot of RAM, the buffer may get corrupted. Consider using 128x32 or U8g2 page buffer mode.

### Display Flickers or Shows Briefly Then Goes Blank

1. **Power issue.** Check voltage at the module pins with a multimeter. Add a 100uF capacitor across VCC/GND.
2. **Watchdog or reset loop.** Your MCU may be crashing. Check serial output.

### I2C Scanner Finds Nothing

1. Check wiring: SDA to SDA, SCL to SCL (not swapped).
2. Check the module is getting power (some have an LED).
3. Try different I2C bus speed: `Wire.setClock(100000);`
4. On ESP32: make sure you called `Wire.begin(SDA_pin, SCL_pin)` with correct pins.

## Tips and Best Practices

- **Minimize full redraws.** Clear and redraw the entire display causes visible flicker. Instead, overwrite only the changed area with a filled rectangle, then redraw the updated content.
- **Use PROGMEM for bitmaps** on AVR to avoid using precious RAM.
- **Frame rate:** I2C at 400 kHz can push the full 1024-byte buffer about 30 times per second. At 100 kHz, about 8 fps. SPI is much faster (several hundred fps theoretical, though usually limited by MCU processing).
- **Multiple OLEDs on I2C:** You can have at most 2 SSD1306 displays on the same I2C bus (addresses 0x3C and 0x3D). For more, use an I2C multiplexer (TCA9548A).
- **Screen burn-in:** OLEDs degrade with use. Pixels that are always on will dim over time. For long-running displays, consider periodically inverting, shifting content, or using a screen saver.
