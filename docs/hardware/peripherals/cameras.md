# Camera Modules

Raspberry Pi cameras, ESP32-CAM, USB webcams — hardware, software, and practical usage.

---

## Raspberry Pi Camera Modules

All official Pi cameras use the CSI (Camera Serial Interface) ribbon cable connector.

### Module Comparison

| Camera     | Sensor   | Resolution | FOV     | Focus      | Price  | Notes                         |
|------------|----------|------------|---------|------------|--------|-------------------------------|
| v1.3       | OV5647   | 5MP        | 62°     | Fixed      | ~$15   | Discontinued, still available |
| v2        | IMX219   | 8MP        | 62°     | Fixed      | ~$25   | Most common                   |
| v3        | IMX708   | 12MP       | 66°/102°| Autofocus  | ~$25   | Autofocus, HDR                |
| v3 Wide    | IMX708   | 12MP       | 102°    | Autofocus  | ~$35   | Wide angle variant            |
| HQ Camera  | IMX477   | 12.3MP     | Varies  | C/CS mount | ~$50   | Interchangeable lenses        |
| GS Camera  | IMX296   | 1.58MP     | Varies  | C/CS mount | ~$50   | Global shutter                |

### NoIR Variants

"NoIR" versions lack the infrared filter — they see near-IR light. Use with IR illuminators for night vision. Available for v1, v2, and v3.

### Connecting the Camera

1. Power off the Pi
2. Lift the CSI connector latch (between HDMI and audio jack on Pi 4)
3. Insert ribbon cable — blue/shiny side facing the Ethernet/USB ports
4. Push latch down
5. Power on

**Pi 5:** Uses a smaller 22-pin FPC connector. Need a 22-to-15 pin adapter cable or a Pi 5 specific cable.

### libcamera (Current Software Stack)

`libcamera` replaced the legacy `raspistill`/`raspivid` commands. It's the default on Raspberry Pi OS Bullseye and later.

**Test camera:**
```bash
libcamera-hello          # Preview for 5 seconds
libcamera-hello -t 0     # Preview indefinitely
```

**Capture still image:**
```bash
libcamera-still -o photo.jpg
libcamera-still -o photo.jpg --width 1920 --height 1080
libcamera-still -o photo.jpg -t 2000 --shutter 10000  # 2s preview, 10ms exposure
libcamera-still -o photo.png --encoding png            # PNG format
```

**Record video:**
```bash
libcamera-vid -o video.h264 -t 10000           # 10 seconds, H.264
libcamera-vid -o video.h264 -t 30000 --width 1920 --height 1080 --framerate 30
libcamera-vid -o video.mp4 --codec libav        # Direct MP4 (newer versions)

# Convert h264 to mp4:
ffmpeg -i video.h264 -c copy video.mp4
```

**Time-lapse:**
```bash
libcamera-still -o image%04d.jpg -t 3600000 --timelapse 10000
# 1 hour, one photo every 10 seconds
# Creates image0001.jpg, image0002.jpg, etc.

# Stitch into video:
ffmpeg -framerate 24 -pattern_type glob -i 'image*.jpg' -c:v libx264 timelapse.mp4
```

**Useful options:**
```bash
--rotation 180          # Rotate image
--hflip / --vflip       # Mirror
--brightness 0.1        # -1.0 to 1.0
--contrast 1.2          # Default 1.0
--shutter 100000        # Exposure in microseconds
--gain 8                # Analog gain (ISO)
--awb auto/daylight/tungsten/fluorescent
--roi 0.25,0.25,0.5,0.5  # Region of interest (x,y,w,h as fractions)
```

### Python with Picamera2

