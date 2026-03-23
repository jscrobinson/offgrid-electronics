# USB Stick Usage Guide

How to use the Tech Survival USB stick for offline development and reference.

---

## Quick Start

1. **Plug in the USB stick** to any computer (Windows, Mac, or Linux)
2. **Open `START_HERE.html`** in any web browser — this is the main entry point
3. Browse the documentation, tools, and resources from there

No internet connection required. Everything on this drive works offline.

---

## Directory Structure

```
USB Root/
|
+-- START_HERE.html          <-- Open this first (main index page)
|
+-- docs/                    <-- Markdown documentation (source)
|   +-- hardware/
|   |   +-- displays/        -- E-ink, OLED, TFT display guides
|   |   +-- peripherals/     -- Sensors, relays, motors, GPS, cameras
|   |   +-- platforms/       -- Raspberry Pi, ESP32, Arduino, LoRa boards
|   |   +-- power/           -- Batteries, regulators, solar charging
|   +-- mesh-networking/     -- Meshtastic, LoRa mesh, Reticulum
|   +-- networking/          -- WiFi, SSH, VPN, DNS, IP networking
|   +-- programming/         -- Git, regex, Python, C/C++, shell scripting
|   +-- survival/            -- Solar setups, enclosures, field repair
|
+-- build/
|   +-- docs/                <-- Rendered HTML docs (mirrored from docs/)
|   |   +-- ...              -- Same structure as docs/ but as HTML pages
|   |                          with navigation, search, and styling
|   |
|   +-- toolchains/          <-- Development tools and IDEs
|       +-- arduino/         -- Arduino IDE (portable)
|       +-- platformio/      -- PlatformIO core
|       +-- esptool/         -- ESP32 flash tool
|       +-- python/          -- Python portable distribution
|       +-- editors/         -- VS Code portable / other editors
|
+-- firmware/                <-- Pre-built firmware images
|   +-- meshtastic/          -- Meshtastic firmware for various boards
|   +-- tasmota/             -- Tasmota firmware for ESP devices
|   +-- esphome/             -- ESPHome base images
|
+-- docker/                  <-- Docker images (tar archives)
|   +-- README.md            -- Instructions for loading images
|   +-- *.tar               -- Docker image archives
|
+-- packages/                <-- Offline package repositories
|   +-- pip/                 -- Python packages (wheels)
|   +-- npm/                 -- Node.js packages (tarballs)
|   +-- apt/                 -- Debian packages (for Pi)
|
+-- datasheets/              <-- Component datasheets (PDF)
|   +-- esp32/
|   +-- sensors/
|   +-- lora/
|   +-- power/
|
+-- scripts/                 <-- Utility scripts
    +-- setup-offline-pip.sh -- Configure pip for offline install
    +-- setup-offline-npm.sh -- Configure npm for offline install
    +-- verify-integrity.sh  -- Check file integrity (SHA256)
    +-- flash-firmware.sh    -- Helper for flashing firmware
```

---

## Reading Documentation

### Markdown Files (docs/)

The `docs/` directory contains all documentation as Markdown (.md) files. These can be read:

1. **Directly in any text editor** — Markdown is plain text and fully readable as-is
2. **In a Markdown viewer** — VS Code, Typora, or any Markdown-capable editor
3. **In a terminal** — `cat`, `less`, or `glow` (if installed)
4. **On GitHub** — If you upload to a repo, GitHub renders Markdown automatically

### Rendered HTML (build/docs/)

The `build/docs/` directory contains the same documentation pre-rendered as HTML pages with:
- Navigation sidebar
- Search functionality
- Clickable table of contents
- Syntax-highlighted code blocks
- Works in any web browser, no server needed

**To browse:** Open `build/docs/index.html` in your browser, or start from `START_HERE.html`.

---

## Using Development Toolchains

### Arduino IDE (Portable)

```bash
# Linux/Mac
cd build/toolchains/arduino/
./arduino-ide

# Windows
cd build\toolchains\arduino\
arduino-ide.exe
```

The portable installation includes:
- Board packages for ESP32, Arduino AVR
- Common libraries pre-installed
- Example sketches

### PlatformIO

```bash
# If Python is available on the system:
cd build/toolchains/platformio/
pip install --no-index --find-links=. platformio

# Or use the bundled Python:
cd build/toolchains/python/
./python -m pip install --no-index --find-links=../platformio platformio
```

### esptool (ESP32 Flash Utility)

```bash
cd build/toolchains/esptool/

# Flash firmware
python esptool.py --chip esp32 --port /dev/ttyUSB0 write_flash 0x0 firmware.bin

# Erase flash
python esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash

# Read flash info
python esptool.py --chip esp32 --port /dev/ttyUSB0 flash_id
```

---

## Docker Images

Pre-built Docker images are stored as tar archives.

### Loading an Image

```bash
# Load image from tar file
docker load -i docker/image-name.tar

# Verify it loaded
docker images

# Run the container
docker run -d --name mycontainer loaded-image-name
```

