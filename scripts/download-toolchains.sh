#!/bin/bash
# download-toolchains.sh — Download Arduino IDE, ESP-IDF, and PlatformIO for offline use
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Downloading Toolchains"

require_cmd curl

TC_DIR=$(ensure_build_dir "toolchains")

# --- Arduino IDE ---
log_info "Downloading Arduino IDE..."
ARDUINO_DIR="${TC_DIR}/arduino-ide"
mkdir -p "$ARDUINO_DIR"

ARDUINO_VERSION="2.3.4"

# Windows
download_file \
    "https://downloads.arduino.cc/arduino-ide/arduino-ide_${ARDUINO_VERSION}_Windows_64bit.zip" \
    "${ARDUINO_DIR}/arduino-ide_${ARDUINO_VERSION}_Windows_64bit.zip" \
    "Arduino IDE ${ARDUINO_VERSION} (Windows 64-bit)"

# Linux
download_file \
    "https://downloads.arduino.cc/arduino-ide/arduino-ide_${ARDUINO_VERSION}_Linux_64bit.AppImage" \
    "${ARDUINO_DIR}/arduino-ide_${ARDUINO_VERSION}_Linux_64bit.AppImage" \
    "Arduino IDE ${ARDUINO_VERSION} (Linux AppImage)"

# --- ESP-IDF ---
log_info "Downloading ESP-IDF..."
ESPIDF_DIR="${TC_DIR}/esp-idf"
mkdir -p "$ESPIDF_DIR"

ESP_IDF_VERSION="v5.2.1"

# Download ESP-IDF release archive (faster than git clone for offline use)
download_file \
    "https://github.com/espressif/esp-idf/releases/download/${ESP_IDF_VERSION}/esp-idf-${ESP_IDF_VERSION}.zip" \
    "${ESPIDF_DIR}/esp-idf-${ESP_IDF_VERSION}.zip" \
    "ESP-IDF ${ESP_IDF_VERSION}"

# ESP-IDF Windows installer
download_file \
    "https://dl.espressif.com/dl/idf-installer/esp-idf-tools-setup-offline-${ESP_IDF_VERSION}.exe" \
    "${ESPIDF_DIR}/esp-idf-tools-setup-offline-${ESP_IDF_VERSION}.exe" \
    "ESP-IDF Tools Installer (Windows offline)" || \
    log_warn "ESP-IDF offline installer not found — may need online install"

cat > "${ESPIDF_DIR}/INSTALL.md" << 'INSTALLEOF'
# ESP-IDF Installation

## Windows (Recommended: Offline Installer)
1. Run `esp-idf-tools-setup-offline-*.exe`
2. Follow the wizard — it installs ESP-IDF, toolchain, and tools

## Windows/Linux/macOS (Manual)
1. Extract `esp-idf-*.zip`
2. Run: `./install.sh esp32,esp32s3,esp32c3`
3. Source the environment: `. ./export.sh`
4. Verify: `idf.py --version`

## Key commands
- `idf.py set-target esp32`  — select target chip
- `idf.py menuconfig`        — configure project
- `idf.py build`              — compile
- `idf.py flash`              — flash to device
- `idf.py monitor`            — serial monitor
INSTALLEOF

# --- PlatformIO ---
log_info "Setting up PlatformIO offline installer..."
PIO_DIR="${TC_DIR}/platformio"
mkdir -p "$PIO_DIR"

cat > "${PIO_DIR}/INSTALL.md" << 'PIOEOF'
# PlatformIO Installation

PlatformIO is installed via pip (Python package manager).

## Quick Install (requires Python 3.6+)
```bash
pip install platformio
# or from cached packages:
pip install --no-index --find-links ../packages/pip/ platformio
```

## VS Code Extension
1. Open VS Code
2. Extensions → Search "PlatformIO IDE"
3. Install

## CLI Usage
```bash
pio init --board esp32dev          # Initialize ESP32 project
pio run                             # Build
pio run --target upload             # Flash
pio device monitor                  # Serial monitor
pio lib install "RadioLib"          # Install library
```

## Offline: Pre-download platforms and packages
```bash
# These are cached automatically after first use in ~/.platformio/
# To pre-populate, run on an online machine:
pio pkg install -p espressif32
pio pkg install -p atmelavr
```
PIOEOF

# Download PlatformIO installer script
download_file \
    "https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py" \
    "${PIO_DIR}/get-platformio.py" \
    "PlatformIO installer script"

echo ""
log_ok "Toolchains download complete!"
log_info "Total toolchains size: $(dir_size "$TC_DIR")"

for d in "${TC_DIR}"/*/; do
    [[ -d "$d" ]] && echo "  $(basename "$d"): $(dir_size "$d")"
done