```python
from picamera2 import Picamera2
import time

picam2 = Picamera2()

# Still capture
config = picam2.create_still_configuration(
    main={"size": (1920, 1080)})
picam2.configure(config)
picam2.start()
time.sleep(2)  # Let auto exposure settle
picam2.capture_file("image.jpg")
picam2.stop()

# Video capture
config = picam2.create_video_configuration(
    main={"size": (1280, 720), "format": "RGB888"})
picam2.configure(config)
encoder = picam2.create_encoder("h264")
picam2.start_recording(encoder, "video.h264")
time.sleep(10)
picam2.stop_recording()
```

**Install:** `sudo apt install python3-picamera2` (pre-installed on Pi OS)

---

## ESP32-CAM (OV2640)

### Overview

The ESP32-CAM is a ~$5 board with an ESP32-S module, OV2640 camera (2MP), microSD slot, and LED flash. It's the cheapest way to get a wireless camera.

### Specs

- **Processor:** ESP32-S (dual core 240MHz, WiFi, Bluetooth)
- **Camera:** OV2640, 2MP, up to 1600x1200
- **RAM:** 520KB SRAM + 4MB PSRAM (needed for high-res frames)
- **Storage:** microSD slot
- **Flash LED:** Bright white LED (GPIO4)
- **Power:** 5V via header (no USB connector on base board)

### Programming (No Built-in USB)

The ESP32-CAM has no USB-to-serial chip. You need an external FTDI/CP2102 adapter:

```
FTDI        ESP32-CAM
----        ---------
5V       →  5V
GND      →  GND
TX       →  U0R (GPIO3)
RX       →  U0T (GPIO1)

For upload mode: Connect GPIO0 to GND, then press reset
After upload: Disconnect GPIO0 from GND, press reset
```

### Arduino IDE Setup

1. Add ESP32 board package (Espressif board manager URL)
2. Select board: **AI Thinker ESP32-CAM**
3. Select your FTDI COM port
4. Load example: File → Examples → ESP32 → Camera → CameraWebServer

### CameraWebServer Example (Modified)

```cpp
#include "esp_camera.h"
#include <WiFi.h>

// AI Thinker ESP32-CAM pin definition
#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27
#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22

const char* ssid = "your_network";
const char* password = "your_password";

void startCameraServer();  // Defined in camera server code

void setup() {
    Serial.begin(115200);

    camera_config_t config;
    config.ledc_channel = LEDC_CHANNEL_0;
    config.ledc_timer = LEDC_TIMER_0;
    config.pin_d0 = Y2_GPIO_NUM;
    config.pin_d1 = Y3_GPIO_NUM;
    config.pin_d2 = Y4_GPIO_NUM;
    config.pin_d3 = Y5_GPIO_NUM;
    config.pin_d4 = Y6_GPIO_NUM;
    config.pin_d5 = Y7_GPIO_NUM;
    config.pin_d6 = Y8_GPIO_NUM;
    config.pin_d7 = Y9_GPIO_NUM;
    config.pin_xclk = XCLK_GPIO_NUM;
    config.pin_pclk = PCLK_GPIO_NUM;
    config.pin_vsync = VSYNC_GPIO_NUM;
    config.pin_href = HREF_GPIO_NUM;
    config.pin_sscb_sda = SIOD_GPIO_NUM;
    config.pin_sscb_scl = SIOC_GPIO_NUM;
    config.pin_pwdn = PWDN_GPIO_NUM;
    config.pin_reset = RESET_GPIO_NUM;
    config.xclk_freq_hz = 20000000;
    config.pixel_format = PIXFORMAT_JPEG;

    // Use PSRAM if available
    if (psramFound()) {
        config.frame_size = FRAMESIZE_UXGA;  // 1600x1200
        config.jpeg_quality = 10;             // 0-63, lower = better
        config.fb_count = 2;
    } else {
        config.frame_size = FRAMESIZE_SVGA;   // 800x600
        config.jpeg_quality = 12;
        config.fb_count = 1;
    }

    esp_err_t err = esp_camera_init(&config);
    if (err != ESP_OK) {
        Serial.printf("Camera init failed: 0x%x\n", err);
        return;
    }

    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
    }
    Serial.println(WiFi.localIP());

    startCameraServer();
}
```

