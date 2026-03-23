# PlatformIO for ESP32 Development

## What is PlatformIO?

PlatformIO is a cross-platform build system and library manager for embedded development. It wraps toolchains (including ESP-IDF and Arduino) behind a consistent interface and provides excellent VS Code integration. For ESP32 development, it offers:

- One-click installation of toolchains (no manual setup of ESP-IDF or Arduino core)
- Unified `platformio.ini` config file per project
- Library dependency management with version pinning
- Multiple build environments in one project (e.g., ESP32 + ESP32-S3 + ESP32-C3)
- Built-in serial monitor
- OTA upload support
- JTAG debugging integration

---

## Installation

### VS Code Extension (Recommended)

1. Install VS Code: https://code.visualstudio.com/
2. Open Extensions panel (Ctrl+Shift+X)
3. Search "PlatformIO IDE" and install
4. Restart VS Code
5. PlatformIO will install its core tools automatically

The PlatformIO toolbar appears at the bottom of VS Code with build, upload, monitor, and clean buttons.

### CLI Only

If you prefer terminal-only workflow:

```bash
# Using pip (Python 3.6+)
pip install platformio

# Or using the installer script
curl -fsSL -o get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py
python3 get-platformio.py

# Add to PATH
export PATH="$HOME/.platformio/penv/bin:$PATH"
# Add this line to your ~/.bashrc or ~/.zshrc
```

Verify:
```bash
pio --version
```

### Linux Serial Port Access

```bash
sudo usermod -a -G dialout $USER
# Log out and back in
```

---

## Project Structure

```
my_project/
  platformio.ini        # Build configuration
  src/
    main.cpp            # Your application code
  include/
    config.h            # Header files
  lib/
    my_library/         # Project-specific libraries
      my_library.h
      my_library.cpp
  test/                 # Unit tests
  data/                 # SPIFFS/LittleFS filesystem data
```

Create a new project:
```bash
# CLI
pio project init --board esp32dev

# Or for a specific framework
pio project init --board esp32dev --project-option "framework=arduino"
```

---

## platformio.ini Configuration

### Basic ESP32 (Arduino Framework)

```ini
[env:esp32dev]
platform = espressif32
board = esp32dev
framework = arduino
monitor_speed = 115200
upload_speed = 921600
```

### ESP32-S3 (Arduino Framework)

```ini
[env:esp32s3]
platform = espressif32
board = esp32-s3-devkitc-1
framework = arduino
monitor_speed = 115200
upload_speed = 921600
board_build.mcu = esp32s3
board_build.f_cpu = 240000000L

; For boards with native USB (no external UART chip)
upload_protocol = esptool
monitor_port = /dev/ttyACM0
; If using USB CDC for serial output:
build_flags =
    -DARDUINO_USB_CDC_ON_BOOT=1
    -DARDUINO_USB_MODE=1
```

### ESP32-C3 (Arduino Framework)

```ini
[env:esp32c3]
platform = espressif32
board = esp32-c3-devkitm-1
framework = arduino
monitor_speed = 115200
board_build.mcu = esp32c3
board_build.f_cpu = 160000000L

; C3 often uses USB Serial/JTAG for programming
upload_protocol = esptool
build_flags =
    -DARDUINO_USB_CDC_ON_BOOT=1
```

### ESP32 with ESP-IDF Framework

```ini
[env:esp32_idf]
platform = espressif32
board = esp32dev
framework = espidf
monitor_speed = 115200

; ESP-IDF specific settings
board_build.partitions = partitions.csv
board_build.embed_txtfiles =
    managed_components/certificate.pem
```

---

## Common Board Configurations

### ESP32 DevKit V1 (Generic)

```ini
[env:esp32dev]
platform = espressif32
board = esp32dev
framework = arduino
monitor_speed = 115200
upload_speed = 921600
```

### TTGO T-Beam (GPS + LoRa)

```ini
[env:tbeam]
platform = espressif32
board = ttgo-t-beam
framework = arduino
monitor_speed = 115200
upload_speed = 921600
board_build.partitions = huge_app.csv

build_flags =
    -DHAS_AXP192           ; Power management IC
    -DGPS_RX_PIN=34
    -DGPS_TX_PIN=12
    -DLORA_SCK=5
    -DLORA_MISO=19
    -DLORA_MOSI=27
    -DLORA_CS=18
    -DLORA_RST=23
    -DLORA_DIO0=26

lib_deps =
    mikalhart/TinyGPSPlus@^1.0.3
    sandeepmistry/LoRa@^0.8.0
    lewisxhe/AXP202X_Library@^1.1.3
```

