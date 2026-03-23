# Meshtastic: Flashing and Initial Setup

Step-by-step guide to getting Meshtastic running on your hardware.

---

## Method 1: Web Flasher (Easiest)

The web flasher is the simplest way to get started. No software installation required.

### Requirements
- Chrome or Edge browser (WebSerial API required — Firefox and Safari do not support this)
- USB cable (data-capable — some cheap USB cables are charge-only and will not work)
- Your Meshtastic device

### Steps

1. **Connect your device** via USB to your computer
2. **Open** https://flasher.meshtastic.org in Chrome or Edge
3. **Select your device type** from the dropdown (e.g., "T-Beam", "Heltec V3", "T-Echo")
4. **Select firmware version** — use the latest stable release unless you have a reason not to
5. **Click "Flash"**
6. **Select the serial port** in the browser popup (the device should appear as a COM port on Windows or /dev/ttyUSB0 or /dev/ttyACM0 on Linux)
7. **Wait** for flashing to complete (usually 1-2 minutes)
8. The device will reboot with fresh Meshtastic firmware

### Troubleshooting Web Flasher
- **No serial port appears:** install the CP2102 or CH340 USB-serial driver for your device. T-Beam uses CP2102. Heltec V3 uses CH340 (some) or native USB (ESP32-S3).
- **Device not entering bootloader:** hold the BOOT button while plugging in USB, or hold BOOT and press RST
- **"Failed to connect":** try a different USB cable (must be data-capable), try a different USB port, close any serial monitors that might be holding the port open

---

## Method 2: Python CLI

More control, works from the command line, scriptable.

### Install

```bash
pip install meshtastic
# or
pip3 install meshtastic
```

This installs the `meshtastic` command-line tool and the `meshtastic` Python library.

### Flash Firmware

```bash
# Flash the latest stable firmware (auto-detects device)
meshtastic --flash-firmware

# Flash a specific version
meshtastic --flash-firmware --version 2.x.x.x
```

The CLI will auto-detect your device type and download the correct firmware.

### If Auto-Detection Fails

Specify the port manually:

```bash
# Linux
meshtastic --flash-firmware --port /dev/ttyUSB0

# Windows
meshtastic --flash-firmware --port COM3

# macOS
meshtastic --flash-firmware --port /dev/cu.usbserial-0001
```

---

## Method 3: Manual Flash with esptool.py (ESP32 Devices)

For maximum control or when other methods fail.

### Install esptool

```bash
pip install esptool
```

### Download Firmware

1. Go to https://github.com/meshtastic/firmware/releases
2. Download the zip file for your specific hardware (e.g., `firmware-tbeam-2.x.x.x.zip`)
3. Extract the zip — you'll find several .bin files

### Flash

```bash
# Erase flash first (recommended for clean install)
esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash

# Flash the firmware files (file names and addresses from the release)
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 write_flash \
  0x1000 bootloader.bin \
  0x8000 partitions.bin \
  0x10000 firmware.bin
```

**Note:** Exact addresses and filenames vary by firmware version. Check the `device-install.sh` or `device-install.bat` script included in the firmware zip for the correct commands.

### For ESP32-S3 Devices (Heltec V3, T-Beam Supreme)

```bash
esptool.py --chip esp32s3 --port /dev/ttyACM0 erase_flash

esptool.py --chip esp32s3 --port /dev/ttyACM0 --baud 921600 write_flash \
  0x0 bootloader.bin \
  0x8000 partitions.bin \
  0x10000 firmware.bin
```

ESP32-S3 uses native USB — the port will typically be /dev/ttyACM0 on Linux rather than /dev/ttyUSB0.

---

## Method 4: nRF52 Devices (T-Echo, RAK nRF52)

nRF52 devices use UF2 bootloader, not esptool.

### Steps
1. **Download** the firmware .uf2 file from the releases page
2. **Double-tap the RST button** on the device to enter bootloader mode
3. A USB drive named "MESHTASTIC" or "NRF52BOOT" will appear on your computer
4. **Drag and drop** the .uf2 file onto the drive
5. The device will flash automatically and reboot