### Capture and Save to SD

```cpp
#include "FS.h"
#include "SD_MMC.h"

void captureAndSave() {
    camera_fb_t *fb = esp_camera_fb_get();
    if (!fb) {
        Serial.println("Capture failed");
        return;
    }

    String path = "/photo_" + String(millis()) + ".jpg";
    File file = SD_MMC.open(path.c_str(), FILE_WRITE);
    if (file) {
        file.write(fb->buf, fb->len);
        file.close();
        Serial.printf("Saved: %s (%d bytes)\n", path.c_str(), fb->len);
    }

    esp_camera_fb_return(fb);
}
```

### ESP32-CAM Known Issues

1. **Brownout on boot:** The camera draws significant current on startup. Use a good 5V supply (1A+). Add a 1000μF capacitor on 5V rail. Disable brownout detection if needed: `WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);`

2. **SD card conflicts:** GPIO4 (flash LED) is also used by the SD card. You can't use the flash LED and SD card simultaneously. GPIO12 is a bootstrap pin — if pulled high during boot (e.g., by SD card), the ESP32 may not boot. Fix: set eFuse or use `gpio_hold_dis(GPIO_NUM_12)`.

3. **Limited GPIOs:** Most GPIOs are used by the camera. Only GPIO13, GPIO14, GPIO15, GPIO2, GPIO12 are somewhat available (GPIO12 has boot strap issues).

4. **Antenna:** The PCB antenna is weak. Some boards have a U.FL connector for an external antenna — check for a 0-ohm resistor to select between PCB and external.

5. **Heat:** Gets warm during continuous streaming. Not a problem in normal use.

6. **No USB programming:** Need an FTDI adapter and GPIO0-to-GND jumper for upload. Tedious.

---

## ESP32-S3 Cameras

Newer alternative to the ESP32-CAM with better performance:

### XIAO ESP32S3 Sense

- ESP32-S3 with built-in USB-C (no FTDI needed!)
- OV2640 camera, microphone, SD card slot
- Much more available GPIOs
- Better WiFi/BLE performance
- Native USB for programming and serial

### Freenove ESP32-S3 WROOM CAM

- OV2640 or OV5640 (5MP)
- USB-C, more GPIO, PSRAM
- Compatible with esp32-camera library

### ESP32-S3 Camera Code

Same `esp_camera.h` library works, just different pin definitions. Check manufacturer's documentation for pin mapping.

---

## USB Webcams on Raspberry Pi

### Detection and Setup

```bash
# List connected cameras
lsusb
ls /dev/video*

# Install tools
sudo apt install v4l-utils fswebcam

# Check camera capabilities
v4l2-ctl --list-devices
v4l2-ctl -d /dev/video0 --list-formats-ext
```

### Capture with fswebcam

```bash
fswebcam -r 1280x720 --jpeg 95 photo.jpg
fswebcam -r 1920x1080 --no-banner -S 10 photo.jpg  # Skip 10 frames (auto-exposure settle)
```

### Streaming with ffmpeg

```bash
# Stream to file
ffmpeg -f v4l2 -video_size 1280x720 -i /dev/video0 -c:v libx264 output.mp4

# Stream MJPEG to network
ffmpeg -f v4l2 -video_size 640x480 -i /dev/video0 -f mjpeg -q:v 5 http://0.0.0.0:8080
```

### motion (Motion Detection Software)

```bash
sudo apt install motion

# Edit config
sudo nano /etc/motion/motion.conf
# Key settings:
#   daemon on
#   stream_port 8081
#   stream_localhost off
#   width 1280
#   height 720
#   framerate 15
#   threshold 1500
#   target_dir /home/pi/motion

sudo systemctl start motion
# Access stream at http://pi-ip:8081
```

---

## OpenCV on Raspberry Pi

### Installation

