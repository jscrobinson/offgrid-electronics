# E-Ink (E-Paper) Displays

## How E-Ink Works

E-ink displays use **bistable** technology — they retain their image with zero power. Each pixel contains microcapsules filled with positively charged white particles and negatively charged black particles suspended in a clear fluid. Applying an electric field moves particles to the top or bottom surface, creating black or white pixels.

**Key property:** Once the image is set, the display holds it indefinitely without any power draw. This makes e-ink ideal for battery-powered and solar-powered applications.

## Display Types

### Black & White (B/W)
- Most common, fastest refresh
- High contrast ratio (~15:1)
- Typical refresh: 1-3 seconds full, ~0.3s partial

### Three-Color (B/W/Red or B/W/Yellow)
- Third color pigment added to microcapsules
- Much slower refresh: 10-25 seconds
- No partial refresh capability on most models
- Red variants more common than yellow

### Four-Color and ACeP (Advanced Color ePaper)
- Gallery palette or spectra displays
- 7 colors available on some panels (5.65" Waveshare)
- Very slow refresh: 25-40 seconds
- Limited availability, higher cost

### Grayscale
- 4-level or 16-level grayscale via voltage modulation
- Achieved through partial charging of pixels
- Slower refresh for more gray levels

## Common Sizes and Resolutions

| Size   | Resolution  | Active Area (mm) | Controller  | Typical Use        |
|--------|-------------|-------------------|-------------|--------------------|
| 1.54"  | 200x200     | 27.6x27.6         | SSD1681     | Wearable, badge    |
| 2.13"  | 250x122     | 48.5x23.8         | SSD1675B    | Small status       |
| 2.9"   | 296x128     | 66.9x29.1         | SSD1680     | Compact dashboard  |
| 4.2"   | 400x300     | 84.8x63.6         | SSD1619A    | Dashboard, sign    |
| 5.83"  | 648x480     | 118.8x88.2        | —           | Large display      |
| 7.5"   | 800x480     | 163.2x97.9        | —           | Signage, calendar  |

## SPI Interface Wiring

E-ink displays use SPI plus several control pins:

```
E-Ink Pin    ESP32       RPi          Arduino Uno
---------    -----       ---          -----------
VCC          3.3V        3.3V         3.3V (or 5V if module has regulator)
GND          GND         GND          GND
DIN (MOSI)   GPIO23      GPIO10       D11
CLK (SCK)    GPIO18      GPIO11       D13
CS           GPIO5       GPIO8        D10
DC           GPIO17      GPIO25       D9
RST          GPIO16      GPIO17       D8
BUSY         GPIO4       GPIO24       D7
```

**Pin descriptions:**
- **DIN/MOSI** — Serial data in
- **CLK/SCK** — SPI clock
- **CS** — Chip select (active low)
- **DC** — Data/Command select (low=command, high=data)
- **RST** — Hardware reset (active low)
- **BUSY** — Display busy signal (check before sending new data)

## GxEPD2 Library (Arduino/ESP32)

GxEPD2 is the standard library for driving e-ink displays from Arduino-compatible platforms.

### Installation
```
Arduino IDE: Sketch → Include Library → Manage Libraries → "GxEPD2"
PlatformIO: lib_deps = zinggjm/GxEPD2
```

Also install: **Adafruit GFX Library** (dependency for graphics primitives).

### Basic Usage

```cpp
#include <GxEPD2_BW.h>  // For B/W displays
// #include <GxEPD2_3C.h>  // For 3-color displays

// Pick your display — example for 2.9" B/W SSD1680
GxEPD2_BW<GxEPD2_290_GDEY029T94, GxEPD2_290_GDEY029T94::HEIGHT>
    display(GxEPD2_290_GDEY029T94(/*CS=*/5, /*DC=*/17, /*RST=*/16, /*BUSY=*/4));

void setup() {
    display.init(115200);
    display.setRotation(1);
    display.setFont(&FreeMonoBold9pt7b);
    display.setTextColor(GxEPD_BLACK);

    // Full window update
    display.setFullWindow();
    display.firstPage();
    do {
        display.fillScreen(GxEPD_WHITE);
        display.setCursor(10, 30);
        display.println("Hello E-Ink!");
    } while (display.nextPage());

    display.hibernate();  // Put display controller to sleep
}
```

### Partial Refresh

```cpp
// Define the region to update
uint16_t x = 10, y = 10, w = 150, h = 30;
display.setPartialWindow(x, y, w, h);
display.firstPage();
do {
    display.fillScreen(GxEPD_WHITE);
    display.setCursor(x + 5, y + 20);
    display.print(sensorValue);
} while (display.nextPage());
```

Partial refresh is faster (~0.3s) and reduces flicker, but repeated partial refreshes cause **ghosting**. Do a full refresh every 10-20 partial updates.

### Display Selection Defines

GxEPD2 has many display classes. Common ones:

| Display                          | Class                                 |
|----------------------------------|---------------------------------------|
| 1.54" B/W 200x200               | GxEPD2_154_D67                        |
| 2.13" B/W 250x122               | GxEPD2_213_BN                         |
| 2.9" B/W 296x128                | GxEPD2_290_BS                         |
| 4.2" B/W 400x300                | GxEPD2_420                            |
| 7.5" B/W 800x480                | GxEPD2_750_T7                         |
| 2.13" B/W/Red 250x122           | GxEPD2_213_Z98c                       |
| 4.2" B/W/Red 400x300            | GxEPD2_420c_Z21                       |

Check the GxEPD2 library examples folder for the full list and select the class matching your panel's controller chip.

## Raspberry Pi with E-Ink

Use Waveshare's Python libraries or the `Pillow` imaging library:

```python
# Using Waveshare library for 2.13" V4
from waveshare_epd import epd2in13_V4
from PIL import Image, ImageDraw, ImageFont

epd = epd2in13_V4.EPD()
epd.init()
epd.Clear(0xFF)

# Create image
image = Image.new('1', (epd.height, epd.width), 255)
draw = ImageDraw.Draw(image)
font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 18)
draw.text((10, 10), "Hello from Pi!", font=font, fill=0)

epd.display(epd.getbuffer(image))
epd.sleep()  # Put display to sleep
```

Install: `pip install waveshare-epd Pillow`
Enable SPI: `sudo raspi-config` → Interface Options → SPI → Enable

## Refresh Times

| Type             | Full Refresh  | Partial Refresh | Notes                       |
|------------------|---------------|------------------|-----------------------------|
| B/W small        | 1-2s          | 0.2-0.5s         | Most practical               |
| B/W large (7.5") | 3-5s          | 0.5-1s           | Partial not always supported |
| 3-color          | 10-25s        | Not supported     | Very slow                    |
| 4-color          | 25-40s        | Not supported     | Specialty use only           |

**Fast refresh modes:** Some newer panels (e.g., GDEY series) support "fast" or "turbo" modes with ~0.5s full refresh, at the cost of increased ghosting.

## Ghosting

**What it is:** Faint remnants of previous images visible after refresh.

**Causes:**
- Repeated partial refreshes without full refresh
- Temperature extremes (especially cold)
- Display aging

**Mitigation:**
- Perform a full refresh (with screen flash) every 10-20 partial updates
- Use the display's built-in LUT (look-up table) for proper voltage waveforms
- Avoid operating below 0°C or above 50°C
- Some displays have "fast" vs "quality" LUTs — use quality for important content

## Deep Sleep + E-Ink for Ultra-Low Power

The killer combination for battery-powered devices:

### ESP32 Deep Sleep Pattern

```cpp
#include <GxEPD2_BW.h>

// Display setup...

void setup() {
    // Read sensor
    float temp = readSensor();

    // Update e-ink
    display.init(0);  // 0 = no serial debug
    display.setFullWindow();
    display.firstPage();
    do {
        display.fillScreen(GxEPD_WHITE);
        display.setCursor(10, 40);
        display.printf("Temp: %.1f C", temp);
    } while (display.nextPage());
    display.hibernate();  // Display controller sleep

    // ESP32 deep sleep for 5 minutes
    esp_sleep_enable_timer_wakeup(5 * 60 * 1000000ULL);
    esp_deep_sleep_start();
}

void loop() {} // Never reached
```

### Power Budget Example

| State                | Current Draw  | Duration  | Energy (mAh) |
|----------------------|---------------|-----------|---------------|
| ESP32 deep sleep     | ~10 uA        | 5 min     | 0.0008        |
| ESP32 active + WiFi  | ~160 mA       | 2s        | 0.089         |
| E-ink refresh        | ~20 mA        | 2s        | 0.011         |
| E-ink holding image  | ~0 uA         | 5 min     | 0             |

With a 1000mAh battery and 5-minute updates, this setup can last **months**.

## Use Cases for Off-Grid Applications

1. **Environmental monitoring dashboard** — Update temperature/humidity every 15 min, runs on small solar panel
2. **Trail/campsite signage** — Static message, update once a day, effectively zero power
3. **Mesh network message display** — Show last received Meshtastic message
4. **Battery voltage monitor** — Show system battery status without draining it
5. **Weather station** — Display barometric pressure trends, rainfall
6. **Asset tracking** — Show GPS coordinates, updated periodically
7. **E-ink name badges** — Update once, wear all day

## Buying Guide

### Recommended Vendors
- **Waveshare** — Widest selection, good documentation, Arduino + Pi support
- **Good Display (GDEY/GDEW)** — OEM manufacturer, cheapest in bulk
- **Adafruit** — Higher price, better tutorials and community support
- **LilyGo** — ESP32 boards with integrated e-ink (T5 series)

### What to Check Before Buying
- Controller chip (must match your library)
- Operating temperature range
- Partial refresh support
- Connector type (FPC ribbon — fragile, handle carefully)
- Whether a driver board is included or just the bare panel

## Troubleshooting

| Problem                 | Likely Cause                    | Fix                                    |
|-------------------------|---------------------------------|----------------------------------------|
| Blank screen            | Wrong controller class in code  | Check datasheet, try different class   |
| Garbled image           | SPI speed too high              | Lower SPI clock, check wiring          |
| Partial refresh ghosting| Too many partials               | Do a full refresh cycle                |
| Very slow refresh       | Using 3-color mode on B/W panel | Use `GxEPD2_BW` not `GxEPD2_3C`       |
| Display won't wake      | Hibernate vs sleep confusion    | Call `init()` again after hibernate    |
| Image persists after power off | Normal! | This is how e-ink works — feature not bug |
