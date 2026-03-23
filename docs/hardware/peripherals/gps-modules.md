# GPS Modules

NEO-6M/7M/8M modules, NMEA parsing, antennas, and practical usage.

---

## Module Comparison

| Module  | Channels | Update Rate | Sensitivity    | Cold Start | Hot Start | Price  |
|---------|----------|-------------|----------------|------------|-----------|--------|
| NEO-6M  | 50       | 5 Hz max    | -161 dBm       | 27s        | 1s        | ~$3    |
| NEO-7M  | 56       | 10 Hz max   | -162 dBm       | 27s        | 1s        | ~$5    |
| NEO-M8N | 72       | 10 Hz max   | -167 dBm       | 26s        | 1s        | ~$8    |
| NEO-M8P | 72       | 10 Hz max   | -167 dBm       | 26s        | 1s        | ~$200  |
| NEO-M9N | 92       | 25 Hz max   | -167 dBm       | 24s        | 2s        | ~$25   |

For most hobby/field projects, the **NEO-6M** is perfectly adequate. The NEO-M8N gives better sensitivity and faster fix in challenging conditions.

---

## UART Interface

GPS modules output serial data at **9600 baud** by default (can be configured higher).

### Wiring

```
GPS Module     ESP32        RPi              Arduino Uno
----------     -----        ---              -----------
VCC            3.3V         3.3V             5V (most modules have regulator)
GND            GND          GND              GND
TX             GPIO16 (RX)  GPIO15 (RXD)     D4 (SoftwareSerial RX)
RX             GPIO17 (TX)  GPIO14 (TXD)     D3 (SoftwareSerial TX)
PPS            Any GPIO     Any GPIO         Any GPIO (optional)
```