### Heltec WiFi LoRa 32 V3 (ESP32-S3 + LoRa + OLED)

```ini
[env:heltec_v3]
platform = espressif32
board = heltec_wifi_lora_32_V3
framework = arduino
monitor_speed = 115200
upload_speed = 921600

build_flags =
    -DARDUINO_USB_CDC_ON_BOOT=1
    -DOLED_SDA=17
    -DOLED_SCL=18
    -DOLED_RST=21

lib_deps =
    thingpulse/ESP8266 and ESP32 OLED driver for SSD1306 displays@^4.4.0
    sandeepmistry/LoRa@^0.8.0
```

### LILYGO T-Display S3 (ESP32-S3 + TFT)

```ini
[env:t_display_s3]
platform = espressif32
board = lilygo-t-display-s3
framework = arduino
monitor_speed = 115200
upload_speed = 921600

build_flags =
    -DARDUINO_USB_CDC_ON_BOOT=1
    -DUSER_SETUP_LOADED
    -DST7789_DRIVER
    -DTFT_WIDTH=170
    -DTFT_HEIGHT=320

lib_deps =
    bodmer/TFT_eSPI@^2.5.0
```

### Seeed XIAO ESP32-C3

```ini
[env:xiao_c3]
platform = espressif32
board = seeed_xiao_esp32c3
framework = arduino
monitor_speed = 115200

build_flags =
    -DARDUINO_USB_CDC_ON_BOOT=1
```

---

## Library Management

### Adding Libraries via lib_deps

```ini
lib_deps =
    ; By library name (from PlatformIO Registry)
    adafruit/Adafruit BME280 Library@^2.2.2

    ; By GitHub repository
    https://github.com/me-no-dev/ESPAsyncWebServer.git

    ; By GitHub with specific tag/branch
    https://github.com/me-no-dev/AsyncTCP.git#v1.1.1

    ; By local path (for development)
    symlink://../shared_lib

    ; Multiple on separate lines (no commas needed)
    bblanchon/ArduinoJson@^6.21.3
    knolleary/PubSubClient@^2.8
```

### Library Search

```bash
pio lib search "bme280"
pio lib search "lora" --framework arduino --platform espressif32
```

### lib/ Directory

Libraries placed in `lib/` are automatically compiled and linked. Good for:
- Project-specific code you want organized as a library
- Modified versions of third-party libraries
- Libraries not available in the PlatformIO registry

Structure:
```
lib/
  my_sensor/
    library.json          # Optional metadata
    src/
      my_sensor.h
      my_sensor.cpp
```

---

## Build Flags

```ini
build_flags =
    ; Preprocessor defines
    -DDEBUG_MODE=1
    -DWIFI_SSID=\"MyNetwork\"
    -DWIFI_PASS=\"MyPassword\"

    ; Include paths
    -Iinclude/vendor

    ; Optimization
    -Os                    ; Optimize for size
    -O2                    ; Optimize for speed

    ; Warnings
    -Wall
    -Wextra

    ; ESP32-specific
    -DBOARD_HAS_PSRAM      ; Enable PSRAM
    -DCONFIG_SPIRAM_SUPPORT=1
    -mfix-esp32-psram-cache-issue  ; Required for Rev0 ESP32 with PSRAM

    ; Arduino-specific
    -DCORE_DEBUG_LEVEL=5   ; Max debug output (0=none, 5=verbose)
    -DARDUINO_USB_CDC_ON_BOOT=1  ; Use USB for Serial on S2/S3/C3
```

### build_unflags

Remove flags that the platform sets by default:
```ini
build_unflags =
    -Os          ; Remove size optimization
    -std=gnu++11 ; Remove old C++ standard

build_flags =
    -O2          ; Use speed optimization instead
    -std=gnu++17 ; Use C++17
```

---

## Upload and Monitor Speed

