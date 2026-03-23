# RTL-SDR Setup and Driver Installation

## Overview

RTL-SDR devices use the Realtek RTL2832U demodulator chip, originally designed for DVB-T television reception. To use the device as a wideband SDR receiver, you need to install specific drivers that allow direct access to the raw I/Q samples from the ADC.

---

## Windows Setup

### Option 1: SDR# Auto-Installer (Easiest)

1. Download SDR# from https://airspy.com/download/
2. Extract the ZIP file to a folder (e.g., `C:\SDR\SDRSharp`).
3. Run `install-rtlsdr.bat` from the extracted folder. This downloads the RTL-SDR USB driver files.
4. Plug in your RTL-SDR dongle.
5. Run **Zadig** (included in the SDR# package, or download from https://zadig.akeo.ie/).

### Zadig Driver Installation

Zadig replaces the default Windows DVB-T driver with the WinUSB driver that SDR software needs.

1. Run `zadig.exe` **as administrator**.
2. Go to **Options > List All Devices**.
3. In the dropdown, find your RTL-SDR device. It may appear as:
   - "Bulk-In, Interface (Interface 0)"
   - "RTL2832U" or "RTL2838UHIDIR"
   - A device with USB ID `0BDA:2838` or similar
4. Make sure the **target driver** (right side of the green arrow) says **WinUSB**.
5. Click **Replace Driver** (or "Install Driver" if no driver is currently installed).
6. Wait for installation to complete ("Driver installed successfully").
7. **Important**: Only replace the driver for the RTL-SDR device. Do NOT accidentally replace drivers for other USB devices.

### Verifying on Windows

1. Open **Device Manager** (right-click Start > Device Manager).
2. Under **Universal Serial Bus devices**, you should see "Bulk-In, Interface" or "RTL2838UHIDIR".
3. It should NOT appear under "Sound, video and game controllers" as a DVB-T device — if it does, the Zadig driver replacement was not applied.

### If Zadig Does Not Show the Device

- Try a different USB port (avoid USB hubs).
- Try a USB 2.0 port instead of USB 3.0.
- Uninstall any DVB-T software that may have claimed the device.
- On Windows 11, you may need to temporarily disable driver signature enforcement.

---

## Linux Setup

### Installing RTL-SDR Drivers

#### Debian / Ubuntu / Raspberry Pi OS

```bash
sudo apt update
sudo apt install rtl-sdr librtlsdr-dev
```

#### Fedora

```bash
sudo dnf install rtl-sdr rtl-sdr-devel
```

#### Arch Linux

```bash
sudo pacman -S rtl-sdr
```

#### From Source (Latest Version)

```bash
sudo apt install git cmake build-essential libusb-1.0-0-dev
git clone https://github.com/rtlsdrblog/rtl-sdr-blog.git
cd rtl-sdr-blog
mkdir build && cd build
cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON
make
sudo make install
sudo ldconfig
```

The `rtl-sdr-blog` fork includes enhancements for the RTL-SDR Blog V3/V4 hardware (bias-T control, improved direct sampling, V4 support).

### Blacklisting DVB-T Kernel Modules

Linux includes built-in DVB-T drivers that will claim the RTL-SDR device and prevent SDR software from accessing it. You must blacklist these modules.

Create a blacklist file:

```bash
sudo tee /etc/modprobe.d/blacklist-rtlsdr.conf << 'EOF'
# Blacklist DVB-T kernel modules to allow RTL-SDR use
blacklist dvb_usb_rtl28xxu
blacklist dvb_usb_rtl2832u
blacklist dvb_usb_v2
blacklist rtl2832
blacklist rtl2830
blacklist rtl2832_sdr
blacklist r820t
EOF
```

Then either reboot or manually unload the modules:

```bash
sudo rmmod dvb_usb_rtl28xxu 2>/dev/null
sudo rmmod dvb_usb_rtl2832u 2>/dev/null
sudo rmmod rtl2832_sdr 2>/dev/null
sudo rmmod rtl2832 2>/dev/null
sudo rmmod r820t 2>/dev/null
```

### Udev Rules for Non-Root Access

To use the RTL-SDR without `sudo`:

```bash
sudo tee /etc/udev/rules.d/20-rtlsdr.rules << 'EOF'
# RTL-SDR udev rules - allow non-root access
SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="plugdev", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832", GROUP="plugdev", MODE="0666"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger
```

Make sure your user is in the `plugdev` group:
```bash
sudo usermod -a -G plugdev $USER
```

Log out and back in for group membership to take effect.

### Verifying on Linux

#### Check USB Device Detection

```bash
lsusb | grep -i realtek
```

Expected output (similar to):
```
Bus 001 Device 004: ID 0bda:2838 Realtek Semiconductor Corp. RTL2838 DVB-T
```

#### Test with rtl_test

```bash
rtl_test -t
```

Expected output:
```
Found 1 device(s):
  0:  Realtek, RTL2838UHIDIR, SN: 00000001

Using device 0: Generic RTL2832U OEM
Found Rafael Micro R820T tuner
Supported gain values (29): 0.0 0.9 1.4 2.7 3.7 7.7 8.7 12.5 14.4 15.7
  16.6 19.7 20.7 22.9 25.4 28.0 29.7 32.8 33.8 36.4 37.2 38.6 40.2 42.1
  43.4 43.9 44.5 48.0 49.6
[R82XX] PLL locked, OK
Sampling at 2048000 S/s.
No E4000 tuner found, aborting.
```

The "PLL locked, OK" message confirms the tuner is working. The "No E4000" message is normal for R820T/R820T2 tuners (it is just checking for a different tuner type).

#### Quick FM Reception Test

```bash
# Receive FM broadcast at 100.1 MHz, output to speaker
rtl_fm -f 100.1e6 -M wbfm -s 200000 -r 48000 - | aplay -r 48000 -f S16_LE
```

If you hear FM audio, everything is working.

#### rtl_power — Spectrum Sweep

```bash
# Scan 88-108 MHz and output to CSV
rtl_power -f 88M:108M:125k -g 40 -i 10 -e 1m scan.csv
```

This scans the FM broadcast band and saves signal strength data to a CSV file. Useful for finding active frequencies.

---

## macOS Setup

### Using Homebrew

```bash
brew install librtlsdr
```

Or from source:
```bash
brew install cmake libusb
git clone https://github.com/rtlsdrblog/rtl-sdr-blog.git
cd rtl-sdr-blog
mkdir build && cd build
cmake ../
make
sudo make install
```

No driver blacklisting is needed on macOS (no built-in DVB-T drivers).

---

## RTL-SDR Blog V4 Specific Notes

The V4 uses the R828D tuner (slightly different from the R820T2 in the V3) and has design improvements:

- Requires the **rtl-sdr-blog fork** of the drivers for full V4 support (the standard osmocom rtl-sdr drivers may not work correctly with V4).
- Install from: https://github.com/rtlsdrblog/rtl-sdr-blog
- In SDR# and some other software, select the device type carefully. V4 may need updated device support.
- The V4 has improved HF performance via direct sampling compared to V3.

---

## Common Issues

### "No Devices Found" or "No RTL-SDR Device Found"

**Windows**:
- Run Zadig and reinstall the WinUSB driver.
- Make sure the device appears in Device Manager under "Universal Serial Bus devices" (not under media/TV devices).
- Try a different USB port. Avoid USB hubs.
- Some USB 3.0 ports have compatibility issues — try USB 2.0.

**Linux**:
- Check `lsusb` to see if the device is detected.
- Check if DVB-T modules are still loaded: `lsmod | grep dvb`. If so, blacklist them (see above) and reboot.
- Check udev rules and permissions: `ls -la /dev/bus/usb/*/` to verify the device is accessible.
- Try running with `sudo` to determine if it is a permissions issue.

### "Permission Denied" (Linux)

- Install udev rules (see above).
- Add your user to the `plugdev` group.
- Log out and back in.
- As a quick test, run with `sudo`.

### "Kernel Driver Active" (Linux)

The DVB-T kernel module has claimed the device. Blacklist it:
```bash
sudo rmmod dvb_usb_rtl28xxu
```
Then create the blacklist file (see above) for a permanent fix.

### USB Bandwidth / Sample Drop Issues

- If you see sample drops or "lost samples" messages, the USB bus is overloaded.
- Try a different USB port (preferably USB 3.0 for the host controller, even though the device is USB 2.0).
- Reduce sample rate (try 2.048 MSPS or 1.024 MSPS).
- Close other USB-intensive programs.
- On a Raspberry Pi, use the top USB ports (directly on the SoC bus, not the hub).

### Device Overheating

RTL-SDR dongles can get warm during extended use. This is normal, but excessive heat can cause frequency drift. If the device gets very hot:
- Use a short USB extension cable to move the dongle away from other heat sources.
- Ensure airflow around the device.
- Use a small heatsink if needed.

---

## Bias-T Power

The RTL-SDR Blog V3 and V4 include a **bias-T** — a DC voltage (4.5V) injected onto the coax center conductor through the SMA port. This can power:
- LNA (low-noise amplifier) at the antenna
- Active antennas
- Bandpass filters with built-in LNA

### Enabling Bias-T

**Command line**:
```bash
rtl_biast -b 1    # Turn on
rtl_biast -b 0    # Turn off
```

**In SDR#**: Use the bias-T plugin or check the bias-T option in RTL-SDR settings.

**Warning**: Do not enable bias-T if your antenna or connected device does not expect DC power. It can damage passive antennas or devices not designed for it.

---

## Command-Line Tools Reference

| Command | Description |
|---------|-------------|
| `rtl_test -t` | Test the device (PLL lock, tuner detection) |
| `rtl_test -s 2.4e6` | Test at specific sample rate, show dropped samples |
| `rtl_fm -f FREQ -M MODE` | Command-line FM receiver |
| `rtl_power -f START:STOP:STEP` | Wideband power spectrum scanner |
| `rtl_tcp -a 0.0.0.0` | Start an RTL-SDR TCP server (remote access) |
| `rtl_adsb` | Simple ADS-B decoder |
| `rtl_433` | ISM band device decoder (separate package) |
| `rtl_biast -b 1` | Enable bias-T power |
| `rtl_eeprom` | Read/write RTL-SDR EEPROM (serial number, etc.) |
