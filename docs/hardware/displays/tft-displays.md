# TFT Display Guide

## Overview

TFT (Thin Film Transistor) LCD displays bring full-color graphics to embedded projects. They are available in sizes from 1.3" to 7"+ and offer resolutions far beyond character LCDs or small OLEDs. While they require more processing power and memory, modern microcontrollers like the ESP32 handle them well.

## Common TFT Controllers

| Controller | Resolution | Typical Sizes | Colors | Notes |
|---|---|---|---|---|
| ST7735 | 128x160 | 1.8" | 65K (16-bit) | Small, cheap, good for simple UIs |
| ST7789 | 240x240 or 240x320 | 1.3", 1.54", 2.0", 2.4" | 65K | Very popular, good quality |
| ILI9341 | 240x320 | 2.4", 2.8", 3.2" | 65K | Most common medium TFT, well supported |
| ILI9488 | 320x480 | 3.5" | 262K (18-bit) | Larger display, needs more RAM/bandwidth |
| ILI9486 | 320x480 | 3.5" | 65K | Similar to ILI9488 |
| ST7796S | 320x480 | 3.5", 4.0" | 65K | Newer alternative to ILI9488 |
| HX8357D | 320x480 | 3.5" | 65K | Adafruit uses this |
| SSD1351 | 128x128 | 1.5" | 65K | OLED (not LCD), very vibrant |

## Interface Types

### SPI (Serial Peripheral Interface)

Most common for hobby use. Uses 5-7 pins and is fast enough for most applications.

**Typical SPI pins:**

| Pin | Function | Description |
|---|---|---|
| VCC | Power | 3.3V (some modules have 5V regulator) |
| GND | Ground | |
| SCK (CLK) | SPI Clock | |
| MOSI (SDA/DIN) | SPI Data Out | Master Out Slave In |
| CS | Chip Select | Active LOW, select this device |
| DC (A0/RS) | Data/Command | LOW=command, HIGH=data |
| RST (RES) | Reset | Active LOW, can tie to MCU RST |
| BL (LED) | Backlight | Usually active HIGH, can PWM for brightness |

**SPI Speed:** Typically 20-80 MHz depending on controller and MCU. ESP32 can do 80 MHz SPI to ILI9341.

### Parallel 8-bit / 16-bit

Uses 8 or 16 data pins plus control pins. Much faster than SPI but uses many GPIO pins. Common on Arduino Mega shields and some ESP32 boards.

Parallel 8-bit needs: D0-D7 + RS + WR + RD + CS + RST = 13 pins minimum.

### RGB Interface

