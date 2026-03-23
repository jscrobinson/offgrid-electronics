# Raspberry Pi Overview and Comparison

## Model Comparison Table

| Feature | Pi 5 | Pi 4 Model B | Pi 3 Model B+ | Pi Zero 2 W | Pi Pico / Pico W |
|---|---|---|---|---|---|
| **SoC** | BCM2712 | BCM2711 | BCM2837B0 | RP3A0 | RP2040 |
| **CPU** | Quad Cortex-A76 | Quad Cortex-A72 | Quad Cortex-A53 | Quad Cortex-A53 | Dual Cortex-M0+ |
| **Clock** | 2.4 GHz | 1.5/1.8 GHz | 1.4 GHz | 1.0 GHz | 133 MHz |
| **RAM** | 4/8 GB LPDDR4X | 1/2/4/8 GB LPDDR4 | 1 GB LPDDR2 | 512 MB LPDDR2 | 264 KB SRAM |
| **Storage** | microSD / NVMe | microSD / USB boot | microSD | microSD | 2 MB flash |
| **WiFi** | 802.11ac (dual band) | 802.11ac (dual band) | 802.11ac (dual band) | 802.11n (2.4 GHz) | Pico W: 802.11n |
| **Bluetooth** | BT 5.0 / BLE | BT 5.0 / BLE | BT 4.2 / BLE | BT 4.2 / BLE | Pico W: BT 5.2 |
| **USB** | 2x USB 3.0, 2x USB 2.0 | 2x USB 3.0, 2x USB 2.0 | 4x USB 2.0 | 1x Micro-USB (OTG) | 1x Micro-USB |
| **Video** | 2x Micro-HDMI (4Kp60) | 2x Micro-HDMI (4Kp60) | 1x HDMI (1080p) | 1x Mini-HDMI (1080p) | None |
| **Ethernet** | Gigabit | Gigabit (true, not USB-shared) | Gigabit (USB 2.0 shared, ~300Mbps) | None | None |
| **GPIO** | 40-pin header | 40-pin header | 40-pin header | 40-pin header | 26 GPIO pins |
| **PCIe** | 1x PCIe 2.0 (x1) | None | None | None | None |
| **Power** | USB-C (5V/5A via PD) | USB-C (5V/3A) | Micro-USB (5V/2.5A) | Micro-USB (5V/1.2A) | Micro-USB (5V) |
| **Price** | $60 (4GB) / $80 (8GB) | $35-75 | $35 | $15 | $4 / $6 (W) |
| **Type** | Single-board computer | Single-board computer | Single-board computer | Single-board computer | Microcontroller |

## Detailed Model Descriptions

### Raspberry Pi 5

The most powerful Pi. Released October 2023.

- **BCM2712:** Custom quad-core Arm Cortex-A76 at 2.4 GHz, dramatically faster than Pi 4
- **Memory:** 4 GB or 8 GB LPDDR4X-4267
- **PCIe 2.0 x1:** External connector via FFC cable. Enables NVMe SSD storage (via HAT+ adapter), significantly faster than microSD
- **RP1 southbridge chip:** New I/O controller providing USB, Ethernet, GPIO, and more
- **Dual 4Kp60 HDMI** output via micro-HDMI connectors
- **Real-time clock (RTC):** Battery-backed RTC on-board (needs external coin cell battery)
- **Power button:** On-board power button for clean shutdown/wake
- **Active cooling recommended:** Ships with optional active cooler; thermal throttles under sustained load without cooling
- **Power requirements:** 5V/5A via USB-C with USB PD. A standard 5V/3A supply works but may trigger warnings under heavy USB device load

**Use cases:** Desktop replacement, media center, AI/ML workloads, NVMe-based NAS, software development, any CPU-intensive Pi project.

### Raspberry Pi 4 Model B

The workhorse Pi. Most widely available and well-supported model.

- **BCM2711:** Quad-core Cortex-A72 at 1.5 GHz (overclockable to 1.8-2.0 GHz with cooling)
- **Memory options:** 1 GB, 2 GB, 4 GB, or 8 GB LPDDR4
- **True Gigabit Ethernet:** Not USB-shared like the Pi 3 — full throughput
- **USB:** 2x USB 3.0 (5 Gbps) + 2x USB 2.0
- **Dual 4Kp60 HDMI** via micro-HDMI
- **USB-C power:** 5V/3A minimum recommended
- **Thermal:** Passive heatsink sufficient for light use; active cooling recommended for sustained loads

