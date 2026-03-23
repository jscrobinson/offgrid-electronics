# CubicSDR Guide

## Overview

CubicSDR is a free, open-source, cross-platform SDR application. Its main advantages are true cross-platform support (Windows, Linux, macOS), a clean modern interface, and the ability to run multiple demodulators (VFOs) simultaneously — you can listen to multiple signals within your SDR's bandwidth at the same time.

**Website**: https://cubicsdr.com

---

## Installation

### Windows

1. Download the Windows installer from https://cubicsdr.com or the GitHub releases page.
2. Run the installer.
3. Ensure RTL-SDR drivers are installed via Zadig (see rtl-sdr-setup.md).

### Linux

#### Ubuntu/Debian

```bash
sudo apt install cubicsdr
```

#### Flatpak

```bash
flatpak install flathub com.cubicsdr.CubicSDR
```

#### AppImage

Download the AppImage from GitHub releases:
```bash
chmod +x CubicSDR-*.AppImage
./CubicSDR-*.AppImage
```

### macOS

```bash
brew install --cask cubicsdr
```

Or download the DMG from the releases page.

---

## First Launch and Device Selection

1. On first launch, CubicSDR opens the **SDR Device Selection** dialog.
2. Available devices are listed (RTL-SDR, Airspy, HackRF, etc.).
3. Select your device and click **Start**.
4. If no device appears, check driver installation and USB connection.

### Device Settings

After selecting a device, you can configure:
- **Sample rate**: Choose based on desired bandwidth and CPU capability.
- **PPM correction**: Frequency offset correction.
- **Gain**: Set initial gain values.

---

## User Interface

### Main Display

```
┌─────────────────────────────────────────┐
│  [Frequency] [Mode] [Gain]  [Controls] │
├─────────────────────────────────────────┤
│                                         │
│          Wideband Spectrum              │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│          Wideband Waterfall             │
│                                         │
├─────────────────────────────────────────┤
│          Demodulator Spectrum           │
│          (zoomed view of selected VFO)  │
├─────────────────────────────────────────┤
│  [Bookmarks] [Active VFOs]             │
└─────────────────────────────────────────┘
```

### Wideband View

The upper spectrum and waterfall show the full bandwidth captured by the SDR. You can see all signals within the sample rate bandwidth simultaneously.

### Demodulator View

The lower section shows a zoomed-in view of the currently selected demodulator (VFO), making it easier to fine-tune.

---

## Basic Operation

### Tuning

- **Click** on the wideband spectrum/waterfall to create a new demodulator at that frequency.
- **Mouse wheel** on the frequency display to adjust.
- **Type** a frequency directly in the frequency field.
- **Drag** an existing demodulator marker to retune it.

### Selecting Demodulation Mode

Click the mode selector (or right-click on a demodulator):

| Mode | Description |
|------|-------------|
| FM | Narrowband FM |
| FMS | Wideband FM Stereo |
| AM | Amplitude Modulation |
| LSB | Lower Sideband |
| USB | Upper Sideband |
| DSB | Double Sideband |
| I/Q | Raw I/Q passthrough |

### Adjusting Bandwidth

- Drag the edges of the demodulator overlay on the spectrum to change filter bandwidth.
- Or set bandwidth numerically.

### Volume and Squelch

- **Volume**: Adjust per-demodulator.
- **Squelch**: Set the threshold. Audio is muted when signal drops below this level.
- **Mute**: Click the mute button on individual VFOs.

---

## Multiple VFOs

CubicSDR's standout feature is the ability to run **multiple demodulators simultaneously**. Any signal within the SDR's bandwidth can have its own VFO.

### Adding a VFO

- Click on the wideband spectrum at a different frequency.
- A new demodulator marker appears.
- Each VFO has independent mode, bandwidth, volume, and squelch settings.

### Managing VFOs

- Click on a VFO marker to select it (the demodulator view updates to show that VFO).
- The **Active VFOs** panel lists all running demodulators.
- Right-click a VFO for options (remove, change mode, etc.).

### Use Cases

- Monitor a repeater output and the simplex calling frequency simultaneously.
- Listen to multiple FRS/GMRS channels at once.
- Track multiple aircraft communications.

---

## Frequency Bookmarks

### Adding Bookmarks

1. Tune to the desired frequency.
2. Click the **Bookmark** button (star icon) or right-click and select "Add Bookmark."
3. Enter a label and optionally assign a group.

### Using Bookmarks

- The **Bookmarks** panel lists all saved frequencies.
- Click a bookmark to tune to it.
- Organize bookmarks into groups for easy navigation.
- Bookmarks persist between sessions.

### Importing Bookmarks

CubicSDR can import frequency lists. Check the documentation for supported formats.

---

## Recording

### Audio Recording

- Right-click on a demodulator and select **Record** to start recording audio.
- Audio is saved as a WAV file.

### I/Q Recording

- CubicSDR does not have built-in I/Q recording in all versions.
- For I/Q recording, consider using `rtl_sdr` command-line tool or GNU Radio.

---

## Gain Settings

Access gain controls through the device settings panel:

- **RF Gain / LNA Gain**: Main tuner gain.
- **IF Gain**: Intermediate frequency gain (if supported by hardware).
- Manual gain control is generally recommended over AGC.

---

## Performance Tips

1. **Reduce sample rate** if CPU usage is too high. 1.024 MSPS is lighter than 2.4 MSPS.
2. **Reduce the number of active VFOs**. Each demodulator consumes CPU.
3. **Lower FFT resolution** if the spectrum display is sluggish.
4. CubicSDR uses SoapySDR as its device abstraction layer, which provides broad hardware compatibility but may have slightly higher overhead than direct device access.

---

## SoapySDR Backend

CubicSDR uses **SoapySDR** as its hardware abstraction layer. This means it supports any SDR device that has a SoapySDR driver, including:

- RTL-SDR (via SoapyRTLSDR)
- Airspy (via SoapyAirspy)
- HackRF (via SoapyHackRF)
- SDRplay (via SoapySDRPlay)
- LimeSDR (via SoapyLMS7)
- PlutoSDR (via SoapyPlutoSDR)

If your device does not appear in CubicSDR, you may need to install the appropriate SoapySDR module:

```bash
# Example: Install SoapyRTLSDR on Ubuntu
sudo apt install soapysdr-module-rtlsdr

# List available SoapySDR devices
SoapySDRUtil --find
```

---

## Comparison with Other SDR Software

| Feature | CubicSDR | SDR# | GQRX |
|---------|---------|------|------|
| Platform | Win/Lin/Mac | Windows | Linux/Mac |
| Multiple VFOs | Yes | No (1 VFO) | No (1 VFO) |
| Ease of use | Moderate | Easy | Easy |
| Plugin system | No | Yes | No |
| Hardware support | SoapySDR (broad) | Airspy + RTL-SDR | GNU Radio (broad) |
| Recording (I/Q) | Limited | Yes | Yes |
| Remote control | No | No | Yes (TCP) |

CubicSDR's main strength is multi-VFO operation. If you need to monitor multiple frequencies simultaneously without multiple SDR dongles, CubicSDR is the best choice.