```ini
; Upload speed (baud rate for flashing)
upload_speed = 921600    ; Fast, works with most boards
; upload_speed = 460800  ; If 921600 fails
; upload_speed = 115200  ; Slowest, most reliable

; Monitor speed (must match Serial.begin() in your code)
monitor_speed = 115200

; Custom serial port
upload_port = /dev/ttyUSB0
monitor_port = /dev/ttyUSB0

; Monitor filters
monitor_filters =
    default          ; Remove non-printable chars
    esp32_exception_decoder  ; Decode crash backtraces to source lines
    time             ; Prefix each line with timestamp
    log2file         ; Save output to a file
```

---

## Multiple Environments

A major strength of PlatformIO is building the same project for multiple boards:

```ini
[platformio]
default_envs = esp32dev  ; Build this by default

; Shared settings
[common]
framework = arduino
monitor_speed = 115200
lib_deps =
    bblanchon/ArduinoJson@^6.21.3
    knolleary/PubSubClient@^2.8

build_flags =
    -DMQTT_BROKER=\"192.168.1.100\"

[env:esp32dev]
platform = espressif32
board = esp32dev
framework = ${common.framework}
monitor_speed = ${common.monitor_speed}
lib_deps = ${common.lib_deps}
build_flags =
    ${common.build_flags}
    -DBOARD_TYPE=1
    -DLED_PIN=2

[env:esp32s3]
platform = espressif32
board = esp32-s3-devkitc-1
framework = ${common.framework}
monitor_speed = ${common.monitor_speed}
lib_deps = ${common.lib_deps}
build_flags =
    ${common.build_flags}
    -DBOARD_TYPE=2
    -DLED_PIN=48
    -DARDUINO_USB_CDC_ON_BOOT=1

[env:esp32c3]
platform = espressif32
board = esp32-c3-devkitm-1
framework = ${common.framework}
monitor_speed = ${common.monitor_speed}
lib_deps = ${common.lib_deps}
build_flags =
    ${common.build_flags}
    -DBOARD_TYPE=3
    -DLED_PIN=8
    -DARDUINO_USB_CDC_ON_BOOT=1
```

Build/upload for a specific environment:
```bash
pio run -e esp32s3              # Build only esp32s3
pio run -e esp32s3 -t upload    # Upload to esp32s3
pio run                         # Build default_envs
pio run -e esp32dev -e esp32c3  # Build two environments
```

---

## Partition Tables

### Built-in Partition Schemes

```ini
; Use a built-in scheme
board_build.partitions = default.csv        ; 1.2 MB app, 1.5 MB SPIFFS
board_build.partitions = no_ota.csv         ; 2 MB app, no OTA
board_build.partitions = huge_app.csv       ; 3 MB app, no OTA, no SPIFFS
board_build.partitions = min_spiffs.csv     ; 1.9 MB app + OTA, 128 KB SPIFFS
board_build.partitions = default_16MB.csv   ; For 16 MB flash
```

### Custom Partition Table

Create `partitions.csv` in your project root:
```csv
# Name,   Type, SubType,  Offset,  Size,     Flags
nvs,      data, nvs,      0x9000,  0x5000,
otadata,  data, ota,      0xe000,  0x2000,
app0,     app,  ota_0,    0x10000, 0x1E0000,
app1,     app,  ota_1,    0x1F0000,0x1E0000,
spiffs,   data, spiffs,   0x3D0000,0x30000,
```

Reference it:
```ini
board_build.partitions = partitions.csv
```

---

## SPIFFS / LittleFS Filesystem

Upload files from the `data/` directory to the ESP32's filesystem:

```
data/
  index.html
  style.css
  config.json
```

```ini
; For SPIFFS
board_build.filesystem = spiffs

; For LittleFS (recommended - more robust)
board_build.filesystem = littlefs
```

Upload filesystem:
```bash
pio run -t uploadfs
```

---

## OTA Update Configuration

### ArduinoOTA (Local Network)

```ini
[env:esp32_ota]
platform = espressif32
board = esp32dev
framework = arduino

; For initial flash via serial
upload_protocol = esptool
upload_speed = 921600

; Uncomment these for OTA upload (after initial serial flash)
; upload_protocol = espota
; upload_port = 192.168.1.100
; upload_flags =
;     --port=3232
;     --auth=my_ota_password

board_build.partitions = min_spiffs.csv  ; Must have OTA partitions
```

