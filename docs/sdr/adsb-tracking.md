# ADS-B Aircraft Tracking

## What Is ADS-B?

ADS-B (Automatic Dependent Surveillance-Broadcast) is a system where aircraft automatically broadcast their GPS-derived position, altitude, speed, heading, and identification at regular intervals on **1090 MHz**. Since January 2020, ADS-B Out is mandatory for most aircraft operating in controlled airspace in the US.

With an RTL-SDR and appropriate software, you can receive and decode these broadcasts to track aircraft in real-time on a map — essentially building your own flight tracker.

### What ADS-B Provides

Each ADS-B message can include:
- **ICAO hex address**: Unique aircraft identifier
- **Callsign/flight number** (e.g., UAL123)
- **Position**: Latitude and longitude
- **Altitude**: Barometric and/or GNSS altitude
- **Ground speed and heading**
- **Vertical rate** (climb/descent)
- **Squawk code** (transponder code)
- **Aircraft category** (light, large, heavy, rotorcraft, etc.)

### ADS-B Frequencies

| Frequency | Protocol | Notes |
|-----------|----------|-------|
| **1090 MHz** | Mode S / ADS-B (Extended Squitter) | Primary. All ADS-B traffic. |
| 978 MHz | UAT (Universal Access Transceiver) | US only. Used by some general aviation below 18,000 ft. |

---

## Hardware Setup

### RTL-SDR

Any RTL-SDR will work for ADS-B. The RTL-SDR Blog V3/V4 is an excellent choice.

### Antenna

The stock RTL-SDR antenna is not great at 1090 MHz. Better options:

| Antenna | Performance | Cost |
|---------|-------------|------|
| Stock RTL-SDR whip | Minimal range | Included |
| DIY quarter-wave (6.8 cm wire) | Moderate improvement | Free |
| RTL-SDR Blog ADS-B antenna | Good, purpose-built | ~$10 |
| FlightAware ProStick antenna | Good | ~$15 |
| DIY collinear (8 segments) | Very good | ~$5 in materials |
| Commercial 1090 MHz collinear | Excellent | $30-60 |

### Bandpass Filter

A 1090 MHz bandpass filter dramatically improves performance by rejecting strong out-of-band signals (cell towers, FM broadcast) that overload the RTL-SDR's front-end:

- **RTL-SDR Blog ADS-B Triple Filtered LNA**: Combined LNA + filter, powered by bias-T. Excellent. ~$25.
- **FlightAware ProStick Plus**: RTL-SDR dongle with built-in 1090 MHz filter and LNA. ~$30.
- **Generic 1090 MHz SAW filter**: Available on Amazon/eBay. ~$10-15.

### Ideal Setup

```
[1090 MHz Antenna] → [Bandpass Filter/LNA] → [Short Coax] → [RTL-SDR] → [Computer]
```

Place the antenna outdoors (or in a window) as high as possible with clear sky view. ADS-B is line-of-sight — higher antenna = more aircraft seen at greater distances.

---

## dump1090 — The Core Decoder

dump1090 is the most popular ADS-B decoder for RTL-SDR. Several forks exist.

### Recommended Forks

| Fork | Description |
|------|-------------|
| **dump1090-mutability** | Widely used, good web interface |
| **dump1090-fa** | FlightAware's fork. Optimized, integrated with their feeder. |
| **readsb** | Modern successor to dump1090-mutability. Active development. Recommended. |

### Installing readsb (Recommended)

```bash
# Dependencies
sudo apt install git build-essential debhelper librtlsdr-dev pkg-config \
  libncurses-dev zlib1g-dev libusb-1.0-0-dev

# Clone and build
git clone https://github.com/wiedehopf/readsb.git
cd readsb
dpkg-buildpackage -b --no-sign
cd ..
sudo dpkg -i readsb_*.deb
```

Or use the automated installer script:
```bash
sudo bash -c "$(wget -O - https://github.com/wiedehopf/adsb-scripts/raw/master/readsb-install.sh)"
```

### Installing dump1090-fa (FlightAware)

```bash
# Add FlightAware repository
wget https://flightaware.com/adsb/piaware/files/packages/pool/piaware/f/flightaware-apt-repository/flightaware-apt-repository_1.2_all.deb
sudo dpkg -i flightaware-apt-repository_1.2_all.deb
sudo apt update
sudo apt install dump1090-fa
```

### Running dump1090 Manually

```bash
# Basic operation with web server
dump1090-mutability --net --interactive

# Or with readsb
readsb --net --interactive --device-type rtlsdr
```

### Command-Line Options

```bash
dump1090 --net            # Enable network output (required for web interface)
         --interactive    # Show interactive text display of aircraft
         --gain 49.6      # Set gain (max for best ADS-B reception)
         --ppm 0          # Frequency correction
         --lat 40.7128    # Your latitude (for distance calculations)
         --lon -74.0060   # Your longitude
         --max-range 360  # Maximum range in nautical miles
```

---

## Web Interface

dump1090/readsb includes a built-in web server showing aircraft on a map.

### Default URL

```
http://localhost:8080
```