---

## Initial Configuration After Flashing

Once the firmware is running, you need to set at minimum the **region** before the radio will transmit.

### Using the Phone App (Recommended for First Setup)

1. **Install the app:**
   - Android: "Meshtastic" on Google Play Store (or download APK from GitHub)
   - iOS: "Meshtastic" on App Store

2. **Enable Bluetooth** on your phone

3. **Open the app** and tap the "+" button or "Connect to Device"

4. **Select your device** from the Bluetooth scan list
   - It will appear as "Meshtastic_XXXX" (where XXXX is part of the node ID)
   - First connection may require confirming a pairing code (check the device OLED if it has one, or accept the default)

5. **Set your region:**
   - Go to Settings > Radio Configuration > LoRa
   - Set Region to your location:
     - `US` — United States (915 MHz)
     - `EU_868` — Europe (868 MHz)
     - `EU_433` — Europe (433 MHz)
     - `CN` — China
     - `JP` — Japan
     - `ANZ` — Australia/New Zealand
     - `KR` — Korea
     - `TW` — Taiwan
     - `RU` — Russia
     - `IN` — India
     - `NZ_865` — New Zealand (865 MHz)
     - `TH` — Thailand
     - `UA_433` / `UA_868` — Ukraine
     - `LORA_24` — 2.4 GHz (worldwide, shorter range)
   - **The radio will not transmit until a region is set.** This is a legal compliance requirement.

6. **Set your name:**
   - Go to Settings > User
   - Set "Long Name" (your display name, e.g., "John's Node")
   - Set "Short Name" (4 characters max, e.g., "JOHN")

7. **Save settings** — the device will reboot

### Using the Python CLI

```bash
# Set region (required before radio will transmit)
meshtastic --set lora.region US

# Set your name
meshtastic --set-owner "John's Node"
meshtastic --set-owner-short "JOHN"

# Verify settings
meshtastic --info
```

### Using the Web Interface (ESP32 Only)

1. Connect your device via USB or WiFi
2. For WiFi: the device creates a WiFi AP on first boot
   - SSID: "meshtasticXXXX"
   - Password: check documentation (default varies by version)
3. Navigate to http://meshtastic.local or the device IP (usually 192.168.4.1 for AP mode)
4. Use the web UI to set region and name

---

## First Message Test

Once two or more nodes are configured with the same region:

1. **Place the nodes within range of each other** (start with the same room for testing)
2. **Open the Meshtastic app** on your phone, connected to one node
3. **Navigate to the Messages tab**
4. **Select the primary channel** (LongFast by default)
5. **Type a message and send it**
6. The other node should receive the message within a few seconds
7. **Check for acknowledgment** — a checkmark indicates the message was received

### What If Messages Don't Get Through?
- Verify both nodes have the same region set
- Verify both nodes are on the same channel with the same encryption key (default LongFast is fine for testing)
- Check that both nodes have been rebooted after setting the region
- Try bringing nodes closer together
- Check the node list — if you can see the other node in your node list, radio communication is working

---

## USB Serial Driver Reference

| Device | USB Chip | Driver | Notes |
|--------|----------|--------|-------|
| T-Beam V1.0-1.1 | CP2102 | CP210x | Usually auto-installed on modern OS |
| T-Beam V1.2 | CP2102 | CP210x | Same driver |
| T-Beam Supreme | ESP32-S3 native USB | Built-in | No driver needed |
| Heltec V3 | ESP32-S3 native USB or CH340 | CH340 or built-in | Check your specific board revision |
| T-Echo | nRF52 native USB | Built-in | UF2 bootloader |
| RAK WisBlock | nRF52/ESP32 varies | Varies | Check RAK documentation |

### Driver Downloads
- **CP210x:** https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers
- **CH340:** http://www.wch-ic.com/downloads/CH341SER_EXE.html (Windows) or usually auto-installed on Linux/macOS
