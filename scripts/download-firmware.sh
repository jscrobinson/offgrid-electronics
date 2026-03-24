#!/bin/bash
# download-firmware.sh — Download firmware images for offline flashing
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Downloading Firmware"

require_cmd curl

FW_DIR=$(ensure_build_dir "firmware")

# --- Meshtastic ---
section "Meshtastic Firmware"
MESH_DIR="${FW_DIR}/meshtastic"
mkdir -p "$MESH_DIR"

log_info "Fetching latest Meshtastic firmware release..."
MESH_RELEASE=$(curl -fsSL "https://api.github.com/repos/meshtastic/firmware/releases/latest" 2>/dev/null || echo "{}")
MESH_TAG=$(echo "$MESH_RELEASE" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4 || true)

if [[ -n "$MESH_TAG" ]]; then
    log_info "Latest Meshtastic firmware: $MESH_TAG"

    # Download the main firmware zip (contains all board variants)
    FW_URL=$(echo "$MESH_RELEASE" | grep -o '"browser_download_url": *"[^"]*firmware[^"]*\.zip"' | head -1 | cut -d'"' -f4 || true)
    if [[ -n "$FW_URL" ]]; then
        download_file "$FW_URL" "${MESH_DIR}/$(basename "$FW_URL")" "Meshtastic firmware ${MESH_TAG}"
    fi

    # Also grab the web flasher UF2/bin files for common boards
    for pattern in "tbeam" "heltec-v3" "t-echo" "rak4631" "station-g2"; do
        URL=$(echo "$MESH_RELEASE" | grep -o "\"browser_download_url\": *\"[^\"]*${pattern}[^\"]*\"" | head -1 | cut -d'"' -f4 || true)
        if [[ -n "$URL" ]]; then
            download_file "$URL" "${MESH_DIR}/$(basename "$URL")" "Meshtastic ${pattern}"
        fi
    done
else
    log_warn "Could not determine latest Meshtastic release"
fi

# Save release notes
if [[ -n "${MESH_TAG:-}" ]]; then
    echo "$MESH_RELEASE" | grep -o '"body": *"[^"]*"' | head -1 | cut -d'"' -f4 \
        > "${MESH_DIR}/RELEASE_NOTES.txt" 2>/dev/null || true
    echo "$MESH_TAG" > "${MESH_DIR}/VERSION.txt"
fi

# --- Meshtastic Python CLI (for flashing) ---
log_info "Downloading Meshtastic Python flasher..."
download_file \
    "https://github.com/meshtastic/python/archive/refs/heads/master.tar.gz" \
    "${MESH_DIR}/meshtastic-python-master.tar.gz" \
    "Meshtastic Python CLI source" || true

# --- ESPHome ---
section "ESPHome"
ESPHOME_DIR="${FW_DIR}/esphome"
mkdir -p "$ESPHOME_DIR"

cat > "${ESPHOME_DIR}/README.md" << 'EOF'
# ESPHome Offline

ESPHome generates firmware from YAML config files.

## Offline Usage
1. Install from cached pip packages:
   ```
   pip install --no-index --find-links ../../packages/pip/ esphome
   ```
2. Compile your YAML config:
   ```
   esphome compile my-device.yaml
   ```
3. Flash:
   ```
   esphome upload my-device.yaml
   ```

## Pre-compiled Binaries
ESPHome compiles firmware per-device from YAML, so pre-built binaries
aren't practical. Instead, ensure the esphome pip package and its
dependencies (platformio, etc.) are cached in packages/pip/.
EOF

# --- esptool ---
section "esptool"
ESPTOOL_DIR="${FW_DIR}/esptool"
mkdir -p "$ESPTOOL_DIR"

ESPTOOL_RELEASE=$(curl -fsSL "https://api.github.com/repos/espressif/esptool/releases/latest" 2>/dev/null || echo "{}")
ESPTOOL_TAG=$(echo "$ESPTOOL_RELEASE" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4 || true)

if [[ -n "$ESPTOOL_TAG" ]]; then
    log_info "Latest esptool: $ESPTOOL_TAG"

    # Windows standalone
    WIN_URL=$(echo "$ESPTOOL_RELEASE" | grep -o '"browser_download_url": *"[^"]*win64[^"]*\.zip"' | head -1 | cut -d'"' -f4 || true)
    if [[ -n "$WIN_URL" ]]; then
        download_file "$WIN_URL" "${ESPTOOL_DIR}/$(basename "$WIN_URL")" "esptool Windows"
    fi

    # Linux standalone
    LINUX_URL=$(echo "$ESPTOOL_RELEASE" | grep -o '"browser_download_url": *"[^"]*linux-amd64[^"]*\.zip"' | head -1 | cut -d'"' -f4 || true)
    if [[ -n "$LINUX_URL" ]]; then
        download_file "$LINUX_URL" "${ESPTOOL_DIR}/$(basename "$LINUX_URL")" "esptool Linux"
    fi

    # macOS standalone
    MAC_URL=$(echo "$ESPTOOL_RELEASE" | grep -o '"browser_download_url": *"[^"]*macos[^"]*\.zip"' | head -1 | cut -d'"' -f4 || true)
    if [[ -n "$MAC_URL" ]]; then
        download_file "$MAC_URL" "${ESPTOOL_DIR}/$(basename "$MAC_URL")" "esptool macOS"
    fi
fi

cat > "${ESPTOOL_DIR}/README.md" << 'EOF'
# esptool — ESP32 Flash Utility

## Usage
```bash
# Erase flash
esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash

# Flash firmware
esptool.py --chip esp32 --port /dev/ttyUSB0 write_flash 0x0 firmware.bin

# Flash Meshtastic (ESP32, typical offsets)
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 \
  write_flash 0x1000 firmware.bin

# For ESP32-S3 (Heltec V3)
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
  write_flash 0x0 firmware.bin

# Read chip info
esptool.py --port /dev/ttyUSB0 chip_id
esptool.py --port /dev/ttyUSB0 flash_id
```

## Install from pip (alternative to standalone)
```bash
pip install --no-index --find-links ../../packages/pip/ esptool
```
EOF

echo ""
log_ok "Firmware downloads complete!"
log_info "Total firmware size: $(dir_size "$FW_DIR")"

for d in "${FW_DIR}"/*/; do
    [[ -d "$d" ]] && echo "  $(basename "$d"): $(dir_size "$d")"
done