In your code:
```cpp
#include <ArduinoOTA.h>

void setup() {
    WiFi.begin("SSID", "password");
    while (WiFi.status() != WL_CONNECTED) delay(500);

    ArduinoOTA.setHostname("esp32-sensor");
    ArduinoOTA.setPassword("my_ota_password");
    ArduinoOTA.begin();
}

void loop() {
    ArduinoOTA.handle();
    // ... your code
}
```

---

## Debugging with JTAG

ESP32 supports JTAG debugging through OpenOCD. The ESP32-S3 and ESP32-C3 have built-in USB JTAG (no external adapter needed).

### ESP32 (Original) - External JTAG Adapter

```ini
[env:esp32_debug]
platform = espressif32
board = esp32dev
framework = arduino

debug_tool = esp-prog         ; Espressif ESP-PROG adapter
; debug_tool = minimodule     ; FTDI FT2232H-based
debug_init_break = tbreak setup  ; Break at setup()
debug_speed = 5000            ; JTAG clock in kHz
```

JTAG pins on ESP32:
| JTAG Signal | ESP32 GPIO |
|-------------|-----------|
| TMS | GPIO14 |
| TDI | GPIO12 |
| TCK | GPIO13 |
| TDO | GPIO15 |

### ESP32-S3 / ESP32-C3 - Built-in USB JTAG

```ini
[env:esp32s3_debug]
platform = espressif32
board = esp32-s3-devkitc-1
framework = arduino

debug_tool = esp-builtin      ; Use built-in USB JTAG
debug_init_break = tbreak setup
debug_speed = 40000

build_type = debug            ; Include debug symbols, disable optimization
```

### Using the Debugger in VS Code

1. Set breakpoints by clicking in the gutter
2. Click the PlatformIO debug icon (or F5)
3. Use the debug toolbar: step over, step into, step out, continue
4. Watch variables, inspect call stack, view memory

### Debug Build Type

```ini
build_type = debug
; This adds -Og optimization and -g debug symbols
; Binary will be larger and slightly slower
; Use build_type = release for production
```

---

## Useful PlatformIO CLI Commands

```bash
# Project commands
pio run                      # Build (default environment)
pio run -t upload            # Build and upload
pio run -t clean             # Clean build files
pio run -t uploadfs          # Upload filesystem image
pio device monitor           # Open serial monitor

# Board/platform info
pio boards "esp32"           # List all ESP32 boards
pio platform show espressif32  # Show platform details

# Library commands
pio lib search "keyword"     # Search libraries
pio lib install "ArduinoJson"  # Install to project
pio lib list                 # List installed libraries
pio lib update               # Update all libraries

# System
pio system info              # Show PlatformIO system info
pio upgrade                  # Upgrade PlatformIO core
pio platform update          # Update platform packages

# Advanced
pio check                    # Static code analysis (cppcheck, clangtidy)
pio test                     # Run unit tests
pio remote run -t upload     # Remote upload via PlatformIO Cloud
```

---

## Tips and Troubleshooting

### Board Not Detected
- Check USB cable (some are charge-only with no data lines)
- Install CP2102 or CH340 drivers if needed
- On Linux: check `ls /dev/ttyUSB*` or `ls /dev/ttyACM*`
- On WSL2: use usbipd to attach the USB device

### Upload Fails
- Hold the BOOT button while clicking upload (for boards without auto-reset)
- Reduce upload speed: `upload_speed = 115200`
- Try a different USB cable or port
- Check that no serial monitor is holding the port open

### Build Fails with "framework not found"
```bash
# Force platform reinstall
pio platform install espressif32 --with-package framework-arduinoespressif32
```

### IntelliSense Not Working in VS Code
- Build the project once first (PlatformIO generates compile_commands.json)
- Check that the PlatformIO extension is active (not just C/C++ extension)

### Monitoring Crash Backtraces
Add the exception decoder to your monitor:
```ini
monitor_filters = esp32_exception_decoder
```
This converts raw addresses to file:line references when the ESP32 crashes.

### Flash Size Mismatch
If your board has more flash than the default:
```ini
board_build.flash_size = 16MB
board_upload.flash_size = 16MB
```