```bash
# Install from apt (faster, recommended)
sudo apt install python3-opencv

# Or install with pip for latest version
pip install opencv-python-headless  # No GUI
# pip install opencv-python         # With GUI (needs display)
```

### Basic Camera Capture

```python
import cv2

cap = cv2.VideoCapture(0)  # USB webcam
# cap = cv2.VideoCapture('/dev/video0')

cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

ret, frame = cap.read()
if ret:
    cv2.imwrite('capture.jpg', frame)

cap.release()
```

### With Picamera2 + OpenCV

```python
from picamera2 import Picamera2
import cv2

picam2 = Picamera2()
config = picam2.create_preview_configuration(
    main={"format": "RGB888", "size": (640, 480)})
picam2.configure(config)
picam2.start()

while True:
    frame = picam2.capture_array()

    # OpenCV processing
    gray = cv2.cvtColor(frame, cv2.COLOR_RGB2GRAY)
    edges = cv2.Canny(gray, 50, 150)

    # Display (if you have a monitor)
    cv2.imshow("Camera", frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

picam2.stop()
cv2.destroyAllWindows()
```

### Motion Detection with OpenCV

```python
import cv2
import numpy as np

cap = cv2.VideoCapture(0)
ret, prev_frame = cap.read()
prev_gray = cv2.cvtColor(prev_frame, cv2.COLOR_BGR2GRAY)
prev_gray = cv2.GaussianBlur(prev_gray, (21, 21), 0)

while True:
    ret, frame = cap.read()
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    gray = cv2.GaussianBlur(gray, (21, 21), 0)

    diff = cv2.absdiff(prev_gray, gray)
    thresh = cv2.threshold(diff, 25, 255, cv2.THRESH_BINARY)[1]
    thresh = cv2.dilate(thresh, None, iterations=2)

    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    motion_detected = False
    for c in contours:
        if cv2.contourArea(c) > 5000:
            motion_detected = True
            (x, y, w, h) = cv2.boundingRect(c)
            cv2.rectangle(frame, (x, y), (x+w, y+h), (0, 255, 0), 2)

    if motion_detected:
        cv2.imwrite(f'motion_{int(time.time())}.jpg', frame)

    prev_gray = gray

cap.release()
```

---

## Camera Selection Guide

| Use Case                    | Best Option                  | Why                              |
|-----------------------------|------------------------------|----------------------------------|
| High quality stills/video   | RPi Camera v3 or HQ          | Best sensors, autofocus          |
| Cheapest wireless camera    | ESP32-CAM                     | ~$5, built-in WiFi               |
| Easy wireless camera        | XIAO ESP32S3 Sense            | USB-C, better than ESP32-CAM     |
| Night vision                | RPi NoIR + IR LEDs            | See in dark with IR illumination |
| Machine vision              | RPi HQ + C-mount lens         | Interchangeable lenses           |
| Motion detection            | RPi + USB webcam + motion     | Well-supported software          |
| Global shutter (fast motion)| RPi GS Camera                 | No rolling shutter artifacts     |
| Time-lapse                  | RPi Camera + cron             | Reliable, scriptable             |
| Surveillance (off-grid)     | ESP32-CAM + solar + SD card   | Low power, autonomous            |

## Troubleshooting

| Problem                     | Solution                                                     |
|-----------------------------|--------------------------------------------------------------|
| `libcamera` not detecting   | Check ribbon cable seating, enable camera in raspi-config    |
| Pink/purple tint on Pi cam  | IR filter issue — make sure you're not using NoIR in daylight without filter |
| ESP32-CAM boot loop         | Bad power supply or GPIO0 still grounded after upload        |
| ESP32-CAM blurry images     | Manually adjust lens focus (turn the lens element)           |
| USB webcam not at /dev/video0 | Check `v4l2-ctl --list-devices` for correct device number  |
| Low FPS                     | Reduce resolution, use JPEG, check USB bandwidth             |
| Out of memory (ESP32-CAM)   | Reduce frame size, ensure PSRAM is enabled in board settings |
