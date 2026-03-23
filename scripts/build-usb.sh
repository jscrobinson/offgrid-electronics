#!/bin/bash
# build-usb.sh — Assemble everything onto USB stick
# Usage: build-usb.sh /mnt/e [full|lite]
set -euo pipefail
source "$(dirname "$0")/common.sh"

USB_MOUNT="${1:?Usage: build-usb.sh /mnt/usb [full|lite]}"
MODE="${2:-full}"

section "Building USB Stick (${MODE} mode)"

if [[ ! -d "$USB_MOUNT" ]]; then
    log_error "USB mount point does not exist: $USB_MOUNT"
    exit 1
fi

# Check available space
if [[ "$MODE" == "full" ]]; then
    check_disk_space "$USB_MOUNT" 30000  # 30 GB minimum for full
else
    check_disk_space "$USB_MOUNT" 15000  # 15 GB minimum for lite
fi

# --- Copy authored docs ---
section "Copying authored documentation"
log_info "Copying docs/..."
rsync -a --delete "${PROJECT_ROOT}/docs/" "${USB_MOUNT}/docs/"
log_ok "Docs copied"

log_info "Copying static/..."
rsync -a --delete "${PROJECT_ROOT}/static/" "${USB_MOUNT}/static/"
log_ok "Static files copied"

log_info "Copying templates/..."
rsync -a --delete "${PROJECT_ROOT}/templates/" "${USB_MOUNT}/templates/"
log_ok "Templates copied"

# --- Copy build artifacts ---
section "Copying downloaded content"

# Always copy these
for dir in docs html toolchains editors sdr radio datasheets packages fonts; do
    src="${BUILD_DIR}/${dir}"
    if [[ -d "$src" ]]; then
        log_info "Copying build/${dir}/..."
        rsync -a "${src}/" "${USB_MOUNT}/build/${dir}/"
        log_ok "Copied: ${dir} ($(dir_size "$src"))"
    else
        log_warn "Not found (skipping): build/${dir}/"
    fi
done

# Docker images only in full mode
if [[ "$MODE" == "full" ]]; then
    if [[ -d "${BUILD_DIR}/docker" ]]; then
        log_info "Copying Docker images..."
        rsync -a "${BUILD_DIR}/docker/" "${USB_MOUNT}/build/docker/"
        log_ok "Docker images copied ($(dir_size "${BUILD_DIR}/docker"))"
    fi
else
    log_info "Lite mode: skipping Docker images"
fi

# --- Copy scripts (useful for rebuilding/updating) ---
section "Copying scripts and config"
rsync -a "${PROJECT_ROOT}/scripts/" "${USB_MOUNT}/scripts/"
rsync -a "${PROJECT_ROOT}/config/" "${USB_MOUNT}/config/"

# --- Copy root files ---
cp "${PROJECT_ROOT}/README.md" "${USB_MOUNT}/README.md"
cp "${PROJECT_ROOT}/LICENSE" "${USB_MOUNT}/LICENSE"
cp "${PROJECT_ROOT}/Makefile" "${USB_MOUNT}/Makefile"

# --- Copy START_HERE.html from project root ---
section "Copying START_HERE.html"
if [[ -f "${PROJECT_ROOT}/START_HERE.html" ]]; then
    cp "${PROJECT_ROOT}/START_HERE.html" "${USB_MOUNT}/START_HERE.html"
    log_ok "START_HERE.html copied from project root"
