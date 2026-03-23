# USB Stick Usage Guide

> How to use the Tech Survival USB stick for offline development and reference.

## Quick Start

1. Plug the USB stick into any computer
2. Open `START_HERE.html` in a web browser
3. Browse documentation, install tools, and work offline

## What's On This USB

### Authored Documentation (`docs/`)

All files in the `docs/` folder are Markdown (`.md`) files. You can read them with:

- **Any text editor** (Notepad, nano, vim)
- **VS Code** (from `build/editors/vscode/`) — best experience with preview
- **A web browser** with a Markdown extension
- **START_HERE.html** has links to all major sections

### Mirrored External Docs (`build/docs/`)

Offline copies of official documentation:

| Folder | Contents |
|---|---|
| `build/docs/python/` | Python 3.12 official docs (HTML) |
| `build/docs/nodejs/` | Node.js 20 API reference |
| `build/docs/arduino/` | Arduino language reference |
| `build/docs/esp-idf/` | ESP-IDF programming guide (PDF + examples) |
| `build/docs/meshtastic/` | Meshtastic documentation source |
| `build/docs/devdocs/` | DevDocs self-hosted (requires Ruby to run) |

### Toolchains (`build/toolchains/`)

| Folder | Contents |
|---|---|
| `build/toolchains/arduino-ide/` | Arduino IDE portable (Windows zip + Linux AppImage) |
| `build/toolchains/esp-idf/` | ESP-IDF framework + Windows offline installer |
| `build/toolchains/platformio/` | PlatformIO installer script + instructions |

**Arduino IDE (Windows)**:
1. Extract `arduino-ide_*_Windows_64bit.zip`
2. Run `Arduino IDE.exe`
3. Install ESP32 board package from Tools → Board Manager (or use bundled if available)

**Arduino IDE (Linux)**:
```bash
chmod +x arduino-ide_*_Linux_64bit.AppImage
./arduino-ide_*_Linux_64bit.AppImage
```

### Editors (`build/editors/`)

**VS Code Portable**:
1. Extract the archive for your OS
2. Create a `data` folder inside the extracted directory (enables portable mode)
3. Install extensions from VSIX files in `build/editors/vscode/extensions/`:
   - In VS Code: Ctrl+Shift+P → "Install from VSIX..."

### SDR Software (`build/sdr/`)

| Folder | Platform | Description |
|---|---|---|
| `sdrsharp/` | Windows | SDR# receiver — extract and run |
| `gqrx/` | Linux | GQRX AppImage — chmod +x and run |
| `cubicsdr/` | Cross-platform | CubicSDR receiver |
| `gnuradio/` | Win/Linux | GNU Radio (radioconda installer for Windows) |
| `rtl-sdr/` | Win/Linux | RTL-SDR drivers and command-line tools |
| `dump1090/` | Linux | ADS-B aircraft decoder (build from source) |
| `rtl_433/` | Win/Linux | ISM band device decoder |

### Radio Software (`build/radio/`)

- **CHIRP**: Radio programming software (installer + Python wheel)
- **chirp-frequencies.csv**: Pre-built frequency list for Baofeng/JucJet radios
- **CH341SER.EXE**: CH340 USB-serial driver for programming cables

### Datasheets (`build/datasheets/`)

PDF datasheets for common components (ESP32, SX1276, AXP2101, BME280, etc.)

### Cached Packages (`build/packages/`)

#### npm (Node.js) packages

```bash
# Install from cached packages
npm install --cache /path/to/usb/build/packages/npm/ <package-name>

# Or copy the cache to your local npm cache
cp -r /path/to/usb/build/packages/npm/* ~/.npm/_cacache/
```

#### pip (Python) packages

```bash
# Install from cached packages
pip install --no-index --find-links /path/to/usb/build/packages/pip/ <package-name>

# Install all available packages
pip install --no-index --find-links /path/to/usb/build/packages/pip/ \
    esptool pyserial flask meshtastic platformio
```

### Docker Images (`build/docker/`)

Pre-pulled Docker images saved as tar files:

```bash
# Load an image
docker load < /path/to/usb/build/docker/node-20-alpine.tar
docker load < /path/to/usb/build/docker/python-3.12-slim.tar
docker load < /path/to/usb/build/docker/eclipse-mosquitto-latest.tar

# Verify loaded images
docker images

# Run
docker run -it node:20-alpine sh
docker run -it python:3.12-slim bash
docker run -d -p 1883:1883 eclipse-mosquitto:latest
```

## Configuration Files (`config/`)

| File | Purpose |
|---|---|
| `chirp-frequencies.csv` | Import into CHIRP for Baofeng programming |
| `meshtastic-presets.yaml` | Meshtastic configuration presets for different roles |
| `packages-npm.txt` | List of cached npm packages |
| `packages-pip.txt` | List of cached pip packages |
| `docker-images.txt` | List of cached Docker images |
| `datasheets.txt` | Datasheet source URLs |

## Verifying USB Integrity

After copying or if you suspect file corruption:

```bash
cd /path/to/usb
bash scripts/verify-usb.sh /path/to/usb
```

This checks SHA256 checksums of all files against `MANIFEST.txt`.

## Updating the USB

To refresh the USB with latest downloads:

```bash
# On an internet-connected machine with this repo cloned:
cd offgrid_electronics
make all          # Download everything fresh
make usb USB=/mnt/e   # Copy to USB (full version)
# or
make usb-lite USB=/mnt/e  # Without Docker images
```

## Tips

- **Back up the USB** — copy the entire contents to a hard drive as a backup
- **Multiple copies** — keep one USB at home, one in your go-bag, one at a friend's
- **Check dates** — software versions become outdated; rebuild periodically
- **Test offline** — disconnect from internet and verify you can actually use the tools
- **USB speed matters** — use USB 3.0+ drives for much faster access to large files
- **File system** — format as exFAT for cross-platform compatibility (Windows + Linux + Mac)