**Use cases:** General-purpose server, home automation hub, Pi-hole, NAS, media center, retro gaming, desktop computing (with 4GB+ RAM), IoT gateway.

### Raspberry Pi 3 Model B+

The previous generation. Still widely deployed and available.

- **BCM2837B0:** Quad-core Cortex-A53 at 1.4 GHz
- **1 GB LPDDR2** RAM (not upgradable)
- **Ethernet:** Gigabit PHY but limited to ~300 Mbps through USB 2.0 bus
- **WiFi:** Dual-band 802.11ac
- **Full-size HDMI** port
- **4x USB 2.0** ports
- **Micro-USB power:** 5V/2.5A

**Use cases:** Still perfectly capable for lightweight servers, Pi-hole, simple automation, IoT, learning. Choose Pi 4 for new projects unless cost is critical and you have Pi 3s on hand.

### Raspberry Pi Zero 2 W

Ultra-compact Pi with wireless connectivity.

- **RP3A0:** Quad-core Cortex-A53 at 1 GHz (same architecture as Pi 3, lower clock)
- **512 MB LPDDR2** RAM
- **WiFi 802.11n** (2.4 GHz only) + Bluetooth 4.2
- **Mini-HDMI** port (needs adapter for standard HDMI)
- **Micro-USB OTG** port (needs USB OTG adapter for peripherals)
- **Form factor:** 65 x 30 mm — half the size of a standard Pi
- **No Ethernet** (WiFi only)
- **Unpopulated GPIO header:** 40-pin header footprint, solder your own header pins
- **Camera/display connectors:** Same as full-size Pi but needs different FFC cables

**Use cases:** Embedded projects where space is limited, wireless sensors, camera projects, wearable computing, remote monitoring. Not suitable for heavy workloads due to limited RAM and thermal constraints.

### Raspberry Pi Pico / Pico W

Not a Linux computer — this is a microcontroller board, more comparable to Arduino.

- **RP2040:** Dual-core ARM Cortex-M0+ at up to 133 MHz
- **264 KB SRAM**, 2 MB on-board flash
- **No operating system** by default — runs bare-metal code or MicroPython/CircuitPython
- **26 GPIO pins**, 3 analog inputs (12-bit ADC), 2x UART, 2x SPI, 2x I2C
- **8 PIO (Programmable I/O) state machines:** Hardware-level I/O for custom protocols (NeoPixel, VGA, etc.)
- **Pico W adds:** WiFi 802.11n (2.4 GHz), Bluetooth 5.2 / BLE via CYW43439
- **USB 1.1:** Device and host mode
- **Price:** $4 (Pico) / $6 (Pico W)
- **No wireless on base Pico** — must use Pico W for WiFi/BT
- **3.3V logic level** — not 5V tolerant

**Programming options:**
- **MicroPython:** Easiest, interactive REPL via USB serial
- **CircuitPython:** Adafruit's MicroPython fork with extensive library support
- **C/C++ SDK:** Maximum performance, official Pico SDK
- **Arduino IDE:** Supported via board manager (arduino-pico core by Earle Philhower)

**Use cases:** Replaces Arduino for many projects (faster, cheaper, more RAM), custom USB devices, real-time control, sensor nodes, PIO-based protocol implementations.

---

## Operating System Options

### Raspberry Pi OS (formerly Raspbian)

The official operating system. Based on Debian Linux.

- **Raspberry Pi OS Lite:** No desktop, command-line only. Best for servers and headless projects.
  - Minimal install: ~400 MB on disk, ~60 MB RAM at idle
- **Raspberry Pi OS with Desktop:** LXDE-based desktop with Chromium, Thonny IDE, utilities
  - ~2.5 GB on disk, ~300 MB RAM at idle
- **Raspberry Pi OS Full:** Desktop + recommended software (LibreOffice, Scratch, games)
  - ~5 GB on disk

