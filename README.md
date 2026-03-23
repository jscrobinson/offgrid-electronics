# Offgrid Electronics — Tech Survival USB Stick

A comprehensive offline documentation and tooling repository for electronics development, radio communications, and mesh networking. Everything you need to keep building when the internet goes dark.

## What's Inside

- **Hardware References** — Raspberry Pi, Arduino, ESP32, LoRa (T-Beam 1.2, Heltec V3), displays, sensors
- **Electronics Fundamentals** — Components, circuits, soldering, test equipment
- **Communication Protocols** — I2C, SPI, UART, MQTT, Modbus
- **Radio & SDR** — Amateur radio, Baofeng/JucJet programming, CHIRP, RTL-SDR, SDR#, GQRX, GNU Radio
- **Mesh Networking** — Meshtastic setup and configuration for T-Beam and Heltec
- **Power Systems** — Batteries, solar charging, power calculations
- **Programming** — Python, MicroPython, Node.js, C/C++ embedded, bash
- **Networking** — IP, WiFi AP mode, SSH, WireGuard
- **Offline Toolchains** — Arduino IDE, ESP-IDF, PlatformIO, VS Code portable
- **Cached Packages** — npm and pip packages for offline installs
- **Docker Images** — Node, Python, Mosquitto, Portainer (saved as .tar)
- **SDR Software** — SDR#, GQRX, CubicSDR, GNU Radio, rtl_433, dump1090

## Quick Start

```bash
# Build everything (requires internet)
make all

# Copy to USB (64 GB recommended)
make usb USB=/mnt/e

# Lite version without Docker images (fits 32 GB)
make usb-lite USB=/mnt/e

# Verify USB integrity
make verify USB=/mnt/e

# Check total size
make size
```

## Recommended USB: 64 GB

| Category | Est. Size |
|---|---|
| Authored markdown docs | ~5 MB |
| Mirrored docs | ~500 MB |
| DevDocs offline bundle | ~2 GB |
| Docker images | ~8-12 GB |
| Toolchains | ~2.5 GB |
| VS Code portable + extensions | ~500 MB |
| npm/pip packages | ~3-8 GB |
| Datasheets | ~500 MB |
| SDR software | ~1-2 GB |
| CHIRP + radio files | ~100 MB |
| **Total** | **~20-30 GB** |

## Using the USB Offline

Plug in the USB and open `START_HERE.html` in any browser. See `docs/survival/usb-stick-usage-guide.md` for full instructions.

## Building

Requires: bash, curl, wget, git, docker (optional), npm (optional), pip (optional)

```bash
# Mirror documentation only
make docs mirror

# Download toolchains and editors
make toolchains editors

# Download SDR software
make sdr

# Download Docker images (optional, ~10 GB)
make docker

# Cache npm/pip packages
make packages
```

## License

MIT