else
    log_info "Generating START_HERE.html (fallback)"
    cat > "${USB_MOUNT}/START_HERE.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tech Survival USB — Offgrid Electronics</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            line-height: 1.6; color: #e0e0e0; background: #1a1a2e;
            max-width: 1200px; margin: 0 auto; padding: 20px;
        }
        h1 { color: #00d4ff; margin-bottom: 10px; font-size: 2em; }
        h2 { color: #00d4ff; margin: 30px 0 15px; border-bottom: 1px solid #333; padding-bottom: 5px; }
        h3 { color: #7fdbca; margin: 15px 0 10px; }
        .subtitle { color: #888; font-size: 1.1em; margin-bottom: 30px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 20px; margin: 20px 0; }
        .card {
            background: #16213e; border: 1px solid #333; border-radius: 8px;
            padding: 20px; transition: border-color 0.2s;
        }
        .card:hover { border-color: #00d4ff; }
        .card h3 { margin-top: 0; }
        a { color: #00d4ff; text-decoration: none; }
        a:hover { text-decoration: underline; }
        ul { list-style: none; padding: 0; }
        ul li { padding: 3px 0; }
        ul li::before { content: "→ "; color: #555; }
        code { background: #0a0a1a; padding: 2px 6px; border-radius: 3px; font-size: 0.9em; }
        .tip { background: #1a2a1a; border-left: 3px solid #4caf50; padding: 10px 15px; margin: 10px 0; border-radius: 0 4px 4px 0; }
        .warn { background: #2a2a1a; border-left: 3px solid #ff9800; padding: 10px 15px; margin: 10px 0; border-radius: 0 4px 4px 0; }
        footer { margin-top: 40px; padding-top: 20px; border-top: 1px solid #333; color: #666; text-align: center; }
    </style>
</head>
<body>
    <h1>Tech Survival USB</h1>
    <p class="subtitle">Offline documentation and tools for electronics, radio, and mesh networking</p>

    <div class="tip">
        <strong>Quick Start:</strong> Browse the <a href="docs/index.md">documentation index</a> or explore sections below.
        All docs are in Markdown format — open with any text editor, VS Code, or a Markdown viewer.
    </div>

    <h2>Documentation</h2>
    <div class="grid">
        <div class="card">
            <h3>Hardware</h3>
            <ul>
                <li><a href="docs/hardware/lora/lilygo-tbeam-v1.2.md">Lilygo T-Beam v1.2</a></li>
                <li><a href="docs/hardware/lora/heltec-esp32-v3.md">Heltec ESP32 V3</a></li>
                <li><a href="docs/hardware/esp32/overview.md">ESP32 Overview</a></li>
                <li><a href="docs/hardware/arduino/overview.md">Arduino Overview</a></li>
                <li><a href="docs/hardware/raspberry-pi/overview.md">Raspberry Pi</a></li>
                <li><a href="docs/hardware/raspberry-pi/gpio-pinout.md">RPi GPIO Pinout</a></li>
                <li><a href="docs/hardware/displays/oled-ssd1306.md">OLED Displays</a></li>
                <li><a href="docs/hardware/peripherals/sensors.md">Sensors</a></li>
            </ul>
        </div>
        <div class="card">
            <h3>Radio & SDR</h3>
            <ul>
                <li><a href="docs/radio/baofeng-uv5r.md">Baofeng UV-5R / JucJet UV5RH</a></li>
                <li><a href="docs/radio/chirp-programming.md">CHIRP Programming</a></li>
                <li><a href="docs/radio/emergency-frequencies.md">Emergency Frequencies</a></li>
                <li><a href="docs/radio/morse-code.md">Morse Code</a></li>
                <li><a href="docs/sdr/overview.md">SDR Overview</a></li>
                <li><a href="docs/sdr/rtl-sdr-setup.md">RTL-SDR Setup</a></li>
                <li><a href="docs/sdr/rtl_433.md">rtl_433 ISM Decoding</a></li>
                <li><a href="docs/sdr/frequency-reference.md">Frequency Reference</a></li>
            </ul>
        </div>
        <div class="card">
            <h3>Mesh Networking</h3>
            <ul>
                <li><a href="docs/mesh-networking/meshtastic-overview.md">Meshtastic Overview</a></li>
                <li><a href="docs/mesh-networking/meshtastic-setup.md">Meshtastic Setup</a></li>
                <li><a href="docs/mesh-networking/meshtastic-tbeam.md">Meshtastic on T-Beam</a></li>
                <li><a href="docs/mesh-networking/meshtastic-heltec.md">Meshtastic on Heltec V3</a></li>
                <li><a href="docs/mesh-networking/mesh-network-planning.md">Network Planning</a></li>
                <li><a href="docs/mesh-networking/lora-mesh-alternatives.md">Alternatives (Reticulum)</a></li>
            </ul>
        </div>
        <div class="card">
            <h3>Electronics</h3>
            <ul>
                <li><a href="docs/electronics/fundamentals.md">Fundamentals (Ohm's Law)</a></li>
                <li><a href="docs/electronics/resistor-color-codes.md">Resistor Color Codes</a></li>
                <li><a href="docs/electronics/transistors.md">Transistors</a></li>
                <li><a href="docs/electronics/voltage-regulators.md">Voltage Regulators</a></li>
                <li><a href="docs/electronics/common-circuits.md">Common Circuits</a></li>
                <li><a href="docs/electronics/soldering.md">Soldering Guide</a></li>
                <li><a href="docs/electronics/test-equipment.md">Test Equipment</a></li>
            </ul>
        </div>
        <div class="card">
            <h3>Protocols</h3>
            <ul>
                <li><a href="docs/protocols/i2c.md">I2C</a></li>
                <li><a href="docs/protocols/spi.md">SPI</a></li>
                <li><a href="docs/protocols/uart-serial.md">UART / Serial</a></li>
                <li><a href="docs/protocols/mqtt.md">MQTT</a></li>
                <li><a href="docs/protocols/pwm.md">PWM</a></li>
                <li><a href="docs/protocols/modbus.md">Modbus</a></li>
            </ul>
        </div>
        <div class="card">
            <h3>Power & Battery</h3>
            <ul>
                <li><a href="docs/power/battery-types.md">Battery Types</a></li>
                <li><a href="docs/power/battery-management.md">Battery Management</a></li>
                <li><a href="docs/power/solar-charging.md">Solar Charging</a></li>
                <li><a href="docs/power/power-calculations.md">Power Calculations</a></li>
                <li><a href="docs/power/18650-guide.md">18650 Guide</a></li>
            </ul>
        </div>
        <div class="card">
            <h3>Programming</h3>
            <ul>
                <li><a href="docs/programming/python-quickref.md">Python</a></li>
                <li><a href="docs/programming/micropython.md">MicroPython</a></li>
                <li><a href="docs/programming/nodejs-quickref.md">Node.js</a></li>
                <li><a href="docs/programming/c-cpp-embedded.md">C/C++ Embedded</a></li>
                <li><a href="docs/programming/bash-scripting.md">Bash Scripting</a></li>
                <li><a href="docs/programming/git-reference.md">Git Reference</a></li>
            </ul>
        </div>
        <div class="card">
            <h3>Networking & Survival</h3>
            <ul>
                <li><a href="docs/networking/ip-subnetting.md">IP & Subnetting</a></li>
                <li><a href="docs/networking/wifi-setup.md">WiFi AP Mode</a></li>
                <li><a href="docs/networking/ssh-reference.md">SSH Reference</a></li>
                <li><a href="docs/networking/vpn-wireguard.md">WireGuard VPN</a></li>
                <li><a href="docs/survival/solar-setup-guide.md">Solar Setup</a></li>
                <li><a href="docs/survival/field-repair.md">Field Repair</a></li>
            </ul>
        </div>
    </div>

    <h2>Software & Tools</h2>
    <div class="grid">
        <div class="card">
            <h3>Toolchains</h3>
            <ul>
                <li><a href="build/toolchains/arduino-ide/">Arduino IDE</a></li>
                <li><a href="build/toolchains/esp-idf/">ESP-IDF</a></li>
                <li><a href="build/toolchains/platformio/">PlatformIO</a></li>
            </ul>
        </div>
        <div class="card">
            <h3>Editors</h3>
            <ul>
                <li><a href="build/editors/vscode/">VS Code Portable</a></li>
                <li><a href="build/editors/micro/">Micro Editor</a></li>
            </ul>
        </div>
        <div class="card">
            <h3>SDR Software</h3>
            <ul>
                <li><a href="build/sdr/sdrsharp/">SDR# (Windows)</a></li>
                <li><a href="build/sdr/gqrx/">GQRX (Linux)</a></li>
                <li><a href="build/sdr/cubicsdr/">CubicSDR</a></li>
                <li><a href="build/sdr/gnuradio/">GNU Radio</a></li>
                <li><a href="build/sdr/rtl-sdr/">RTL-SDR Drivers</a></li>
                <li><a href="build/sdr/rtl_433/">rtl_433</a></li>
                <li><a href="build/sdr/dump1090/">dump1090 (ADS-B)</a></li>
            </ul>
        </div>
        <div class="card">
            <h3>Radio</h3>
            <ul>
                <li><a href="build/radio/">CHIRP</a></li>
                <li><a href="config/chirp-frequencies.csv">CHIRP Frequency List</a></li>
            </ul>
        </div>
    </div>

    <h2>Mirrored Documentation</h2>
    <div class="grid">
        <div class="card">
            <h3>Official Docs (Offline)</h3>
            <ul>
                <li><a href="build/docs/python/">Python 3.12 Docs</a></li>
                <li><a href="build/docs/nodejs/">Node.js 20 API Docs</a></li>
                <li><a href="build/docs/arduino/">Arduino Reference</a></li>
                <li><a href="build/docs/esp-idf/">ESP-IDF Programming Guide</a></li>
                <li><a href="build/docs/meshtastic/">Meshtastic Docs</a></li>
                <li><a href="build/docs/devdocs/">DevDocs (self-hosted)</a></li>
            </ul>
        </div>
        <div class="card">
            <h3>Datasheets</h3>
            <ul>
                <li><a href="build/datasheets/">Component datasheets (PDF)</a></li>
            </ul>
        </div>
    </div>

    <h2>Offline Package Installation</h2>
    <div class="warn">
        <strong>npm:</strong> <code>npm install --cache ./build/packages/npm/ &lt;package&gt;</code><br>
        <strong>pip:</strong> <code>pip install --no-index --find-links ./build/packages/pip/ &lt;package&gt;</code><br>
        <strong>Docker:</strong> <code>docker load &lt; ./build/docker/image-name.tar</code>
    </div>

    <footer>
        <p>Tech Survival USB — Built for offline use</p>
        <p>See <a href="docs/survival/usb-stick-usage-guide.md">USB Stick Usage Guide</a> for detailed instructions</p>
    </footer>
</body>
</html>
HTMLEOF
    log_ok "START_HERE.html generated"
fi

# --- Generate MANIFEST.txt ---
section "Generating manifest"
generate_checksums "$USB_MOUNT" "${USB_MOUNT}/MANIFEST.txt"

# --- Summary ---
section "USB Build Complete!"
log_ok "Mode: $MODE"
log_ok "Location: $USB_MOUNT"
log_info "Total size: $(dir_size "$USB_MOUNT")"
echo ""
echo "Contents:"
for d in "${USB_MOUNT}"/*/; do
    [[ -d "$d" ]] && echo "  $(basename "$d")/: $(dir_size "$d")"
done
echo ""
echo "Open START_HERE.html in a browser to get started."