Higher-end displays (4.3"+) use an RGB parallel interface with HSYNC/VSYNC signals. Requires an MCU with LCD controller peripheral (ESP32-S3 supports this).

## Wiring — SPI TFT to ESP32

```
TFT Pin     ESP32 Pin    Notes
-------     ---------    -----
VCC         3.3V
GND         GND
SCK         GPIO18       (default VSPI CLK)
MOSI        GPIO23       (default VSPI MOSI)
CS          GPIO5        (any GPIO)
DC          GPIO2        (any GPIO)
RST         GPIO4        (any GPIO, or tie to EN/3.3V via 10K)
BL          GPIO15       (any GPIO, or 3.3V for always-on)
```

For Arduino Uno, use the hardware SPI pins (SCK=13, MOSI=11) and any digital pins for CS, DC, RST.

## Touchscreen

### Resistive Touchscreen

A resistive touch panel has 4 pins (X+, X-, Y+, Y-) that connect to analog input pins. You read touch by applying voltage across one axis and reading the other.

```cpp
// Arduino with Adafruit TouchScreen library
#include <TouchScreen.h>

#define YP A2  // analog pin
#define XM A3  // analog pin
#define YM 8   // digital pin
#define XP 9   // digital pin

TouchScreen ts = TouchScreen(XP, YP, XM, YM, 300); // 300 ohm resistance

void loop() {
  TSPoint p = ts.getPoint();
  if (p.z > 10 && p.z < 1000) {  // valid touch
    int x = map(p.x, 100, 900, 0, 240);  // calibrate these values
    int y = map(p.y, 100, 900, 0, 320);
    Serial.printf("Touch: %d, %d\n", x, y);
  }
}
```

### Capacitive Touchscreen (I2C)

Capacitive touch panels use controllers like FT6236, FT5206, or GT911. They communicate via I2C and are more responsive and accurate than resistive.

```cpp
// FT6236 capacitive touch
#include <Wire.h>
#include <FT6236.h>

FT6236 ts = FT6236();

void setup() {
  Wire.begin(21, 22);
  ts.begin(40);  // threshold
}

void loop() {
  if (ts.touched()) {
    TS_Point p = ts.getPoint();
    Serial.printf("Touch: %d, %d\n", p.x, p.y);
  }
}
```

## Libraries

### TFT_eSPI (Recommended for ESP32)

The TFT_eSPI library by Bodmer is the go-to library for ESP32 TFT projects. It is fast (uses DMA), highly configurable, and supports most common TFT controllers.

**Installation:** Arduino Library Manager, search "TFT_eSPI".

**Configuration:** You MUST edit the `User_Setup.h` file in the library folder (or create a `User_Setup_Select.h` to choose a predefined setup). This is not optional.

Location: `Arduino/libraries/TFT_eSPI/User_Setup.h`

```cpp
// User_Setup.h — Example for ILI9341 on ESP32

// Select driver:
#define ILI9341_DRIVER
// #define ST7789_DRIVER
// #define ST7735_DRIVER

// Display dimensions (for ST7789 240x240, uncomment):
// #define TFT_WIDTH  240
// #define TFT_HEIGHT 240

// ESP32 pin assignments:
#define TFT_MOSI 23
#define TFT_SCLK 18
#define TFT_CS    5
#define TFT_DC    2
#define TFT_RST   4
// #define TFT_BL   15  // Backlight pin (optional)

// SPI clock frequency:
#define SPI_FREQUENCY  40000000  // 40 MHz (try 80000000 for faster)
#define SPI_READ_FREQUENCY  20000000
#define SPI_TOUCH_FREQUENCY  2500000
```

**Basic usage:**

```cpp
#include <TFT_eSPI.h>
#include <SPI.h>

TFT_eSPI tft = TFT_eSPI();

void setup() {
  tft.init();
  tft.setRotation(1);  // 0-3, landscape/portrait
  tft.fillScreen(TFT_BLACK);

  // Text
  tft.setTextColor(TFT_WHITE, TFT_BLACK);  // foreground, background
  tft.setTextSize(2);
  tft.setCursor(10, 10);
  tft.println("Hello TFT!");

  // Shapes
  tft.drawRect(10, 50, 100, 60, TFT_GREEN);
  tft.fillRect(120, 50, 100, 60, TFT_BLUE);
  tft.drawCircle(160, 180, 40, TFT_RED);
  tft.fillCircle(60, 180, 40, TFT_YELLOW);
  tft.drawLine(0, 0, 319, 239, TFT_CYAN);

  // Formatted text with sprite (flicker-free)
  // See sprite section below
}

void loop() {}
```

### TFT_eSPI Sprites (Double Buffering)

Sprites are off-screen frame buffers. Draw to a sprite, then push it to the display in one operation for flicker-free updates. Essential for animations and frequently updated values.

```cpp
TFT_eSPI tft = TFT_eSPI();
TFT_eSprite sprite = TFT_eSprite(&tft);

void setup() {
  tft.init();
  tft.fillScreen(TFT_BLACK);

  sprite.createSprite(200, 50);  // width, height in pixels
}

void loop() {
  sprite.fillSprite(TFT_BLACK);
  sprite.setTextColor(TFT_WHITE);
  sprite.setTextSize(2);
  sprite.setCursor(0, 0);
  sprite.printf("Time: %lu", millis() / 1000);
  sprite.pushSprite(10, 10);  // push to display at x=10, y=10
  delay(100);
}
```

**RAM usage:** A 240x320 16-bit sprite needs 240 * 320 * 2 = 153,600 bytes. ESP32 has enough RAM for this, but ATmega328 (Uno) does not. Use partial sprites for small update regions.

### Adafruit GFX + Driver Library

A more portable but slower option. Works on Arduino Uno (with limitations).

```cpp
#include <Adafruit_GFX.h>
#include <Adafruit_ILI9341.h>

#define TFT_CS   10
#define TFT_DC   9
#define TFT_RST  8

Adafruit_ILI9341 tft = Adafruit_ILI9341(TFT_CS, TFT_DC, TFT_RST);

void setup() {
  tft.begin();
  tft.setRotation(1);
  tft.fillScreen(ILI9341_BLACK);
  tft.setTextColor(ILI9341_WHITE);
  tft.setTextSize(2);
  tft.setCursor(10, 10);
  tft.println("Adafruit GFX");
}

void loop() {}
```

Driver libraries available: `Adafruit_ILI9341`, `Adafruit_ST7735`, `Adafruit_ST7789`, `Adafruit_HX8357`, etc.

### LovyanGFX

An alternative to TFT_eSPI with similar performance and additional features. Supports ESP32, ESP32-S2, ESP32-S3, ESP32-C3, RP2040. Good DMA support and auto-detection of some displays.

## LVGL (Light and Versatile Graphics Library)

LVGL is a full-featured GUI library for embedded systems. It provides widgets (buttons, sliders, charts, labels, etc.), themes, animations, and touch input handling.

### LVGL with ESP32

```cpp
#include <lvgl.h>
#include <TFT_eSPI.h>

TFT_eSPI tft = TFT_eSPI();

static lv_disp_draw_buf_t draw_buf;
static lv_color_t buf[240 * 10];  // buffer for 10 lines

// Display flush callback
void my_disp_flush(lv_disp_drv_t *disp, const lv_area_t *area, lv_color_t *color_p) {
  uint32_t w = (area->x2 - area->x1 + 1);
  uint32_t h = (area->y2 - area->y1 + 1);
  tft.startWrite();
  tft.setAddrWindow(area->x1, area->y1, w, h);
  tft.pushColors((uint16_t *)&color_p->full, w * h, true);
  tft.endWrite();
  lv_disp_flush_ready(disp);
}

void setup() {
  tft.init();
  tft.setRotation(1);

  lv_init();
  lv_disp_draw_buf_init(&draw_buf, buf, NULL, 240 * 10);

  static lv_disp_drv_t disp_drv;
  lv_disp_drv_init(&disp_drv);
  disp_drv.hor_res = 320;
  disp_drv.ver_res = 240;
  disp_drv.flush_cb = my_disp_flush;
  disp_drv.draw_buf = &draw_buf;
  lv_disp_drv_register(&disp_drv);

  // Create a simple label
  lv_obj_t *label = lv_label_create(lv_scr_act());
  lv_label_set_text(label, "Hello LVGL!");
  lv_obj_align(label, LV_ALIGN_CENTER, 0, 0);
}

void loop() {
  lv_timer_handler();  // must call regularly
  delay(5);
}
```

LVGL is powerful but has a learning curve. It is best suited for projects that need a real GUI (menus, settings screens, dashboards) rather than simple text/graphics.

## SD Card on TFT Modules

Many TFT breakout boards include a microSD card slot that shares the SPI bus. It uses a separate CS (chip select) pin.

```cpp
#include <SD.h>
#include <TFT_eSPI.h>

#define SD_CS 4  // SD card chip select pin

TFT_eSPI tft = TFT_eSPI();

void setup() {
  tft.init();

  if (!SD.begin(SD_CS)) {
    Serial.println("SD card init failed");
    return;
  }

  // Read BMP from SD and display
  // (use TFT_eSPI BMP example or Adafruit ImageReader)
}
```

**Important:** When using shared SPI bus with TFT and SD card, only one device can be active at a time. The libraries handle CS pin management, but make sure both CS pins are defined and not conflicting. Initialize SD after TFT.

## Performance Optimization

### SPI Clock Speed

| MCU | Max Practical SPI Speed |
|---|---|
| Arduino Uno (ATmega328) | 8 MHz |
| Arduino Mega | 8 MHz |
| ESP32 | 80 MHz |
| ESP32-S3 | 80 MHz |
| RP2040 (Pi Pico) | 62.5 MHz |
| STM32F4 | 42 MHz |

Higher SPI speeds mean faster screen updates. An ESP32 at 80 MHz can fill a 240x320 screen in about 12ms (vs ~300ms on an Uno at 8 MHz).

### DMA (Direct Memory Access)

DMA allows the SPI peripheral to send data to the display without CPU involvement. TFT_eSPI supports DMA on ESP32. This frees the CPU to prepare the next frame while the current one is being transferred.

### Partial Updates

Instead of redrawing the entire screen, update only the regions that changed. This is critical on slower MCUs.

```cpp
// Only update a small area
tft.fillRect(10, 10, 100, 20, TFT_BLACK);  // clear region
tft.setCursor(10, 10);
tft.print(sensorValue);
```

### Color Depth

16-bit color (RGB565) is standard and uses 2 bytes per pixel. For a 240x320 display, a full frame buffer is 153,600 bytes. 8-bit color (RGB332) uses half the memory but looks worse. Most TFT controllers expect 16-bit or 18-bit color.

**RGB565 color format:**
```
Bits:  RRRRR GGGGGG BBBBB
       5-red  6-green 5-blue
```

Common color values (RGB565):
```cpp
#define BLACK   0x0000
#define WHITE   0xFFFF
#define RED     0xF800
#define GREEN   0x07E0
#define BLUE    0x001F
#define CYAN    0x07FF
#define MAGENTA 0xF81F
#define YELLOW  0xFFE0
#define ORANGE  0xFD20
```

Convert RGB888 to RGB565:
```cpp
uint16_t color565(uint8_t r, uint8_t g, uint8_t b) {
  return ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3);
}
```

## Display Rotation

All libraries support rotation (0, 1, 2, 3 = 0, 90, 180, 270 degrees):

```cpp
tft.setRotation(0);  // Portrait
tft.setRotation(1);  // Landscape
tft.setRotation(2);  // Portrait inverted
tft.setRotation(3);  // Landscape inverted
```

After rotation, `tft.width()` and `tft.height()` return the rotated dimensions.

## Common Issues

### White Screen / No Display

1. **Wrong driver selected.** Check your display's controller IC. Look at markings on the ribbon cable or PCB. ST7789 and ILI9341 are NOT interchangeable in code.
2. **Wrong pin configuration in User_Setup.h** (TFT_eSPI). Triple-check every pin assignment.
3. **3.3V vs 5V mismatch.** Most TFT modules are 3.3V logic. If your module does not have a level shifter, do not connect 5V logic directly.
4. **RST pin not connected.** Some displays need an explicit reset pulse.
5. **Backlight not powered.** Connect BL pin to 3.3V or a GPIO set HIGH.

### Colors Wrong / Inverted

1. **Wrong color order.** Some displays use BGR instead of RGB. In TFT_eSPI, add `#define TFT_RGB_ORDER TFT_BGR` in User_Setup.h.
2. **Color inversion.** Try `tft.invertDisplay(true);` or `tft.invertDisplay(false);`.

### Display Offset (Content Shifted)

Some ST7789 240x240 displays have a column/row offset because the controller supports 240x320 but the panel is 240x240. TFT_eSPI handles common offsets, but you may need to set them manually:
```cpp
// In User_Setup.h for some ST7789 displays:
#define TFT_WIDTH  240
#define TFT_HEIGHT 240
#define CGRAM_OFFSET
```

### Flickering

Use sprites/double buffering for areas that update frequently. Avoid clearing the entire screen with `fillScreen()` on every frame. Instead, redraw only changed regions.

## Backlight Brightness Control

```cpp
#define BL_PIN 15

void setup() {
  // ESP32 LEDC PWM for backlight
  ledcSetup(0, 5000, 8);        // channel 0, 5kHz, 8-bit
  ledcAttachPin(BL_PIN, 0);
  ledcWrite(0, 200);             // brightness 0-255
}

// Dim to save power
void setBacklight(uint8_t brightness) {
  ledcWrite(0, brightness);
}
```
