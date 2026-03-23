#!/bin/bash
# download-sdr-software.sh — Download SDR software packages for offline use
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Downloading SDR Software"

require_cmd curl

SDR_DIR=$(ensure_build_dir "sdr")

# --- RTL-SDR drivers and tools ---
log_info "Downloading RTL-SDR drivers..."
RTL_DIR="${SDR_DIR}/rtl-sdr"
mkdir -p "$RTL_DIR"

# Windows pre-built rtl-sdr binaries
download_file \
    "https://ftp.osmocom.org/binaries/windows/rtl-sdr/rtl-sdr-64bit-20240623.zip" \
    "${RTL_DIR}/rtl-sdr-64bit-windows.zip" \
    "RTL-SDR Windows 64-bit drivers" || \
download_file \
    "https://github.com/osmocom/rtl-sdr/archive/refs/tags/v2.0.2.tar.gz" \
    "${RTL_DIR}/rtl-sdr-v2.0.2-source.tar.gz" \
    "RTL-SDR source (fallback)"

# --- SDR# (SDRSharp) ---
log_info "Downloading SDR#..."
SDRSHARP_DIR="${SDR_DIR}/sdrsharp"
mkdir -p "$SDRSHARP_DIR"

download_file \
    "https://airspy.com/downloads/sdrsharp-x86.zip" \
    "${SDRSHARP_DIR}/sdrsharp-x86.zip" \
    "SDR# (SDRSharp) Windows" || \
    log_warn "SDR# download failed — may need manual download from airspy.com"

# --- GQRX ---
log_info "Downloading GQRX..."
GQRX_DIR="${SDR_DIR}/gqrx"
mkdir -p "$GQRX_DIR"

# Get latest GQRX AppImage from GitHub releases
GQRX_RELEASE=$(curl -fsSL "https://api.github.com/repos/gqrx-sdr/gqrx/releases/latest" 2>/dev/null || echo "{}")
GQRX_URL=$(echo "$GQRX_RELEASE" | grep -o '"browser_download_url": *"[^"]*AppImage"' | head -1 | cut -d'"' -f4 || true)

if [[ -n "$GQRX_URL" ]]; then
    download_file "$GQRX_URL" "${GQRX_DIR}/$(basename "$GQRX_URL")" "GQRX AppImage (Linux)"
else
    log_warn "Could not find GQRX AppImage URL — check https://github.com/gqrx-sdr/gqrx/releases"
fi

# --- CubicSDR ---
log_info "Downloading CubicSDR..."
CUBIC_DIR="${SDR_DIR}/cubicsdr"
mkdir -p "$CUBIC_DIR"

CUBIC_RELEASE=$(curl -fsSL "https://api.github.com/repos/cjcliffe/CubicSDR/releases/latest" 2>/dev/null || echo "{}")

# Download all platform builds
for pattern in "AppImage" "exe" "dmg"; do
    URL=$(echo "$CUBIC_RELEASE" | grep -o "\"browser_download_url\": *\"[^\"]*\.${pattern}\"" | head -1 | cut -d'"' -f4 || true)
    if [[ -n "$URL" ]]; then
        download_file "$URL" "${CUBIC_DIR}/$(basename "$URL")" "CubicSDR (${pattern})"
    fi
done

# --- GNU Radio ---
log_info "Downloading GNU Radio..."
GNURADIO_DIR="${SDR_DIR}/gnuradio"
mkdir -p "$GNURADIO_DIR"

# GNU Radio Windows installer from radioconda
download_file \
    "https://github.com/ryanvolz/radioconda/releases/latest/download/radioconda-Windows-x86_64.exe" \
    "${GNURADIO_DIR}/radioconda-Windows-x86_64.exe" \
    "Radioconda (GNU Radio for Windows)" || \
    log_warn "Radioconda download failed — check https://github.com/ryanvolz/radioconda/releases"

cat > "${GNURADIO_DIR}/INSTALL-LINUX.md" << 'EOF'
# GNU Radio on Linux
Install from package manager:
  sudo apt install gnuradio    # Debian/Ubuntu
  sudo dnf install gnuradio    # Fedora
  sudo pacman -S gnuradio      # Arch

Or build from source: https://github.com/gnuradio/gnuradio
EOF

# --- dump1090 (ADS-B) ---
log_info "Downloading dump1090..."
DUMP1090_DIR="${SDR_DIR}/dump1090"
mkdir -p "$DUMP1090_DIR"

download_file \
    "https://github.com/flightaware/dump1090/archive/refs/heads/master.tar.gz" \
    "${DUMP1090_DIR}/dump1090-fa-master.tar.gz" \
    "dump1090-fa source (FlightAware fork)"

# --- rtl_433 ---
log_info "Downloading rtl_433..."
RTL433_DIR="${SDR_DIR}/rtl_433"
mkdir -p "$RTL433_DIR"

RTL433_RELEASE=$(curl -fsSL "https://api.github.com/repos/merbanan/rtl_433/releases/latest" 2>/dev/null || echo "{}")
RTL433_TAG=$(echo "$RTL433_RELEASE" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4 || true)

if [[ -n "$RTL433_TAG" ]]; then
    download_file \
        "https://github.com/merbanan/rtl_433/archive/refs/tags/${RTL433_TAG}.tar.gz" \
        "${RTL433_DIR}/rtl_433-${RTL433_TAG}.tar.gz" \
        "rtl_433 ${RTL433_TAG} source"
fi

# Windows binary if available
for url_pattern in "rtl_433-win-x64" "rtl_433_64bit_static"; do
    WIN_URL=$(echo "$RTL433_RELEASE" | grep -o "\"browser_download_url\": *\"[^\"]*${url_pattern}[^\"]*\"" | head -1 | cut -d'"' -f4 || true)
    if [[ -n "$WIN_URL" ]]; then
        download_file "$WIN_URL" "${RTL433_DIR}/$(basename "$WIN_URL")" "rtl_433 Windows binary"
        break
    fi
done

echo ""
log_ok "SDR software downloads complete!"
log_info "Total SDR size: $(dir_size "$SDR_DIR")"

echo ""
echo "Contents:"
for d in "${SDR_DIR}"/*/; do
    [[ -d "$d" ]] && echo "  $(basename "$d"): $(dir_size "$d")"
done