**Note:** GPS TX connects to MCU RX, and vice versa (they're crossed).

### ESP32 Example with Hardware Serial

```cpp
#define GPS_RX 16
#define GPS_TX 17

void setup() {
    Serial.begin(115200);
    Serial2.begin(9600, SERIAL_8N1, GPS_RX, GPS_TX);
}

void loop() {
    while (Serial2.available()) {
        char c = Serial2.read();
        Serial.print(c);  // Forward GPS data to USB serial
    }
}
```

### Arduino Uno with SoftwareSerial

```cpp
#include <SoftwareSerial.h>

SoftwareSerial gpsSerial(4, 3);  // RX, TX

void setup() {
    Serial.begin(115200);
    gpsSerial.begin(9600);
}

void loop() {
    while (gpsSerial.available()) {
        Serial.write(gpsSerial.read());
    }
}
```

### Raspberry Pi

The GPS module connects to `/dev/serial0` (GPIO 14/15). Disable the serial console first:

```bash
sudo raspi-config
# Interface Options → Serial Port
# Login shell over serial: No
# Serial port hardware: Yes

# Install gpsd
sudo apt install gpsd gpsd-clients

# Configure gpsd
sudo nano /etc/default/gpsd
# Set: DEVICES="/dev/serial0"
# Set: GPSD_OPTIONS="-n"

sudo systemctl restart gpsd

# Test
gpsmon
# or
cgps -s
```

**Python:**
```python
import serial

ser = serial.Serial('/dev/serial0', 9600, timeout=1)
while True:
    line = ser.readline().decode('ascii', errors='replace').strip()
    if line.startswith('$GPRMC') or line.startswith('$GNRMC'):
        print(line)
```

---

## NMEA Sentences

GPS modules output NMEA 0183 sentences — ASCII text lines starting with `$`.

### GPGGA — Fix Information

```
$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,47.0,M,,*47
```

| Field          | Value       | Meaning                           |
|----------------|-------------|-----------------------------------|
| Time           | 123519      | 12:35:19 UTC                      |
| Latitude       | 4807.038,N  | 48° 07.038' N                     |
| Longitude      | 01131.000,E | 011° 31.000' E                    |
| Fix quality    | 1           | 0=invalid, 1=GPS, 2=DGPS         |
| Satellites     | 08          | Number of satellites in use       |
| HDOP           | 0.9         | Horizontal dilution of precision  |
| Altitude       | 545.4,M     | Altitude above sea level (meters) |
| Geoid sep.     | 47.0,M      | Geoid separation                  |

### GPRMC — Recommended Minimum

```
$GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W*6A
```

| Field          | Value       | Meaning                           |
|----------------|-------------|-----------------------------------|
| Time           | 123519      | 12:35:19 UTC                      |
| Status         | A           | A=active(valid), V=void(invalid)  |
| Latitude       | 4807.038,N  | 48° 07.038' N                     |
| Longitude      | 01131.000,E | 011° 31.000' E                    |
| Speed          | 022.4       | Speed over ground (knots)         |
| Course         | 084.4       | Track angle (degrees true)        |
| Date           | 230394      | 23 March 1994 (DDMMYY)           |
| Magnetic var.  | 003.1,W     | Magnetic variation                |

### Other Common Sentences

| Sentence | Content                                    |
|----------|--------------------------------------------|
| GPGSV    | Satellites in view (azimuth, elevation, SNR)|
| GPGSA    | DOP and active satellites                   |
| GPVTG    | Track and ground speed                      |
| GNGGA    | Multi-GNSS version of GPGGA                 |
| GNRMC    | Multi-GNSS version of GPRMC                 |

**Prefix meanings:** GP = GPS only, GL = GLONASS, GA = Galileo, GN = Multi-GNSS.

### Coordinate Format

NMEA uses **degrees and decimal minutes** (DDMM.MMMM), not decimal degrees:

```
4807.038 = 48° 07.038'

To convert to decimal degrees:
48 + (07.038 / 60) = 48.1173°
```

---

## TinyGPS++ Library

The standard Arduino library for parsing NMEA data.

### Installation

Arduino: Library Manager → search "TinyGPSPlus"
PlatformIO: `lib_deps = mikalhart/TinyGPSPlus`

### Basic Usage

```cpp
#include <TinyGPSPlus.h>

TinyGPSPlus gps;

void setup() {
    Serial.begin(115200);
    Serial2.begin(9600, SERIAL_8N1, 16, 17);
}

void loop() {
    while (Serial2.available()) {
        gps.encode(Serial2.read());
    }

    if (gps.location.isUpdated()) {
        Serial.printf("Lat: %.6f\n", gps.location.lat());
        Serial.printf("Lng: %.6f\n", gps.location.lng());
        Serial.printf("Alt: %.1f m\n", gps.altitude.meters());
        Serial.printf("Speed: %.1f km/h\n", gps.speed.kmph());
        Serial.printf("Course: %.1f°\n", gps.course.deg());
        Serial.printf("Sats: %d\n", gps.satellites.value());
        Serial.printf("HDOP: %.1f\n", gps.hdop.hdop());

        // Date and time (UTC)
        Serial.printf("Date: %02d/%02d/%04d\n",
            gps.date.day(), gps.date.month(), gps.date.year());
        Serial.printf("Time: %02d:%02d:%02d\n",
            gps.time.hour(), gps.time.minute(), gps.time.second());
    }
}
```

### Distance and Bearing Between Two Points

```cpp
double distMeters = TinyGPSPlus::distanceBetween(
    lat1, lng1, lat2, lng2);

double bearing = TinyGPSPlus::courseTo(
    lat1, lng1, lat2, lng2);

const char* cardinal = TinyGPSPlus::cardinal(bearing);
// Returns "N", "NE", "E", etc.
```

### Custom NMEA Parsing

```cpp
// Parse a non-standard sentence field
TinyGPSCustom pdop(gps, "GPGSA", 15);  // 15th field of GPGSA

// After gps.encode():
if (pdop.isUpdated()) {
    Serial.printf("PDOP: %s\n", pdop.value());
}
```

---

## Cold / Warm / Hot Start

| Start Type | Condition                              | Time to Fix | What's Cached          |
|------------|----------------------------------------|-------------|------------------------|
| Cold       | No stored data, first power-on         | 25-35s      | Nothing                |
| Warm       | Has almanac, approximate time/position | 25-30s      | Almanac                |
| Hot        | Recent fix (<4hrs), position known     | 1-2s        | Almanac + ephemeris    |

### Battery Backup

Most GPS modules have a small battery (or supercapacitor) that keeps the RTC and satellite data alive when main power is off. This enables hot starts.

- **CR1220 coin cell** on many modules — lasts months
- **Supercapacitor** on cheaper modules — lasts hours
- **VBAT pin** — connect to always-on 3.3V for persistent backup

Without backup power, every start is a cold start.

---

## Antennas

### Ceramic Patch Antenna

Most modules come with a small ceramic patch antenna mounted on the PCB.

- **Must face the sky** — won't work indoors well, blocked by metal
- Gain: ~2 dBi
- OK for outdoor use with clear sky view

### External Active Antenna

Connect via **U.FL** (IPEX) connector on the module to an SMA antenna.

- Includes a Low Noise Amplifier (LNA) — powered by the module
- Much better reception, works with some indoor sky obstruction
- Magnetic mount types stick to metal surfaces
- Cable length: keep under 5m to avoid signal loss

### Antenna Selection Tips

- **Urban canyon/trees:** Use active antenna on a mast
- **Vehicle:** Magnetic mount active antenna on roof
- **Portable device:** Ceramic patch OK with sky view
- **Under cover/in enclosure:** Must use external antenna with cable routed outside

---

## PPS (Pulse Per Second)

The PPS pin outputs a precise pulse at exactly 1 Hz, synchronized to GPS time. Rising edge is accurate to ~10-30 nanoseconds.

### Uses

- **Time synchronization:** Discipline a local clock (NTP server on RPi)
- **Frequency calibration:** Reference for oscillator calibration
- **Data logging:** Precise timestamp alignment

### Using PPS on Raspberry Pi

```bash
sudo apt install pps-tools

# Add to /boot/config.txt:
dtoverlay=pps-gpio,gpiopin=18

# Reboot, then test:
sudo ppstest /dev/pps0
```

For NTP time server, configure `chrony` or `gpsd` with PPS input for sub-millisecond accuracy.

---

## Power Consumption

| State              | NEO-6M  | NEO-M8N  | Notes                    |
|--------------------|---------|----------|--------------------------|
| Acquisition        | ~45mA   | ~25mA    | Searching for satellites  |
| Continuous tracking| ~40mA   | ~23mA    | Normal operation          |
| Power save mode    | ~11mA   | ~7mA     | Reduced update rate       |
| Backup mode        | ~15μA   | ~15μA    | RTC only, no tracking     |

### Power Saving Strategies

1. **Cyclic tracking:** Module sleeps between fixes. Configure via UBX commands
2. **Power gating:** Turn off GPS module via MOSFET when not needed
3. **Duty cycling:** Get a fix, store position, power off for N minutes
4. **Reduce update rate:** 1 Hz is usually enough (default). Lower to 0.2 Hz if possible

### ESP32 Example — Periodic GPS Fix

```cpp
#define GPS_POWER_PIN 12  // Control via MOSFET

void getGPSFix() {
    digitalWrite(GPS_POWER_PIN, HIGH);  // Power on GPS
    unsigned long start = millis();

    while (millis() - start < 60000) {  // 60s timeout
        while (Serial2.available()) {
            gps.encode(Serial2.read());
        }
        if (gps.location.isValid() && gps.location.age() < 2000) {
            // Got a valid fix
            saveFix(gps.location.lat(), gps.location.lng());
            break;
        }
    }

    digitalWrite(GPS_POWER_PIN, LOW);  // Power off GPS
}
```

---

## UBX Configuration

u-blox modules support binary UBX protocol for configuration (in addition to NMEA). Use **u-center** software (Windows) for visual configuration, or send UBX commands programmatically.

### Common Configurations

**Change baud rate to 115200:**
```cpp
// UBX-CFG-PRT command
byte changeBaud[] = {
    0xB5, 0x62, 0x06, 0x00, 0x14, 0x00,
    0x01, 0x00, 0x00, 0x00, 0xD0, 0x08, 0x00, 0x00,
    0x00, 0xC2, 0x01, 0x00, 0x07, 0x00, 0x03, 0x00,
    0x00, 0x00, 0x00, 0x00, 0xC0, 0x7E
};
Serial2.write(changeBaud, sizeof(changeBaud));
delay(100);
Serial2.updateBaudRate(115200);
```

**Set update rate to 5 Hz:**
```cpp
// UBX-CFG-RATE: measurement period = 200ms
byte setRate[] = {
    0xB5, 0x62, 0x06, 0x08, 0x06, 0x00,
    0xC8, 0x00, 0x01, 0x00, 0x01, 0x00,
    0xDE, 0x6A
};
Serial2.write(setRate, sizeof(setRate));
```

**Save configuration to flash (NEO-M8+):**
```cpp
byte saveConfig[] = {
    0xB5, 0x62, 0x06, 0x09, 0x0D, 0x00,
    0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x17, 0x31, 0xBF
};
Serial2.write(saveConfig, sizeof(saveConfig));
```

---

## Troubleshooting

| Problem                    | Likely Cause                    | Fix                                     |
|----------------------------|---------------------------------|-----------------------------------------|
| No data at all             | TX/RX swapped or wrong baud     | Swap TX/RX; verify 9600 baud            |
| Data but no fix            | No sky view                     | Move outdoors, check antenna            |
| Fix takes very long        | Cold start, poor sky view       | Ensure backup battery, wait 30-60s      |
| Coordinates are wrong      | Parsing degrees/minutes wrong   | NMEA uses DDMM.MMMM, not decimal degrees|
| Time is UTC                | Normal — GPS outputs UTC only   | Add local timezone offset in software   |
| Altitude seems wrong       | Normal — GPS altitude ±10-25m   | Use barometric altitude for precision   |
| Position jumps around      | Poor satellite geometry (HDOP)  | Check HDOP; >5 = poor quality           |
| PPS not working            | PPS pin not connected or no fix | PPS only pulses after a valid fix       |

## Field Tips

- First fix in a new location always takes longer (cold start). Be patient
- GPS works poorly under dense tree canopy, in canyons, near tall buildings
- Metal enclosures block GPS signal — mount antenna outside or use a plastic enclosure lid
- GPS antennas work best facing straight up — avoid mounting at angles
- For long-term logging, periodically validate fix quality (HDOP < 2 is good, < 5 is usable)
- Battery backup saves ~25 seconds per startup — worth the cost of a CR1220