**Versions:**
- **Bookworm (current):** Based on Debian 12. Uses Wayland display server (Pi 4/5), NetworkManager for networking
- **Bullseye (previous):** Based on Debian 11. Uses X11, dhcpcd for networking
- **32-bit vs 64-bit:** 64-bit recommended for Pi 3/4/5 with 1GB+ RAM. Required for 8GB Pi 4 to use all memory. Pi Zero 2 W supports 64-bit.

### Ubuntu

Official Ubuntu images available for Pi.

- **Ubuntu Server:** Headless, good for servers. Official LTS support.
- **Ubuntu Desktop:** Full GNOME desktop (needs Pi 4 with 4GB+ RAM)
- **Ubuntu Core:** Snap-based IoT-focused OS

**Advantages over Raspberry Pi OS:** Better for users already familiar with Ubuntu, access to Ubuntu's larger package repository, LTS support cycles.

### DietPi

Extremely lightweight Debian-based distribution optimized for single-board computers.

- Minimal base install: ~400 MB disk, ~30 MB RAM at idle
- Built-in software catalog: `dietpi-software` tool to install optimized packages (Pi-hole, Docker, Home Assistant, Nextcloud, etc.)
- Automated optimization: disables unnecessary services, logging to RAM
- Excellent for headless servers where every MB of RAM counts

### Other Notable Options

| OS | Use Case | Notes |
|---|---|---|
| **LibreELEC / OSMC** | Media center | Kodi-based, optimized for media playback |
| **RetroPie** | Retro gaming | EmulationStation + RetroArch |
| **Home Assistant OS** | Home automation | Dedicated HA install with Supervisor |
| **Kali Linux** | Security/pentesting | Full security toolkit |
| **Volumio / moOde** | Audio player | Hi-fi music streaming |
| **OctoPrint** | 3D printing | 3D printer remote management |

---

## Power Requirements and Considerations

| Model | Minimum Supply | Recommended Supply | Idle Power | Max Power (under load) |
|---|---|---|---|---|
| Pi 5 | 5V/3A | 5V/5A (USB PD) | ~3.5W | ~12W |
| Pi 4B | 5V/2.5A | 5V/3A USB-C | ~3W | ~7.5W |
| Pi 3B+ | 5V/2A | 5V/2.5A Micro-USB | ~2W | ~5W |
| Zero 2 W | 5V/1A | 5V/1.2A Micro-USB | ~0.4W | ~2.5W |
| Pico | 1.8-5.5V | 5V via USB | ~25 mW | ~100 mW |

**Under-voltage:** A lightning bolt icon on screen (Pi OS) or `Under-voltage detected` in `dmesg` means your power supply is insufficient. This causes instability, SD card corruption, and random crashes.

**For off-grid/battery operation:**
- Pi Zero 2 W is the best choice (lowest power)
- Use Raspberry Pi OS Lite and disable WiFi/BT if not needed (`rfkill block wifi bluetooth`)
- Disable HDMI: `tvservice -o` (saves ~30mA)
- Underclock the CPU: `echo 600000 > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq`
- Consider the Pico for truly low-power sensing (sleep modes available)

---

## Storage Performance

| Storage Type | Sequential Read | Sequential Write | Random IOPS | Notes |
|---|---|---|---|---|
| Class 10 microSD | ~25 MB/s | ~10 MB/s | ~500 | Minimum for Pi OS |
| UHS-I A1 microSD | ~80 MB/s | ~30 MB/s | ~1500 | Recommended |
| UHS-I A2 microSD | ~90 MB/s | ~60 MB/s | ~4000 | Best SD option |
| USB 3.0 SSD (Pi 4/5) | ~350 MB/s | ~300 MB/s | ~50000 | Dramatic improvement |
| NVMe SSD (Pi 5) | ~800 MB/s | ~600 MB/s | ~100000 | Best performance, needs HAT |

**SD card recommendations:**
- Samsung EVO Plus or SanDisk Extreme — consistently reliable
- Avoid cheap, no-name cards — they fail and corrupt data
- Enable TRIM if your card supports it (rare)
- Use `log2ram` to reduce SD card writes (extends card life)

**USB boot (Pi 4/5):**
Boot directly from a USB SSD for dramatically better performance and reliability than microSD. Enable via `raspi-config` > Advanced Options > Boot Order.
