# AIS Marine Vessel Tracking

## What Is AIS?

The Automatic Identification System (AIS) is a maritime tracking system used by ships and vessel traffic services. Ships equipped with AIS transceivers automatically broadcast their identity, position, course, speed, and other information at regular intervals.

AIS operates on two VHF maritime frequencies:
- **161.975 MHz** (AIS Channel 1 / AIS1)
- **162.025 MHz** (AIS Channel 2 / AIS2)

AIS is mandatory for:
- All ships of 300 gross tonnage or more on international voyages
- All cargo ships of 500 gross tonnage or more
- All passenger ships regardless of size
- Many fishing vessels and smaller craft voluntarily carry AIS

### AIS Message Types

AIS broadcasts several types of messages:

| Message Type | Content | Interval |
|-------------|---------|----------|
| Position Report (Class A) | MMSI, position, SOG, COG, heading, ROT | Every 2-10 sec (depending on speed/turning) |
| Position Report (Class B) | MMSI, position, SOG, COG | Every 30 sec |
| Static Data | Ship name, callsign, IMO number, ship type, dimensions | Every 6 min |
| Voyage Data | Destination, ETA, draught, cargo type | Every 6 min |
| Base Station Report | Position, UTC time | Every 10 sec |
| Safety Messages | Free-text safety information | As needed |

---

## Receiving AIS with RTL-SDR

### Hardware

Any RTL-SDR will receive AIS. No special antenna or filter is typically needed, though a VHF antenna will outperform the stock RTL-SDR antenna.

**Antenna recommendations**:
- The stock RTL-SDR dipole antenna works for nearby vessels.
- A marine VHF antenna (tuned for 156-162 MHz) is better.
- A discone antenna works well for general VHF/UHF reception including AIS.
- Height is critical — the higher the antenna, the further you can "see" (AIS is line-of-sight).

### Expected Range

| Setup | Range |
|-------|-------|
| Indoor, stock antenna | 5-15 nautical miles |
| Window/balcony, VHF antenna | 15-30 nm |
| Roof-mounted VHF antenna | 30-60+ nm |
| Hilltop with good antenna | 60-100+ nm |

Range depends on antenna height, terrain, and vessel transmit power (Class A: 12.5W, Class B: 2W).

---

## Software Options

### rtl-ais

A lightweight, dedicated AIS decoder for RTL-SDR.

#### Installation

```bash
# Dependencies
sudo apt install git build-essential librtlsdr-dev libusb-1.0-0-dev pkg-config

# Clone and build
git clone https://github.com/dgiardini/rtl-ais.git
cd rtl-ais
make
sudo make install
```

#### Usage

```bash
# Basic operation — decode AIS and output to console
rtl_ais

# Specify gain
rtl_ais -g 40

# Output NMEA sentences to a TCP port (for feeding to chart software)
rtl_ais -n -h 127.0.0.1 -P 10110

# Output to UDP
rtl_ais -l 10110
```

rtl-ais receives both AIS frequencies simultaneously by tuning the RTL-SDR to a center frequency between the two channels and using a wide enough bandwidth to capture both.

### AIS Decoder (aisdecoder)

Another lightweight decoder:

```bash
# Pipe rtl_fm output to aisdecoder
rtl_fm -f 162000000 -s 48000 -g 40 | aisdecoder -h 127.0.0.1 -p 10110 -a stdin -c mono -d -f /dev/stdin
```

### GNU AIS (gnuais)

```bash
sudo apt install gnuais
```

Uses the sound card or piped audio for AIS decoding.

### SDR# + AIS Plugin (Windows)

1. Run SDR# tuned to 162.000 MHz.
2. Use an AIS decoder plugin or pipe audio to a standalone AIS decoder.

### AIS-catcher

A modern, high-performance AIS decoder:

```bash
git clone https://github.com/jvde-github/AIS-catcher.git
cd AIS-catcher
mkdir build && cd build
cmake ..
make
sudo make install
```

```bash
# Run with RTL-SDR
AIS-catcher -d 0 -gr TUNER auto RTLAGC on
```

AIS-catcher includes a built-in web interface and can feed online AIS services.

---

## Displaying AIS Data on a Map

### OpenCPN (Recommended)

OpenCPN is a free, open-source chart plotter and navigation software that can display AIS targets on nautical charts.

#### Installation

```bash
# Ubuntu / Debian
sudo apt install opencpn

# Or download from opencpn.org
```

#### Configuring AIS Input

1. Open OpenCPN.
2. Go to **Options (wrench icon) > Connections**.
3. Click **Add Connection**.
4. Set:
   - **Type**: Network
   - **Protocol**: TCP or UDP
   - **Address**: 127.0.0.1 (if rtl-ais is on the same machine)
   - **Port**: 10110 (or whatever port rtl-ais is outputting to)
5. Click **OK**.
6. AIS targets will appear as triangles on the chart, with ship names and course/speed vectors.

### Ship Plotter

A Windows-based AIS display application. Commercial but popular.

### Web-Based Display

AIS-catcher and some other tools include built-in web interfaces that show AIS targets on a map without needing additional software.

### MarineTraffic / VesselFinder

You can feed your AIS data to online services:
- **MarineTraffic**: https://www.marinetraffic.com — provides a free station and visibility on their platform.
- **VesselFinder**: https://www.vesselfinder.com — similar feeder program.
- **AISHub**: https://www.aishub.net — community AIS data sharing network.

---

## NMEA Output Format

AIS decoders output standard **NMEA 0183** sentences. The most common AIS-related sentences:

```
!AIVDM,1,1,,A,13u@Dt002s000000000000000000,0*56
```

| Field | Description |
|-------|-------------|
| `!AIVDM` | AIS VDM sentence identifier |
| `1` | Fragment count (total fragments in multi-sentence message) |
| `1` | Fragment number |
| (empty) | Sequential message ID (for multi-fragment) |
| `A` | AIS channel (A=161.975, B=162.025) |
| `13u@Dt...` | Encoded AIS payload (6-bit ASCII) |
| `0` | Fill bits |
| `*56` | NMEA checksum |

The payload is decoded by AIS software to extract MMSI, position, speed, name, etc. You don't need to decode this manually — that is what the decoder software does.

---

## Practical Applications

### Coastal Monitoring

If you live near the coast, a harbor, or navigable waterways, an AIS receiver gives you real-time awareness of vessel traffic.

### Boating Safety

On your own vessel, a receive-only AIS setup (RTL-SDR + tablet running OpenCPN) provides collision avoidance information at minimal cost compared to a dedicated AIS receiver ($150-500).

### Emergency Awareness

Monitor vessel distress signals and safety broadcasts in your area.

### Hobbyist Interest

Track ship movements, identify vessels, monitor port activity, and log maritime traffic patterns.

---

## Multi-Function Setup

Since AIS uses the VHF band (near 162 MHz), and the RTL-SDR can only tune to one frequency range at a time, you need separate RTL-SDR dongles if you want to simultaneously receive:
- AIS (162 MHz)
- ADS-B (1090 MHz)
- Other signals

Each RTL-SDR dongle is inexpensive ($30), so running multiple dongles for different purposes is practical. On a Raspberry Pi, you can run ADS-B and AIS simultaneously with two dongles. Use `rtl_test -d 0` and `rtl_test -d 1` to identify them, and specify the device index in each application.
