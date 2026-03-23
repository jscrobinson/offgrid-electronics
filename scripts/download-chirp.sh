#!/bin/bash
# download-chirp.sh — Download CHIRP radio programming software
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Downloading CHIRP"

require_cmd curl

RADIO_DIR=$(ensure_build_dir "radio")

# CHIRP-next (Python 3 version)
log_info "Fetching latest CHIRP-next release info..."
CHIRP_RELEASE=$(curl -fsSL "https://api.github.com/repos/kk7ds/chirp/releases/latest" 2>/dev/null || echo "{}")
CHIRP_TAG=$(echo "$CHIRP_RELEASE" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4 || true)

if [[ -n "$CHIRP_TAG" ]]; then
    log_info "Latest CHIRP release: $CHIRP_TAG"

    # Windows installer
    WIN_URL=$(echo "$CHIRP_RELEASE" | grep -o '"browser_download_url": *"[^"]*\.exe"' | head -1 | cut -d'"' -f4 || true)
    if [[ -n "$WIN_URL" ]]; then
        download_file "$WIN_URL" "${RADIO_DIR}/chirp-$(basename "$WIN_URL")" "CHIRP Windows installer"
    fi

    # Source/wheel for Linux
    WHL_URL=$(echo "$CHIRP_RELEASE" | grep -o '"browser_download_url": *"[^"]*\.whl"' | head -1 | cut -d'"' -f4 || true)
    if [[ -n "$WHL_URL" ]]; then
        download_file "$WHL_URL" "${RADIO_DIR}/chirp-$(basename "$WHL_URL")" "CHIRP Python wheel"
    fi

    # Flatpak/AppImage if available
    APPIMAGE_URL=$(echo "$CHIRP_RELEASE" | grep -o '"browser_download_url": *"[^"]*\.flatpak"' | head -1 | cut -d'"' -f4 || true)
    if [[ -n "$APPIMAGE_URL" ]]; then
        download_file "$APPIMAGE_URL" "${RADIO_DIR}/chirp-$(basename "$APPIMAGE_URL")" "CHIRP Flatpak"
    fi
else
    log_warn "Could not determine latest CHIRP release"
    log_info "Visit https://chirp.danplanet.com/projects/chirp/wiki/Download to download manually"
fi

# Copy pre-built frequency list if it exists in config
if [[ -f "${CONFIG_DIR}/chirp-frequencies.csv" ]]; then
    cp "${CONFIG_DIR}/chirp-frequencies.csv" "${RADIO_DIR}/chirp-frequencies.csv"
    log_ok "Copied CHIRP frequency list to radio dir"
fi

# CH340 driver download (common USB-serial chip used in programming cables)
log_info "Downloading CH340 USB-Serial driver..."
download_file \
    "https://github.com/nicedreams/ch340-driver/raw/main/CH341SER.EXE" \
    "${RADIO_DIR}/CH341SER.EXE" \
    "CH340/CH341 USB-Serial driver (Windows)" || \
    log_warn "CH340 driver download failed — may need manual download from wch-ic.com"

log_ok "CHIRP and radio software ready: $(dir_size "$RADIO_DIR")"