### Available Images

Check `docker/README.md` for the list of included images and their intended use.

---

## Offline Package Installation

### Python (pip)

```bash
# Option 1: Use the setup script
bash scripts/setup-offline-pip.sh

# Option 2: Manual
pip install --no-index --find-links=packages/pip/ package-name

# Install all available packages
pip install --no-index --find-links=packages/pip/ -r packages/pip/requirements.txt

# Example: Install a specific package
pip install --no-index --find-links=packages/pip/ flask
```

### Node.js (npm)

```bash
# Option 1: Use the setup script
bash scripts/setup-offline-npm.sh

# Option 2: Manual install from tarball
npm install packages/npm/package-name-1.0.0.tgz

# Install from a local registry mirror
npm install --registry=file://$(pwd)/packages/npm/registry package-name
```

### Debian/Raspberry Pi (apt)

```bash
# Copy packages to Pi
scp -r packages/apt/ pi@raspberrypi:/tmp/

# On the Pi, install from local packages
sudo dpkg -i /tmp/apt/*.deb

# Or set up a local apt repository
# (see packages/apt/README.md for details)
```

---

## Verifying File Integrity

The USB drive includes SHA256 checksums to verify no files have been corrupted.

```bash
# Run the verification script
bash scripts/verify-integrity.sh

# Or manually check specific files
sha256sum -c checksums.sha256

# Generate new checksums (if you modify files)
find . -type f -not -path '*/\.*' -exec sha256sum {} \; > checksums.sha256
```

### What Corruption Looks Like

- Documents won't open or show garbled text
- Firmware files fail to flash with "invalid header" or checksum errors
- Archives fail to extract
- HTML pages are partially rendered

If files are corrupted, check if you have a backup of the USB drive. Flash drives can develop bad sectors over time — consider refreshing the drive annually.

---

## Flashing Firmware

### Meshtastic

```bash
# Using the helper script
bash scripts/flash-firmware.sh meshtastic tbeam

# Or manually with esptool
cd firmware/meshtastic/
python ../../build/toolchains/esptool/esptool.py \
    --chip esp32 \
    --port /dev/ttyUSB0 \
    --baud 921600 \
    write_flash 0x1000 firmware-tbeam-*.bin
```

### Tasmota

```bash
# Using esptool
cd firmware/tasmota/
python ../../build/toolchains/esptool/esptool.py \
    --chip esp8266 \
    --port /dev/ttyUSB0 \
    write_flash -fs 1MB 0x0 tasmota.bin
```

Check the README.md in each firmware directory for board-specific flashing instructions.

---

## Tips for Using This USB Drive

### Performance

- **Copy to local disk first** if you'll be reading docs heavily — USB read speeds can be slow, especially on USB 2.0 ports
- **Don't run tools directly from the USB** if possible — copy toolchains to your local disk for better performance
- **Use a USB 3.0 port** if available for much faster access

### Maintenance

- **Keep a backup** — Copy the entire USB contents to a hard drive
- **Update periodically** — When internet is available, check for updated firmware and documentation
- **Check drive health** — USB flash drives have limited write cycles. Run `badblocks` (Linux) periodically
- **Write-protect if possible** — Some USB drives have a physical write-protect switch. Enable it to prevent accidental modification

### Sharing

- **This drive is meant to be copied** — Share the contents freely
- **Create multiple copies** — In emergency/disaster scenarios, distribute copies to team members
- **Keep one master copy** — Maintain one unmodified copy as the source of truth

### Offline Search

If the HTML docs have a search feature:
1. Open `build/docs/index.html`
2. Use the search bar at the top
3. Search works entirely offline (client-side JavaScript)

If searching Markdown files directly:
```bash
# Search across all docs
grep -r "search term" docs/

# Search with context
grep -r -n -C 2 "BME280" docs/

# Find files by name
find docs/ -name "*.md" | xargs grep -l "solar"
```

---

## What's NOT on This USB

This USB focuses on practical offline reference material. It does **not** include:
- Full operating system ISOs (too large — download separately when needed)
- Complete language documentation (Python docs, MDN, etc.)
- Video tutorials
- Large datasets or machine learning models
- Proprietary software

For full OS images, use the Raspberry Pi Imager (if available) or download from official sources when internet access is available.

---

## Troubleshooting

| Problem                          | Solution                                         |
|----------------------------------|--------------------------------------------------|
| USB not detected                 | Try different port, check if drive letter appears |
| Files appear corrupted           | Run verify-integrity.sh, try different USB port   |
| HTML pages don't render properly | Open in Chrome/Firefox, not IE                    |
| Can't run scripts (permission)   | `chmod +x scripts/*.sh`                          |
| Python tools won't run           | Check Python version: `python3 --version`         |
| esptool can't find device        | Check USB cable (data, not charge-only), install drivers |
| "Disk is write-protected"        | Check physical switch on USB, or try reformatting |