Or on the local network:
```
http://RASPBERRY_PI_IP:8080
```

### What You See

- **Map**: Aircraft positions plotted on OpenStreetMap tiles.
- **Aircraft list**: Table showing ICAO hex, callsign, altitude, speed, distance, bearing, RSSI.
- **Tracks**: Lines showing aircraft flight paths.
- **Statistics**: Message rate, aircraft count, range rings.

### tar1090 — Improved Web Interface

tar1090 is a significantly improved web interface for readsb/dump1090:

```bash
sudo bash -c "$(wget -O - https://github.com/wiedehopf/tar1090/raw/master/install.sh)"
```

Features:
- Faster map rendering
- Better aircraft trail persistence
- Heatmap of aircraft coverage
- Range outline showing your receiver's coverage
- Historical playback
- Shareable aircraft links

Access at: `http://localhost/tar1090`

---

## Feeding Online Services

You can share your ADS-B data with online flight tracking services. In return, you typically get a free premium account.

### FlightAware (PiAware)

```bash
sudo apt install piaware
sudo piaware-config feeder-id YOUR_FEEDER_ID
sudo systemctl restart piaware
```

- Sign up at https://flightaware.com/adsb/piaware/
- Claim your feeder for a free Enterprise account.

### Flightradar24

```bash
sudo bash -c "$(wget -O - https://repo-feed.flightradar24.com/install_fr24_rpi.sh)"
```

- Follow the setup wizard.
- Get a free Business account.

### ADS-B Exchange

Open, unfiltered ADS-B data aggregation (no military filtering).

```bash
sudo bash -c "$(wget -O - https://github.com/wiedehopf/adsb-scripts/raw/master/feed-adsbx.sh)"
```

### Multiple Feeders

You can feed all services simultaneously. Each feeder reads from dump1090/readsb's network output (Beast protocol on port 30005) and forwards data independently.

---

## Typical Performance

| Setup | Aircraft Seen | Range |
|-------|--------------|-------|
| Indoor, stock antenna | 20-50 | 30-50 nm |
| Window-mounted, basic antenna | 50-100 | 50-100 nm |
| Outdoor, collinear + filter | 100-200+ | 100-200 nm |
| Roof-mounted, LNA + filter | 200-400+ | 150-250+ nm |

Range depends heavily on antenna placement (height and sky visibility), local terrain, and whether you use a bandpass filter and LNA.

---

## 978 MHz UAT (US Only)

Some US general aviation aircraft below 18,000 feet use 978 MHz UAT instead of 1090 MHz. To receive both:

- Use two RTL-SDR dongles (one tuned to 1090, one to 978).
- dump978 decodes UAT signals: https://github.com/flightaware/dump978

```bash
sudo apt install dump978-fa
```

---

## Data Output Formats

dump1090/readsb provides data in several formats:

| Port | Protocol | Use |
|------|----------|-----|
| 30001 | Raw (hex) | Legacy raw output |
| 30002 | Raw (hex) | Legacy raw input |
| 30003 | SBS/BaseStation | CSV format for logging/analysis tools |
| 30005 | Beast binary | Standard feeder format. Most feeders connect here. |
| 8080 | HTTP | Web interface and JSON API |

### JSON API

```bash
# Get all aircraft currently being tracked
curl http://localhost:8080/data/aircraft.json
```

Returns a JSON array of aircraft with position, altitude, speed, etc. Useful for building custom dashboards or alerts.

---

## DIY ADS-B Antenna

### Simple Quarter-Wave Ground Plane

Materials: A piece of wire, an SMA connector or coax.

1. Cut a wire to **6.8 cm** (quarter wavelength at 1090 MHz).
2. Solder to the center pin of an SMA connector (or the center conductor of your coax).
3. Add 3-4 ground plane radials (also 6.8 cm each) connected to the ground/shield, angled downward at about 45 degrees.
4. Mount vertically with the main element pointing up.

### Collinear Antenna (Higher Gain)

A coaxial collinear antenna made from coax cable provides about 5-6 dBi gain:

1. Use RG-6 or RG-58 coax.
2. Cut 8 segments of coax, each **130mm** long (half wavelength in coax at 1090 MHz, accounting for velocity factor).
3. Connect them with alternating shield-to-center connections (each segment reverses the phase).
4. Place vertically in a PVC pipe for weather protection.

Many guides are available online with detailed construction instructions. Search for "coaxial collinear 1090 antenna."

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No aircraft seen | Check antenna connection. Increase gain to max. Try different USB port. |
| Very few aircraft | Antenna placement is key. Move to window or outdoor. Add bandpass filter. |
| "No device found" | RTL-SDR drivers not installed. See rtl-sdr-setup.md. |
| Messages but no positions | Some Mode S messages do not contain position. Ensure you are receiving extended squitter (ES) messages. More messages = more positions. |
| Poor range | Antenna height and sky visibility are the dominant factors. Even a simple antenna on a roof outperforms a great antenna indoors. |
| CPU issues on Raspberry Pi | Use readsb (optimized). Reduce web interface update rate. |
